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

(defn lt2 []
  (let [a [1 2 3 4] b ["a" "b" "c" "d"]]
    (loop [aa a bb b]
      (if (not (nil? aa))
        (do
          (println (first aa) "-" (first bb))
          (recur (next aa) (next bb)))))))

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


(defmacro xx [f & lists]
  (let [num-lists (count lists)]
    (cond 
      (= 2 num-lists) 
        (let [[a b] lists]
          `(loop [a# ~a b# ~b]
            (if (not (nil? a#))
              (do
                (~f (first a#) (first b#))
                (recur (next a#) (next b#))))))
      (= 3 num-lists) 
        (let [[a b c] lists]
          `(loop [a# ~a b# ~b c# ~c]
            (if (not (nil? a#))
              (do
                (~f (first a#) (first b#) (first c#))
                (recur (next a#) (next b#) (next c#))))))
      (= 4 num-lists) 
        (let [[a b c d] lists]
          `(loop [a# ~a b# ~b c# ~c d# ~d]
            (if (not (nil? a#))
              (do
                (~f (first a#) (first b#) (first c#) (first d#))
                (recur (next a#) (next b#) (next c#) (next d#))))))
      (= 5 num-lists) 
        (let [[a b c d e] lists]
          `(loop [a# ~a b# ~b c# ~c d# ~d e# ~e]
            (if (not (nil? a#))
              (do
                (~f (first a#) (first b#) (first c#) (first d#) (first e#))
                (recur (next a#) (next b#) (next c#) (next d#) (next e#)))))))))
