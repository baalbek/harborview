(ns harborview.floorplans.dbx
  (:import
    [stearnswharf.systems 
      ProjectBean 
      FloorPlanBean 
      SystemBean 
      VinapuElementBean 
      VinapuElementLoadBean ]
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

;oid | sys_id |    dsc     | n1 | n2 | plw | w1  | w2 | angle | element_type | wnode

(defn new-vinapu-element [sys-id dsc n1 n2 plw w1]
  (let [v (VinapuElementBean.)]
    (doto v
      (.setSystemId sys-id)
      (.setDsc dsc)
      (.setN1 n1)
      (.setN2 n2)
      (.setPlw plw)
      (.setW1 w1))
    (DB/with-session FloorPlansMapper
      (.newVinapuElement it v))
    v))


(defn new-vinapu-element-load [element-id load-id form-factor]
  (let [v (VinapuElementLoadBean. element-id load-id form-factor)]
    (DB/with-session FloorPlansMapper
      (.newVinapuElementLoad it v))))

