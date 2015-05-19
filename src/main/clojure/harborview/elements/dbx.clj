(ns harborview.elements.dbx
  (:import
    [stearnswharf.elements SteelBeam]
    [stearnswharf.mybatis ElementsMapper])
  (:require
    [harborview.service.db :as DB]))

(def fetch-steel-beams 
  (memoize 
    (fn []
      (DB/with-session ElementsMapper
        (.fetchSteelBeams it)))))


(defn new-steel-elements  [sys-id steel
                          [n1 n2 n3 n4 n5]
                          [qall q1 q2 q3 q4]
                          [p1 p2 p3 p4 p6]
                          [p1lf p2lf p3lf p4lf p6lf]]
  (str n1 "-" qall "-" p1))




