(ns harborview.vinapu.dbx
  (:import
    [stearnswharf.mybatis.geometry
      ProjectsMapper LocationsMapper SystemsMapper NodesMapper]
    [stearnswharf.mybatis.materials
      LoadsMapper]
    [stearnswharf.mybatis.vinapu
      ElementsMapper]
    [stearnswharf.geometry
      ProjectBean LocationBean SystemBean]
    [stearnswharf.vinapu.elements
      ElementLoadBean])
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

(defn insert-location [pid loc]
  (let [result (LocationBean.)]
    (.setProjectId result pid)
    (.setLocationName result loc)
   (DB/with-session :stearnswharf LocationsMapper
     (.insertLocation it result))
   result))

(defn insert-system [loc sys]
  (let [result (SystemBean.)]
    (.setLocationId result loc)
    (.setSystemName result sys)
   (DB/with-session :stearnswharf SystemsMapper
     (.insertSystem it result))
   result))

(defn insert-element [sys-id dsc n1 n2 plw w1]
  (let [result (ElementLoadBean.)]
    (.setSystemId result sys-id)
    (.setDsc result dsc)
    (.setN1 result n1)
    (.setN2 result n2)
    (.setPlw result plw)
    (.setW1 result w1)
    (DB/with-session :stearnswharf ElementsMapper
     (.insertElement it result))
    result))

(defn insert-element-load [element-id load-id load-factor form-factor]
  (let [result (ElementLoadBean.)]
    (.setOid result element-id)
    (.setLoadId result load-id)
    (.setLoadFactor result load-factor)
    (.setFormFactor result form-factor)
    (DB/with-session :stearnswharf ElementsMapper
     (.insertElementLoad it result))
    result))

(defn fetch-locations [project-id]
  (DB/with-session :stearnswharf LocationsMapper
    (.fetchLocations it project-id)))

(defn fetch-systems [loc-id]
  (DB/with-session :stearnswharf SystemsMapper
    (.fetchSystems it loc-id)))

(defn fetch-nodes [loc-id]
  (DB/with-session :stearnswharf NodesMapper
    (.locationNodes it loc-id)))

(defn fetch-loads []
  (DB/with-session :stearnswharf LoadsMapper
    (.fetchLoads it)))


(defn fetch-element-loads [sys-id]
  (DB/with-session :stearnswharf ElementsMapper
    (.fetchElementLoads it sys-id)))
