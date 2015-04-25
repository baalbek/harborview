(ns harborview.webapp
  (:require
    [compojure.route :as R]
    [harborview.templates.snippets :as SNIP]
    [net.cgrand.enlive-html :as HTML])
  (:use
   [compojure.handler :only (api)]
   [compojure.core :only (GET defroutes context)]
   [ring.adapter.jetty :only (run-jetty)]
   [ring.middleware.params :only (wrap-params)]))

(HTML/deftemplate index "templates/index.html" []
  [:head] (HTML/substitute (SNIP/head "Harbor View" "/js/dialogs.js")))

(defroutes main-routes
  (GET "/" request (index))
  (R/files "/" {:root "public"})
  (R/resources "/" {:root "public"}))

(def webapp
  (-> main-routes
    api
    wrap-params))

(def server (run-jetty #'webapp {:port 8082 :join? false}))
