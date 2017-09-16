(ns harborview.webapp
  (:gen-class)
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
   [harborview.maunaloa.html :as MAU]
   [harborview.service.htmlutils :as UTIL])
  (:use
   [compojure.handler :only (api)]
   [compojure.core :only (GET defroutes context)]
   [ring.adapter.jetty :only (run-jetty)]
   [ring.middleware.params :only (wrap-params)]))

(P/set-resource-path! "/home/rcs/opt/java/harborview/src/resources/")
(P/cache-off!)

(defroutes main-routes
  ;(GET "/" request (MAU/init-options))
  (GET "/" request (MAU/init-charts))
  ;(GET "/" request (VIN/projects))
  ;(GET "/" request (GJ/general-journal))
  (GET "/" request (HRL/hourlist))
  ;(GET "/" request (CRT/overlook "11"))   ;(CRT/overlook (DBX/active-purchases (U/rs 11))))
  ;(GET "/" request (OPX/route-derivatives "3" OPXD/calls))
  (context "/generaljournal" [] GJ/my-routes)
  (context "/vinapu" [] VIN/my-routes)
  (context "/maunaloa" [] MAU/my-routes)
  (context "/hourlist" [] HRL/my-routes)
  (context "/critters" [] CRT/my-routes)
  (context "/opx" [] OPX/my-routes)
  (R/files "/" {:root "public"})
  (R/resources "/" {:root "public"}))

;(def handler (-> app wrap-params allow-cross-origin)

(def webapp
  (-> main-routes
    api
    wrap-params
    U/allow-cross-origin))

;(def server (run-jetty #'webapp {:port 8082 :join? false}))

(defn -main [args]
<<<<<<< HEAD
  (def server (run-jetty #'webapp {:port 8082 :join? false}))
  (comment server
    (run-jetty #'webapp
               {:port 8443
                :join? false
                :ssl? true
                :keystore "../local/harborview.ssl"
                :key-password "VhCHeUJ4"})))
=======
    (def server (run-jetty #'webapp {:port 8082 :join? false}))
    (comment server
      (run-jetty #'webapp
                 {:port 8443
                  :join? false
                  :ssl? true
                  :keystore "../local/harborview.ssl"
                  :key-password "VhCHeUJ4"})))
>>>>>>> dev/elm

(-main 1)
