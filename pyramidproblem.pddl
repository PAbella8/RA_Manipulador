(define (problem build-pyramid)
   (:domain pyramidmanipulation)

   (:objects
      c1 c2 c3 c4 c5 c6 c7 c8 c9 c10 - cube
      robot1 - robot
   )

   (:init
      (hand-empty robot1)
      (= (total-cost) 0)

      ; Level hierarchy
      (next-level l0 l1)
      (next-level l1 l2)
      (next-level l2 l3)

      ; All cubes start in storage: not placed, not stable, no slots defined
      (stored c1)  (stored c2)  (stored c3)  (stored c4)
      (stored c5)  (stored c6)  (stored c7)
      (stored c8)  (stored c9)  (stored c10)
   )

   ; Goal: every cube must be placed and stable.
   ; Action costs guide the planner: place-on-ground costs 10, place-on-cubes costs 1.
   ; The optimal solution minimises ground placements, naturally producing a pyramid.
   (:goal
      (and
         (stable c1)  (stable c2)  (stable c3)  (stable c4)
         (stable c5)  (stable c6)  (stable c7)
         (stable c8)  (stable c9)
         (stable c10)
      )
   )

   (:metric minimize (total-cost))

)
