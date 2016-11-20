(ns harborview.vinapu.html
  (:import
    [stearnswharf.vinapu.elements ElementLoadBean])
  (:use
   [compojure.core :only (GET POST defroutes)])
  (:require
    [clj-json.core :as json]
   [selmer.parser :as P]
   [harborview.vinapu.dbx :as DBX]
   [harborview.service.htmlutils :as U]))

(defn projects []
  (P/render-file "templates/vinapu/projects.html"
    {:projects 
      (concat
        [{:value "-1" :content "-"}]
        (map (fn [v] {:content v :value (str (.getOid v))})
          (DBX/fetch-projects)))
    :locations [{:value "-1" :content "-"}]
    :systems [{:value "-1" :content "-"}]
                }))

(defn fetch-projects []
  (U/json-response
    (map (fn [v] {"t" (.toString v) "v" (str (.getOid v))})
      (DBX/fetch-projects))))

(defn fetch-x [oid fetch-fn]
  (U/json-response (map U/bean->json (fetch-fn (U/rs oid)))))

(defn cur-element-loads [sys-id]
  (let [loads (DBX/fetch-element-loads sys-id)]
        ;load->html (fn [^ElementLoadBean lx] 
        ;              )]
    (map bean loads)))


(defroutes my-routes
  (GET "/" request (projects))
  (GET "/projects" [] (fetch-projects))
  (POST "/newproject" request 
    (let [r (slurp (:body request))
          jr (json/parse-string r)
          result (DBX/insert-project (jr "pn"))]
          (U/json-response (.getOid result))))
  (GET "/locations" [oid] (fetch-x oid DBX/fetch-locations))
  (GET "/systems" [oid] (fetch-x oid DBX/fetch-systems))
  (GET "/elementloads" [oid] 
    (P/render-file "templates/vinapu/elementloads.html" {:curelementloads (cur-element-loads (U/rs oid))})))

  ;(GET "/locations" [oid] (U/json-response (map U/bean->json (DBX/fetch-locations (U/rs oid)))))
  ;(GET "/systems" [oid] (U/json-response (map U/bean->json (DBX/fetch-systems (U/rs oid))))))
