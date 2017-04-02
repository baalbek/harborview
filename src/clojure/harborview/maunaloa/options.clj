(ns harborview.maunaloa.options
  (:import
    [org.springframework.beans.factory BeanFactory]
    [org.springframework.context.support ClassPathXmlApplicationContext]
    [oahu.dto Tuple3]
    [oahu.financial Derivative DerivativePrice StockPrice]
    [oahu.financial.repository EtradeRepository])
  (:use
    [harborview.service.commonutils :only (defn-memo)])
  (:require
    [harborview.service.commonutils :as CU]
    [harborview.service.htmlutils :as U]))

(defn-memo spring-context []
  (println "Initializing spring context: harborview.xml")
  (ClassPathXmlApplicationContext. "harborview.xml"))


(defn get-bean  [bn]
  (let [^BeanFactory factory (spring-context)]
    (.getBean factory bn)))

(defn-memo parse-html [ticker]
  (let [^EtradeRepository e (get-bean "etrade")]
    (.parseHtmlFor e ticker nil)))

(defn check-implied-vol [ox]
  (try
    (if (> (.getIvBuy ox) 0)
      (if (> (.getIvSell ox) 0)
        true
        (do
          (println "Iv sell <= 0 for: " (-> ox .getDerivative .getTicker))
          false))
      (do
        (println "Iv buy <= 0 for: " (-> ox .getDerivative .getTicker))
        false))
    (catch Exception ex
        (println "Iv sell fail for: " (-> ox .getDerivative .getTicker))
        false)))


(defn valid? [ox]
  (if (> (.getBuy ox) 0)
    (if (> (.getSell ox) 0)
      (check-implied-vol ox)
      false)
    false))

(defn option->json [^DerivativePrice o]
  (let [d (.getDerivative o)
        sp (.getStockPrice o)]
    ;(U/json-response
    {:dx (CU/ld->str (.getLocalDx sp))
     :ticker (-> o .getDerivative .getTicker)
     :days (.getDays o)
     :buy (.getBuy o)
     :sell (.getSell o)
     :iv-buy (.getIvBuy o)
     :iv-sell (.getIvSell o)}))

(defn stock [ticker]
  (let [^Tuple3 parsed (parse-html ticker)]
    (.first parsed)))

(defn calls [ticker]
  (let [^Tuple3 parsed (parse-html ticker)]
    (filter valid? (.second parsed))))

(defn puts [ticker]
  (let [^Tuple3 parsed (parse-html ticker)]
    (filter valid? (.third parsed))))
