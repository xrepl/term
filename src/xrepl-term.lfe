(defmodule xrepl-term
  "Core terminal control and detection.

  Provides terminal capability detection, control sequences,
  hyperlinks, notifications, and utility functions."
  (export
   ;; Terminal detection
   (detect-terminal 0)
   (capabilities 0)
   (terminal-info 0)

   ;; Terminal control
   (clear-screen 0)
   (clear-line 0)
   (set-title 1)
   (set-cwd 1)
   (bell 0)
   (urgent 0)

   ;; Screen management
   (enter-alt-screen 0)
   (exit-alt-screen 0)
   (with-alt-screen 1)

   ;; Cursor control
   (cursor-hide 0)
   (cursor-show 0)
   (cursor-save 0)
   (cursor-restore 0)
   (cursor-position 2)
   (cursor-up 1)
   (cursor-down 1)
   (cursor-forward 1)
   (cursor-backward 1)

   ;; Hyperlinks (OSC 8)
   (link 2)
   (link 3)

   ;; Notifications
   (notify 1)
   (notify 2)

   ;; Terminal queries
   (terminal-size 0)

   ;; Progress indicators
   (progress-bar 2)
   (progress-bar 3)

   ;; Utilities
   (supports? 1)))

;;; Terminal Detection

(defun detect-terminal ()
  "Detect terminal type.

  Returns:
    wezterm | iterm2 | kitty | apple-terminal | vscode | unknown"
  (let ((term-program (os:getenv "TERM_PROGRAM"))
        (term (os:getenv "TERM")))
    (cond
      ((== term-program "WezTerm") 'wezterm)
      ((== term-program "iTerm.app") 'iterm2)
      ((== term-program "Apple_Terminal") 'apple-terminal)
      ((== term-program "vscode") 'vscode)
      ((== term "xterm-kitty") 'kitty)
      ((andalso (is_list term-program)
                (=/= (string:find term-program "kitty") 'nomatch))
       'kitty)
      ('true 'unknown))))

(defun terminal-info ()
  "Get detailed terminal information.

  Returns:
    Map with terminal metadata"
  (let* ((term-program (os:getenv "TERM_PROGRAM"))
         (term (os:getenv "TERM"))
         (version (os:getenv "TERM_PROGRAM_VERSION"))
         (colorterm (os:getenv "COLORTERM")))
    `#m(terminal ,(detect-terminal)
        term-program ,(if (=/= term-program 'false) term-program "unknown")
        term ,(if (=/= term 'false) term "unknown")
        version ,(if (=/= version 'false) version "unknown")
        colorterm ,(if (=/= colorterm 'false) colorterm "unknown"))))

(defun capabilities ()
  "Detect terminal capabilities.

  Returns:
    Map of supported features"
  (let ((terminal (detect-terminal)))
    (maps:from_list
      `(#(terminal ,terminal)
        #(graphics ,(detect-graphics-support terminal))
        #(hyperlinks ,(supports-hyperlinks? terminal))
        #(notifications ,(supports-notifications? terminal))
        #(true-colour ,(supports-true-colour?))
        #(unicode ,(supports-unicode?))
        #(alt-screen true)
        #(cursor-control true)))))

(defun detect-graphics-support (terminal)
  "Detect graphics protocol support.

  Returns:
    List of supported protocols: (iterm2), (kitty), etc."
  (case terminal
    ('wezterm '(iterm2))
    ('iterm2 '(iterm2))
    ('kitty '(kitty iterm2))
    (_ '())))

(defun supports-hyperlinks? (terminal)
  "Check if terminal supports OSC 8 hyperlinks."
  (lists:member terminal '(wezterm iterm2 kitty)))

(defun supports-notifications? (terminal)
  "Check if terminal supports desktop notifications."
  (lists:member terminal '(iterm2 kitty)))

(defun supports-true-colour? ()
  "Check if terminal supports 24-bit colour."
  (case (os:getenv "COLORTERM")
    ("truecolor" 'true)
    ("24bit" 'true)
    (_ 'false)))

(defun supports-unicode? ()
  "Check if terminal supports Unicode."
  (case (os:getenv "LANG")
    ('false 'false)
    (lang (=/= (string:find lang "UTF") 'nomatch))))

(defun supports? (capability)
  "Check if terminal supports a specific capability.

  Args:
    capability: Atom like 'graphics, 'hyperlinks, 'true-colour

  Returns:
    true | false"
  (let ((caps (capabilities)))
    (case capability
      ('graphics (not (== (maps:get 'graphics caps) '())))
      ('hyperlinks (maps:get 'hyperlinks caps))
      ('notifications (maps:get 'notifications caps))
      ('true-colour (maps:get 'true-colour caps))
      ('unicode (maps:get 'unicode caps))
      (_ 'false))))

;;; Terminal Control

(defun clear-screen ()
  "Clear entire screen and move cursor to home."
  (io:put_chars "\e[2J\e[H")
  'ok)

(defun clear-line ()
  "Clear current line."
  (io:put_chars "\e[2K")
  'ok)

(defun set-title (title)
  "Set terminal window/tab title (OSC 0).

  Args:
    title: String or binary

  Returns:
    ok"
  (let ((title-str (to-string title)))
    (io:format "\e]0;~s\a" (list title-str)))
  'ok)

(defun set-cwd (path)
  "Tell terminal the current working directory (OSC 7).

  Enables terminal features like 'Open in Finder/Explorer'.

  Args:
    path: Directory path (string or binary)

  Returns:
    ok"
  (let* ((path-str (to-string path))
         (hostname (case (inet:gethostname)
                     (`#(ok ,host) host)
                     (_ "localhost")))
         ;; Simple URL encoding for path
         (encoded-path (http_uri:encode path-str)))
    (io:format "\e]7;file://~s~s\a" (list hostname encoded-path)))
  'ok)

(defun bell ()
  "Ring terminal bell (usually visual flash)."
  (io:put_chars "\a")
  'ok)

(defun urgent ()
  "Set urgent flag (flash taskbar/dock icon)."
  (bell))

(defun to-string (value)
  "Convert value to string."
  (cond
    ((is_binary value) (binary_to_list value))
    ((is_list value) value)
    ((is_atom value) (atom_to_list value))
    ('true (lists:flatten (io_lib:format "~p" (list value))))))

;;; Screen Management

(defun enter-alt-screen ()
  "Switch to alternate screen buffer.

  Like vim/less - creates clean screen, preserves original."
  (io:put_chars "\e[?1049h")
  'ok)

(defun exit-alt-screen ()
  "Return to normal screen buffer."
  (io:put_chars "\e[?1049l")
  'ok)

(defun with-alt-screen (fun)
  "Execute function in alternate screen buffer.

  Automatically returns to normal screen when done.

  Args:
    fun: Zero-arity function to execute

  Returns:
    {ok, result} | {error, reason}"
  (enter-alt-screen)
  (try
    (let ((result (funcall fun)))
      (exit-alt-screen)
      (tuple 'ok result))
    (catch
      ((tuple class reason stacktrace)
       (exit-alt-screen)
       (tuple 'error (tuple class reason))))))

;;; Cursor Control

(defun cursor-hide ()
  "Hide cursor (DECTCEM)."
  (io:put_chars "\e[?25l")
  'ok)

(defun cursor-show ()
  "Show cursor (DECTCEM)."
  (io:put_chars "\e[?25h")
  'ok)

(defun cursor-save ()
  "Save cursor position (DECSC)."
  (io:put_chars "\e7")
  'ok)

(defun cursor-restore ()
  "Restore cursor position (DECRC)."
  (io:put_chars "\e8")
  'ok)

(defun cursor-position (row col)
  "Move cursor to position (CUP).

  Args:
    row: Row number (1-based)
    col: Column number (1-based)"
  (io:format "\e[~p;~pH" (list row col))
  'ok)

(defun cursor-up (n)
  "Move cursor up n lines (CUU)."
  (io:format "\e[~pA" (list n))
  'ok)

(defun cursor-down (n)
  "Move cursor down n lines (CUD)."
  (io:format "\e[~pB" (list n))
  'ok)

(defun cursor-forward (n)
  "Move cursor forward n columns (CUF)."
  (io:format "\e[~pC" (list n))
  'ok)

(defun cursor-backward (n)
  "Move cursor backward n columns (CUB)."
  (io:format "\e[~pD" (list n))
  'ok)

;;; Hyperlinks

(defun link (url text)
  "Create clickable hyperlink (OSC 8).

  Args:
    url: Target URL (string)
    text: Link text to display (string)

  Returns:
    {ok, string} | {error, not-supported}"
  (link url text #m()))

(defun link (url text opts)
  "Create hyperlink with options.

  Args:
    url: Target URL
    text: Link text
    opts: Options map (reserved for future use)

  Returns:
    {ok, string} | {error, not-supported}"
  (case (supports? 'hyperlinks)
    ('true
     (let ((url-str (to-string url))
           (text-str (to-string text)))
       (tuple 'ok (++ "\e]8;;" url-str "\e\\" text-str "\e]8;;\e\\"))))
    ('false
     (tuple 'error 'not-supported))))

;;; Notifications

(defun notify (message)
  "Send desktop notification.

  Args:
    message: Notification message (string)

  Returns:
    {ok, sent} | {error, not-supported}"
  (notify "" message))

(defun notify (title message)
  "Send desktop notification with title.

  Args:
    title: Notification title (string, can be empty)
    message: Notification message (string)

  Returns:
    {ok, sent} | {error, not-supported}"
  (case (supports? 'notifications)
    ('true
     (let* ((title-str (to-string title))
            (msg-str (to-string message))
            (full-msg (if (== title-str "")
                        msg-str
                        (++ title-str ": " msg-str))))
       ;; OSC 9 - iTerm2 notification format
       (io:format "\e]9;~s\a" (list full-msg))
       (tuple 'ok 'sent)))
    ('false
     (tuple 'error 'not-supported))))

;;; Terminal Queries

(defun terminal-size ()
  "Get terminal size in columns and rows.

  Returns:
    {ok, {cols, rows}} | {error, reason}"
  (case (io:columns)
    (`#(ok ,cols)
     (case (io:rows)
       (`#(ok ,rows)
        (tuple 'ok (tuple cols rows)))
       (error error)))
    (error error)))

;;; Progress Indicators

(defun progress-bar (progress label)
  "Display progress bar.

  Args:
    progress: Float between 0.0 and 1.0
    label: Label text (string)

  Returns:
    ok"
  (progress-bar progress label #m()))

(defun progress-bar (progress label opts)
  "Display progress bar with options.

  Args:
    progress: Float between 0.0 and 1.0
    label: Label text
    opts: Options map:
      - width: Bar width in characters (default 40)
      - filled-char: String for filled portion (default \"=\")
      - empty-char: String for empty portion (default \" \")

  Returns:
    ok"
  (let* ((width (maps:get 'width opts 40))
         (filled-char (maps:get 'filled-char opts "="))
         (empty-char (maps:get 'empty-char opts " "))
         (filled (round (* progress width)))
         (empty (- width filled))
         (bar (++ (string:copies filled-char filled)
                  (string:copies empty-char empty)))
         (percent (round (* progress 100))))
    (io:format "\r~s [~s] ~p%" (list label bar percent))
    'ok))
