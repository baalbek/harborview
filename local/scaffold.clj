(ns scaffold
  (:require
    [net.cgrand.enlive-html :as HTML]
    [harborview.systems.html :as s]
    [harborview.floorplans.dbx :as d]))

(defn af
  [x]
  (filter #(and (sequential? %) (not-any? sequential? %))
    (rest (tree-seq #(and (sequential? %) (some sequential? %)) seq x))))

(defn ffp [bid]
  (d/fetch-floorplans bid))

(defn fp [bid]
  (let [floorplans (ffp bid)
        print-fp (fn [x]
                   (prn (.getSystemId x) "-"(.getSystemDsc x))
                   (.getFloorPlan x))]
    (map print-fp floorplans)))


(def sfp s/floorplans)

(def emit HTML/emit*)

(defn ex [n] (s/floorplan->table (nth (ffp 2) n)))

(def e (comp print clojure.string/join HTML/emit*))

(defn px [bid] (sfp (take 10 (ffp bid))))

(defn pxx [bid] (e (px bid)))

