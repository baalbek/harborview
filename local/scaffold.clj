(ns scaffold
  (:require
   ;[selmer.parser :as P]
    [harborview.vinapu.dbx :as VIN]
    [harborview.vinapu.html :as VH]
    [harborview.service.db :as DB]))


(defn proj []
  (VIN/fetch-projects)) 

(defn elx []
  (VIN/fetch-element-loads 2)) 

(defn celx []
  (VH/cur-element-loads 2)) 

(comment gs [fnr]
  (DB/with-session :koteriku HourlistGroupMapper
                             (.selectGroupBySpec it fnr)))

(comment hb (HourlistBean.))


(comment pa [oid]
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
