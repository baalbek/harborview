(ns scaffold
  (:import
    [java.time LocalDate]
    [java.sql Date]
    [org.springframework.context.support ClassPathXmlApplicationContext]
    [ org.bson.types ObjectId])
  (:require
    [monger.core :as mg]
    [monger.collection :as mc]
    [harborview.service.commonutils :as CU]
    [harborview.maunaloa.options :as OPX]
    [harborview.maunaloa.html :as H]))

  ;(:require))
    ;[harborview.vinapu.dbx :as VIN]
    ;[harborview.vinapu.html :as VH]
    ;[harborview.maunaloa.html :as MAU]
    ;[harborview.maunaloa.dbx :as MAUX]
    ;[harborview.service.db :as DB]
    ;[harborview.service.htmlutils :as U]))

;(def conn (atom (mg/connect-via-uri mongo-uri)))

;(def conn (atom (mg/connect {:host "172.17.0.3"})))

(def min-dx (LocalDate/of 2014 1 1))

(defn id []
  (ObjectId.))

(def conn
  (memoize
    (fn []
      (mg/connect {:host "172.17.0.3"}))))

(defn db []
  ;(mg/get-db  "maunaloa")
  (mg/get-db  (conn) "monger-test"))


(defn insert []
  ;(mc/insert-and-return (db) "documents" {:name "John" :age 30})
  (let [
        db   (mg/get-db (conn) "monger-test")
        oid  (ObjectId.)
        doc  {:_id oid :first_name "Alpakka" :last_name "Shurt"}]
    ;(mc/insert db "documents" (merge doc {:_id oid}))))
    (prn oid)
    (mc/insert db "documents" doc)))

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

(def tc H/ticker-chart)
