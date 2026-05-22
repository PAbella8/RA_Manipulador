(define (domain pyramidmanipulation)

(:requirements :typing :equality :action-costs)

(:types cube robot level)

(:constants l0 l1 l2 l3 - level)

(:functions (total-cost))

(:predicates
   (hand-empty ?rob - robot)
   (holding ?rob - robot ?c - cube)
   (stored ?c - cube)
   (on-ground ?c - cube)
   (on-cubes ?c-top - cube ?c-left - cube ?c-right - cube)
   (stable ?c - cube)
   (left-clear ?c - cube)
   (right-clear ?c - cube)
   (at-level ?c - cube ?l - level)
   (next-level ?l1 - level ?l2 - level)
)

(:action pick-from-storage
   :parameters (?rob - robot ?c - cube)
   :precondition (and
      (hand-empty ?rob)
      (stored ?c)
   )
   :effect (and
      (holding ?rob ?c)
      (not (hand-empty ?rob))
      (not (stored ?c))
      (increase (total-cost) 0)
   )
)

(:action pick-from-ground
   :parameters (?rob - robot ?c - cube)
   :precondition (and
      (hand-empty ?rob)
      (on-ground ?c)
      (left-clear ?c)
      (right-clear ?c)
   )
   :effect (and
      (holding ?rob ?c)
      (not (hand-empty ?rob))
      (not (on-ground ?c))
      (not (stable ?c))
      (not (at-level ?c l0))
      (increase (total-cost) 0)
   )
)

(:action place-on-ground
   :parameters (?rob - robot ?c - cube)
   :precondition (holding ?rob ?c)
   :effect (and
      (on-ground ?c)
      (stable ?c)
      (at-level ?c l0)
      (left-clear ?c)
      (right-clear ?c)
      (hand-empty ?rob)
      (not (holding ?rob ?c))
      (increase (total-cost) 10)
   )
)

(:action pick-from-cubes
   :parameters (?rob - robot ?c - cube ?left - cube ?right - cube ?lev - level)
   :precondition (and
      (hand-empty ?rob)
      (on-cubes ?c ?left ?right)
      (left-clear ?c)
      (right-clear ?c)
      (not (= ?left ?right))
      (at-level ?c ?lev)
   )
   :effect (and
      (holding ?rob ?c)
      (not (hand-empty ?rob))
      (not (on-cubes ?c ?left ?right))
      (not (stable ?c))
      (not (at-level ?c ?lev))
      (right-clear ?left)
      (left-clear ?right)
      (increase (total-cost) 0)
   )
)

(:action place-on-cubes
   :parameters (?rob - robot ?c - cube ?left - cube ?right - cube ?lev - level ?next - level)
   :precondition (and
      (holding ?rob ?c)
      (stable ?left)
      (stable ?right)
      (right-clear ?left)
      (left-clear ?right)
      (not (= ?left ?right))
      (at-level ?left ?lev)
      (at-level ?right ?lev)
      (next-level ?lev ?next)
   )
   :effect (and
      (on-cubes ?c ?left ?right)
      (stable ?c)
      (at-level ?c ?next)
      (left-clear ?c)
      (right-clear ?c)
      (hand-empty ?rob)
      (not (holding ?rob ?c))
      (not (right-clear ?left))
      (not (left-clear ?right))
      (increase (total-cost) 1)
   )
)

)
