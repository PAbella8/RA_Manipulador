(define (domain pyramidmanipulation)

(:requirements :typing :action-costs :negative-preconditions :disjunctive-preconditions :conditional-effects)

(:types cube robot region)

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

; Cubre todos los casos de colocacion:
;   Primer cubo de una fila: (not (right-support-used ?ls)), ?prev es dummy
;   Siguiente cubo de una fila: (right-support-user ?ls ?prev), ?prev es su vecino izquierdo
; Los objetos de mesa (t0-t4) actuan como soportes del nivel del suelo en el problema.
(:action place
   :parameters (?rob - robot ?c - cube ?reg - region ?ls - cube ?rs - cube ?prev - cube)
   :precondition (and
      (holding ?rob ?c)
      (in-pyramid ?reg)
      (stable ?ls)
      (stable ?rs)
      (right-of ?ls ?rs)
      (slot-free ?ls ?rs)
      (or (not (right-support-used ?ls))
          (right-support-user ?ls ?prev))
   )
   :effect (and
      (stable ?c)
      (hand-empty ?rob)
      (not (holding ?rob ?c))
      (not (slot-free ?ls ?rs))
      (right-support-user ?rs ?c)
      (right-support-used ?rs)
      (when (right-support-user ?ls ?prev)
            (and (right-of ?prev ?c) (slot-free ?prev ?c)))
      (increase (total-cost) 1)
   )
)

)
