(defmodule table-demo
  (export (demo 0)))

(defun demo ()
  "Demonstrate table rendering."

  (io:format "~n=== Table Demo ===~n~n")

  ;; Simple table with default styling
  (io:format "Simple table (single border):~n")
  (xrepl-term-ui:table
    #m(headers '("Name" "Age" "City")
       rows '(("Alice" 30 "NYC")
              ("Bob" 25 "SF")
              ("Charlie" 35 "LA"))))

  ;; Table with double border
  (io:format "~nTable with double border:~n")
  (xrepl-term-ui:table
    #m(headers '("Status" "Count" "Percentage")
       rows '(("Active" 42 "75%")
              ("Pending" 15 "25%")
              ("Failed" 3 "5%")))
    #m(border double))

  ;; Table with custom header styling
  (io:format "~nTable with styled headers:~n")
  (xrepl-term-ui:table
    #m(headers '("Product" "Price" "Stock")
       rows '(("Widget" "$10.99" 42)
              ("Gadget" "$25.50" 18)
              ("Gizmo" "$5.99" 105)))
    #m(border single
       header-style #m(fg cyan bold true)))

  ;; Table without borders
  (io:format "~nTable without borders:~n")
  (xrepl-term-ui:table
    #m(headers '("Key" "Value")
       rows '(("Version" "0.1.0")
              ("Author" "LFE Team")
              ("License" "Apache-2.0")))
    #m(border none))

  (io:format "~n"))
