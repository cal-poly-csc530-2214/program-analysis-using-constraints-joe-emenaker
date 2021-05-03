;(set-logic QF_LIA)
(declare-const a1 Int)
(declare-const a2 Int)
(declare-const a3 Int)
(declare-const a4 Int)
(declare-const a5 Int)
(declare-const a6 Int)

(define-fun Invar1 ((x Int) (y Int)) Int
	(+
		(* a1 x)
		(* a2 y)
		a3
	)
)

(define-fun Invar2 ((x Int) (y Int)) Int
	(+
		(* a4 x)
		(* a5 y)
		a6
	)
)

(define-fun Invar ((x Int) (y Int)) Bool
	(or
		(>= (Invar1 x y) 0) ; a1x + a2y + a3 >= 0
		(>= (Invar2 x y) 0) ; a4x + a5y + a6 >= 0
	)
)

; Constrain coefficients to something workable
(assert (> a1 -3))
(assert (< a1 3))
(assert (> a2 -3))
(assert (< a2 3))
(assert (> a3 -3))
(assert (< a3 3))
(assert (> a4 -3))
(assert (< a4 3))
(assert (> a5 -3))
(assert (< a5 3))
(assert (> a6 -3))
(assert (< a6 3))

; 1st Verification Constraint
(assert (forall ((y Int))
	(Invar -50 y)
))

; 2nd Verification Constraint
;(assert (forall ((x Int) (y Int))
;	(=>
;		(and
;			(Invar x y)
;			(< x 0)
;		)
;		; implies...
;		(Invar (+ x y) (+ x 1))
;	)
;))

; 3rd Verification Constraint
(assert (forall ((x Int) (y Int))
	(=>
		(and
			(Invar x y)
			(>= x 0)
		)
		; implies..
		(> y 0)
	)
))

(check-sat)
;(check-sat-using (then qe smt))
(get-value (a1 a2 a3 a4 a5 a6))

; Yields
;sat
;((a1 (- 1))
; (a2 2)
; (a3 (- 1))
; (a4 (- 1))
; (a5 0)
; (a6 (- 1)))
; aka      (-x + 2y >= 1)  OR  (-x >= 1)