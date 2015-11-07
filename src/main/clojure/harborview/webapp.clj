(ns harborview.webapp
  (:require
    [net.cgrand.enlive-html :as HTML]
    [compojure.route :as R]
    [harborview.templates.snippets :as SNIP]
    [harborview.elements.html :as E]
    [harborview.systems.html :as SYS]
    [harborview.nodes.html :as N]
    [harborview.loads.html :as LD])
  (:use
   [compojure.handler :only (api)]
   [compojure.core :only (GET defroutes context)]
   [ring.adapter.jetty :only (run-jetty)]
   [ring.middleware.params :only (wrap-params)]))

(HTML/deftemplate index "templates/index.html" []
  [:head] (HTML/substitute (SNIP/head "Harbor View"))
  [:.ribbon-area] (HTML/substitute (SNIP/ribbon)))

(defroutes main-routes
  (GET "/" request (index))
  (R/files "/" {:root "public"})
  (R/resources "/" {:root "public"}))


(def webapp
  (-> main-routes
    api
    wrap-params))

(def server (run-jetty #'webapp {:port 8082 :join? false}))
