(ns harborview.systems.html
  (:import
    [stearnswharf.systems ProjectBean])
  (:use
    [compojure.core :only (GET PUT defroutes)])
  (:require
    [net.cgrand.enlive-html :as HTML]
    [harborview.service.htmlutils :as U]
    [harborview.templates.snippets :as SNIP]
    [harborview.floorplans.dbx :as DBF]))


(defn projects->select [^ProjectBean v]
  (let [oid (.getOid v)]
    {:name (.toHtml v) :value (str oid) :selected (.isSelected v)}))


(HTML/deftemplate my-systems "templates/floorplans.html" []
  [:head] (HTML/substitute (SNIP/head "Harbor View" "/js/dialogs.js"))
  [:.ribbon-area] (HTML/substitute (SNIP/ribbon))
  [:#projects] (U/populate-select (map projects->select (DBF/fetch-projects))))


(defn buildings-for [pid]
  ;(let [buildings (DBF/fetch-buildings (U/rs pid))]
  (U/json-response {"result" [{"oid" "2", "val" "2 - Gregers"} {"oid" "3", "val" "3 - Whatever"}]}))


(defroutes my-routes
  (GET "/" request (my-systems))
  (GET "/fetchbuildings" [pid] (buildings-for pid)))


