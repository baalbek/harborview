(ns harborview.vinapu.html
  (:use
   [compojure.core :only (GET PUT defroutes)])
  (:require
   [selmer.parser :as P]
   [harborview.vinapu.dbx :as DBX]
   [harborview.service.htmlutils :as U]))

(defn projects []
  (P/render-file "templates/vinapu/projects.html"
    {:projects 
      (concat
        [{:value "-1" :content "-"}]
        ;(map #(.asClojureMap %) (DBX/fetch-projects)))}))
        (map (fn [v] {:content v :value (str (.getOid v))})
          (DBX/fetch-projects)))
    :locations [{:value "-1" :content "-"}]
    :systems [{:value "-1" :content "-"}]
                }))

(defn fetch-x [oid fetch-fn]
  (U/json-response (map U/bean->json (fetch-fn (U/rs oid)))))


(defroutes my-routes
  (GET "/" request (projects))
  (GET "/locations" [oid] (fetch-x oid DBX/fetch-locations))
  (GET "/systems" [oid] (fetch-x oid DBX/fetch-systems))
  (GET "/elementloads" [oid] 
    (P/render-file "templates/vinapu/elementloads.html" {:curelementloads []})))

  ;(GET "/locations" [oid] (U/json-response (map U/bean->json (DBX/fetch-locations (U/rs oid)))))
  ;(GET "/systems" [oid] (U/json-response (map U/bean->json (DBX/fetch-systems (U/rs oid))))))
