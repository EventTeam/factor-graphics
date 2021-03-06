#!r6rs
;; Copyright 2009 Derick Eddington.  My MIT-style license is in the file named
;; LICENSE from the original collection this file is distributed with.

(import
  (rnrs)
  (xitomatl lists)
  (srfi :78 lightweight-testing))

(define-syntax check-AV
  (syntax-rules ()
    ((_ expr)
     (check (guard (ex (else (assertion-violation? ex)))
              expr
              'unexpected-return)
            => #T))))

(define (make-L s e)
  (do ((i (- e 1) (- i 1))
       (l '() (cons i l))) 
      ((< i s) l)))

(define L (make-L 0 #e1e5))
(define L-len (length L))

;;;; sub-list
(check (sublist '() 0 0) => '())
(check (sublist '() 0) => '())
(check-AV (sublist '() 0 1))
(check-AV (sublist '() 1 0))
(check-AV (sublist '() 1 1))
(check-AV (sublist '() 2))
(check (sublist '(a) 0 0) => '())
(check (sublist '(a) 0 1) => '(a))
(check (sublist '(a) 1 1) => '())
(check (sublist '(a) 0) => '(a))
(check (sublist '(a) 1) => '())
(check-AV (sublist '(1) 0 2))
(check-AV (sublist '(1) 1 0))
(check-AV (sublist '(1) 55 55))
(check-AV (sublist '(1) 5))
(check (sublist '(a b) 0 0) => '())
(check (sublist '(a b) 0 1) => '(a))
(check (sublist '(a b) 1 1) => '())
(check (sublist '(a b) 1 2) => '(b))
(check (sublist '(a b) 0 2) => '(a b))
(check (sublist '(a b) 2 2) => '())
(check (sublist '(a b) 0) => '(a b))
(check (sublist '(a b) 1) => '(b))
(check (sublist '(a b) 2) => '())
(check-AV (sublist '(a b) 3 3))
(check-AV (sublist '(a b) 1 0))
(check-AV (sublist '(a b) 2 3))
(check-AV (sublist '(a b) 3))
(check (sublist '(a b c d e f) 0 0) => '())
(check (sublist '(a b c d e f) 0 1) => '(a))
(check (sublist '(a b c d e f) 1 2) => '(b))
(check (sublist '(a b c d e f) 0 2) => '(a b))
(check (sublist '(a b c d e f) 2 2) => '())
(check (sublist '(a b c d e f) 0 5) => '(a b c d e))
(check (sublist '(a b c d e f) 1 5) => '(b c d e))
(check (sublist '(a b c d e f) 4 5) => '(e))
(check (sublist '(a b c d e f) 5 6) => '(f))
(check (sublist '(a b c d e f) 3 6) => '(d e f))
(check (sublist '(a b c d e f) 2 4) => '(c d))
(check (sublist '(a b c d e f) 0 6) => '(a b c d e f))
(check (sublist '(a b c d e f) 6 6) => '())
(check (sublist '(a b c d e f) 0) => '(a b c d e f))
(check (sublist '(a b c d e f) 1) => '(b c d e f))
(check (sublist '(a b c d e f) 2) => '(c d e f))
(check (sublist '(a b c d e f) 3) => '(d e f))
(check (sublist '(a b c d e f) 4) => '(e f))
(check (sublist '(a b c d e f) 5) => '(f))
(check (sublist '(a b c d e f) 6) => '())
(check-AV (sublist '(a b c d e f) 5 4))
(check-AV (sublist '(a b c d e f) 1 7))
(check-AV (sublist '(a b c d e f) 42 45))
(check-AV (sublist '(a b c d e f) 7))
(check (sublist L 0 L-len) => L)
(check (sublist L 1 (- L-len 1)) => (make-L 1 (- L-len 1)))
(check (sublist L 123 (- L-len 321)) => (make-L 123 (- L-len 321)))
(check (sublist L 0 0) => '())
(check (sublist L (/ L-len 2) (/ L-len 2)) => '())
(check (sublist L L-len L-len) => '())
(check (sublist L 0) => L)
(check (sublist L 1) => (make-L 1 L-len))
(check (sublist L 123) => (make-L 123 L-len))
(check (sublist L L-len) => '())
(check-AV (sublist L 5 (+ 1 L-len)))
(check-AV (sublist L (+ 1 L-len) 5))
(check-AV (sublist L (+ 1 L-len)))
;;;; make-list
(check (length (make-list 123456)) => 123456)
(check (make-list 4 'x) => '(x x x x))
(check-AV (make-list -1))
(check-AV (make-list 'oops))
;;;; last-pair
(check (last-pair '(1 . 2)) => '(1 . 2))
(check (last-pair '(1 2 3 4 5 6 7 8 9 . 10)) => '(9 . 10))
(check (last-pair '(1 2 3 4 5 6 7 8)) => '(8))
(check-AV (last-pair '#(oops)))
;;;; map/left-right/preserving
(let ((a '()) (l L))
  (map/left-right/preserving (lambda (i) (set! a (cons i a))) l)
  (check (reverse a) => l))
(let ((x (string #\a)) (y (vector 'b)) (z (list 1)))
  (let ((l (list x y z)))
    (check (map/left-right/preserving values l) (=> eq?) l)))
;;;; map/filter
(check (map/filter odd? L) => (filter values (map odd? L)))
(check (map/filter (lambda (x y z) (odd? (+ x y z))) L L L)
       => (filter values (map (lambda (x y z) (odd? (+ x y z))) L L L)))
;;;; remp-dups
(check (remp-dups (lambda _ (assert #F)) '()) => '())
(check (remp-dups remq '(a)) => '(a))
(check (remp-dups remove '(a "b" #\c 4)) => '(a "b" #\c 4))
(check (remp-dups (lambda (x r)
                    (reverse (remp (lambda (y) (equal? (cadr x) (cadr y)))
                                   r)))
                  '((1 a) (2 #\b) (3 a) (4 "c") (5 #\b) (6 "c") (7 d) (8 a)))
       => '((1 a) (7 d) (2 #\b) (6 "c")))
;;;; remove-dups
(check (remove-dups '(a "a" (b 2) c (b 2) (b 2) a d "a")) 
       => '(a "a" (b 2) c d))
;;;; remv-dups
(check (remv-dups (list (list 1) 2 (list 1) 2 2 3 (list 1) #\c #\a #\c)) 
       => '((1) 2 (1) 3 (1) #\c #\a))
;;;; remq-dups
(let ((x (string #\s)) (y (vector 'v)) (z (list 1)))
  (check (remq-dups (list "s" y x '(1) x z x z (vector 'v) y (string #\s)))
         => '("s" #(v) "s" (1) (1) #(v) "s")))
;;;; dup?
(check ((dup? eq?) '(a b c d e c f g)) => 2)
(check ((dup? eq?) '(a b c d e f g)) => #F)
(let* ((x (string-copy "abc"))
       (y (string-copy "abc"))
       (l `("zz" ,x "yy" ,y "foo")))
  (check ((dup? equal?) l) => 1)
  (check ((dup? eqv?) l) => #F))
(check-AV ((dup? eq?) 'oops))
(check-AV ((dup? eq?) '(a b c . oops)))
;;;; unique?
(check ((unique? eq?) '(a b c d)) => #T)
(check ((unique? eq?) '(a b c d b)) => #F)
(check-AV ((unique? eq?) '(a b . oops)))
;;;; intersperse
(check (intersperse '() 1) => '())
(check (intersperse '(a) 1) => '(a))
(check (intersperse '(a b) 1) => '(a 1 b))
(check (intersperse '(a b c) 1) => '(a 1 b 1 c))
(check (intersperse '(a b c d e f g h i j k l m n o p q r s t u v w x y z) 1) 
       => '(a 1 b 1 c 1 d 1 e 1 f 1 g 1 h 1 i 1 j 1 k 1 l 1 m 1 n 1 o 1 p 1 q 1 r 1 s 1 t 1 u 1 v 1 w 1 x 1 y 1 z))
;;;; group-by
(define alphabet
  '(a b c d e f g h i j k l m n o p q r s t u v w x y z)) 
(check ((group-by 1) '()) => '())
(check ((group-by 1) '(a)) => '((a)))
(check ((group-by 1) '(a b)) => '((a) (b)))
(check ((group-by 1) '(a b c)) => '((a) (b) (c)))
(check ((group-by 1) '(a b c d)) => '((a) (b) (c) (d)))
(check ((group-by 1) '(a b c d e)) => '((a) (b) (c) (d) (e)))
(check ((group-by 1) alphabet) => (map list alphabet)) 
(check ((group-by 2) '()) => '())
(check-AV ((group-by 2) '(a)))
(check ((group-by 2 #T) '(a)) => '((a)))
(check ((group-by 2) '(a b)) => '((a b)))
(check-AV ((group-by 2) '(a b c)))
(check ((group-by 2 #T) '(a b c)) => '((a b) (c)))
(check ((group-by 2) '(a b c d)) => '((a b) (c d)))
(check-AV ((group-by 2) '(a b c d e)))
(check ((group-by 2 #T) '(a b c d e)) => '((a b) (c d) (e)))
(check ((group-by 2) '(a b c d e f)) => '((a b) (c d) (e f)))
(check-AV ((group-by 2) '(a b c d e f g)))
(check ((group-by 2 #T) '(a b c d e f g)) => '((a b) (c d) (e f) (g)))
(check ((group-by 2) '(a b c d e f g h)) => '((a b) (c d) (e f) (g h)))
(check-AV ((group-by 2) '(a b c d e f g h i)))
(check ((group-by 2 #T) '(a b c d e f g h i)) => '((a b) (c d) (e f) (g h) (i)))
(check ((group-by 2) alphabet)
       => '((a b) (c d) (e f) (g h) (i j) (k l) (m n)
            (o p) (q r) (s t) (u v) (w x) (y z)))
(check-AV ((group-by 2) (cdr alphabet)))
(check ((group-by 2 #T) (cdr alphabet))
       => '((b c) (d e) (f g) (h i) (j k) (l m)
            (n o) (p q) (r s) (t u) (v w) (x y) (z))) 
(check ((group-by 3) '()) => '())
(check-AV ((group-by 3) '(a)))
(check ((group-by 3 #T) '(a)) => '((a)))
(check-AV ((group-by 3) '(a b)))
(check ((group-by 3 #T) '(a b)) => '((a b)))
(check ((group-by 3) '(a b c)) => '((a b c)))
(check-AV ((group-by 3) '(a b c d)))
(check ((group-by 3 #T) '(a b c d)) => '((a b c) (d)))
(check-AV ((group-by 3) '(a b c d e)))
(check ((group-by 3 #T) '(a b c d e)) => '((a b c) (d e)))
(check ((group-by 3) '(a b c d e f)) => '((a b c) (d e f)))
(check-AV ((group-by 3) '(a b c d e f g)))
(check ((group-by 3 #T) '(a b c d e f g)) => '((a b c) (d e f) (g)))
(check-AV ((group-by 3) '(a b c d e f g h)))
(check ((group-by 3 #T) '(a b c d e f g h)) => '((a b c) (d e f) (g h)))
(check ((group-by 3) '(a b c d e f g h i)) => '((a b c) (d e f) (g h i)))
(check-AV ((group-by 3) alphabet))
(check ((group-by 3 #T) alphabet)
       => '((a b c) (d e f) (g h i) (j k l) (m n o) (p q r) (s t u) (v w x) (y z)))
(check-AV ((group-by 3) (cdr alphabet)))
(check ((group-by 3 #T) (cdr alphabet))
       => '((b c d) (e f g) (h i j) (k l m) (n o p) (q r s) (t u v) (w x y) (z)))
(check ((group-by 3) (cddr alphabet))
       => '((c d e) (f g h) (i j k) (l m n) (o p q) (r s t) (u v w) (x y z))) 
(check ((group-by 8) '()) => '())
(check-AV ((group-by 8) '(a b c)))
(check ((group-by 8 #T) '(a b c)) => '((a b c)))
(check ((group-by 8) (sublist alphabet 0 16))
       => '((a b c d e f g h) (i j k l m n o p)))
(check-AV ((group-by 8) alphabet))
(check ((group-by 8 #T) alphabet)
       => '((a b c d e f g h) (i j k l m n o p) (q r s t u v w x) (y z))) 
(check ((group-by 11) '()) => '())
(check-AV ((group-by 11) '(a b c)))
(check ((group-by 11 #T) '(a b c)) => '((a b c)))
(check ((group-by 11) (sublist alphabet 0 22))
       => '((a b c d e f g h i j k) (l m n o p q r s t u v)))
(check-AV ((group-by 11) alphabet))
(check ((group-by 11 #T) alphabet)
       => '((a b c d e f g h i j k) (l m n o p q r s t u v) (w x y z))) 
(check ((group-by 13) alphabet)
       => '((a b c d e f g h i j k l m) (n o p q r s t u v w x y z)))
(check ((group-by 26) alphabet)
       => '((a b c d e f g h i j k l m n o p q r s t u v w x y z)))
(check ((group-by 123) '()) => '())
(check-AV ((group-by 123) alphabet))
(check ((group-by 123 #T) alphabet)
       => '((a b c d e f g h i j k l m n o p q r s t u v w x y z)))
(check-AV (group-by 'oops))
(check-AV (group-by 0))
(check-AV (group-by 1.0))
(check-AV ((group-by 2) 'oops))
(check-AV ((group-by 3) '(a b c . oops)))
;;;; alist->plist
(check (alist->plist '()) => '())
(check (alist->plist '((a . 1))) => '(a 1))
(check (alist->plist '((a . 1) (b . 2))) => '(a 1 b 2))
(check (alist->plist '((a . 1) (b . 2) (c . 3))) => '(a 1 b 2 c 3))
(check (alist->plist '((a . 1) (b . 2) (c . 3) (d . 4) (e . 5) (f . 6)))
       => '(a 1 b 2 c 3 d 4 e 5 f 6))
(check-AV (alist->plist 'oops))
(check-AV (alist->plist '(oops)))
(check-AV (alist->plist '((a . 1) (b . 2) (c . 3) oops (e . 5))))
;;;; plist->alist
(check (plist->alist '()) => '())
(check (plist->alist '(a 1)) => '((a . 1)))
(check (plist->alist '(a 1 b 2)) => '((a . 1) (b . 2)))
(check (plist->alist '(a 1 b 2 c 3)) => '((a . 1) (b . 2) (c . 3)))
(check (plist->alist '(a 1 b 2 c 3 d 4 e 5 f 6))
       => '((a . 1) (b . 2) (c . 3) (d . 4) (e . 5) (f . 6)))
(check-AV (plist->alist 'oops))
(check-AV (plist->alist '(a)))
(check-AV (plist->alist '(a 1 b)))
(check-AV (plist->alist '(a 1 b 2 c)))
(check-AV (plist->alist '(a 1 b 2 c 3 d 4 e 5 f)))


(check-report)
