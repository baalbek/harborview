(ns harborview.floorplans.dbx
  (:import
    [stearnswharf.systems ProjectBean FloorPlanBean]
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

(defn fetch-floorplans [building-id]
  (DB/with-session FloorPlansMapper
    (.fetchFloorPlans it building-id)))

(defn fetch-floorplan-systems [building-id floorplan-id]
  (DB/with-session FloorPlansMapper
    (.fetchFloorPlanSystems it building-id floorplan-id)))

(defn new-floorplan [^FloorPlanBean f]
  (DB/with-session FloorPlansMapper
    (.newSystem it f)))



