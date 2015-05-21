(ns harborview.nodes.dbx
  (:import
    [stearnswharf.mybatis NodesMapper]
    [stearnswharf.nodes NodeBean])
  (:require
    [harborview.service.db :as DB]))

(defn fetch-all-nodes [project-id]
  (DB/with-session NodesMapper 
    (.fetchAllNodes it project-id)))

(defn fetch-nodes [project-id cosyid]
  (DB/with-session NodesMapper
    (.fetchNodes it project-id cosyid)))

(defn fetch-system-nodes [sys-id]
  (DB/with-session NodesMapper
    (let [coord-sys (.systemCoordSys it sys-id)]
      (.systemNodes it sys-id coord-sys))))

(comment fetch-system-nodes2 [sys-id]
  (DB/with-session NodesMapper
    (.systemCoordSys it sys-id)))

(comment fetch-coord-sys [project-id]
  (DB/with-session NodesMapper 
    (.fetchCoordSys it project-id)))

