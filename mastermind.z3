;(set-logic QF_LIA)

; Looks like Z3 has a built-in 'List' type with, at least, the following properties/methods:
; List<T>
;  head : T
;  tail : List<T>
;  insert T List<T> : List<T>

; an enumeration datatype
(declare-datatype Color ( A B C D E F ))
(declare-datatype Position ( p0 p1 p2 p3 ))

(declare-const pos_nil (List Position))
(assert (= pos_nil (as nil (List Position))))

(declare-const color_nil (List Color))
(assert (= color_nil (as nil (List Color))))

(define-fun-rec ColorListLen ((x!0 (List Color))) Int
    (ite (= x!0 (as nil (List Color))) 0 (+ 1 (ColorListLen (tail x!0))))
)
;(assert (= (ColorListLen color_nil) 0))
;(assert (= (ColorListLen (insert A color_nil)) 1))

; Returns the length of a Position list
(define-fun-rec PosListLen ((x!0 (List Position))) Int
    (ite (= x!0 pos_nil) 0 (+ 1 (PosListLen (tail x!0))))
)

; If time allows, it would be nice to automatically generate the responses to a guess
; based upon the "true" answer.
; === target = [ A B C D ]
(declare-const target (List Color))
(assert (= target (insert D (insert C (insert B (insert A (as nil (List Color))))))))

; === positions = [ 0 1 2 3 ]
(declare-const positions (List Position))
(assert (= positions (insert p3 (insert p2 (insert p1 (insert p0 pos_nil))))))

; Removes an element from a list
(define-fun-rec RemoveElement ((x!0 Int) (x!1 (List Position))) (List Position)
    (ite
        ; Are we supposed to remove the head?
        (= x!0 0)
        ; If so, return 'tail x!1'
        (tail x!1)
        ; Otherwise, return head prepended to tail with (pos-1) removed
        (insert (head x!1) (RemoveElement (- x!0 1) (tail x!1)))
    )
)
; Tests of element removal
(assert (= 
    (RemoveElement 0 (insert p1 pos_nil))
    pos_nil
))

; More element removal tests. We need to assert the length (below) because removing
; an element from nil doesn't throw an error, it just returns nil (in the same way
; that (pred 0)=0 in lambda calculus). We could probably fix this by having the function
; return a duple ((List Position) Bool) so that we could indicate success/failure, but
; this project is getting complicated enough, and, with length checks, we can work
; around this problem.
(declare-const two_elements (List Position))
(assert (=
    (RemoveElement 0 (RemoveElement 1 two_elements))
    pos_nil
))
(assert (= (PosListLen two_elements) 2))

(declare-const possible_solution (List Color))
(assert (= (ColorListLen possible_solution) 4)) ; Solution must contain 4 pegs

; Function: GuessResult
; This is the main engine for asserting implications about the responses to our guesses
; Parms:
;   guess : List<Color>    ; Our guess this time
;   positions : List<Position>  ; List of positions in the tagret solution which are available to match with part of our guess
;   corr_pos  : Int        ; Number of stones in our guess with correct color AND position
;   corr_col  : Int        ; Number of stones in our guess with correct color
;   cur_pos   : Int        ; Current poistion we're examining (starts at 0)
;
; Semantics and possible sanity checks:
; corr_pos + cor_col should never be greater than len(positions)
; 'guess' contains just the colors, not positions, as the colors are for positions 0 - 3, in order. 
(define-fun-rec GuessResult ((guess (List Color)) (positions (List Position)) (corr_pos Int) (corr_col Int)) Bool
    (ite
        ; First, if corr_pos+corr_col > len(guess), then there aren't enough pegs left in our guess
        ; to account for all of the responses, so this branch should fail
        (> (+ corr_pos corr_col) (ColorListLen guess))
        false
        ; Otherwise, either...
        ;   corr_pos > 0 AND...
        ;      the head of guess is correct OR...
        ;      the head of guess is not correct
        ;  OR 
        ;   corr_col > 0 AND...
        ;      the head of guess matches one of the colors in the proposed solution at the positions in positions list
        ;      OR the head of guess doesn't match one of the colors in the proposed solution at the positions in positions list
        ;  OR
        
        true
    ) 
)

(declare-const guess_one (List Color))
(assert (= guess_one (insert C (insert D (insert E (insert F (as nil (List Color))))))))
(assert (= (GuessResult guess_one positions 1 0) true))

(declare-const guess_two (List Color))
(assert (= (ColorListLen guess_two) 4))
(assert (not (= guess_two guess_one)))

(declare-const guess_three (List Color))
(assert (= (ColorListLen guess_three) 4))
(assert (not (= guess_three guess_one)))
(assert (not (= guess_three guess_two)))

(assert (GuessResult guess_one positions 1 3))




(check-sat)
(get-model)
