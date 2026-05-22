(define (domain pyramidmanipulation)

(:requirements :typing :equality :action-costs)

(:types cube robot)

(:functions (total-cost))

(:predicates
   (hand-empty ?rob - robot)
   (holding ?rob - robot ?c - cube)
   (stored ?c - cube)             ; cube is in the initial storage area (not yet placed)
   (on-ground ?c - cube)
   (on-cubes ?c-top - cube ?c-left - cube ?c-right - cube)
   (stable ?c - cube)
   (left-clear ?c - cube)
   (right-clear ?c - cube)
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
      (increase (total-cost) 0)
   )
)

(:action place-on-ground
   :parameters (?rob - robot ?c - cube)
   :precondition (holding ?rob ?c)
   :effect (and
      (on-ground ?c)
      (stable ?c)
      (left-clear ?c)
      (right-clear ?c)
      (hand-empty ?rob)
      (not (holding ?rob ?c))
      (increase (total-cost) 10)
   )
)

(:action pick-from-cubes
   :parameters (?rob - robot ?c - cube ?left - cube ?right - cube)
   :precondition (and
      (hand-empty ?rob)
      (on-cubes ?c ?left ?right)
      (left-clear ?c)
      (right-clear ?c)
      (not (= ?left ?right))
   )
   :effect (and
      (holding ?rob ?c)
      (not (hand-empty ?rob))
      (not (on-cubes ?c ?left ?right))
      (not (stable ?c))
      (right-clear ?left)
      (left-clear ?right)
      (increase (total-cost) 0)
   )
)

(:action place-on-cubes
   :parameters (?rob - robot ?c - cube ?left - cube ?right - cube)
   :precondition (and
      (holding ?rob ?c)
      (stable ?left)
      (stable ?right)
      (right-clear ?left)
      (left-clear ?right)
      (not (= ?left ?right))
   )
   :effect (and
      (on-cubes ?c ?left ?right)
      (stable ?c)
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
