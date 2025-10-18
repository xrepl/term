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
