(ns scaffold
  (:import
    [java.time LocalDate]
    [java.sql Date]
    [org.springframework.context.support ClassPathXmlApplicationContext])
  (:require
    [harborview.service.commonutils :as CU]
    [harborview.maunaloa.options :as OPX]))

  ;(:require))
    ;[harborview.vinapu.dbx :as VIN]
    ;[harborview.vinapu.html :as VH]
    ;[harborview.maunaloa.html :as MAU]
    ;[harborview.maunaloa.dbx :as MAUX]
    ;[harborview.service.db :as DB]
    ;[harborview.service.htmlutils :as U]))

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
