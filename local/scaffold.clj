(ns scaffold
  (:import
   [ranoraraku.models.mybatis CritterMapper]
   [koteriku.models.mybatis HourlistGroupMapper])
  (:require
   [selmer.parser :as P]
   [harborview.service.db :as DB]
   [harborview.critters.html :as HTML]
   [harborview.critters.dbx :as DBX]))


(comment groups [show-inactive]
  (DB/with-session :koteriku HourlistGroupMapper
                             (.selectHourlistGroups it show-inactive)))
  ;(DBX/fetch-hourlist-groups show-inactive))

(comment gs [fnr]
  (DB/with-session :koteriku HourlistGroupMapper
                             (.selectGroupBySpec it fnr)))

(defn pa [accid]
  (let [p (DBX/find-purchase-accid accid)]
    (HTML/purchase-area p)))

(defn pax [accid]
  (P/render-file "templates/critters/purchase.html"
    {:purchase (pa accid)}))


(defn paxx [accid]
  (let [p (DBX/find-purchase-accid accid)]
    (HTML/overlook [p])))

(defn fp [purchase-id]
   (DB/with-session :ranoraraku CritterMapper
     (.findPurchase it purchase-id)))
