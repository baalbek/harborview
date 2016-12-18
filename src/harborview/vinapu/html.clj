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
  (P/render-file "templates/vinapu/projects.html" {}))

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

  (GET "/projects" [] 
    (let [my-fetch (fn [fetch-fnx] (map U/bean->json (fetch-fnx)))
          projects (my-fetch DBX/fetch-projects)
          loads (my-fetch DBX/fetch-loads)]
      (U/json-response
        {:projects projects :loads loads})))


  (POST "/newproject" request 
    (let [jr (U/json-req-parse request)
          result (DBX/insert-project (jr "pn"))]
          (U/json-response (.getOid result))))

  (POST "/newlocation" request
    (let [jr (U/json-req-parse request)
          result (DBX/insert-location (jr "pid") (jr "loc"))]
          (U/json-response (.getOid result))))

  (POST "/newsystem" request
    (let [jr (U/json-req-parse request)
          result (DBX/insert-system (jr "loc") (jr "sys"))]
          (U/json-response (.getOid result))))

  (GET "/locations" [oid] (fetch-x oid DBX/fetch-locations))

  ;(GET "/systems" [oid] (fetch-x oid DBX/fetch-systems))

  (GET "/systems" [oid] 
    (let [my-fetch (fn [fetch-fnx] (map U/bean->json (fetch-fnx (U/rs oid))))
          systems (my-fetch DBX/fetch-systems)
          nodes (my-fetch DBX/fetch-nodes)]
      (U/json-response
        {:systems systems :nodes nodes})))

  (GET "/elementloads" [oid] 
    (P/render-file "templates/vinapu/elementloads.html" {:curelementloads (cur-element-loads (U/rs oid))})))

  ;(GET "/locations" [oid] (U/json-response (map U/bean->json (DBX/fetch-locations (U/rs oid)))))
  ;(GET "/systems" [oid] (U/json-response (map U/bean->json (DBX/fetch-systems (U/rs oid))))))
