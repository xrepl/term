(defmodule basic-colours
  (export (demo 0)))

(include-lib "xrepl_term/include/colours.lfe")

(defun demo ()
  "Demonstrate basic colour functionality."

  (io:format "~n=== Basic Colours Demo ===~n~n")

  ;; Basic foreground colours
  (io:format "Foreground colours:~n")
  (io:format "~s~n" (list (red "Red text")))
  (io:format "~s~n" (list (green "Green text")))
  (io:format "~s~n" (list (yellow "Yellow text")))
  (io:format "~s~n" (list (blue "Blue text")))
  (io:format "~s~n" (list (magenta "Magenta text")))
  (io:format "~s~n" (list (cyan "Cyan text")))
  (io:format "~s~n" (list (white "White text")))

  ;; Bright colours
  (io:format "~nBright colours:~n")
  (io:format "~s~n" (list (bright-red "Bright red")))
  (io:format "~s~n" (list (bright-green "Bright green")))
  (io:format "~s~n" (list (bright-yellow "Bright yellow")))
  (io:format "~s~n" (list (bright-blue "Bright blue")))

  ;; Styles
  (io:format "~nStyles:~n")
  (io:format "~s~n" (list (bold "Bold text")))
  (io:format "~s~n" (list (italic "Italic text")))
  (io:format "~s~n" (list (underline "Underlined text")))
  (io:format "~s~n" (list (strike "Strikethrough text")))

  ;; Combined styles
  (io:format "~nCombined styles:~n")
  (io:format "~s~n" (list (bold-red "Bold red text")))
  (io:format "~s~n" (list (bold-green "Bold green text")))

  ;; Threading example
  (io:format "~nThreading with clj:->:~n")
  (io:format "~s~n"
    (list (clj:-> "Threaded styled text"
            (bold)
            (cyan)
            (underline))))

  ;; Background colours
  (io:format "~nWith background:~n")
  (io:format "~s~n"
    (list (xrepl-term-colour:apply "Red on black"
            #m(fg red bg black))))

  (io:format "~n"))
