(ns harborview.vinapu.dbx
  (:import
    [stearnswharf.mybatis.geometry 
      ProjectsMapper LocationsMapper SystemsMapper]
    [stearnswharf.mybatis.vinapu
      ElementsMapper]
    [stearnswharf.vinapu.elements
      ElementLoadBean])
  (:require
    [harborview.service.db :as DB]))


(defn fetch-projects []
  (DB/with-session :stearnswharf ProjectsMapper
    (.fetchProjects it)))

(defn fetch-locations[project-id]
  (DB/with-session :stearnswharf LocationsMapper 
    (.fetchLocations it project-id)))

(defn fetch-systems[loc-id]
  (DB/with-session :stearnswharf SystemsMapper 
    (.fetchSystems it loc-id)))

(defn fetch-element-loads [sys-id]
  (DB/with-session :stearnswharf ElementsMapper 
    (.fetchElementLoads it sys-id)))
