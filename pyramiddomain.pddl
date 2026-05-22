(define (domain pyramidmanipulation)

(:requirements :typing :equality :action-costs)

(:types cube robot)

(:functions (total-cost))

(:predicates
   (hand-empty ?rob - robot)
   (holding ?rob - robot ?c - cube)
   (stored ?c - cube)
   (on-ground ?c - cube)
   (stable ?c - cube)
   (right-cube ?c - cube)
   (cube-on-top ?c - cube)
   (initial-placed ?rob - robot)
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

(:action place-initial
   :parameters (?rob - robot ?c - cube)
   :precondition (and(holding ?rob ?c)
      (not(initial-placed ?rob))
      )
   :effect (and
      (on-ground ?c)
      (stable ?c)
      (hand-empty ?rob)
      (not (holding ?rob ?c))
      (initial-placed ?rob)
      (increase (total-cost) 10)
   )
)

(:action place-on-ground
   :parameters (?rob - robot ?c - cube ?left - cube)
   :precondition (and (holding ?rob ?c)
      (not (right-cube ?left))
      (stable ?left)
      (on-ground ?left)
      (initial-placed ?rob)
      )
   :effect (and
      (stable ?c)
      (hand-empty ?rob)
      (not (holding ?rob ?c))
      (on-ground ?c)
      (right-cube ?left)
      (increase (total-cost) 10)
   )
)


(:action place-on-cubes
   :parameters (?rob - robot ?c - cube ?left - cube)
   :precondition (and
      (holding ?rob ?c)
      (stable ?left)
      (right-cube ?left)
      (not (cube-on-top ?left))
   )
   :effect (and
      (cube-on-top ?left)
      (stable ?c)
      (hand-empty ?rob)
      (not (holding ?rob ?c))
      (increase (total-cost) 1)
   )
)

)
