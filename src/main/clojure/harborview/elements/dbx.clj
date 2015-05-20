(ns harborview.elements.dbx
  (:import
    [stearnswharf.elements SteelBeam DistLoad]
    [stearnswharf.mybatis ElementsMapper])
  (:require
    [harborview.service.htmlutils :as U]
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



(def r U/rs)

(defn new-dist-load [sysid qx1 qx2 qy1 qy2 qz1 qz2 lf]
  (let [d (DistLoad.)]
    (doto d
      (.setSysId (r sysid))
      (.setQx1 (r qx1))
      (.setQx2 (r qx2))
      (.setQy1 (r qy1))
      (.setQy2 (r qy2))
      (.setQz1 (r qz1))
      (.setQz2 (r qz2))
      (.setLoadFactor (r lf)))
    (DB/with-session ElementsMapper
      (.newDistLoad it d))
    d))

