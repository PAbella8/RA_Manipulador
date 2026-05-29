(define (domain pyramidmanipulation)

(:requirements :typing :action-costs)

(:types cube robot)

(:functions (total-cost))

(:predicates
   (hand-empty ?rob - robot)
   (holding ?rob - robot ?c - cube)
   (stored ?c - cube)
   (stable ?c - cube)
   (right-of ?c1 - cube ?c2 - cube)
   (slot-free ?c1 - cube ?c2 - cube)
   (right-support-user ?rs - cube ?c - cube)
   (right-support-used ?c - cube)
   (rightmost ?c - cube)
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
   :precondition (and
      (holding ?rob ?c)
      (not (initial-placed ?rob))
   )
   :effect (and
      (stable ?c)
      (hand-empty ?rob)
      (not (holding ?rob ?c))
      (initial-placed ?rob)
      (rightmost ?c)
      (increase (total-cost) 10)
   )
)

(:action place-on-ground
   :parameters (?rob - robot ?c - cube ?left - cube)
   :precondition (and
      (holding ?rob ?c)
      (stable ?left)
      (rightmost ?left)
      (initial-placed ?rob)
   )
   :effect (and
      (stable ?c)
      (hand-empty ?rob)
      (not (holding ?rob ?c))
      (right-of ?left ?c)
      (slot-free ?left ?c)
      (not (rightmost ?left))
      (rightmost ?c)
      (increase (total-cost) 10)
   )
)

; Primer cubo de una nueva fila: ningun cubo a su izquierda en el mismo nivel
(:action place-new-row
   :parameters (?rob - robot ?c - cube ?ls - cube ?rs - cube)
   :precondition (and
      (holding ?rob ?c)
      (stable ?ls)
      (stable ?rs)
      (right-of ?ls ?rs)
      (slot-free ?ls ?rs)
      (not (right-support-used ?ls))
   )
   :effect (and
      (stable ?c)
      (hand-empty ?rob)
      (not (holding ?rob ?c))
      (not (slot-free ?ls ?rs))
      (right-support-user ?rs ?c)
      (right-support-used ?rs)
      (increase (total-cost) 1)
   )
)

; Cubo siguiente en la misma fila: ?prev es su vecino izquierdo en el mismo nivel
(:action place-on-cubes
   :parameters (?rob - robot ?c - cube ?prev - cube ?ls - cube ?rs - cube)
   :precondition (and
      (holding ?rob ?c)
      (stable ?ls)
      (stable ?rs)
      (right-of ?ls ?rs)
      (slot-free ?ls ?rs)
      (right-support-user ?ls ?prev)
   )
   :effect (and
      (stable ?c)
      (hand-empty ?rob)
      (not (holding ?rob ?c))
      (not (slot-free ?ls ?rs))
      (right-support-user ?rs ?c)
      (right-support-used ?rs)
      (right-of ?prev ?c)
      (slot-free ?prev ?c)
      (increase (total-cost) 1)
   )
)

)
