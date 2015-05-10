(ns harborview.loads.html
  (:import
    [stearnswharf.loads VinapuLoadBean])
  (:use
    [compojure.core :only (GET PUT defroutes)])
  (:require
    [net.cgrand.enlive-html :as HTML]
    [harborview.loads.dbx :as DBF]
    [harborview.service.htmlutils :as U]
    [harborview.templates.snippets :as SNIP]))


(defn dead-loads []
  (let [loads (DBF/fetch-dead-loads)]
    (U/json-response {"loads" (map U/bean->json loads)})))

(defn live-loads []
  (let [loads (DBF/fetch-live-loads)]
    (U/json-response {"loads" (map U/bean->json loads)})))

(defroutes my-routes
  (GET "/vinapudeadloads" request (dead-loads))
  (GET "/vinapuliveloads" request (live-loads)))

