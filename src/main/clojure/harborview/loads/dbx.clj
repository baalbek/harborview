(ns harborview.loads.dbx
  (:import
    [stearnswharf.mybatis LoadsMapper]
    [stearnswharf.loads VinapuLoadBean])
  (:require
    [harborview.service.db :as DB]))

(def fetch-dead-loads
  (memoize
    (fn []
      (DB/with-session LoadsMapper(.fetchVinapuDeadLoads it)))))

(def fetch-live-loads
  (memoize
    (fn []
      (DB/with-session LoadsMapper(.fetchVinapuLiveLoads it)))))



