(define (problem build-pyramid)
   (:domain pyramidmanipulation)

   (:objects
      c1 c2 c3 c4 c5 c6 c7 c8 c9 c10 - cube
      robot1 - robot
   )

   (:init
      (hand-empty robot1)

      ; All cubes start on the ground
      (on-ground c1)  (stable c1)
      (on-ground c2)  (stable c2)
      (on-ground c3)  (stable c3)
      (on-ground c4)  (stable c4)
      (on-ground c5)  (stable c5)
      (on-ground c6)  (stable c6)
      (on-ground c7)  (stable c7)
      (on-ground c8)  (stable c8)
      (on-ground c9)  (stable c9)
      (on-ground c10) (stable c10)

      ; All slots are initially free
      (left-clear c1)  (right-clear c1)
      (left-clear c2)  (right-clear c2)
      (left-clear c3)  (right-clear c3)
      (left-clear c4)  (right-clear c4)
      (left-clear c5)  (right-clear c5)
      (left-clear c6)  (right-clear c6)
      (left-clear c7)  (right-clear c7)
      (left-clear c8)  (right-clear c8)
      (left-clear c9)  (right-clear c9)
      (left-clear c10) (right-clear c10)

   )

   ; Goal: pyramid 4-3-2-1 with 10 cubes.
   ; Base (4): c1 c2 c3 c4 on ground
   ; Row 2 (3): c5 on (c1,c2), c6 on (c2,c3), c7 on (c3,c4)
   ; Row 3 (2): c8 on (c5,c6), c9 on (c6,c7)
   ; Top  (1): c10 on (c8,c9)
   (:goal
      (and
         (on-ground c1)  (on-ground c2)  (on-ground c3)  (on-ground c4)
         (on-cubes c5 c1 c2)
         (on-cubes c6 c2 c3)
         (on-cubes c7 c3 c4)
         (on-cubes c8 c5 c6)
         (on-cubes c9 c6 c7)
         (on-cubes c10 c8 c9)
      )
   )

)
