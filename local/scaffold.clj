(ns scaffold
  (:require
    [harborview.floorplans.dbx :as FDB]
    [harborview.nodes.html :as NH]
    [harborview.nodes.dbx :as NDB]))

(defn af
  [x]
  (filter #(and (sequential? %) (not-any? sequential? %))
    (rest (tree-seq #(and (sequential? %) (some sequential? %)) seq x))))

(def vl FDB/new-vinapu-element-load)
