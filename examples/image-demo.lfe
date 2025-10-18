(defmodule image-demo
  (export (demo 0)))

(defun demo ()
  "Demonstrate image rendering (if supported)."

  (io:format "~n=== Image Demo ===~n~n")

  ;; Check if graphics are supported
  (case (xrepl-term-graphics:supports-graphics?)
    ('true
     (io:format "Terminal supports graphics!~n")
     (io:format "Protocol: ~p~n~n" (list (xrepl-term-graphics:detect-protocol)))

     ;; Note: This demo shows the API, but won't actually display
     ;; without a real image file
     (io:format "Example usage:~n")
     (io:format "  (xrepl-term-graphics:render-file \"image.png\")~n")
     (io:format "  (xrepl-term-graphics:render-file \"logo.png\" #m(width \"50%\"))~n")
     (io:format "~nTo test with a real image:~n")
     (io:format "  1. Place an image file in this directory~n")
     (io:format "  2. Call: (xrepl-term-graphics:render-file \"your-image.png\")~n"))

    ('false
     (io:format "Graphics not supported in this terminal.~n")
     (io:format "Terminal: ~p~n" (list (xrepl-term:detect-terminal)))
     (io:format "~nSupported terminals: WezTerm, iTerm2, Kitty~n")))

  (io:format "~n"))
