(define (problem build-pyramid)
   (:domain pyramidmanipulation)

   (:objects
      c1 c2 c3 c4 c5 c6 c7 c8 c9 c10 - cube
      t0 t1 t2 t3 t4 - cube
      robot1 - robot
      storage pyramid - region
   )

   (:init
      (hand-empty robot1)
      (= (total-cost) 0)

      (in-storage storage)
      (in-pyramid pyramid)

      ; Cubos reales en almacen (los objetos de mesa no se almacenan)
      (stored c1)  (stored c2)  (stored c3)  (stored c4)
      (stored c5)  (stored c6)  (stored c7)
      (stored c8)  (stored c9)  (stored c10)

      ; Objetos de mesa: ya estables, con slots adyacentes para los 4 cubos del suelo
      (stable t0)  (stable t1)  (stable t2)  (stable t3)  (stable t4)
      (right-of t0 t1)  (slot-free t0 t1)
      (right-of t1 t2)  (slot-free t1 t2)
      (right-of t2 t3)  (slot-free t2 t3)
      (right-of t3 t4)  (slot-free t3 t4)
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
