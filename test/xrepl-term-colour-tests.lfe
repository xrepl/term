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
