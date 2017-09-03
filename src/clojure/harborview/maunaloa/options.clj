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
    [harborview.service.commonutils :only (defn-memo,defn-memb)])
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
        cur-file (str (today-feed feed) "/" t "-" (.getHour t-now) "_" (.getMinute t-now) ".html")
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

(comment parse-html [ticker]
  (let [^EtradeRepository e (get-bean "etrade")
        page (save-page ticker)]
    (.parseHtmlFor e ticker page)))

(defn-memb parse-html [ticker]
  (let [^EtradeRepository e (get-bean "etrade")]
    (.parseHtmlFor e ticker nil)))

(comment check-implied-vol [ox]
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

(defn check-implied-vol [ox]
  (if (= (.isPresent (.getIvBuy ox)) true)
    (if (= (.isPresent (.getIvSell ox)) true)
      true
      false)
    false))

(defn valid? [ox]
  (if (> (.getBuy ox) 0)
    (if (> (.getSell ox) 0)
      (if (= (check-implied-vol ox) true)
        (.isPresent (.getBreakEven ox)))
      false)
    false))

(defn option->json [^DerivativePrice o]
  (let [iv-buy (-> o .getIvBuy .get)
        iv-sell (-> o .getIvSell .get)
        be (-> o .getBreakEven .get)
        d (.getDerivative o)]
    {:ticker (.getTicker d)
     :x (.getX d)
     :days (.getDays o)
     :buy (.getBuy o)
     :sell (.getSell o)
     :iv-buy (CU/double->decimal iv-buy 1000.0)
     :iv-sell (CU/double->decimal iv-sell 1000.0)
     :br-even (CU/double->decimal be 1000.0)}))

(defn stock->json [^StockPrice s]
  {:dx (CU/ld->str (.getLocalDx s))
   :tm (CU/tm->str (.getTm s))
   :o (.getOpn s)
   :h (.getHi s)
   :l (.getLo s)
   :c (.getCls s)})

(defn risc->json [^DerivativePrice o]
  {:ticker (.getTicker o)
   :be (-> o .getBreakEven .get)
   :stockprice (-> o .getCurrentRiscStockPrice .get)
   :optionprice (.getCurrentRiscOptionValue o)
   :risc (.getCurrentRisc o)})

(defn stock [ticker]
  (let [^Tuple3 parsed (parse-html ticker)]
    (.first parsed)))

(def option-cache (atom {}))

(defn populate-cache [options]
  (doseq [o options]
    (swap! option-cache assoc (.getTicker o) o)))

(defn-memb calls [ticker]
  (let [^Tuple3 parsed (parse-html ticker)
        result (filter valid? (.second parsed))]
    (populate-cache result)
    result))

(defn-memb puts [ticker]
  (let [^Tuple3 parsed (parse-html ticker)
        result (filter valid? (.third parsed))]
    (populate-cache result)
    result))
