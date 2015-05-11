(ns scaffold
  (:require
    [harborview.nodes.html :as NH]
    [harborview.nodes.dbx :as NDB]))

(defn af
  [x]
  (filter #(and (sequential? %) (not-any? sequential? %))
    (rest (tree-seq #(and (sequential? %) (some sequential? %)) seq x))))

(defn nx [pid] (NDB/fetch-coord-sys pid))

(defn nh [pid] (NH/cosys pid))
