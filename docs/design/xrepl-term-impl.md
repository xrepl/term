# xrepl-term: LFE Terminal Control Library

## Project Overview

**xrepl-term** is a comprehensive LFE library providing idiomatic, composable APIs for modern terminal capabilities. It supports ANSI styling, inline graphics (iTerm2, Kitty, Sixel), hyperlinks, notifications, and UI components—all with graceful degradation and automatic capability detection.

### Repository Structure

```
~/lab/lfe/xrepl/term/
├── rebar.config
├── README.md
├── LICENSE
├── src/
│   ├── xrepl_term.app.src
│   ├── xrepl-term.lfe           # Core terminal control
│   ├── xrepl-term-colour.lfe    # ANSI colour/style implementation
│   ├── xrepl-term-graphics.lfe  # Image rendering protocols
│   └── xrepl-term-ui.lfe        # High-level UI components
├── include/
│   └── colours.lfe              # Colour DSL macros
├── test/
│   ├── xrepl-term-tests.lfe
│   ├── xrepl-term-colour-tests.lfe
│   ├── xrepl-term-graphics-tests.lfe
│   └── xrepl-term-ui-tests.lfe
└── examples/
    ├── basic-colours.lfe
    ├── image-demo.lfe
    ├── table-demo.lfe
    └── tree-demo.lfe
```

### Key Design Principles

1. **LFE-idiomatic**: Leverage `clj:->` threading, composition, pipeline-friendly APIs
2. **Graceful degradation**: Detect capabilities, provide fallbacks
3. **Zero external dependencies**: Pure Erlang/LFE (except optional ImageMagick)
4. **Include-lib DSL**: Colour macros via `(include-lib "xrepl_term/include/colours.lfe")`
5. **Composable**: Functions chain naturally via `clj:->`
6. **Proper nomenclature**: `apply` and `reset` match ANSI specification terminology

---

## Phase 1: Project Scaffolding

**Goal**: Create the basic LFE project structure with rebar3 configuration.

### 1.1 Create rebar.config

```erlang
{erl_opts, [debug_info]}.

{deps, [
    {lfe, "2.2.0"}
]}.

{plugins, [
    {rebar3_lfe, "0.4.11"}
]}.

{provider_hooks, [
    {pre, [{compile, {lfe, compile}}]}
]}.

{profiles, [
    {test, [
        {deps, [
            {proper, "1.5.0"},
            {ltest, "0.13.11"}
        ]},
        {eunit_opts, [verbose]},
        {erl_opts, [{src_dirs, ["src", "test"]}]}
    ]}
]}.

{alias, [
    {coverage, [
        {proper, "-c"},
        {cover, "-v --min_coverage=0"}
    ]},
    {check, [
        compile,
        %%xref,
        %%dialyzer,
        eunit,
        coverage
    ]}
]}.
```

### 1.2 Create src/xrepl_term.app.src

```erlang
{application, xrepl_term,
 [{description, "LFE Terminal Control Library - ANSI colours, graphics, UI components"},
  {vsn, "0.1.0"},
  {registered, []},
  {applications, [kernel, stdlib]},
  {env, []},
  {modules, []},
  {licenses, ["Apache-2.0"]},
  {links, [{"GitHub", "https://github.com/xrepl/term"}]}
 ]}.
```

### 1.3 Create README.md

```markdown
# xrepl-term

> Modern terminal control library for LFE

## Features

- 🎨 **ANSI Colours & Styles** - Rich text formatting with composable DSL
- 🖼️ **Inline Graphics** - Display images via iTerm2, Kitty, and Sixel protocols
- 🔗 **Hyperlinks** - Clickable terminal links (OSC 8)
- 🔔 **Notifications** - Desktop notifications from terminal
- 📊 **UI Components** - Tables, progress bars, tree views
- 🔍 **Auto-detection** - Automatically detect terminal capabilities
- 🎯 **Zero Dependencies** - Pure Erlang/LFE implementation

## Installation

Add to your `rebar.config`:

```erlang
{deps, [
    {xrepl_term, {git, "https://github.com/xrepl/term.git", {branch, "main"}}}
]}.
```

## Quick Start

```lfe
;; Include colour macros
(include-lib "xrepl_term/include/colours.lfe")

;; Basic styling
(io:format "~s~n" (list (red! "Error: " (bold! "File not found"))))

;; Threading macro style
(clj:-> "Important Message"
  (bold!)
  (fg! 'cyan)
  (underline!)
  (list)
  (io:format "~s~n"))

;; Display image
(xrepl-term-graphics:render-file "chart.png" #m(width "80%"))

;; Create table
(xrepl-term-ui:table
  #m(headers '("Name" "Age" "City")
     rows '(("Alice" 30 "NYC")
            ("Bob" 25 "SF"))))
```

## Documentation

See [examples/](examples/) for more usage patterns.

## License

Apache-2.0

```

### 1.4 Create LICENSE

```

Apache License
Version 2.0, January 2004
<http://www.apache.org/licenses/>

(Full Apache 2.0 license text - available at <https://www.apache.org/licenses/LICENSE-2.0.txt>)

```

### Testing Phase 1

```bash
$ mkdir -p github.com/xrepl/term
$ cd github.com/xrepl/term
$ rebar3 new lfe-lib xrepl-term  # Or manually create structure
$ rebar3 compile
# Should compile successfully with no errors
```

**Success Criteria**:

- Project compiles cleanly
- Directory structure matches specification
- rebar.config is valid and loads dependencies

---

## Phase 2: Core Terminal Module (xrepl-term.lfe)

**Goal**: Implement terminal detection, control sequences, and utility functions.

### File: `src/xrepl-term.lfe`

```lfe
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
```

### 2.1 Terminal Detection

```lfe
(defun detect-terminal ()
  "Detect terminal type.

  Returns:
    wezterm | iterm2 | kitty | apple-terminal | unknown"
  (let ((term-program (os:getenv "TERM_PROGRAM"))
        (term (os:getenv "TERM")))
    (cond
      ((== term-program "WezTerm") 'wezterm)
      ((== term-program "iTerm.app") 'iterm2)
      ((== term-program "Apple_Terminal") 'apple-terminal)
      ((== term "xterm-kitty") 'kitty)
      ((andalso (is_list term-program)
                (=/= (string:find term-program "kitty") 'nomatch))
       'kitty)
      ('true 'unknown))))

(defun terminal-info ()
  "Get detailed terminal information.

  Returns:
    Map with terminal metadata"
  (let ((term-program (os:getenv "TERM_PROGRAM"))
        (term (os:getenv "TERM"))
        (version (os:getenv "TERM_PROGRAM_VERSION"))
        (colorterm (os:getenv "COLORTERM")))
    (maps:from_list
      `(#(terminal ,(detect-terminal))
        #(term-program ,(if term-program term-program "unknown"))
        #(term ,(if term term "unknown"))
        #(version ,(if version version "unknown"))
        #(colorterm ,(if colorterm colorterm "unknown"))))))

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
```

### 2.2 Terminal Control

```lfe
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
```

### 2.3 Screen Management

```lfe
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
```

### 2.4 Cursor Control

```lfe
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
```

### 2.5 Hyperlinks

```lfe
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
```

### 2.6 Notifications

```lfe
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
     (let ((title-str (to-string title))
           (msg-str (to-string message))
           (full-msg (if (== title-str "")
                       msg-str
                       (++ title-str ": " msg-str))))
       ;; OSC 9 - iTerm2 notification format
       (io:format "\e]9;~s\a" (list full-msg))
       (tuple 'ok 'sent)))
    ('false
     (tuple 'error 'not-supported))))
