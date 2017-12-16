(ns scaffold
  (:import
    [java.time LocalDate]
    [java.sql Date]
    [org.springframework.context.support ClassPathXmlApplicationContext]
    [ org.bson.types ObjectId]
    [ranoraraku.models.mybatis CritterMapper]
    [java.time.temporal ChronoUnit])
  (:use
    [harborview.service.commonutils :only (*reset-cache*)])
  (:require
    [monger.core :as mg]
    [monger.collection :as mc]
    [harborview.service.commonutils :as CU]
    [harborview.maunaloa.options :as OPX]
    [harborview.maunaloa.html :as H]
    [harborview.service.db :as DB]
    [harborview.service.springservice :as S]
    [harborview.maunaloa.dbx :as DBX]))

  ;(:require))
    ;[harborview.vinapu.dbx :as VIN]
    ;[harborview.vinapu.html :as VH]
    ;[harborview.maunaloa.html :as MAU]
    ;[harborview.maunaloa.dbx :as MAUX]
    ;[harborview.service.db :as DB]
    ;[harborview.service.htmlutils :as U]))

;(def conn (atom (mg/connect-via-uri mongo-uri)))

;(def conn (atom (mg/connect {:host "172.17.0.3"})))

(def factory
  (memoize
    (fn []
      (ClassPathXmlApplicationContext. "harborview.xml"))))

(defn calc []
  (.getBean (factory) "calculator"))

(comment opx [oid status optype]
  (DB/with-session :ranoraraku CritterMapper
    (.purchasesWithSales it oid 11 status optype)))

(defn t [d0 d1]
  (let [days (.between ChronoUnit/DAYS d0 d1)]
    (/ days 365.0)))

(def px OPX/purchasesales->json)

(def stox OPX/stock)

(def calls OPX/calls)
(def puts OPX/puts)

(def opx1 (:opx1 DBX/opx))
(def opx2 (:opx2 DBX/opx))

(def sell DBX/sell-purchase)

(def opx DBX/option-purchases)

(def fpx H/fetchpurchases)

(comment
  (def min-dx (LocalDate/of 2004 1 1))

  (defn months []
    (let [prices (DB/fetch-prices-m 3 (java.sql.Date/valueOf min-dx))]
      (prn "Num beans: " (count prices))
      (DB/candlestick-months prices)))

  (defn verify [m]
    (map (fn [x] (let [d0 (first m) d1 (last m)]
                   [d0 d1])) m)))


(comment
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

  (def tc H/ticker-chart))
