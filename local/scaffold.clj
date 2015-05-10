(ns scaffold
  (:import [stearnswharf.systems SystemBean])
  (:require
    [net.cgrand.enlive-html :as HTML]
    [harborview.service.db :as db]
    [harborview.systems.html :as s]
    [harborview.floorplans.dbx :as d]
    [harborview.loads.dbx :as ld]))

(defn af
  [x]
  (filter #(and (sequential? %) (not-any? sequential? %))
    (rest (tree-seq #(and (sequential? %) (some sequential? %)) seq x))))

(defn ffp [bid]
  (d/fetch-floorplans bid))

(defn ffps [bid fid]
  (d/fetch-floorplan-systems bid fid))

(defn fp [bid]
  (let [floorplans (ffp bid)
        print-fp (fn [x]
                   (prn (.getSystemId x) "-"(.getSystemDsc x))
                   (.getFloorPlan x))]
    (map print-fp floorplans)))

(def emp s/empty-floorplan)

(def bf s/buildings-for)

(def sfp s/floorplans)

(def emit HTML/emit*)

(defn ex [n] (s/floorplan->table (nth (ffp 2) n)))

(def e (comp print clojure.string/join HTML/emit*))

(defn px [bid] (sfp (take 10 (ffp bid))))

(defn pxx [bid] (e (px bid)))

(defn crsys [pid bid fid sd]
  (let [s (SystemBean.)]
    (doto s
      (.setProjectId pid)
      (.setBuildingId bid)
      (.setFloorPlan fid)
      (.setSd sd)
      (.setGroupId 1))
    s))

(def nsys d/new-system)

(def loads ld/fetch-vinapu-loads)
