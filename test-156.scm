;; 1. Helper syntax

(define-syntax infix/postfix
  (syntax-rules ()
    ((infix/postfix x somewhat?)
     (somewhat? x))

    ((infix/postfix left related-to? right)
     (related-to? left right))

    ((infix/postfix left related-to? right . likewise)
     (let ((right* right))
       (and (infix/postfix left related-to? right*)
	    (infix/postfix right* . likewise))))))

(define-syntax extract-placeholders
  (syntax-rules (_)
    ((extract-placeholders final () () body)
     (final (infix/postfix . body)))

    ((extract-placeholders final () args body)
     (lambda args (final (infix/postfix . body))))

    ((extract-placeholders final (_ op . rest) (args ...) (body ...))
     (extract-placeholders final rest (args ... arg) (body ... arg op)))

    ((extract-placeholders final (arg op . rest) args (body ...))
     (extract-placeholders final rest args (body ... arg op)))

    ((extract-placeholders final (_) (args ...) (body ...))
     (extract-placeholders final () (args ... arg) (body ... arg)))

    ((extract-placeholders final (arg) args (body ...))
     (extract-placeholders final () args (body ... arg)))))

(define-syntax identity-syntax
  (syntax-rules ()
    ((identity-syntax form)
     form)))

;; 2. The "is" and "isnt" macros that are intended to be exported

(define-syntax is
  (syntax-rules ()
    ((is . something)
     (extract-placeholders identity-syntax something () ()))))

(define-syntax isnt
  (syntax-rules ()
    ((isnt . something)
     (extract-placeholders not something () ()))))

;; 3. A micro unit-test framework for the purpose of demonstation

(define-syntax e.g.
  (syntax-rules ()
    ((e.g. expression)
     (let ((result expression))
       (if (not result)
	   (error "test failed: " 'expression)
	   result)))))

;; 4. Examples/tests:

;; single argument/unary predicate:

(e.g.
 (is 1 odd?))

(e.g.
 (isnt 2 odd?))

(e.g.
 (is '() null?))

(e.g.
 (is procedure? procedure?))

(e.g.
 (isnt 5 procedure?))

;; two arguments:

(e.g.
 (is 1 < 2))

(e.g.
 (isnt 1 < 1))

(e.g.
 (is (+ 2 2) = 4))

(e.g.
 (is 'x eq? 'x))

(e.g.
 (is procedure? eq? procedure?))

(e.g.
 (eq? (is eq? eq? eq?)
      (eq? eq? eq?)))

(e.g.
 (is (is eq? eq? eq?) eq? (eq? eq? eq?)))

(e.g.
 (is 'y memq '(x y z)))

(e.g.
 (is '(1) member '(() (1) (2) (1 2))))

(e.g.
 (isnt 'x eq? 'y))

(e.g.
 (is '(a b c) equal? '(a b c)))

(e.g.
 (isnt '(a b c) equal? '(c b a)))

(e.g.
 (is 0 = 0.0))

(e.g.
 (is 1.0 = 1))

(e.g.
 (isnt 1 = 0))

(define (divisible-by? x y)
  (is (modulo x y) = 0))

(e.g.
 (is 9 divisible-by? 3))

(e.g.
 (isnt 3 divisible-by? 9))

;; ending with unary predicate:

(e.g.
 (is 1 < 2 even?))

(e.g.
 (isnt 1 < 2 odd?))

(e.g.
 (isnt 2 < 1 even?))

(e.g.
 (is 0 = 0.0 zero?))

(e.g.
 (isnt 1.0 = 1 zero?))

(e.g.
 (is eq? eq? eq? eq?))

;; three arguments:

(e.g.
 (is 1 < 2 <= 3))

(e.g.
 (is 0 = 0.0 = 0+0i = 0.0+0.0i))

(e.g.
 (isnt 1 <= 2 < 2))

;; predicates don't need to be transitive
;; (although that's not particularly elegant):

(e.g.
 (is 1 < 2 > 1.5))

(e.g.
 (isnt 1 < 2 > 3))

(e.g.
 (isnt 3 < 2 < 1))

(e.g.
 (is 'x member '(x y) member '((x y) (y x))))

;; more arguments:

(e.g.
 (is -0.4 < -0.1 <= 0 = 0.0 < 0.1 < 0.4))

(e.g.
 (isnt -0.4 < -0.1 <= 0 = 0.0 < 0.1 < -0.1))

(e.g.
 (is 0 = 0.0 = 0+0i = 0.0+0.0i = (+) < (*) = 1 = 1.0 = 1+0i = 1.0+0.0i))

(e.g.
 (is eq? eq? eq? eq? eq? eq? eq? eq? eq?))

(e.g.
 (isnt eq? eq? eq? eq? eq? eq? eq? eq? procedure?))

;; ending with unary predicate:

(e.g.
 (is -0.4 < -0.1 <= 0 <= 0.0 < 0.1 < 0.4 <= 2 even?))

(e.g.
 (isnt -0.4 < -0.1 <= 0 <= 0.0 < 0.1 < 0.4 <= 2 odd?))

(e.g.
 (is eq? eq? eq? eq? eq? eq? eq? eq? eq? procedure?))

;; as procedures (with underscore):

(e.g.
 (equal? (filter (isnt _ even?) '(2 4 5 6 7 8))
	 '(5 7)))

(e.g.
 (equal? (filter (is _ < 2) '(1 3 2 0))
	 '(1 0)))

(e.g.
 (equal? (filter (is 1 < _) '(1 3 2 0))
	 '(3 2)))

(e.g.
 (equal? (filter (is 3 < _ <= 5) '(2 3 4 5 6 7))
	 '(4 5)))

(e.g.
 (equal? (filter (is 'x memq _) '((a b) (x) (p q) (x y) (c d) (z x)))
	 '((x) (x y) (z x))))

(e.g.
 (equal? (filter (isnt 'x memq _) '((a b) (x) (p q) (x y) (c d) (z x)))
	 '((a b) (p q) (c d))))

(e.g.
 (equal? (filter (isnt 3 < _ <= 5) '(2 3 4 5 6 7))
	 '(2 3 6 7)))

(e.g.
 (equal? (filter (is _ eq? 'a) '(m a m a))
	 '(a a)))

(e.g.
 (equal? (filter (isnt 'a eq? _) '(m a m a))
	 '(m m)))

;; multiple underscores:

(e.g.
 ((is _ < 2 < _) 1 3))

(e.g.
 ((isnt 1 < _ <= _ < 3) 2 4))

(e.g.
 ((is _ < _ even?) 1 2))

(e.g.
 ((isnt _ < _ odd?) 1 2))

(e.g.
 ((is 1 < _ <= 3 < _ <= 5 < _) 3 5 6))

(e.g.
 ((isnt 1 < _ <= 3 < _ <= 5 < _) 3 3 6))

(e.g.
 ((is 1 < _ <= 3 < _ <= 5 < _ even?) 3 5 6))

(e.g.
 ((isnt 1 < _ <= 3 < _ <= 5 < _ odd?) 3 5 6))

