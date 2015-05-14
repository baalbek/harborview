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


(defn buildings-for [pid]
  (let [buildings (DBF/fetch-buildings (U/rs pid))]
    (U/json-response {"buildings" (map U/bean->json buildings)})))


;You could always write your own append-attr in the same vein as set-attr. Here is my attempt

;(defn append-attr
;  [& kvs]
;  (fn [node]
;    (let [in-map (apply array-map kvs)
;          old-attrs (:attrs node {})
;          new-attrs (into {} (for [[k v] old-attrs]
;                               [k (str v (get in-map k))]))]
;      (assoc node :attrs new-attrs))))

(HTML/defsnippet floorplan->table "templates/snippets.html" [:.floorplans-form] [^FloorPlanBean f]
  [:.shownewvinapuelement] (HTML/set-attr :data-oid (.getSystemId f))
  [[:tr (HTML/attr= :class "rows")]]
  (HTML/substitute
    (let [vinapu-elements (.getVinapuElements f)]
      (map (fn [^VinapuElementBean x]
             (let [oid (str (.getOid x))]
             {:tag :tr
                :content [
                    (U/td2 [{:tag :a
                             :attrs {:href "#" :class "shownewvinapuelload" :data-oid oid}
                             :content [(str "[ " oid " ] " (.getDsc x))]}])
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
                      ]}))
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
      (HTML/emit* (floorplans rows)))))
  (PUT "/newsystem" [pid bid fid sd gid]
    (let [new-sys (DBF/new-system (U/rs pid) (U/rs bid) (U/rs fid) sd (U/rs gid))]
      (U/json-response {"oid" (.getOid new-sys)})))
  (PUT "/newvinapuelement" [sys dsc n1 n2 plw w1 dload dff lload lff]
    (let [ sys* (U/rs sys)
           n1* (U/rs n1)
           n2* (U/rs n2)
           plw* (U/rs plw)
           w1* (U/rs w1)
           dload* (U/rs dload)
           dff* (U/rs dff)
           lload* (U/rs lload)
           lff* (U/rs lff)
           new-vinapu (DBF/new-vinapu-element
                       sys*
                       dsc
                       n1*
                       n2*
                       plw*
                       w1*)]
      ;(prn sys dsc n1 n2 plw w1 dload dff lload lff)
      (let [oid (.getOid new-vinapu)]
        (if (> dload* 0) (DBF/new-vinapu-element-load oid dload* dff*))
        (if (> lload* 0) (DBF/new-vinapu-element-load oid lload* lff*))
        (U/json-response {"oid" (.getOid new-vinapu)}))))
  (PUT "/newvinapuelementloads" [oid dload dff lload lff]
    (let [oid* (U/rs oid)
          dload* (U/rs dload)
          dff* (U/rs dff)
          lload* (U/rs lload)
          lff* (U/rs lff)]
      (if (> dload* 0) (DBF/new-vinapu-element-load oid* dload* dff*))
      (if (> lload* 0) (DBF/new-vinapu-element-load oid* lload* lff*))
      (U/json-response {"result" "ok"}))))



