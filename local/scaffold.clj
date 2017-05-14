(ns scaffold
  (:import
    [java.time LocalDate]
    [java.sql Date]
    [org.springframework.context.support ClassPathXmlApplicationContext])
  (:require
    [monger.core :as mg]
    [monger.collection :as mc]
    [harborview.service.commonutils :as CU]
    [harborview.maunaloa.options :as OPX]))

  ;(:require))
    ;[harborview.vinapu.dbx :as VIN]
    ;[harborview.vinapu.html :as VH]
    ;[harborview.maunaloa.html :as MAU]
    ;[harborview.maunaloa.dbx :as MAUX]
    ;[harborview.service.db :as DB]
    ;[harborview.service.htmlutils :as U]))

;(def conn (atom (mg/connect-via-uri mongo-uri)))

;(def conn (atom (mg/connect {:host "172.17.0.3"})))

(def conn
  (memoize
    (fn []
      (mg/connect {:host "172.17.0.3"}))))

(defn db []
  (mg/get-db  "maunaloa"))

(defn lt []
  (let [x [[1 1] [2 2] [3 3]]]
    (loop [result {} xx x]
      (if (nil? xx)
        result
        (let [[a b] (first xx)]
          (recur (assoc result a b) (next xx)))))))

(def factory
  (memoize
    (fn []
      (ClassPathXmlApplicationContext. "harborview.xml"))))

(defn etrade []
  (.getBean (factory) "etrade"))

(defn calc []
  (.getBean (factory) "calculator"))

(def calls OPX/calls)

(defn opx [ticker coll]
  (first
    (filter #(.equals (-> % .getDerivative .getTicker) ticker) coll)))

(defn c []
  (opx "YAR7G325" (calls "YAR")))
