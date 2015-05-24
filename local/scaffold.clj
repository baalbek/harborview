(ns scaffold
  (:require
    [harborview.floorplans.dbx :as DBF]
    [harborview.systems.html :as SH]
    [harborview.elements.html :as EH]
    [harborview.elements.dbx :as DBE]
    [harborview.nodes.html :as NH]
    [harborview.nodes.dbx :as NDB]))

(defn af
  [x]
  (filter #(and (sequential? %) (not-any? sequential? %))
    (rest (tree-seq #(and (sequential? %) (some sequential?  seq x))))))


(defmacro j1 [f1] `(fn [v#] (~f1 v#)))

(defmacro j2 [f1 f2] `(fn [v#] [(~f1 v#) (~f2 v#)]))

(defmacro j3 [f1 f2 f3] `(fn [v#] [(~f1 v#) (~f2 v#) (~f3 v#)]))

(defn buildings [pid] (SH/buildings-for pid))

(defn new-sys [pid bid fid sd gid]
  (DBF/new-system pid bid fid sd gid))

(defn elsys [bid fid] (EH/element-systems bid fid))

(defn sysnodes [sysid] (NDB/fetch-system-nodes sysid))

(defn fd [sysid] (DBE/fetch-dist-loads sysid))


;(def steels DBE/new-steel-elements)

(def nodes ["14" "15" "16" "-1" "-1"])

(def qloads ["13" "-1" "-1" "-1"])

(def nloads ["0.0" "-10" "0.0" "0.0" "0.0"])

(def nlf ["1.3" "1.3" "1.3" "1.3" "1.3"])


(defn steels [] (DBE/new-steel-elements 45 7 nodes qloads nloads nlf))


(defn se [sysid] (DBE/fetch-steel-elements sysid))
