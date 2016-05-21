(ns harborview.hourlist.html
  (:import
   [koteriku.beans HourlistBean HourlistGroupBean])
  (:use
   [compojure.core :only (GET PUT defroutes)])
  (:require
   [selmer.parser :as P]
   [harborview.hourlist.dbx :as DBX]
   [harborview.service.htmlutils :as U]))


(defn hourlist []
  (P/render-file "templates/hourlist/hourlist.html"
    {:invoices
      (map (fn [v]
             (let [fnr (.getInvoiceNum v)
                   cust (.getCustomerName v)
                   desc (.getDescription v)]
               {:content (str fnr " - " cust " - " desc) :value (str fnr)}))
        (DBX/fetch-invoices))
     :hourlistgroups
       (map (fn [v]
              {:content (str (.getId v) " - " (.getDescription v)) :value (str (.getId v))})
         (DBX/fetch-hourlist-groups))}))

(defn overview [fnr select-fn]
  (P/render-file "templates/hourlist/hourlistitems.html"
    {:items
     (map (fn [^HourlistBean x]
            {:oid (str (.getOid x))
            :desc (.getDescription x)
            :fnr (str (.getInvoiceNr x))
            :date (U/date->str (.getLocalDate x))
            :hours (str (.getHours x))
            :fromtime (.getFromTime x)
            :totime (.getToTime x)})
      (select-fn fnr))}))

(defn groupsums [fnr]
  (P/render-file "templates/hourlist/groupsums.html"
    {:hourlistsums
      (map (fn [^HourlistGroupBean x]
               {:desc (.getDescription x)
               :sum (str (.getSumHours x))})
        (DBX/fetch-group-sums fnr))}))

(defroutes my-routes
  (GET "/" request (hourlist))
  (GET "/groupsums" [fnr] (groupsums fnr))
  (GET "/overview" [fnr] (overview fnr DBX/fetch-all))
  (PUT "/newhourlistgroup" [groupname]
   (let [bean (DBX/insert-hourlist-group groupname)]
     (U/json-response {"oid" (.getId bean)})))
  (PUT "/insert" [fnr group curdate from_time to_time hours]
    (do
      (DBX/insert-hourlist fnr group curdate from_time to_time hours)
      (overview fnr DBX/fetch-last-5))))

;(U/json-response {"
