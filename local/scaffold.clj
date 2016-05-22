(ns scaffold
  (:import
   [koteriku.models.mybatis HourlistGroupMapper])
  (:require
   [harborview.service.db :as DB]
   [harborview.hourlist.dbx :as DBX]))


(defn groups [show-inactive]
  (DB/with-session :koteriku HourlistGroupMapper
                             (.selectHourlistGroups it show-inactive)))
  ;(DBX/fetch-hourlist-groups show-inactive))

(defn gs [fnr]
  (DB/with-session :koteriku HourlistGroupMapper
                             (.selectGroupBySpec it fnr)))



