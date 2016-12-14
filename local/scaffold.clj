(ns scaffold
  (:require
   ;[selmer.parser :as P]
    [harborview.vinapu.dbx :as VIN]
    [harborview.vinapu.html :as VH]
    [harborview.maunaloa.html :as MAU]
    [harborview.service.db :as DB]
    [harborview.service.htmlutils :as U]))


(def jr U/json-response)
(def bj U/bean->json)

(defn proj []
  (VIN/fetch-projects)) 

(defn projx []
  (VH/fetch-projects)) 

(defn locs [oid]
  (VIN/fetch-locations oid)) 

(defn sys [loc-id]
  (VIN/fetch-systems loc-id)) 

(defn nodes [loc-id]
  (VIN/fetch-nodes loc-id)) 

(defn elx []
  (VIN/fetch-element-loads 2)) 

(defn celx []
  (VH/cur-element-loads 2)) 

(defn tix []
  (MAU/tickers))

(defn tixc []
  (MAU/ticker-chart 2))

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
