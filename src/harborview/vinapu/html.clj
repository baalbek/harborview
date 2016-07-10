(ns harborview.vinapu.html
  (:use
   [compojure.core :only (GET PUT defroutes)])
  (:require
   [selmer.parser :as P]
   [harborview.vinapu.dbx :as DBX]
   [harborview.service.htmlutils :as U]))

(defn projects []
  (P/render-file "templates/vinapu/projects.html"
    {}))

(defroutes my-routes
  (GET "/" request (projects)))
