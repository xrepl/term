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
