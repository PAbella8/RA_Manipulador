(define (problem build-pyramid)
   (:domain pyramidmanipulation)

   (:objects
      c1 c2 c3 c4 c5 c6 c7 c8 c9 c10 - cube
      robot1 - robot
      storage pyramid - region
   )

   (:init
      (hand-empty robot1)
      (= (total-cost) 0)

      (in-storage storage)
      (in-pyramid pyramid)

      ; All cubes start in storage
      (stored c1)  (stored c2)  (stored c3)  (stored c4)
      (stored c5)  (stored c6)  (stored c7)
      (stored c8)  (stored c9)  (stored c10)

      ; Ground-level cubes can be placed immediately (no supports needed)
      (can-place c1)  (can-place c2)  (can-place c3)  (can-place c4)
   )

   (:goal
      (and
         (stable c1)  (stable c2)  (stable c3)  (stable c4)
         (stable c5)  (stable c6)  (stable c7)
         (stable c8)  (stable c9)  (stable c10)
      )
   )

   (:metric minimize (total-cost))

)
