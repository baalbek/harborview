(ns harborview.floorplans.dbx
  (:import
    [stearnswharf.systems ProjectBean FloorPlanBean SystemBean]
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

(defn new-system [pid bid fid sd gid]
  (let [s (SystemBean.)]
    (doto s
      (.setProjectId pid)
      (.setBuildingId bid)
      (.setFloorPlan fid)
      (.setSd sd)
      (.setGroupId gid))
    (DB/with-session FloorPlansMapper
      (do
        (.newSystem it s)
        (.addToFloorPlans it s)))
    s))



