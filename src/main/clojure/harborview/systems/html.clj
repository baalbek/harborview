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
  [:#projects] (U/populate-select (map projects->select (DBF/fetch-projects))))


(defn building->json [b]
  {"oid" (.getOid b), "text" (.toHtml b)})

(defn buildings-for [pid]
  (let [buildings (DBF/fetch-buildings (U/rs pid))]
    (U/json-response {"buildings" (map building->json buildings)})))

(defn floorplans [rows]
  (map (fn [^FloorPlanBean x]
         {:tag :details :attrs nil :content [
            {:tag :summary :attrs nil :content [
                (str "[ " (.getSystemId x) " ] " (.getSystemDsc x))]}
                                              ]})
    rows))

(comment
  (HTML/defsnippet floorplans "templates/snippets.html" [:.floorplans] [rows]
    [[:tr (HTML/attr= :class "rows")]]
    (HTML/substitute
      (map (fn [^FloorPlanBean x]
             ;{:tag :tr, :content [
             {:tag :details :attrs nil :content [
                                                  {:tag :summary :attrs nil :content [
                                                                                       (str "[ " (.getSystemId x) " ] " (.getSystemDsc x))]}
                                                  ]})

        ;     ]}]})

        ;(U/num->td (.getSystemId x))
        ;(U/num->td (.getBuildingId x))
        ;(U/num->td (.getFloorPlan x))
        ;(U/td (.getBuildingDsc x))
        ;(U/td (.getSystemDsc x))
        ;]})
        rows)))
  )
(comment
  (def pre-empty (repeat 5 (U/td nil)))
  (def post-empty (repeat 16 (U/td nil)))

  (defn vinapu-element->td [^VinapuElementBean v]
    [
      (U/num->td (.getOid v))
      (U/td2 (.getDsc v))
      (U/num->td (.getN1 v))
      (U/num->td (.getN2 v))
      (U/num->td (.getPlw v))
      (U/num->td (.getW1 v))
      (U/num->td (.getW2 v))
      (U/num->td (.getWnode v))
      (U/num->td (.getLoadId v))
      (U/td2 (.getLoadDsc v))
      (U/num->td (.getLoadFactor v))
      (U/num->td (.getFormFactor v))
      (U/num->td (.getLoadCategory v))
      (U/num->td (.getLoadQ v))
      (U/num->td (.getServiceLimit v))
      (U/num->td (.getUltimateLimit v))
      ])

  (defn floorplan->td [^FloorPlanBean f]
    (let [vinapu-elements (.getVinapuElements f)
          vinapu (if (> (count vinapu-elements) 0)
                   (map vinapu-element->td vinapu-elements)
                   post-empty)
          floor {:tag :tr, :content (concat
                                      [
                                        (U/num->td (.getSystemId f))
                                        (U/num->td (.getBuildingId f))
                                        (U/num->td (.getFloorPlan f))
                                        (U/td (.getBuildingDsc f))
                                        (U/td (.getSystemDsc f))
                                        ]
                                      (first vinapu))}
          ]
      (loop [result [floor]
             vinapux (rest vinapu)]
        (if-not (seq vinapux)
          result
          (recur
            (conj result {:tag :tr :attrs nil :content (concat pre-empty (first vinapux))})
            (rest vinapux))))
      ))

  (defn floorplans [rows]
    (let [
           headers ["Sys Id" "Building Id" "Floor Plan" "Building Dsc" "Sys Dsc" "E.id" "E.dsc"
                    "N1" "N2" "Plw" "W1" "W2" "Wnode" "Ld id" "Ld dsc" "L.f." "F.f." "L.cat" "Q" "S.l" "U.l"]
           thead (map U/th headers)
           tbody (flatten (map floorplan->td rows))
           ]
      {:tag :table :attrs {:class "std"}
       :content [{:tag :thead :attrs nil :content [
                                                    {:tag :tr :attrs nil :content thead}
                                                    {:tag :tbody :attrs nil :content tbody}
                                                    ]}]}))
  )

(defroutes my-routes
  (GET "/" request (my-systems))
  (GET "/fetchbuildings" [pid] (buildings-for pid))
  (GET "/fetchfloorplans" [bid] (HTML/emit* (floorplans (DBF/fetch-floorplans (U/rs bid))))))


;(GET "/groupsums" [fnr] (H/emit* (groupsums fnr)))

