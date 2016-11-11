(ns harborview.webapp
  (:require
   [selmer.parser :as P]
   [compojure.route :as R]
   [harborview.service.htmlutils :as U]
   [harborview.hourlist.html :as HRL]
   [harborview.critters.html :as CRT]
   [harborview.derivatives.html :as OPX]
   [harborview.derivatives.dbx :as OPXD]
   [harborview.generaljournal.html :as GJ]
   [harborview.vinapu.html :as VIN]
   [harborview.service.htmlutils :as UTIL])
  (:use
   [compojure.handler :only (api)]
   [compojure.core :only (GET defroutes context)]
   [ring.adapter.jetty :only (run-jetty)]
   [ring.middleware.params :only (wrap-params)]))

(P/set-resource-path! "/home/rcs/opt/java/harborview/src/resources/")
(P/cache-off!)

(defroutes main-routes
  (GET "/" request (VIN/projects))
  ;(GET "/" request (GJ/general-journal))
  ;(GET "/" request (HRL/hourlist))
  ;(GET "/" request (CRT/overlook "11"))   ;(CRT/overlook (DBX/active-purchases (U/rs 11))))
  ;(GET "/" request (OPX/route-derivatives "3" OPXD/calls))
  (context "/generaljournal" [] GJ/my-routes)
  (context "/vinapu" [] VIN/my-routes)
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
