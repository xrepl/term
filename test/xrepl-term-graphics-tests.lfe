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