```

### 2.7 Terminal Queries

```lfe
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
```

### 2.8 Progress Indicators

```lfe
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
      - filled-char: Character for filled portion (default '█')
      - empty-char: Character for empty portion (default '░')

  Returns:
    ok"
  (let* ((width (maps:get 'width opts 40))
         (filled-char (maps:get 'filled-char opts #\█))
         (empty-char (maps:get 'empty-char opts #\░))
         (filled (round (* progress width)))
         (empty (- width filled))
         (bar (++ (lists:duplicate filled filled-char)
                  (lists:duplicate empty empty-char)))
         (percent (round (* progress 100))))
    (io:format "\r~s [~s] ~p%" (list label bar percent))
    'ok))
```

### Testing Phase 2

```lfe
;; In LFE REPL
1> (c "src/xrepl-term.lfe")
#(module xrepl-term)

2> (xrepl-term:detect-terminal)
wezterm

3> (xrepl-term:terminal-info)
#M(terminal wezterm term-program "WezTerm" ...)

4> (xrepl-term:supports? 'graphics)
true

5> (xrepl-term:set-title "My REPL")
ok
;; Window title should change

6> (xrepl-term:link "https://lfe.io" "Visit LFE")
{ok, "\e]8;;https://lfe.io\e\\Visit LFE\e]8;;\e\\"}

7> (xrepl-term:progress-bar 0.75 "Downloading")
Downloading [██████████████████████████████░░░░░░░░░░] 75%
ok

8> (xrepl-term:with-alt-screen
     (lambda ()
       (xrepl-term:clear-screen)
       (io:format "Full screen mode!~n")
       (timer:sleep 2000)
       42))
{ok, 42}
;; Should switch to alt screen, then back
```

**Success Criteria**:

- All functions compile without errors
- Terminal detection works correctly
- Links are clickable (in supporting terminals)
- Progress bar renders correctly
- Alt screen switches work
- All functions return proper `{ok, result}` or `{error, reason}` tuples

---

## Phase 3: ANSI Colour Implementation (xrepl-term-colour.lfe)

**Goal**: Implement ANSI colour and style functions using the `apply/reset` nomenclature that honours the ANSI specification.

### File: `src/xrepl-term-colour.lfe`

```lfe
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

   ;; Internal helpers
   (sgr-codes 1)))
```

### 3.1 Core Primitives

```lfe
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
```

### 3.2 SGR Code Generation

```lfe
(defun sgr-codes (attrs)
  "Generate semicolon-delimited SGR parameter codes.

  Converts attribute map to ANSI numeric codes.

  Args:
    attrs: Attribute map

  Returns:
    String like \"1;31\" or \"\" if no attributes"
  (let ((codes (lists:flatten
                 (list (style-codes attrs)
                       (fg-code attrs)
                       (bg-code attrs)))))
    (string:join (lists:filter
                   (lambda (c) (=/= c ""))
                   codes)
                 ";")))

(defun style-codes (attrs)
  "Extract style attribute codes.

  Returns:
    List of code strings"
  (lists:flatten
    (list (if (maps:get 'bold attrs 'false) "1" "")
          (if (maps:get 'dim attrs 'false) "2" "")
          (if (maps:get 'italic attrs 'false) "3" "")
          (if (maps:get 'underline attrs 'false) "4" "")
          (if (maps:get 'blink attrs 'false) "5" "")
          (if (maps:get 'reverse attrs 'false) "7" "")
          (if (maps:get 'hidden attrs 'false) "8" "")
          (if (maps:get 'strike attrs 'false) "9" ""))))

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
```

### 3.3 Utilities

```lfe
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
```

### Testing Phase 3

```lfe
;; In LFE REPL
1> (c "src/xrepl-term-colour.lfe")
#(module xrepl-term-colour)

2> (xrepl-term-colour:apply "Hello" #m(fg red))
"\e[31mHello\e[0m"

3> (xrepl-term-colour:apply "Bold Red" #m(fg red bold true))
"\e[1;31mBold Red\e[0m"

4> (xrepl-term-colour:apply "Fancy" #m(fg cyan bg black bold true underline true))
"\e[1;4;36;40mFancy\e[0m"

5> (io:format "~s~n" (list (xrepl-term-colour:apply "Error!" #m(fg red bold true))))
;; Should display bold red text

6> (xrepl-term-colour:strip-ansi "\e[1;31mBold Red\e[0m")
"Bold Red"

7> (xrepl-term-colour:visual-length "\e[1;31mBold Red\e[0m")
8

8> (xrepl-term-colour:sgr-codes #m(fg red bold true underline true))
"1;4;31"
```

**Success Criteria**:

- SGR codes generate correctly
- Multiple attributes combine in single sequence
- Foreground and background colours work
- 256-colour mode works (test with integer colours)
- `strip-ansi` removes all escape sequences
- `visual-length` calculates correctly

---

## Phase 4: Colour DSL Macros (include/colours.lfe)

**Goal**: Create user-friendly macros that provide syntactic sugar over `xrepl-term-colour:apply`.

### File: `include/colours.lfe`

```lfe
;;;; Colour DSL Macros
;;;;
;;;; Provides user-friendly macros for terminal colours and styles.
;;;; Include in your modules with:
;;;;   (include-lib "xrepl_term/include/colours.lfe")
;;;;
;;;; Two styles of macros:
;;;;   - Pure functions: (red text) → styled string
;;;;   - Side-effect functions: (red! text) → prints styled string, returns ok
;;;;
;;;; All macros work with clj:-> threading.

;;; Style Macros (Pure)

(defmacro bold (text)
  `(xrepl-term-colour:apply ,text #m(bold true)))

(defmacro dim (text)
  `(xrepl-term-colour:apply ,text #m(dim true)))

(defmacro italic (text)
  `(xrepl-term-colour:apply ,text #m(italic true)))

(defmacro underline (text)
  `(xrepl-term-colour:apply ,text #m(underline true)))

(defmacro blink (text)
  `(xrepl-term-colour:apply ,text #m(blink true)))

(defmacro reverse (text)
  `(xrepl-term-colour:apply ,text #m(reverse true)))

(defmacro hidden (text)
  `(xrepl-term-colour:apply ,text #m(hidden true)))

(defmacro strike (text)
  `(xrepl-term-colour:apply ,text #m(strike true)))

;;; Foreground Colour Macros (Pure)

(defmacro black (text)
  `(xrepl-term-colour:apply ,text #m(fg black)))

(defmacro red (text)
  `(xrepl-term-colour:apply ,text #m(fg red)))

(defmacro green (text)
  `(xrepl-term-colour:apply ,text #m(fg green)))

(defmacro yellow (text)
  `(xrepl-term-colour:apply ,text #m(fg yellow)))

(defmacro blue (text)
  `(xrepl-term-colour:apply ,text #m(fg blue)))

(defmacro magenta (text)
  `(xrepl-term-colour:apply ,text #m(fg magenta)))

(defmacro cyan (text)
  `(xrepl-term-colour:apply ,text #m(fg cyan)))

(defmacro white (text)
  `(xrepl-term-colour:apply ,text #m(fg white)))

;;; Bright Foreground Colours (Pure)

(defmacro bright-black (text)
  `(xrepl-term-colour:apply ,text #m(fg bright-black)))

(defmacro bright-red (text)
  `(xrepl-term-colour:apply ,text #m(fg bright-red)))

(defmacro bright-green (text)
  `(xrepl-term-colour:apply ,text #m(fg bright-green)))

(defmacro bright-yellow (text)
  `(xrepl-term-colour:apply ,text #m(fg bright-yellow)))

(defmacro bright-blue (text)
  `(xrepl-term-colour:apply ,text #m(fg bright-blue)))

(defmacro bright-magenta (text)
  `(xrepl-term-colour:apply ,text #m(fg bright-magenta)))

(defmacro bright-cyan (text)
  `(xrepl-term-colour:apply ,text #m(fg bright-cyan)))

(defmacro bright-white (text)
  `(xrepl-term-colour:apply ,text #m(fg bright-white)))

;;; Generic Colour Functions (Pure)

(defmacro fg (colour text)
  "Apply foreground colour.

  Args:
    colour: Atom (named colour) or integer (0-255)
    text: Text to colour

  Example:
    (fg 'red \"Error\")
    (fg 196 \"Bright red\")"
  `(xrepl-term-colour:apply ,text #m(fg ,colour)))

(defmacro bg (colour text)
  "Apply background colour.

  Args:
    colour: Atom (named colour) or integer (0-255)
    text: Text to colour

  Example:
    (bg 'black \"On black\")
    (bg 232 \"Dark grey background\")"
  `(xrepl-term-colour:apply ,text #m(bg ,colour)))

;;; Combined Style Macros (Pure)

(defmacro bold-red (text)
  `(xrepl-term-colour:apply ,text #m(fg red bold true)))

(defmacro bold-green (text)
  `(xrepl-term-colour:apply ,text #m(fg green bold true)))

(defmacro bold-yellow (text)
  `(xrepl-term-colour:apply ,text #m(fg yellow bold true)))

(defmacro bold-blue (text)
  `(xrepl-term-colour:apply ,text #m(fg blue bold true)))

;;; Side-Effect Macros (Print and return ok)

(defmacro bold! (text)
  `(progn
     (io:format "~s" (list (xrepl-term-colour:apply ,text #m(bold true))))
     'ok))

(defmacro dim! (text)
  `(progn
     (io:format "~s" (list (xrepl-term-colour:apply ,text #m(dim true))))
     'ok))

(defmacro italic! (text)
  `(progn
     (io:format "~s" (list (xrepl-term-colour:apply ,text #m(italic true))))
     'ok))

(defmacro underline! (text)
  `(progn
     (io:format "~s" (list (xrepl-term-colour:apply ,text #m(underline true))))
     'ok))

(defmacro red! (text)
  `(progn
     (io:format "~s" (list (xrepl-term-colour:apply ,text #m(fg red))))
     'ok))

(defmacro green! (text)
  `(progn
     (io:format "~s" (list (xrepl-term-colour:apply ,text #m(fg green))))
     'ok))

(defmacro yellow! (text)
  `(progn
     (io:format "~s" (list (xrepl-term-colour:apply ,text #m(fg yellow))))
     'ok))

(defmacro blue! (text)
  `(progn
     (io:format "~s" (list (xrepl-term-colour:apply ,text #m(fg blue))))
     'ok))

(defmacro cyan! (text)
  `(progn
     (io:format "~s" (list (xrepl-term-colour:apply ,text #m(fg cyan))))
     'ok))

(defmacro magenta! (text)
  `(progn
     (io:format "~s" (list (xrepl-term-colour:apply ,text #m(fg magenta))))
     'ok))

(defmacro white! (text)
  `(progn
     (io:format "~s" (list (xrepl-term-colour:apply ,text #m(fg white))))
     'ok))

(defmacro fg! (colour text)
  "Apply foreground colour and print.

  Args:
    colour: Atom (named colour) or integer (0-255)
    text: Text to colour"
  `(progn
     (io:format "~s" (list (xrepl-term-colour:apply ,text #m(fg ,colour))))
     'ok))

(defmacro bg! (colour text)
  "Apply background colour and print.

  Args:
    colour: Atom (named colour) or integer (0-255)
    text: Text to colour"
  `(progn
     (io:format "~s" (list (xrepl-term-colour:apply ,text #m(bg ,colour))))
     'ok))

;;; Combined Side-Effect Macros

(defmacro bold-red! (text)
  `(progn
     (io:format "~s" (list (xrepl-term-colour:apply ,text #m(fg red bold true))))
     'ok))

(defmacro bold-green! (text)
  `(progn
     (io:format "~s" (list (xrepl-term-colour:apply ,text #m(fg green bold true))))
     'ok))

(defmacro bold-yellow! (text)
  `(progn
     (io:format "~s" (list (xrepl-term-colour:apply ,text #m(fg yellow bold true))))
     'ok))

(defmacro bold-blue! (text)
  `(progn
     (io:format "~s" (list (xrepl-term-colour:apply ,text #m(fg blue bold true))))
     'ok))
```

### Testing Phase 4

Create test file: `test/colour-macro-test.lfe`

```lfe
(defmodule colour-macro-test
  (export (test 0)))

;; Include the DSL
(include-lib "xrepl_term/include/colours.lfe")

(defun test ()
  "Test colour macros."

  ;; Test pure macros
  (io:format "~nPure macros:~n")
  (io:format "~s~n" (list (red "Red text")))
  (io:format "~s~n" (list (bold "Bold text")))
  (io:format "~s~n" (list (bold-red "Bold red text")))

  ;; Test side-effect macros
  (io:format "~nSide-effect macros:~n")
  (red! "Red with side effect")
  (io:nl)
  (bold! "Bold with side effect")
  (io:nl)
  (bold-red! "Bold red with side effect")
  (io:nl)

  ;; Test threading (thread-first)
  (io:format "~nThreading test:~n")
  (io:format "~s~n"
    (list (clj:-> "Threaded text"
            (bold)
            (red))))

  ;; Test nested composition
  (io:format "~nNested composition:~n")
  (io:format "~s~n" (list (red (bold "Nested bold red"))))

  'ok)
```

Run test:

```bash
$ rebar3 lfe repl
1> (c "test/colour-macro-test.lfe")
2> (colour-macro-test:test)

Pure macros:
<red text appears>
<bold text appears>
<bold red text appears>

Side-effect macros:
<red text appears>
<bold text appears>
<bold red text appears>

Threading test:
<bold red text appears>

Nested composition:
<bold red text appears>

ok
```

**Success Criteria**:

- Pure macros return styled strings
- Side-effect macros print and return `ok`
- Threading with `clj:->` works correctly
- Nested composition works
- All text appears with correct styling

---

## Phase 5: Graphics Module (xrepl-term-graphics.lfe)

**Goal**: Refactor existing xrepl graphics code into library-first design.

### File: `src/xrepl-term-graphics.lfe`

```lfe
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
```

### 5.1 Protocol Detection

```lfe
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
```

### 5.2 High-Level Rendering

```lfe
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
```

### 5.3 Protocol Implementation

```lfe
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
      ((<= data-size chunk-size)
       (let ((control (if first?
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
```

### Testing Phase 5

```lfe
1> (c "src/xrepl-term-graphics.lfe")
#(module xrepl-term-graphics)

2> (xrepl-term-graphics:detect-protocol)
iterm2

3> (xrepl-term-graphics:supports-graphics?)
true

4> (xrepl-term-graphics:render-file "test.png")
{ok, displayed}
;; Image should appear

5> (xrepl-term-graphics:render-file "test.png" #m(width "50%"))
{ok, displayed}
;; Image at half width

6> (xrepl-term-graphics:render-file "missing.png")
{error, {file-not-found, "missing.png"}}

7> {ok, Data} = file:read_file("test.png").
8> (xrepl-term-graphics:render-data Data)
{ok, displayed}
```

**Success Criteria**:

- Protocol detection works correctly
- Images display in WezTerm/iTerm2/Kitty
- Width/height options are respected
- File not found errors handled gracefully
- Data rendering works same as file rendering
- All functions return proper tuples

---

## Phase 6: UI Components (xrepl-term-ui.lfe)

**Goal**: Implement tables, progress bars, and tree views.

### File: `src/xrepl-term-ui.lfe`

```lfe
(defmodule xrepl-term-ui
  "High-level UI components for terminal.

  Provides tables, progress bars, tree views, and other visual components."
  (export
   ;; Tables
   (table 1)
   (table 2)

   ;; Progress
   (progress 2)
   (progress 3)
   (spinner 2)

   ;; Trees
   (tree 1)
   (tree 2)))
```

### 6.1 Table Rendering

```lfe
(defun table (data)
  "Render table with default styling.

  Args:
    data: Map with:
      - headers: List of header strings
      - rows: List of row lists

  Returns:
    {ok, rendered}"
  (table data #m()))

(defun table (data opts)
  "Render table with options.

  Args:
    data: Map with headers and rows
    opts: Options map:
      - border: Border style (single, double, none)
      - padding: Cell padding (default 1)
      - header-style: Attribute map for headers

  Returns:
    {ok, rendered}"
  (let* ((headers (maps:get 'headers data '()))
         (rows (maps:get 'rows data '()))
         (border (maps:get 'border opts 'single))
         (padding (maps:get 'padding opts 1))
         (header-style (maps:get 'header-style opts #m(bold true))))

    ;; Calculate column widths
    (let* ((col-widths (calculate-column-widths headers rows))
           (border-chars (border-style-chars border)))

      ;; Render table
      (render-table-top border-chars col-widths padding)
      (render-table-headers headers col-widths padding header-style border-chars)
      (render-table-separator border-chars col-widths padding)
      (lists:foreach
        (lambda (row)
          (render-table-row row col-widths padding border-chars))
        rows)
      (render-table-bottom border-chars col-widths padding)
      (tuple 'ok 'rendered))))

(defun calculate-column-widths (headers rows)
  "Calculate width for each column."
  (let ((all-rows (cons headers rows)))
    (lists:foldl
      (lambda (row acc)
        (lists:zipwith
          (lambda (cell cur-width)
            (max (string:length (to-string cell)) cur-width))
          row
          acc))
      (lists:map (lambda (h) (string:length (to-string h))) headers)
      rows)))

(defun border-style-chars (style)
  "Get border characters for style."
  (case style
    ('single
     #m(tl "┌" tr "┐" bl "└" br "┘"
        h "─" v "│"
        mt "┬" mb "┴" ml "├" mr "┤"
        cross "┼"))
    ('double
     #m(tl "╔" tr "╗" bl "╚" br "╝"
        h "═" v "║"
        mt "╦" mb "╩" ml "╠" mr "╣"
        cross "╬"))
    ('none
     #m(tl " " tr " " bl " " br " "
        h " " v " "
        mt " " mb " " ml " " mr " "
        cross " "))))

(defun render-table-top (chars widths padding)
  "Render top border."
  (let ((h (maps:get 'h chars))
        (tl (maps:get 'tl chars))
        (tr (maps:get 'tr chars))
        (mt (maps:get 'mt chars))
        (pad (lists:duplicate padding h)))
    (io:put_chars tl)
    (io:put_chars
      (string:join
        (lists:map
          (lambda (w)
            (lists:duplicate (+ w (* 2 padding)) h))
          widths)
        mt))
    (io:put_chars tr)
    (io:nl)))

(defun render-table-headers (headers widths padding style chars)
  "Render header row."
  (let ((v (maps:get 'v chars))
        (pad-str (lists:duplicate padding #\space)))
    (io:put_chars v)
    (lists:foreach
      (lambda (header-width)
        (let ((header (lists:nth (+ (element 1 header-width) 1) headers))
              (width (element 2 header-width)))
          (io:put_chars pad-str)
          (io:put_chars
            (xrepl-term-colour:apply
              (pad-string (to-string header) width)
              style))
          (io:put_chars pad-str)
          (io:put_chars v)))
      (lists:zip (lists:seq 0 (- (length headers) 1)) widths))
    (io:nl)))

(defun render-table-separator (chars widths padding)
  "Render separator between header and rows."
  (let ((h (maps:get 'h chars))
        (ml (maps:get 'ml chars))
        (mr (maps:get 'mr chars))
        (cross (maps:get 'cross chars)))
    (io:put_chars ml)
    (io:put_chars
      (string:join
        (lists:map
          (lambda (w)
            (lists:duplicate (+ w (* 2 padding)) h))
          widths)
        cross))
    (io:put_chars mr)
    (io:nl)))

(defun render-table-row (row widths padding chars)
  "Render data row."
  (let ((v (maps:get 'v chars))
        (pad-str (lists:duplicate padding #\space)))
    (io:put_chars v)
    (lists:foreach
      (lambda (cell-width)
        (let ((cell (lists:nth (+ (element 1 cell-width) 1) row))
              (width (element 2 cell-width)))
          (io:put_chars pad-str)
          (io:put_chars (pad-string (to-string cell) width))
          (io:put_chars pad-str)
          (io:put_chars v)))
      (lists:zip (lists:seq 0 (- (length row) 1)) widths))
    (io:nl)))

(defun render-table-bottom (chars widths padding)
  "Render bottom border."
  (let ((h (maps:get 'h chars))
        (bl (maps:get 'bl chars))
        (br (maps:get 'br chars))
        (mb (maps:get 'mb chars)))
    (io:put_chars bl)
    (io:put_chars
      (string:join
        (lists:map
          (lambda (w)
            (lists:duplicate (+ w (* 2 padding)) h))
          widths)
        mb))
    (io:put_chars br)
    (io:nl)))

(defun pad-string (str width)
  "Pad string to width."
  (let ((len (string:length str)))
    (if (>= len width)
      (string:slice str 0 width)
      (++ str (lists:duplicate (- width len) #\space)))))

(defun to-string (value)
  "Convert value to string."
  (cond
    ((is_binary value) (binary_to_list value))
    ((is_list value) value)
    ((is_atom value) (atom_to_list value))
    ((is_integer value) (integer_to_list value))
    ((is_float value) (float_to_list value))
    ('true (lists:flatten (io_lib:format "~p" (list value))))))
```

### 6.2 Tree Rendering

```lfe
(defun tree (data)
  "Render tree structure with default styling.

  Args:
    data: Nested tuple/list structure:
      (root (child1 (grandchild1) (grandchild2)) (child2))

  Returns:
    {ok, rendered}"
  (tree data #m()))

(defun tree (data opts)
  "Render tree with options.

  Args:
    data: Tree structure
    opts: Options map:
      - style: Branch style (single, double)

  Returns:
    {ok, rendered}"
  (let ((style (maps:get 'style opts 'single)))
    (render-tree-node data "" style 'true)
    (tuple 'ok 'rendered)))

(defun render-tree-node (node prefix style is-last?)
  "Recursively render tree node."
  (let ((chars (tree-style-chars style))
        (branch (if is-last?
                  (maps:get 'last-branch chars)
                  (maps:get 'branch chars)))
        (cont (if is-last?
                (maps:get 'last-cont chars)
                (maps:get 'cont chars))))
    (cond
      ;; Leaf node (atom or string)
      ((orelse (is_atom node) (is_list node))
       (io:format "~s~s ~s~n" (list prefix branch (to-string node))))

      ;; Branch node (tuple)
      ((is_tuple node)
       (let ((label (element 1 node))
             (children (tl (tuple_to_list node))))
         (io:format "~s~s ~s~n" (list prefix branch (to-string label)))
         (render-tree-children children (++ prefix cont) style)))

      ;; List node
      ((is_list node)
       (case node
         ('() 'ok)
         ((cons label children)
          (io:format "~s~s ~s~n" (list prefix branch (to-string label)))
          (render-tree-children children (++ prefix cont) style)))))))

(defun render-tree-children (children prefix style)
  "Render list of child nodes."
  (let ((num-children (length children)))
    (lists:foldl
      (lambda (child idx)
        (let ((is-last? (== idx (- num-children 1))))
          (render-tree-node child prefix style is-last?)
          (+ idx 1)))
      0
      children)))

(defun tree-style-chars (style)
  "Get tree drawing characters for style."
  (case style
    ('single
     #m(branch "├── "
        last-branch "└── "
        cont "│   "
        last-cont "    "))
    ('double
     #m(branch "╠══ "
        last-branch "╚══ "
        cont "║   "
        last-cont "    "))))
```

### 6.3 Progress Indicators

```lfe
(defun progress (fraction label)
  "Display progress bar.

  Args:
    fraction: Float between 0.0 and 1.0
    label: Label text

  Returns:
    {ok, displayed}"
  (progress fraction label #m()))

(defun progress (fraction label opts)
  "Display progress bar with options.

  Args:
    fraction: Progress (0.0 to 1.0)
    label: Label text
    opts: Options map:
      - width: Bar width in characters (default 40)
      - filled-char: Character for filled portion (default '█')
      - empty-char: Character for empty portion (default '░')
      - show-percent: Show percentage (default true)

  Returns:
    {ok, displayed}"
  (let* ((width (maps:get 'width opts 40))
         (filled-char (maps:get 'filled-char opts #\█))
         (empty-char (maps:get 'empty-char opts #\░))
         (show-percent (maps:get 'show-percent opts 'true))
         (filled (round (* fraction width)))
         (empty (- width filled))
         (bar (++ (lists:duplicate filled filled-char)
                  (lists:duplicate empty empty-char)))
         (percent (round (* fraction 100))))
    (io:format "\r~s [~s]" (list label bar))
    (when show-percent
      (io:format " ~p%" (list percent)))
    (tuple 'ok 'displayed)))

(defun spinner (label fun)
  "Show spinner while executing function.

  NOTE: This is a simplified implementation. A production version
  would need concurrent animation while fun executes.

  Args:
    label: Label text
    fun: Zero-arity function to execute

  Returns:
    {ok, result} | {error, reason}"
  (try
    (io:format "~s ... " (list label))
    (let ((result (funcall fun)))
      (io:format "done~n")
      (tuple 'ok result))
    (catch
      ((tuple _class reason _stack)
       (io:format "failed~n")
       (tuple 'error reason)))))
```

### Testing Phase 6

Create test file: `test/ui-test.lfe`

```lfe
(defmodule ui-test
  (export (test 0)))

(include-lib "xrepl_term/include/colours.lfe")

(defun test ()
  "Test UI components."

  ;; Test table
  (io:format "~nTable test:~n")
  (xrepl-term-ui:table
    #m(headers '("Name" "Age" "City")
       rows '(("Alice" 30 "NYC")
              ("Bob" 25 "SF")
              ("Charlie" 35 "LA"))))

  ;; Test table with custom styling
  (io:format "~nStyled table:~n")
  (xrepl-term-ui:table
    #m(headers '("Status" "Count")
       rows '(("Active" 42)
              ("Pending" 15)
              ("Failed" 3)))
    #m(border double
       header-style #m(fg cyan bold true)))

  ;; Test tree
  (io:format "~nTree test:~n")
  (xrepl-term-ui:tree
    '(project
       (src
         (main.lfe)
         (utils.lfe))
       (test
         (main-tests.lfe))
       (README.md)))

  ;; Test progress bar
  (io:format "~nProgress test:~n")
  (lists:foreach
    (lambda (p)
      (xrepl-term-ui:progress p "Processing")
      (timer:sleep 200))
    '(0.0 0.2 0.4 0.6 0.8 1.0))
  (io:nl)

  'ok)
```

Run test:

```bash
$ rebar3 lfe repl
1> (c "test/ui-test.lfe")
2> (ui-test:test)

Table test:
┌───────────┬───────┬───────┐
│ Name      │ Age   │ City  │
├───────────┼───────┼───────┤
│ Alice     │ 30    │ NYC   │
│ Bob       │ 25    │ SF    │
│ Charlie   │ 35    │ LA    │
└───────────┴───────┴───────┘

Styled table:
╔══════════╦═══════╗
║ Status   ║ Count ║
╠══════════╬═══════╣
║ Active   ║ 42    ║
║ Pending  ║ 15    ║
║ Failed   ║ 3     ║
╚══════════╩═══════╝

Tree test:
└── project
    ├── src
    │   ├── main.lfe
    │   └── utils.lfe
    ├── test
    │   └── main-tests.lfe
    └── README.md

Progress test:
Processing [                                        ] 0%
Processing [████████                                ] 20%
Processing [████████████████                        ] 40%
Processing [████████████████████████                ] 60%
Processing [████████████████████████████████        ] 80%
Processing [████████████████████████████████████████] 100%

ok
```

**Success Criteria**:

- Tables render with proper borders
- Column widths auto-calculate
- Different border styles work
- Header styling applies correctly
- Trees render with proper branching
- Progress bars animate smoothly
- All functions return proper tuples

---

## Phase 7: Testing Suite

**Goal**: Implement comprehensive tests for all modules.

### 7.1 Core Terminal Tests

File: `test/xrepl-term-tests.lfe`

```lfe
(defmodule xrepl-term-tests
  (behaviour ltest-unit)
  (export all))

(include-lib "ltest/include/ltest-macros.lfe")

(deftest detect-terminal
  (is (is_atom (xrepl-term:detect-terminal))))

(deftest terminal-info
  (let ((info (xrepl-term:terminal-info)))
    (is (is_map info))
    (is (maps:is_key 'terminal info))
    (is (maps:is_key 'term info))))

(deftest capabilities
  (let ((caps (xrepl-term:capabilities)))
    (is (is_map caps))
    (is (maps:is_key 'graphics caps))
    (is (maps:is_key 'hyperlinks caps))
    (is (maps:is_key 'true-colour caps))))

(deftest supports-check
  (is (is_boolean (xrepl-term:supports? 'graphics)))
  (is (is_boolean (xrepl-term:supports? 'hyperlinks)))
  (is (is_boolean (xrepl-term:supports? 'true-colour))))

(deftest terminal-control
  ;; These just verify they don't crash
  (is (== 'ok (xrepl-term:clear-line)))
  (is (== 'ok (xrepl-term:bell)))
  (is (== 'ok (xrepl-term:cursor-hide)))
  (is (== 'ok (xrepl-term:cursor-show))))

(deftest hyperlinks
  (case (xrepl-term:link "https://lfe.io" "LFE")
    (`#(ok ,link)
     (is (is_list link))
     (is (=/= (string:find link "https://lfe.io") 'nomatch)))
    (`#(error not-supported)
     ;; Terminal doesn't support links, that's OK
     'ok)))

(deftest terminal-size
  (case (xrepl-term:terminal-size)
    (`#(ok #(,cols ,rows))
     (is (is_integer cols))
     (is (is_integer rows))
     (is (> cols 0))
     (is (> rows 0)))
    (_ 'ok))) ;; IO might not be available in test

(deftest with-alt-screen
  (let ((result (xrepl-term:with-alt-screen
                  (lambda () 42))))
    (is-equal `#(ok 42) result)))
```

### 7.2 Colour Tests

File: `test/xrepl-term-colour-tests.lfe`

```lfe
(defmodule xrepl-term-colour-tests
  (behaviour ltest-unit)
  (export all))

(include-lib "ltest/include/ltest-macros.lfe")

(deftest apply-single-attribute
  (let ((result (xrepl-term-colour:apply "text" #m(bold true))))
    (is (is_list result))
    (is (=/= (string:find result "\e[1m") 'nomatch))
    (is (=/= (string:find result "\e[0m") 'nomatch))))

(deftest apply-colour
  (let ((result (xrepl-term-colour:apply "text" #m(fg red))))
    (is (=/= (string:find result "\e[31m") 'nomatch))))

(deftest apply-combined
  (let ((result (xrepl-term-colour:apply "text"
                  #m(fg red bold true underline true))))
    ;; Should contain bold (1), underline (4), and red (31)
    (is (=/= (string:find result "1;") 'nomatch))
    (is (=/= (string:find result "4;") 'nomatch))
    (is (=/= (string:find result "31") 'nomatch))))

(deftest sgr-codes-generation
  (is-equal "31"
    (xrepl-term-colour:sgr-codes #m(fg red)))
  (is-equal "1;31"
    (xrepl-term-colour:sgr-codes #m(fg red bold true)))
  (is-equal ""
    (xrepl-term-colour:sgr-codes #m())))

(deftest strip-ansi-codes
  (let ((styled (xrepl-term-colour:apply "Hello" #m(fg red bold true))))
    (is-equal "Hello" (xrepl-term-colour:strip-ansi styled))))

(deftest visual-length
  (let ((styled (xrepl-term-colour:apply "Hello" #m(fg red))))
    (is-equal 5 (xrepl-term-colour:visual-length styled))))

(deftest colour-codes
  ;; Test basic colours
  (is-equal "30" (xrepl-term-colour:colour-to-fg-code 'black))
  (is-equal "31" (xrepl-term-colour:colour-to-fg-code 'red))
  (is-equal "32" (xrepl-term-colour:colour-to-fg-code 'green))

  ;; Test bright colours
  (is-equal "91" (xrepl-term-colour:colour-to-fg-code 'bright-red))

  ;; Test 256 colour
  (is-equal "38;5;196" (xrepl-term-colour:colour-to-fg-code 196))

  ;; Test background
  (is-equal "40" (xrepl-term-colour:colour-to-bg-code 'black))
  (is-equal "48;5;196" (xrepl-term-colour:colour-to-bg-code 196)))
```

### 7.3 Graphics Tests

File: `test/xrepl-term-graphics-tests.lfe`

```lfe
(defmodule xrepl-term-graphics-tests
  (behaviour ltest-unit)
  (export all))

(include-lib "ltest/include/ltest-macros.lfe")

(deftest detect-protocol
  (let ((protocol (xrepl-term-graphics:detect-protocol)))
    (is (lists:member protocol '(iterm2 kitty none)))))

(deftest supports-graphics
  (is (is_boolean (xrepl-term-graphics:supports-graphics?))))

(deftest iterm2-sequence-generation
  (let ((test-data (binary "fake-image-data")))
    (case (xrepl-term-graphics:iterm2-sequence test-data #m())
      (`#(ok ,seq)
       (is (is_binary seq))
       (is (=/= (binary:match seq (binary "\e]1337;File=")) 'nomatch)))
      (`#(error ,_) 'ok))))

(deftest kitty-sequence-generation
  (let ((test-data (binary "fake-image-data")))
    (case (xrepl-term-graphics:kitty-sequence test-data #m())
      (`#(ok ,seq)
       (is (is_binary seq))
       (is (=/= (binary:match seq (binary "\e_G")) 'nomatch)))
      (`#(error ,_) 'ok))))

(deftest render-missing-file
  (case (xrepl-term-graphics:render-file "/nonexistent/file.png")
    (`#(error #(file-not-found ,_))
     'ok)
    (other
     (error (tuple 'unexpected-result other)))))
```

### 7.4 Property-Based Tests

File: `test/xrepl-term-colour-proper.lfe`

```lfe
(defmodule xrepl-term-colour-proper
  (export (prop-strip-ansi 0)
          (prop-visual-length 0)))

(include-lib "proper/include/proper.hrl")

(defun prop-strip-ansi ()
  "Property: Stripping ANSI codes from styled text returns original text."
  (proper:forall
    (text (proper_types:non_empty (proper_types:string)))
    (let* ((attrs #m(fg red bold true))
           (styled (xrepl-term-colour:apply text attrs))
           (stripped (xrepl-term-colour:strip-ansi styled)))
      (== stripped text))))

(defun prop-visual-length ()
  "Property: Visual length equals actual length after stripping."
  (proper:forall
    (text (proper_types:non_empty (proper_types:string)))
    (let* ((attrs #m(fg blue underline true))
           (styled (xrepl-term-colour:apply text attrs))
           (vis-len (xrepl-term-colour:visual-length styled))
           (actual-len (string:length text)))
      (== vis-len actual-len))))
```

### Running Tests

```bash
# Run unit tests
$ rebar3 lfe test

# Run with coverage
$ rebar3 as test coverage

# Run property-based tests
$ rebar3 as test proper

# Run all checks
$ rebar3 as test check
```

**Success Criteria**:

- All unit tests pass
- Property-based tests pass (100+ iterations)
- Code coverage > 80%
- No warnings or errors during compilation

---

## Phase 8: Examples and Documentation

**Goal**: Create comprehensive examples and usage documentation.

### 8.1 Basic Colours Example

File: `examples/basic-colours.lfe`

```lfe
(defmodule basic-colours
  (export (demo 0)))

(include-lib "xrepl_term/include/colours.lfe")

(defun demo ()
  "Demonstrate basic colour functionality."

  (io:format "~n=== Basic Colours ===~n~n")

  ;; Pure macros
  (io:format "Pure macros (return strings):~n")
  (io:format "  ~s~n" (list (red "Red text")))
  (io:format "  ~s~n" (list (green "Green text")))
  (io:format "  ~s~n" (list (blue "Blue text")))

  ;; Side-effect macros
  (io:format "~nSide-effect macros (print directly):~n  ")
  (red! "Red ")
  (green! "Green ")
  (blue! "Blue")
  (io:nl)

  ;; Styles
  (io:format "~nStyles:~n")
  (io:format "  ~s~n" (list (bold "Bold")))
  (io:format "  ~s~n" (list (italic "Italic")))
  (io:format "  ~s~n" (list (underline "Underline")))

  ;; Combined
  (io:format "~nCombined:~n")
  (io:format "  ~s~n" (list (bold-red "Bold Red")))
  (io:format "  ~s~n" (list (red (bold "Nested Bold Red"))))

  ;; Threading
  (io:format "~nThreading (clj:->):~n")
  (io:format "  ~s~n"
    (list (clj:-> "Threaded text"
            (bold)
            (underline)
            (cyan))))

  ;; 256 colours
  (io:format "~n256 Colours:~n")
  (io:format "  ~s~n" (list (fg 196 "Bright red (196)")))
  (io:format "  ~s~n" (list (fg 46 "Bright green (46)")))
  (io:format "  ~s~n" (list (bg 17 (fg 226 "Yellow on dark blue"))))

  'ok)
```

### 8.2 Image Demo

File: `examples/image-demo.lfe`

```lfe
(defmodule image-demo
  (export (demo 0) (demo 1)))

(defun demo ()
  "Check if graphics are supported."
  (case (xrepl-term-graphics:supports-graphics?)
    ('true
     (io:format "✓ Graphics supported!~n")
     (io:format "Protocol: ~p~n" (list (xrepl-term-graphics:detect-protocol)))
     (io:format "~nTry: (image-demo:demo \"path/to/image.png\")~n"))
    ('false
     (io:format "✗ Graphics not supported in this terminal~n")
     (io:format "Supported terminals: WezTerm, iTerm2, Kitty~n"))))

(defun demo (filepath)
  "Display image with various options."
  (io:format "~n=== Image Demo ===~n~n")

  ;; Full size
  (io:format "Full size:~n")
  (case (xrepl-term-graphics:render-file filepath)
    (`#(ok displayed)
     (io:format "✓ Displayed~n~n"))
    (`#(error ,reason)
     (io:format "✗ Error: ~p~n~n" (list reason))))

  ;; Half width
  (io:format "50% width:~n")
  (xrepl-term-graphics:render-file filepath #m(width "50%"))
  (io:nl)

  ;; Fixed size
  (io:format "Fixed size (80x24 cells):~n")
  (xrepl-term-graphics:render-file filepath #m(width "80" height "24"))
  (io:nl)

  'ok)
```

### 8.3 Table Demo

File: `examples/table-demo.lfe`

```lfe
(defmodule table-demo
  (export (demo 0)))

(include-lib "xrepl_term/include/colours.lfe")

(defun demo ()
  "Demonstrate table rendering."

  (io:format "~n=== Table Demo ===~n~n")

  ;; Simple table
  (io:format "Simple table:~n")
  (xrepl-term-ui:table
    #m(headers '("Name" "Role" "Active")
       rows '(("Alice" "Developer" "Yes")
              ("Bob" "Designer" "Yes")
              ("Charlie" "Manager" "No"))))

  ;; Double border
  (io:format "~nDouble border:~n")
  (xrepl-term-ui:table
    #m(headers '("ID" "Status" "Count")
       rows '((1 "OK" 142)
              (2 "Warning" 5)
              (3 "Error" 0)))
    #m(border double))

  ;; Styled headers
  (io:format "~nStyled headers:~n")
  (xrepl-term-ui:table
    #m(headers '("Metric" "Value" "Change")
       rows '(("CPU" "45%" "+2%")
              ("Memory" "78%" "-1%")
              ("Disk" "62%" "+5%")))
    #m(border single
       header-style #m(fg cyan bold true)))

  ;; No border
  (io:format "~nNo border (plain):~n")
  (xrepl-term-ui:table
    #m(headers '("Item" "Quantity")
       rows '(("Apples" 5)
              ("Oranges" 3)))
    #m(border none))

  'ok)
```

### 8.4 Tree Demo

File: `examples/tree-demo.lfe`

```lfe
(defmodule tree-demo
  (export (demo 0)))

(defun demo ()
  "Demonstrate tree rendering."

  (io:format "~n=== Tree Demo ===~n~n")

  ;; Project structure
  (io:format "Project structure:~n")
  (xrepl-term-ui:tree
    '(xrepl-term
       (src
         (xrepl-term.lfe)
         (xrepl-term-colour.lfe)
         (xrepl-term-graphics.lfe)
         (xrepl-term-ui.lfe))
       (include
         (colours.lfe))
       (test
         (xrepl-term-tests.lfe))
       (examples
         (basic-colours.lfe)
         (table-demo.lfe))
       (README.md)
       (rebar.config)))

  ;; Double-line style
  (io:format "~nDouble-line style:~n")
  (xrepl-term-ui:tree
    '(filesystem
       (home
         (user
           (documents)
           (downloads)))
       (etc
         (config.d))
       (var
         (log)))
    #m(style double))

  'ok)
```

### 8.5 Update README with Examples

Add to `README.md`:

````markdown
## Examples

### Basic Colours

```lfe
(include-lib "xrepl_term/include/colours.lfe")

;; Simple colours
(io:format "~s~n" (list (red "Error message")))
(io:format "~s~n" (list (green "Success!")))

;; Styles
(io:format "~s~n" (list (bold "Important")))
(io:format "~s~n" (list (underline "Link")))

;; Combined
(io:format "~s~n" (list (bold-red "Critical Error")))

;; Threading
(clj:-> "Status"
  (bold)
  (green)
  (list)
  (io:format "~s~n"))
```

### Terminal Graphics

```lfe
;; Check support
(xrepl-term-graphics:supports-graphics?)  ;; true/false

;; Display image
(xrepl-term-graphics:render-file "chart.png")

;; With options
(xrepl-term-graphics:render-file "photo.jpg"
  #m(width "50%" height "auto"))
```

### Tables

```lfe
(xrepl-term-ui:table
  #m(headers '("Name" "Age" "City")
     rows '(("Alice" 30 "NYC")
            ("Bob" 25 "SF"))))
```

### Tree Views

```lfe
(xrepl-term-ui:tree
  '(project
     (src
       (main.lfe)
       (util.lfe))
     (test
       (tests.lfe))))
```

### Terminal Control

```lfe
;; Hyperlinks
(case (xrepl-term:link "https://lfe.io" "Visit LFE")
  (`#(ok ,link) (io:format "~s~n" (list link))))

;; Notifications
(xrepl-term:notify "Build Complete" "Compiled successfully")

;; Progress
(xrepl-term-ui:progress 0.75 "Processing")
```

## API Reference

### xrepl-term

Core terminal control and capabilities.

- `detect-terminal/0` - Detect terminal type
- `capabilities/0` - Get terminal capabilities map
- `supports?/1` - Check specific capability
- `set-title/1` - Set window/tab title
- `link/2, link/3` - Create hyperlinks
- `notify/1, notify/2` - Desktop notifications
- `cursor-hide/0, cursor-show/0` - Cursor visibility
- `with-alt-screen/1` - Execute in alternate screen

### xrepl-term-colour

ANSI colour and styling.

- `apply/2` - Apply attributes to text
- `reset/1` - Reset all attributes
- `strip-ansi/1` - Remove ANSI codes
- `visual-length/1` - Calculate display length

### xrepl-term-graphics

Terminal graphics protocols.

- `render-file/1, render-file/2` - Display image file
- `render-data/1, render-data/2` - Display image data
- `supports-graphics?/0` - Check graphics support
- `detect-protocol/0` - Get available protocol

### xrepl-term-ui

UI components.

- `table/1, table/2` - Render tables
- `tree/1, tree/2` - Render tree structures
- `progress/2, progress/3` - Progress bars
- `spinner/2` - Animated spinner

### Colour DSL Macros

Include with: `(include-lib "xrepl_term/include/colours.lfe")`

**Pure macros** (return strings):
- Style: `bold`, `italic`, `underline`, `dim`, `strike`
- Colours: `red`, `green`, `blue`, `yellow`, `cyan`, `magenta`, `white`, `black`
- Bright: `bright-red`, `bright-green`, etc.
- Generic: `fg`, `bg` (with colour name or 0-255 number)
- Combined: `bold-red`, `bold-green`, `bold-yellow`, `bold-blue`

**Side-effect macros** (print and return ok):
All pure macros have `!` variants: `red!`, `bold!`, `fg!`, etc.

## Running Examples

```bash
$ rebar3 lfe repl
1> (c "examples/basic-colours.lfe")
2> (basic-colours:demo)

1> (c "examples/table-demo.lfe")
2> (table-demo:demo)

1> (c "examples/tree-demo.lfe")
2> (tree-demo:demo)

1> (c "examples/image-demo.lfe")
2> (image-demo:demo "path/to/image.png")
```
````

---

## Phase 9: Final Integration and Polish

**Goal**: Ensure everything compiles, tests pass, and documentation is complete.

### 9.1 Verify Project Structure

```bash
github.com/xrepl/term/
├── rebar.config                 ✓
├── README.md                    ✓
├── LICENSE                      ✓
├── src/
│   ├── xrepl_term.app.src      ✓
│   ├── xrepl-term.lfe          ✓
│   ├── xrepl-term-colour.lfe   ✓
│   ├── xrepl-term-graphics.lfe ✓
│   └── xrepl-term-ui.lfe       ✓
├── include/
│   └── colours.lfe             ✓
├── test/
│   ├── xrepl-term-tests.lfe           ✓
│   ├── xrepl-term-colour-tests.lfe    ✓
│   ├── xrepl-term-graphics-tests.lfe  ✓
│   └── xrepl-term-colour-proper.lfe   ✓
└── examples/
    ├── basic-colours.lfe       ✓
    ├── image-demo.lfe          ✓
    ├── table-demo.lfe          ✓
    └── tree-demo.lfe           ✓
```

### 9.2 Compilation Checklist

```bash
# Clean build
$ rebar3 clean
$ rebar3 compile
# Should compile with no errors or warnings

# Run all tests
$ rebar3 lfe test
# All tests should pass

# Check code coverage
$ rebar3 as test coverage
# Should report >80% coverage

# Run property tests
$ rebar3 as test proper
# Should pass 100+ test cases
```

### 9.3 Manual Testing Checklist

In LFE REPL:

```lfe
;; Terminal detection
1> (xrepl-term:detect-terminal)
wezterm  ;; or iterm2, kitty

;; Colours
2> (include-lib "xrepl_term/include/colours.lfe")
3> (io:format "~s~n" (list (bold-red "Test")))
;; Should display bold red text

;; Threading
4> (clj:-> "Hello" (bold) (cyan) (list) (io:format "~s~n"))
;; Should display bold cyan text

;; Table
5> (xrepl-term-ui:table
     #m(headers '("A" "B") rows '((1 2) (3 4))))
;; Should render table

;; Tree
6> (xrepl-term-ui:tree '(root (child1) (child2)))
;; Should render tree

;; Graphics (if supported)
7> (xrepl-term-graphics:render-file "test.png")
;; Should display image or return error
```

### 9.4 Documentation Checklist

- [ ] README.md is complete
- [ ] API reference is accurate
- [ ] Examples work correctly
- [ ] Installation instructions are clear
- [ ] LICENSE is present
- [ ] CHANGELOG.md created (if needed)

---

## Completion Checklist

### Phase Completion

- [ ] Phase 1: Project scaffolding complete
- [ ] Phase 2: Core terminal module implemented and tested
- [ ] Phase 3: ANSI colour implementation working
- [ ] Phase 4: Colour DSL macros functional
- [ ] Phase 5: Graphics module implemented
- [ ] Phase 6: UI components (tables, trees) working
- [ ] Phase 7: Test suite passing
- [ ] Phase 8: Examples and documentation complete
- [ ] Phase 9: Final integration verified

### Quality Gates

- [ ] All modules compile without warnings
- [ ] All unit tests pass
- [ ] Property-based tests pass
- [ ] Code coverage >80%
- [ ] Manual testing in WezTerm successful
- [ ] Manual testing in iTerm2 successful (if available)
- [ ] Manual testing in Kitty successful (if available)
- [ ] README examples all work
- [ ] No hardcoded paths or system-specific code

### Release Readiness

- [ ] Version number set in .app.src
- [ ] Git repository initialized
- [ ] Initial commit made
- [ ] Tagged with v0.1.0
- [ ] Pushed to GitHub
- [ ] README displays correctly on GitHub
- [ ] Can be installed via rebar3 from GitHub

---

## Implementation Notes

### Key Design Decisions

1. **apply/reset nomenclature**: Matches ANSI specification rather than inventing new terms
2. **Tuple returns**: All functions return `{ok, result}` or `{error, reason}` for consistent error handling
3. **Map-based attributes**: Colour attributes use maps for clarity and extensibility
4. **Pure vs side-effect macros**: `!` suffix denotes side effects (printing)
5. **Threading support**: Designed for `clj:->` (thread-first) style
6. **Library-first graphics**: Refactored from xrepl for general use

### Performance Considerations

- SGR codes are generated once per `apply/2` call
- No unnecessary string concatenation
- Binary operations where appropriate
- Minimal overhead for colour operations

### Compatibility Notes

- Requires LFE 2.1+ for map literal syntax
- Uses standard Erlang/OTP libraries only
- No external dependencies except PropEr for testing
- Works with any BEAM-compatible system

### Future Enhancements

**Short-term** (v0.2):

- Add colour composition support for threading
- Implement `unapply` for selective attribute removal
- Add more UI components (menus, forms)
- Sixel graphics protocol support

**Medium-term** (v0.3):

- RGB colour support for true-colour terminals
- Colour schemes/themes
- Terminal emulation detection improvements
- Animation support for progress indicators

**Long-term** (v1.0):

- Full TUI framework capabilities
- Event handling (keyboard, mouse)
- Layout engine
- Widget library

---

## Troubleshooting

### Common Issues

**Issue**: Colours don't display

- Check `$TERM` environment variable
- Verify terminal supports ANSI colours
- Try `echo -e "\e[31mRed\e[0m"` in shell

**Issue**: Images don't display

- Verify terminal type: `(xrepl-term:detect-terminal)`
- Check graphics support: `(xrepl-term-graphics:supports-graphics?)`
- Ensure image file exists and is readable

**Issue**: Tables render incorrectly

- Check terminal supports Unicode box-drawing
- Try different border style: `#m(border single)` or `#m(border none)`
- Verify terminal width is sufficient

**Issue**: Macros not found

- Ensure `(include-lib "xrepl_term/include/colours.lfe")` is present
- Check that xrepl_term is in dependencies
- Run `rebar3 compile` to ensure includes are available

### Debug Mode

Enable verbose output:

```lfe
;; Show terminal capabilities
(io:format "~p~n" (list (xrepl-term:capabilities)))

;; Show terminal info
(io:format "~p~n" (list (xrepl-term:terminal-info)))

;; Test colour codes
(io:format "~p~n" (list (xrepl-term-colour:sgr-codes #m(fg red bold true))))
```

---

## Summary

This implementation plan provides comprehensive, step-by-step instructions for creating the **xrepl-term** library. The library offers:

- ✅ Proper ANSI colour support with `apply/reset` nomenclature
- ✅ LFE-idiomatic DSL via include file macros
- ✅ Terminal graphics (iTerm2, Kitty, Sixel)
- ✅ UI components (tables, progress bars, trees)
- ✅ Comprehensive test suite (unit + property-based)
- ✅ Full documentation and examples
- ✅ Zero external dependencies (pure Erlang/LFE)

Each phase is self-contained with clear success criteria, making it straightforward for Claude Code to implement incrementally. The library follows LFE idioms, respects ANSI specifications, and provides excellent developer experience through well-designed APIs and helpful error messages.

**Estimated implementation time**: 12-16 hours across all phases.

🎩 **Cheerio, and happy hacking!**
