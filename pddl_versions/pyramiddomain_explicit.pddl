(define (domain pyramidmanipulation)

(:requirements :typing)

(:types cube robot)

(:predicates
   (hand-empty ?rob - robot)
   (holding ?rob - robot ?c - cube)
   (on-ground ?c - cube)
   (on-cubes ?c-top - cube ?c-left - cube ?c-right - cube)
   (stable ?c - cube)        ; cube is properly supported (on-ground or on-cubes)
   (left-clear ?c - cube)    ; left slot of ?c is free (no cube resting on it from the left)
   (right-clear ?c - cube)   ; right slot of ?c is free
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
   )
)

(:action place-on-ground
   :parameters (?rob - robot ?c - cube)
   :precondition (holding ?rob ?c)
   :effect (and
      (on-ground ?c)
      (stable ?c)
      (hand-empty ?rob)
      (not (holding ?rob ?c))
   )
)

(:action pick-from-cubes
   :parameters (?rob - robot ?c - cube ?left - cube ?right - cube)
   :precondition (and
      (hand-empty ?rob)
      (on-cubes ?c ?left ?right)
      (left-clear ?c)
      (right-clear ?c)
   )
   :effect (and
      (holding ?rob ?c)
      (not (hand-empty ?rob))
      (not (on-cubes ?c ?left ?right))
      (not (stable ?c))
      (right-clear ?left)
      (left-clear ?right)
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
   )
   :effect (and
      (on-cubes ?c ?left ?right)
      (stable ?c)
      (hand-empty ?rob)
      (not (holding ?rob ?c))
      (not (right-clear ?left))
      (not (left-clear ?right))
   )
)

)
