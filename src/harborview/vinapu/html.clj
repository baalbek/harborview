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
    (map bean loads)))

(defn elementloads->html [sys-id]
    (P/render-file
      "templates/vinapu/elementloads.html"
      {:curelementloads
        (cur-element-loads (U/rs sys-id))}))

(defroutes my-routes

  (GET "/" request (projects))

  (GET "/projects" []
    (let [my-fetch (fn [fetch-fnx] (map U/bean->json (fetch-fnx)))
          projects (my-fetch DBX/fetch-projects)
          loads (DBX/fetch-loads)
          load-cat-fn (fn [cat] (map U/bean->json (filter #(= (.getLoadCategory %) cat) loads)))
          dead-loads (load-cat-fn 1)
          live-loads (load-cat-fn 2)]

      (U/json-response
        {:projects projects :deadloads dead-loads :liveloads live-loads})))


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

  (POST "/newelement" request
    (let [jr (U/json-req-parse request)]
        (println "sysid: " (jr "sysid"))
        (println "el: " (jr "el"))
        (println "n1: " (jr "n1"))
        (println "n2: " (jr "n2"))
        (println "plw: " (jr "plw"))
        (println "w: " (jr "w"))
        (println "l1: " (jr "l1"))
        (println "lf1: " (jr "lf1"))
        (println "ff1: " (jr "ff1"))
        (println "l2: " (jr "l2"))
        (println "lf2: " (jr "lf2"))
        (println "lf2: " (jr "ff2"))
        (U/json-response "BlaBlaBla!")))

  (GET "/locations" [oid] (fetch-x oid DBX/fetch-locations))

  ;(GET "/systems" [oid] (fetch-x oid DBX/fetch-systems))

  (GET "/systems" [oid]
    (let [my-fetch (fn [fetch-fnx] (map U/bean->json (fetch-fnx (U/rs oid))))
          systems (my-fetch DBX/fetch-systems)
          nodes (my-fetch DBX/fetch-nodes)]
      (U/json-response
        {:systems systems :nodes nodes})))

  (GET "/elementloads" [oid]
    (elementloads->html oid)))

    ;(P/render-file "templates/vinapu/elementloads.html" {:curelementloads (cur-element-loads (U/rs oid))})))

  ;(GET "/locations" [oid] (U/json-response (map U/bean->json (DBX/fetch-locations (U/rs oid)))))
  ;(GET "/systems" [oid] (U/json-response (map U/bean->json (DBX/fetch-systems (U/rs oid))))))
