(ns harborview.maunaloa.html
  (:use
    [compojure.core :only (GET POST defroutes)])
  (:require
    [selmer.parser :as P]
    [harborview.service.htmlutils :as U]))

(defn charts []
  (P/render-file "templates/maunaloa/charts.html" {}))

(defroutes my-routes
  (GET "/" request (charts)))

