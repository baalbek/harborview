(ns scaffold
  (:import
    [koteriku.beans
      HourlistBean])
  (:require
   ;[selmer.parser :as P]
   ;[harborview.service.db :as DB]
   ;[harborview.critters.html :as HTML]
   [harborview.critters.dbx :as DBX]))


(comment groups [show-inactive]
  (DB/with-session :koteriku HourlistGroupMapper
                             (.selectHourlistGroups it show-inactive)))
  ;(DBX/fetch-hourlist-groups show-inactive))

(comment gs [fnr]
  (DB/with-session :koteriku HourlistGroupMapper
                             (.selectGroupBySpec it fnr)))

(def hb (HourlistBean.))


(defn pa [oid]
  (let [p (DBX/find-purchase-accid oid)]
    p))

(comment pa [accid]
  (let [p (DBX/find-purchase-accid accid)]
    (HTML/purchase-area p)))

(comment pax [accid]
  (P/render-file "templates/critters/purchase.html"
    {:purchase (pa accid)}))


(comment paxx [accid]
  (let [p (DBX/find-purchase-accid accid)]
    (HTML/overlook [p])))

(comment fp [purchase-id]
   (DB/with-session :ranoraraku CritterMapper
     (.findPurchase it purchase-id)))
