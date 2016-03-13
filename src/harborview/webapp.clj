(ns harborview.webapp
  (:require
    [net.cgrand.enlive-html :as HTML]
    [compojure.route :as R]
    [harborview.generaljournal.html :as GJ]
    [harborview.templates.snippets :as SNIP])
  (:use
    [compojure.handler :only (api)]
    [compojure.core :only (GET defroutes context)]
    [ring.adapter.jetty :only (run-jetty)]
    [ring.middleware.params :only (wrap-params)]))

(HTML/deftemplate index "templates/index.html" []
  [:head] (HTML/substitute (SNIP/head))
  ;[:#sidebar-wrapper] (HTML/substitute (SNIP/menu))
  [:.scripts] (HTML/substitute (SNIP/scripts)))

(defroutes main-routes
  (GET "/" request (index))
  ;(GET "/" request (GJ/general-journal))
  (context "/generaljournal" [] GJ/my-routes)
  (R/files "/" {:root "public"})
  (R/resources "/" {:root "public"}))

(def webapp
  (-> main-routes
    api
    wrap-params))

(def server (run-jetty #'webapp {:port 8082 :join? false}))
