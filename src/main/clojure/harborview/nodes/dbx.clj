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

(comment fetch-coord-sys [project-id]
  (DB/with-session NodesMapper 
    (.fetchCoordSys it project-id)))



