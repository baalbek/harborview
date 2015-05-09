(ns harborview.systems.html
  (:import
    [stearnswharf.systems ProjectBean FloorPlanBean VinapuElementBean])
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
  [:#project] (U/populate-select (map projects->select (DBF/fetch-projects))))


(defn building->json [b]
  {"oid" (.getOid b), "text" (.toHtml b)})

(defn buildings-for [pid]
  (let [buildings (DBF/fetch-buildings (U/rs pid))]
    (U/json-response {"buildings" (map building->json buildings)})))



(HTML/defsnippet floorplan->table "templates/snippets.html" [:.floorplans-form] [^FloorPlanBean f]
  [[:tr (HTML/attr= :class "rows")]]
  (HTML/substitute
    (let [vinapu-elements (.getVinapuElements f)]
      (map (fn [^VinapuElementBean x]
             {:tag :tr :content [
                                  (U/num->td (.getOid x))
                                  (U/num->td (.getN1 x))
                                  (U/td (.getN1dsc x))
                                  (U/num->td (.getN2 x))
                                  (U/td (.getN2dsc x))
                                  (U/num->td (.getPlw x))
                                  (U/num->td (.getW1 x))
                                  (U/num->td (.getW2 x))
                                  (U/num->td (.getWnode x))
                                  (U/num->td (.getLoadId x))
                                  (U/td2 (.getLoadDsc x))
                                  (U/num->td (.getLoadFactor x))
                                  (U/num->td (.getFormFactor x))
                                  (U/num->td (.getLoadCategory x))
                                  (U/num2->td (.getServiceLimit x))
                                  (U/num2->td (.getUltimateLimit x))
                                  ]})
        vinapu-elements))))

(defn floorplans [rows]
  (map (fn [^FloorPlanBean x]
         {:tag :details :attrs nil :content [
            {:tag :summary :attrs nil :content [
                (str "[ " (.getSystemId x) " ] [etg: " (.getFloorPlan x) "] " (.getSystemDsc x))]}
            {:tag :div :attrs {:class "vinapu"}
              :content
                         (floorplan->table x)
                         }
            ]})
    rows))

(HTML/defsnippet empty-floorplan "templates/snippets.html" [:.no-floorplan-systems] []
  (HTML/content "No systems for this floor plan!"))

(defroutes my-routes
  (GET "/" request (my-systems))
  (GET "/fetchbuildings" [pid] (buildings-for pid))
  (GET "/fetchfloorplans" [bid] (HTML/emit* (floorplans (DBF/fetch-floorplans (U/rs bid)))))
  (GET "/fetchfloorplansystems" [bid fid]
    (let [rows (DBF/fetch-floorplan-systems (U/rs bid) (U/rs fid))]
      (if (empty? rows) (HTML/emit* (empty-floorplan))
      (HTML/emit* (floorplans rows))))))


