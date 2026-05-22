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

      ; Counter: all 10 cubes are currently on the ground
      (= (cubes-on-ground) 10)
   )

   ; Goal: every cube must be properly supported (on ground or on two cubes).
   ; The metric drives the planner to minimise how many end up on the ground,
   ; which forces it to stack them as high as possible.
   (:goal
      (and
         (stable c1)  (stable c2)  (stable c3)  (stable c4)
         (stable c5)  (stable c6)  (stable c7)
         (stable c8)  (stable c9)
         (stable c10)
      )
   )

   (:metric minimize (cubes-on-ground))

)
