(defmodule tree-demo
  (export (demo 0)))

(defun demo ()
  "Demonstrate tree rendering."

  (io:format "~n=== Tree Demo ===~n~n")

  ;; Project structure tree
  (io:format "Project structure (single line style):~n")
  (xrepl-term-ui:tree
    '(xrepl-term
       (src
         (xrepl-term.lfe)
         (xrepl-term-colour.lfe)
         (xrepl-term-graphics.lfe)
         (xrepl-term-ui.lfe))
       (test
         (xrepl-term-tests.lfe)
         (xrepl-term-colour-tests.lfe))
       (include
         (colours.lfe))
       (README.md)
       (LICENSE)))

  ;; Tree with double line style
  (io:format "~nFile system (double line style):~n")
  (xrepl-term-ui:tree
    '(home
       (documents
         (work
           (report.pdf)
           (presentation.pptx))
         (personal
           (photo.jpg)))
       (downloads
         (file1.zip)
         (file2.tar.gz)))
    #m(style double))

  ;; Simple hierarchy
  (io:format "~nOrganization chart:~n")
  (xrepl-term-ui:tree
    '(CEO
       (CTO
         (Dev-Team-Lead
           (Developer-1)
           (Developer-2))
         (QA-Team-Lead
           (QA-Engineer)))
       (CFO
         (Accountant)
         (Financial-Analyst))))

  (io:format "~n"))
