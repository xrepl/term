(defmodule xrepl-term-graphics
  "Terminal graphics protocol support.

  Supports iTerm2, Kitty, and Sixel protocols for inline image display."
  (export
   ;; High-level API
   (render-file 1)
   (render-file 2)
   (render-data 1)
   (render-data 2)

   ;; Protocol-specific
   (iterm2-sequence 2)
   (kitty-sequence 2)

   ;; Capabilities
   (supports-graphics? 0)
   (best-protocol 0)

   ;; Utilities
   (detect-protocol 0)))

;;; Protocol Detection

(defun detect-protocol ()
  "Detect best available graphics protocol.

  Returns:
    iterm2 | kitty | none"
  (let ((term-program (os:getenv "TERM_PROGRAM"))
        (term (os:getenv "TERM")))
    (cond
      ;; WezTerm supports iTerm2 by default
      ((== term-program "WezTerm") 'iterm2)
      ;; Native iTerm2
      ((== term-program "iTerm.app") 'iterm2)
      ;; Kitty terminal
      ((== term "xterm-kitty") 'kitty)
      ;; No graphics support
      ('true 'none))))

(defun supports-graphics? ()
  "Check if terminal supports any graphics protocol.

  Returns:
    true | false"
  (not (== (detect-protocol) 'none)))

(defun best-protocol ()
  "Get the best available graphics protocol.

  Alias for detect-protocol."
  (detect-protocol))

;;; High-Level Rendering

(defun render-file (filepath)
  "Render image file in terminal.

  Args:
    filepath: Path to image file (string or binary)

  Returns:
    {ok, displayed} | {error, reason}"
  (render-file filepath #m()))

(defun render-file (filepath opts)
  "Render image file with options.

  Args:
    filepath: Path to image file
    opts: Options map:
      - width: Width specification ('auto' or string like '50%' or '100')
      - height: Height specification ('auto' or string)
      - protocol: Force specific protocol (iterm2, kitty)

  Returns:
    {ok, displayed} | {error, reason}"
  (let ((filepath-str (to-string filepath)))
    (case (filelib:is_file filepath-str)
      ('false
       (tuple 'error (tuple 'file-not-found filepath-str)))
      ('true
       (case (file:read_file filepath-str)
         (`#(ok ,image-data)
          (let* ((filename (filename:basename filepath-str))
                 (opts-with-name (maps:put 'filename filename opts)))
            (render-data image-data opts-with-name)))
         (`#(error ,reason)
          (tuple 'error (tuple 'file-read-error reason))))))))

(defun render-data (image-data)
  "Render image data in terminal.

  Args:
    image-data: Binary image data

  Returns:
    {ok, displayed} | {error, reason}"
  (render-data image-data #m()))

(defun render-data (image-data opts)
  "Render image data with options.

  Args:
    image-data: Binary image data
    opts: Options map (see render-file/2)

  Returns:
    {ok, displayed} | {error, reason}"
  (let ((protocol (maps:get 'protocol opts (detect-protocol))))
    (case protocol
      ('iterm2
       (render-iterm2 image-data opts))
      ('kitty
       (render-kitty image-data opts))
      ('none
       (tuple 'error 'no-graphics-support)))))

(defun render-iterm2 (image-data opts)
  "Render using iTerm2 protocol."
  (try
    (case (iterm2-sequence image-data opts)
      (`#(ok ,sequence)
       (io:put_chars sequence)
       (io:nl)
       (tuple 'ok 'displayed))
      (error error))
    (catch
      ((tuple _class reason _stack)
       (tuple 'error reason)))))

(defun render-kitty (image-data opts)
  "Render using Kitty protocol."
  (try
    (case (kitty-sequence image-data opts)
      (`#(ok ,sequence)
       (io:put_chars sequence)
       (io:nl)
       (tuple 'ok 'displayed))
      (error error))
    (catch
      ((tuple _class reason _stack)
       (tuple 'error reason)))))

(defun to-string (value)
  "Convert value to string."
  (cond
    ((is_binary value) (binary_to_list value))
    ((is_list value) value)
    ((is_atom value) (atom_to_list value))
    ('true (lists:flatten (io_lib:format "~p" (list value))))))

;;; Protocol Implementation

(defun iterm2-sequence (image-data opts)
  "Generate iTerm2 inline image escape sequence.

  Protocol: ESC ] 1337 ; File = [params] : [base64-data] BEL

  Args:
    image-data: Binary image data
    opts: Options map:
      - width: Width spec ('auto' or string)
      - height: Height spec ('auto' or string)
      - filename: Optional filename

  Returns:
    {ok, binary-sequence}"
  (try
    (let* ((base64-data (base64:encode image-data))
           (filename (maps:get 'filename opts 'undefined))
           (width (maps:get 'width opts "auto"))
           (height (maps:get 'height opts "auto"))
           (params (build-iterm2-params filename width height)))
      (tuple 'ok
        (iolist_to_binary
          (list "\e]1337;File=" params ":" base64-data "\a"))))
    (catch
      ((tuple _class reason _stack)
       (tuple 'error reason)))))

(defun build-iterm2-params (filename width height)
  "Build parameter string for iTerm2 protocol."
  (let* ((params (list "inline=1"))
         ;; Add filename if provided
         (params (case filename
                   ('undefined params)
                   (name
                     (let ((name-str (to-string name)))
                       (cons (++ "name="
                                (binary_to_list
                                  (base64:encode
                                    (list_to_binary name-str))))
                             params)))))
         ;; Add width if not auto
         (params (case width
                   ("auto" params)
                   (w (cons (++ "width=" w) params))))
         ;; Add height if not auto
         (params (case height
                   ("auto" params)
                   (h (cons (++ "height=" h) params)))))
    (string:join (lists:reverse params) ";")))

(defun kitty-sequence (image-data opts)
  "Generate Kitty graphics protocol escape sequence.

  Protocol: ESC _ G [params] ; [base64-data] ESC \\
  Chunks data into 4096-byte segments.

  Args:
    image-data: Binary image data
    opts: Options map (currently unused)

  Returns:
    {ok, binary-sequence}"
  (try
    (let ((base64-data (base64:encode image-data)))
      (tuple 'ok
        (iolist_to_binary (kitty-chunks base64-data 4096))))
    (catch
      ((tuple _class reason _stack)
       (tuple 'error reason)))))

(defun kitty-chunks (data chunk-size)
  "Split base64 data into Kitty protocol chunks."
  (kitty-chunks data chunk-size 'true '()))

(defun kitty-chunks (data chunk-size first? acc)
  "Recursive chunking implementation."
  (let ((data-size (byte_size data)))
    (cond
      ;; Empty data - return accumulated chunks
      ((== data-size 0)
       (lists:reverse acc))

      ;; Last chunk
      ((=< data-size chunk-size)
       (let* ((control (if first?
                         "a=T,f=100,m=0"  ;; transmit+display, PNG, last
                         "m=0"))          ;; continuation, last
              (chunk (list "\e_G" control ";" data "\e\\")))
         (lists:reverse (cons chunk acc))))

      ;; More chunks needed
      ('true
       (let* ((chunk-data (binary:part data 0 chunk-size))
              (rest (binary:part data chunk-size (- data-size chunk-size)))
              (control (if first?
                         "a=T,f=100,m=1"  ;; transmit+display, PNG, more
                         "m=1"))          ;; continuation, more
              (chunk (list "\e_G" control ";" chunk-data "\e\\")))
         (kitty-chunks rest chunk-size 'false (cons chunk acc)))))))
