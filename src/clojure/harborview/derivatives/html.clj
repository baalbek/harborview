(ns harborview.derivatives.html
  (:import
   [oahu.financial Derivative])
  (:use
   [compojure.core :only (GET PUT defroutes)])
  (:require
   [selmer.parser :as P]
   [harborview.service.db :as DB]
   [harborview.derivatives.dbx :as DBX]
   [harborview.service.htmlutils :as U]))


(defn route-derivatives [tix opx-fn]
  (let [[url user] (DB/dbcp :ranoraraku-dbcp)
        derivatives (opx-fn (read-string tix))]
    (P/render-file "templates/derivatives/overlook.html"
      {:db-url url
       :db-user user
       :derivatives
         (map (fn [^Derivative d]
                {:oid (.getOid d)
                 :ticker (.getTicker d)
                 :x (.getX d)
                 :exp (.getExpiry d)
                 :series (.getSeries d)
                 :optype (.getOpTypeStr d)
                 :days (.getDays d)})
           derivatives)})))

(defroutes my-routes
  (GET "/calls/:tix" [tix] (route-derivatives tix DBX/calls))
  (GET "/puts/:tix" [tix] (route-derivatives tix DBX/puts))
  (PUT "/purchase" [opid price buy volume spot ptype]
    (let [d-bean (DBX/insert (U/rs opid) (U/rs price) (U/rs buy) (U/rs volume) (U/rs spot) (U/rs ptype))]
      (U/json-response {"oid" (.getOid d-bean)}))))
