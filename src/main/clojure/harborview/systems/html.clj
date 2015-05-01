(ns harborview.systems.html
  (:import
    [stearnswharf.systems ProjectBean FloorPlanBean])
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


(defn building->json [b]
  {"oid" (.getOid b), "text" (.toHtml b)})

(defn buildings-for [pid]
  (let [buildings (DBF/fetch-buildings (U/rs pid))]
    (U/json-response {"buildings" (map building->json buildings)})))

(HTML/defsnippet floorplans "templates/snippets.html" [:.floorplans] [rows]
  [[:tr (HTML/attr= :class "rows")]]
  (HTML/substitute
    (map (fn [^FloorPlanBean x]
           {:tag :tr, :content [
                                 (U/num->td (.getSystemId x))
                                 (U/num->td (.getBuildingId x))
                                 (U/num->td (.getFloorPlan x))
                                 (U/td (.getBuildingDsc x))
                                 (U/td (.getSystemDsc x))
                                 ]})
      rows)))

(defroutes my-routes
  (GET "/" request (my-systems))
  (GET "/fetchbuildings" [pid] (buildings-for pid))
  (GET "/fetchfloorplans" [bid] (HTML/emit* (floorplans (DBF/fetch-floorplans (U/rs bid))))))


;(GET "/groupsums" [fnr] (H/emit* (groupsums fnr)))

