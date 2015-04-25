(ns harborview.floorplans.dbx
  (:import
    [stearnswharf.mybatis FloorPlansMapper])
  (:require
    [harborview.service.db :as DB]))


(defn fetch-projects []
   (DB/with-session FloorPlansMapper
     (.fetchProjects it)))

(defn fetch-buildings [project-id]
  (DB/with-session FloorPlansMapper
    (.fetchBuildings it project-id)))

(defn fetch-floor-plans [building-id]
  (DB/with-session FloorPlansMapper
    (.fetchFloorPlans it building-id)))



