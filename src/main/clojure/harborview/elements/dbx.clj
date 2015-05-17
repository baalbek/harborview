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




