(ns harborview.webapp
  (:require
    [compojure.route :as R]
    [harborview.service.htmlutils :as U]
    [harborview.systems.html :as SYS])
  (:use
   [compojure.handler :only (api)]
   [compojure.core :only (GET defroutes context)]
   [ring.adapter.jetty :only (run-jetty)]
   [ring.middleware.params :only (wrap-params)]))

(defroutes main-routes
  (GET "/" request (SYS/my-systems))
  (context "/systems" [] SYS/my-routes)
  (R/files "/" {:root "public"})
  (R/resources "/" {:root "public"}))

(def webapp
  (-> main-routes
    api
    wrap-params))

(def server (run-jetty #'webapp {:port 8082 :join? false}))
