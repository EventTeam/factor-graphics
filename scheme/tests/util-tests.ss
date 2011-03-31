(import (util)
        (srfi :78)
        (srfi :1)
        (abstraction-grammar))
;;;deep-find-all tests
(let* ([sexpr '(let ()
                 (define F8
                   (lambda (V25) (list 'a (list 'a (list V25) (list V25)))))
                 (uniform-draw (F8 (F8 'b)) (F8 'c) (F8 'd)))]
       [pred (lambda (sexpr)
               (if (non-empty-list? sexpr)
                 (if (equal? (first sexpr) 'F8)
                     #t
                     #f)
                 #f))])
  (check (deep-find-all pred sexpr) => '((F8 (F8 'b)) (F8 'b) (F8 'c) (F8 'd))))

;;;sexp-search

(let ([sexprs '((F8 (F8 'b)) (F8 'b) (F8 'c) (F8 'd))])
  (check (sexp-search rule-application? (lambda (x) (list (first x))) sexprs) => '((F8) (F8) (F8) (F8))))