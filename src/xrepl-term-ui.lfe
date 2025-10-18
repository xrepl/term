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

;;; Table Rendering

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
        (mt (maps:get 'mt chars)))
    (io:put_chars tl)
    (io:put_chars
      (string:join
        (lists:map
          (lambda (w)
            (string:copies h (+ w (* 2 padding))))
          widths)
        mt))
    (io:put_chars tr)
    (io:nl)))

(defun render-table-headers (headers widths padding style chars)
  "Render header row."
  (let ((v (maps:get 'v chars))
        (pad-str (string:copies " " padding)))
    (io:put_chars v)
    (lists:foreach
      (lambda (idx)
        (let ((header (lists:nth (+ idx 1) headers))
              (width (lists:nth (+ idx 1) widths)))
          (io:put_chars pad-str)
          (io:put_chars
            (xrepl-term-colour:apply
              (pad-string (to-string header) width)
              style))
          (io:put_chars pad-str)
          (io:put_chars v)))
      (lists:seq 0 (- (length headers) 1)))
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
            (string:copies h (+ w (* 2 padding))))
          widths)
        cross))
    (io:put_chars mr)
    (io:nl)))

(defun render-table-row (row widths padding chars)
  "Render data row."
  (let ((v (maps:get 'v chars))
        (pad-str (string:copies " " padding)))
    (io:put_chars v)
    (lists:foreach
      (lambda (idx)
        (let ((cell (lists:nth (+ idx 1) row))
              (width (lists:nth (+ idx 1) widths)))
          (io:put_chars pad-str)
          (io:put_chars (pad-string (to-string cell) width))
          (io:put_chars pad-str)
          (io:put_chars v)))
      (lists:seq 0 (- (length row) 1)))
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
            (string:copies h (+ w (* 2 padding))))
          widths)
        mb))
    (io:put_chars br)
    (io:nl)))

(defun pad-string (str width)
  "Pad string to width."
  (let ((len (string:length str)))
    (if (>= len width)
      (string:slice str 0 width)
      (++ str (string:copies " " (- width len))))))

;;; Tree Rendering

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
  (let* ((chars (tree-style-chars style))
         (branch (if is-last?
                   (maps:get 'last-branch chars)
                   (maps:get 'branch chars)))
         (cont (if is-last?
                 (maps:get 'last-cont chars)
                 (maps:get 'cont chars))))
    (cond
      ;; Leaf node (atom or string)
      ((orelse (is_atom node) (andalso (is_list node) (not (is_list (car node)))))
       (io:format "~s~s ~s~n" (list prefix branch (to-string node))))

      ;; Tuple node
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
      children)
    'ok))

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

;;; Progress Indicators

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
      - filled-char: String for filled portion (default \"=\")
      - empty-char: String for empty portion (default \" \")
      - show-percent: Show percentage (default true)

  Returns:
    {ok, displayed}"
  (let* ((width (maps:get 'width opts 40))
         (filled-char (maps:get 'filled-char opts "="))
         (empty-char (maps:get 'empty-char opts " "))
         (show-percent (maps:get 'show-percent opts 'true))
         (filled (round (* fraction width)))
         (empty (- width filled))
         (bar (++ (string:copies filled-char filled)
                  (string:copies empty-char empty)))
         (percent (round (* fraction 100))))
    (io:format "\r~s [~s]" (list label bar))
    (if show-percent
      (io:format " ~p%" (list percent))
      'ok)
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
    (progn
      (io:format "~s ... " (list label))
      (let ((result (funcall fun)))
        (io:format "done~n")
        (tuple 'ok result)))
    (catch
      ((tuple _class reason _stack)
       (io:format "failed~n")
       (tuple 'error reason)))))

;;; Utilities

(defun to-string (value)
  "Convert value to string."
  (cond
    ((is_binary value) (binary_to_list value))
    ((is_list value) value)
    ((is_atom value) (atom_to_list value))
    ((is_integer value) (integer_to_list value))
    ((is_float value) (float_to_list value))
    ('true (lists:flatten (io_lib:format "~p" (list value))))))
