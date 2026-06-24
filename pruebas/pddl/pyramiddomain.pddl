(define (domain pyramidmanipulation)

(:requirements :typing :action-costs :conditional-effects :equality)

(:types cube robot region)

(:functions (total-cost))

(:predicates
   (hand-empty ?rob - robot)
   (holding ?rob - robot ?c - cube)
   (stored ?c - cube)
   (stable ?c - cube)
   (can-place ?c - cube)
   (in-storage ?reg - region)
   (in-pyramid ?reg - region)
)

(:action pick
   :parameters (?rob - robot ?c - cube ?reg - region)
   :precondition (and
      (hand-empty ?rob)
      (stored ?c)
      (in-storage ?reg)
   )
   :effect (and
      (holding ?rob ?c)
      (not (hand-empty ?rob))
      (not (stored ?c))
      (increase (total-cost) 1)
   )
)

(:action place
   :parameters (?rob - robot ?c - cube ?reg - region)
   :precondition (and
      (holding ?rob ?c)
      (in-pyramid ?reg)
      (can-place ?c)
   )
   :effect (and
      (stable ?c)
      (hand-empty ?rob)
      (not (holding ?rob ?c))
      (increase (total-cost) 1)
      ; Unlock row-2 cubes: each needs both supports stable
      (when (and (= ?c c1) (stable c2)) (can-place c5))
      (when (and (= ?c c2) (stable c1)) (can-place c5))
      (when (and (= ?c c2) (stable c3)) (can-place c6))
      (when (and (= ?c c3) (stable c2)) (can-place c6))
      (when (and (= ?c c3) (stable c4)) (can-place c7))
      (when (and (= ?c c4) (stable c3)) (can-place c7))
      ; Unlock row-3 cubes
      (when (and (= ?c c5) (stable c6)) (can-place c8))
      (when (and (= ?c c6) (stable c5)) (can-place c8))
      (when (and (= ?c c6) (stable c7)) (can-place c9))
      (when (and (= ?c c7) (stable c6)) (can-place c9))
      ; Unlock top cube
      (when (and (= ?c c8) (stable c9)) (can-place c10))
      (when (and (= ?c c9) (stable c8)) (can-place c10))
   )
)

)
