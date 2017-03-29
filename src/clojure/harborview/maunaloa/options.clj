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

(defn valid? [o]
  true)


(defn option->json [^DerivativePrice o]
  (let [d (.getDerivative o)
        ivb (try
             (.getIvBuy o)
             (catch Exception e
               -1))
        ivs (if (< ivb 0)
              -1
              (try
                (.getIvSell o)
                (catch Exception e
                  -1)))]
    ;(U/json-response
    {:ticker (-> o .getDerivative .getTicker)
     :days (.getDays o)
     :buy (.getBuy o)
     :sell (.getSell o)
     :iv-buy ivb
     :iv-sell ivs}))

(defn stock [ticker]
  (let [^Tuple3 parsed (parse-html ticker)]
    (.first parsed)))

(defn calls [ticker]
  (let [^Tuple3 parsed (parse-html ticker)]
    (.second parsed)))

(defn puts [ticker]
  (let [^Tuple3 parsed (parse-html ticker)]
    (.third parsed)))
