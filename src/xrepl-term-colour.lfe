(defmodule xrepl-term-colour
  "ANSI colour and style implementation.

  Provides low-level ANSI SGR (Select Graphic Rendition) sequence generation.
  Uses apply/reset nomenclature matching ANSI specification terminology.

  Most users will use the macro DSL in include/colours.lfe instead."
  (export
   ;; Core primitives
   (apply 2)
   (reset 1)

   ;; Utilities
   (strip-ansi 1)
   (visual-length 1)

   ;; Internal helpers (exported for testing)
   (sgr-codes 1)
   (colour-to-fg-code 1)
   (colour-to-bg-code 1)))

;;; Core Primitives

(defun apply (text attrs)
  "Apply ANSI attributes to text.

  Generates optimized SGR sequence with all attributes in a single
  escape code, then appends reset sequence.

  Args:
    text: Text to style (string, binary, or iolist)
    attrs: Attribute map with keys:
      - fg: Foreground colour (atom or integer)
      - bg: Background colour (atom or integer)
      - bold: Boolean
      - dim: Boolean
      - italic: Boolean
      - underline: Boolean
      - blink: Boolean
      - reverse: Boolean
      - hidden: Boolean
      - strike: Boolean

  Returns:
    String with ANSI codes: ESC[<codes>m text ESC[0m

  Examples:
    (apply \"Error\" #m(fg red bold true))
    → \"\\e[1;31mError\\e[0m\"

    (apply \"Warning\" #m(fg yellow bg black underline true))
    → \"\\e[4;33;40mWarning\\e[0m\""
  (let* ((text-str (to-string text))
         (codes (sgr-codes attrs))
         (prefix (if (== codes "")
                   ""
                   (++ "\e[" codes "m"))))
    (++ prefix text-str "\e[0m")))

(defun reset (text)
  "Wrap text with reset codes (ESC[0m).

  Args:
    text: Text to wrap

  Returns:
    String with reset: ESC[0m text"
  (++ "\e[0m" (to-string text)))

(defun to-string (value)
  "Convert value to string."
  (cond
    ((is_binary value) (binary_to_list value))
    ((is_list value) value)
    ((is_atom value) (atom_to_list value))
    ('true (lists:flatten (io_lib:format "~p" (list value))))))

;;; SGR Code Generation

(defun sgr-codes (attrs)
  "Generate semicolon-delimited SGR parameter codes.

  Converts attribute map to ANSI numeric codes.

  Args:
    attrs: Attribute map

  Returns:
    String like \"1;31\" or \"\" if no attributes"
  (let* ((codes (++ (style-codes attrs)
                    (fg-code attrs)
                    (bg-code attrs)))
         (filtered (lists:filter
                     (lambda (c) (=/= c ""))
                     codes)))
    (string:join filtered ";")))

(defun style-codes (attrs)
  "Extract style attribute codes.

  Returns:
    List of code strings"
  (list (if (maps:get 'bold attrs 'false) "1" "")
        (if (maps:get 'dim attrs 'false) "2" "")
        (if (maps:get 'italic attrs 'false) "3" "")
        (if (maps:get 'underline attrs 'false) "4" "")
        (if (maps:get 'blink attrs 'false) "5" "")
        (if (maps:get 'reverse attrs 'false) "7" "")
        (if (maps:get 'hidden attrs 'false) "8" "")
        (if (maps:get 'strike attrs 'false) "9" "")))

(defun fg-code (attrs)
  "Get foreground colour code.

  Returns:
    List with colour code string or empty"
  (case (maps:get 'fg attrs 'undefined)
    ('undefined '())
    (colour (list (colour-to-fg-code colour)))))

(defun bg-code (attrs)
  "Get background colour code.

  Returns:
    List with colour code string or empty"
  (case (maps:get 'bg attrs 'undefined)
    ('undefined '())
    (colour (list (colour-to-bg-code colour)))))

(defun colour-to-fg-code (colour)
  "Convert colour to foreground SGR code.

  Args:
    colour: Atom (named colour) or integer (0-255)

  Returns:
    String SGR code"
  (cond
    ((is_integer colour)
     (++ "38;5;" (integer_to_list colour)))
    ('true
     (case colour
       ('black "30")
       ('red "31")
       ('green "32")
       ('yellow "33")
       ('blue "34")
       ('magenta "35")
       ('cyan "36")
       ('white "37")
       ('bright-black "90")
       ('bright-red "91")
       ('bright-green "92")
       ('bright-yellow "93")
       ('bright-blue "94")
       ('bright-magenta "95")
       ('bright-cyan "96")
       ('bright-white "97")
       (_ "39"))))) ;; Default colour

(defun colour-to-bg-code (colour)
  "Convert colour to background SGR code.

  Args:
    colour: Atom (named colour) or integer (0-255)

  Returns:
    String SGR code"
  (cond
    ((is_integer colour)
     (++ "48;5;" (integer_to_list colour)))
    ('true
     (case colour
       ('black "40")
       ('red "41")
       ('green "42")
       ('yellow "43")
       ('blue "44")
       ('magenta "45")
       ('cyan "46")
       ('white "47")
       ('bright-black "100")
       ('bright-red "101")
       ('bright-green "102")
       ('bright-yellow "103")
       ('bright-blue "104")
       ('bright-magenta "105")
       ('bright-cyan "106")
       ('bright-white "107")
       (_ "49"))))) ;; Default colour

;;; Utilities

(defun strip-ansi (text)
  "Remove all ANSI escape sequences from text.

  Args:
    text: Text potentially containing ANSI codes

  Returns:
    Text with ANSI codes removed"
  (let ((text-str (to-string text)))
    ;; Remove CSI sequences: ESC [ ... m
    (re:replace text-str "\\e\\[[0-9;]*m" "" '(global #(return list)))))

(defun visual-length (text)
  "Calculate visual length of text (excluding ANSI codes).

  Args:
    text: Text potentially containing ANSI codes

  Returns:
    Integer length as it appears on screen"
  (string:length (strip-ansi text)))
