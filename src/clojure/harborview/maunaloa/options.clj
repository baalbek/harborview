(ns harborview.maunaloa.options
  (:import
    [java.io IOException File FileOutputStream FileNotFoundException]
    [java.time LocalTime LocalDate]
    [org.springframework.beans.factory BeanFactory]
    [org.springframework.context.support ClassPathXmlApplicationContext]
    [oahu.dto Tuple3]
    [oahu.financial Derivative DerivativePrice StockPrice]
    [oahu.financial.repository EtradeRepository]
    [oahu.financial.html EtradeDownloader])
  (:use
    [harborview.service.commonutils :only (defn-memo,defn-memb,mem-binding,*reset-cache*)])
  (:require
    [harborview.service.commonutils :as CU]
    [harborview.service.htmlutils :as U]))

(defn-memo spring-context []
  (println "Initializing spring context: harborview.xml")
  (ClassPathXmlApplicationContext. "harborview.xml"))


(defn get-bean  [bn]
  (let [^BeanFactory factory (spring-context)]
    (.getBean factory bn)))

(defn today-feed [feed]
  (let [dx (LocalDate/now)
        y (.getYear dx)
        m (-> dx .getMonth .getValue)
        d (.getDayOfMonth dx)]
    (str feed "/" y "/" m "/" d)))

(defn check-file [feed t]
  (let [t-now (LocalTime/now)
        cur-file (str (today-feed feed) "/" t "-" (.getHour t-now) "." (.getMinute t-now) ".html")
        out (File. cur-file)
        pout (.getParentFile out)]
    (if (= (.exists pout) false)
      (.mkdirs pout))
    (if (= (.exists out) false)
      (.createNewFile out))
    out))

(defn save-page [ticker]
  (let [my-feed "../feed"
        ^EtradeDownloader dl (get-bean "downloader")
        page (.downloadDerivatives dl ticker)
        out (check-file my-feed ticker)]
    (try
      (let [contentInBytes (-> page .getWebResponse .getContentAsString .getBytes)
            fop (FileOutputStream. out)]
        (.write fop contentInBytes)
        (doto fop
          .flush
          .close))
      (catch IOException e
        (println (str "Could not save: " out ", " (.getMessage e)))))
    out))

(defn-memb parse-html [ticker]
  (let [^EtradeRepository e (get-bean "etrade")
        page (save-page ticker)]
    (.parseHtmlFor e ticker page)))

(comment parse-html [ticker]
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
        (println "Iv sell fail for: " (-> ox .getDerivative .getTicker) ", " (.getMessage ex))
        false)))


(defn valid? [ox]
  (if (> (.getBuy ox) 0)
    (if (> (.getSell ox) 0)
      (check-implied-vol ox)
      false)
    false))

(defn option->json [^DerivativePrice o]
  (let [d (.getDerivative o)]
        ;sp (.getStockPrice o)]
    ;(U/json-response
    {;:dx (CU/ld->str (.getLocalDx sp))
     :ticker (-> o .getDerivative .getTicker)
     :days (.getDays o)
     :buy (.getBuy o)
     :sell (.getSell o)
     :iv-buy (CU/double->decimal (.getIvBuy o) 1000.0)
     :iv-sell (CU/double->decimal (.getIvSell o) 1000.0)
     :br-even (CU/double->decimal (.getBreakEven o) 1000.0)}))

(defn stock->json [^StockPrice s]
  {:dx (CU/ld->str (.getLocalDx s))
   :tm (CU/tm->str (.getTm s))
   :opn (.getOpn s)
   :hi (.getHi s)
   :lo (.getLo s)
   :spot (.getCls s)})

(defn stock [ticker]
  (let [^Tuple3 parsed (parse-html ticker)]
    (.first parsed)))

(defn-memb calls [ticker]
  (let [^Tuple3 parsed (parse-html ticker)]
    (filter valid? (.second parsed))))

(defn-memb puts [ticker]
  (let [^Tuple3 parsed (parse-html ticker)]
    (filter valid? (.third parsed))))
