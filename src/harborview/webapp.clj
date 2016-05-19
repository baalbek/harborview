(ns harborview.webapp
  (:require
   [selmer.parser :as P]
   [compojure.route :as R]
   [harborview.service.htmlutils :as U]
   [harborview.critters.dbx :as DBX]
   [harborview.hourlist.html :as HRL]
   [harborview.critters.html :as CRT]
   [harborview.derivatives.html :as OPX]
   [harborview.generaljournal.html :as GJ]
   [harborview.service.htmlutils :as UTIL])
  (:use
   [compojure.handler :only (api)]
   [compojure.core :only (GET defroutes context)]
   [ring.adapter.jetty :only (run-jetty)]
   [ring.middleware.params :only (wrap-params)]))

(P/set-resource-path! "/home/rcs/opt/java/harborview/src/resources/")
(P/cache-off!)

(defroutes main-routes
  ;(GET "/" request (HRL/hourlist))
  (GET "/" request (CRT/overlook (DBX/active-purchases (U/rs 11))))
  (context "/generaljournal" [] GJ/my-routes)
  (context "/hourlist" [] HRL/my-routes)
  (context "/critters" [] CRT/my-routes)
  (context "/opx" [] OPX/my-routes)
  (R/files "/" {:root "public"})
  (R/resources "/" {:root "public"}))

(def webapp
  (-> main-routes
    api
    wrap-params))

(def server (run-jetty #'webapp {:port 8082 :join? false}))

;(def server (run-jetty #'webapp {:port 8443 :join? false :ssl? true :keystore "keystore" :key-password "q2uebec9"}))
