(ns scaffold
  (:require
    [harborview.floorplans.dbx :as DBF]
    [harborview.systems.html :as SH]
    [harborview.elements.html :as EH]
    [harborview.nodes.html :as NH]
    [harborview.nodes.dbx :as NDB]))

(defn af
  [x]
  (filter #(and (sequential? %) (not-any? sequential? %))
    (rest (tree-seq #(and (sequential? %) (some sequential? %)) seq x))))


(defn buildings [pid] (SH/buildings-for pid))

(defn new-sys [pid bid fid sd gid]
  (DBF/new-system pid bid fid sd gid))

(defn elsys [bid fid] (EH/element-systems bid fid))

(defn sysnodes [sysid] (NDB/fetch-system-nodes sysid))



