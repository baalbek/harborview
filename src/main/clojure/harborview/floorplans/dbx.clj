(ns harborview.floorplans.dbx
  (:import
    [stearnswharf.systems ProjectBean]
    [stearnswharf.mybatis FloorPlansMapper])
  (:require
    [harborview.service.db :as DB]))


(defn fetch-projects []
  (let [result
          (DB/with-session FloorPlansMapper (.fetchProjects it))]
    (.add result (ProjectBean. -1 "-" true))
    result))

(defn fetch-buildings [project-id]
  (DB/with-session FloorPlansMapper
    (.fetchBuildings it project-id)))

(defn fetch-floor-plans [building-id]
  (DB/with-session FloorPlansMapper
    (.fetchFloorPlans it building-id)))



