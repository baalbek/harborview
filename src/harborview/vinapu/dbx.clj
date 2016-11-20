(ns harborview.vinapu.dbx
  (:import
    [stearnswharf.mybatis.geometry 
      ProjectsMapper LocationsMapper SystemsMapper]
    [stearnswharf.mybatis.vinapu
      ElementsMapper]
    [stearnswharf.geometry
      ProjectBean])
  (:require
    [harborview.service.db :as DB]))


(defn fetch-projects []
  (DB/with-session :stearnswharf ProjectsMapper
    (.fetchProjects it)))

(defn insert-project [pname]
  (let [result (ProjectBean.)]
    (.setProjectName result pname)
  (DB/with-session :stearnswharf ProjectsMapper
    (.insertProject it result))
    result))

(defn fetch-locations[project-id]
  (DB/with-session :stearnswharf LocationsMapper 
    (.fetchLocations it project-id)))

(defn fetch-systems[loc-id]
  (DB/with-session :stearnswharf SystemsMapper 
    (.fetchSystems it loc-id)))

(defn fetch-element-loads [sys-id]
  (DB/with-session :stearnswharf ElementsMapper 
    (.fetchElementLoads it sys-id)))
