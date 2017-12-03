(ns harborview.maunaloa.options
  (:import
    [java.util Optional]
    [java.io IOException File FileOutputStream FileNotFoundException]
    [java.time LocalTime LocalDate]
    [java.time.temporal ChronoUnit]
    [org.springframework.beans.factory BeanFactory]
    [oahu.dto Tuple3]
    [ranoraraku.beans.options OptionPurchaseBean]
    [oahu.financial Derivative DerivativePrice StockPrice]
    [oahu.financial.repository EtradeRepository]
    [oahu.financial.html EtradeDownloader])
  (:use
    [harborview.service.commonutils :only (defn-memo,defn-memb)])
  (:require
    ;[harborview.protocols.optionsprotocol :as P]
    [harborview.service.springservice :as S]
    [harborview.service.commonutils :as CU]
    [harborview.service.htmlutils :as U]))

; region SPRING
(comment
  (defn-memo spring-context []
    (println "Initializing spring context: harborview.xml")
    (ClassPathXmlApplicationContext. "harborview.xml"))


  (defn get-bean  [bn]
    (let [^BeanFactory factory (spring-context)]
      (.getBean factory bn))))

; endregion

; region protocols

(def jse "\"")

(comment P/Vega
  OptionPurchaseBean
  (toJSON [this]
    (let [calc (S/get-bean "calculator")
          oid (.getOid this)
          ticker (.getOptionName this)
          d0 (.getLocalDx this)
          ot (.getOptionType this)
          spot (.getSpotAtPurchase this)
          price (.getPrice this)
          bid (.getBuyAtPurchase this)
          x (.getX this)
          d1 (.getExpiry this)
          days (.between ChronoUnit/DAYS d0 d1)
          t (/ days 365.0)
          svol (.volumeSold this)
      ;(println "d0: " d0 ", days:" days ", ot: " ot ",spot: " spot ",strike: " x)
          iv (if (= ot "c")
              (.ivCall calc spot x t price)
              (.ivPut calc spot x t price))]
       (str "{\"oid\":" oid
            ",\"ticker\":\"" ticker  jse
            ",\"pdate\":\"" (CU/ld->str d0) jse
            ",\"price\":" price
            ",\"spot\":" spot
            ",\"bid\":" bid
            ",\"svol\":" svol
            ",\"iv\":" iv
            "}"))))





; endregion

; region NETFONDS REPOS
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
        ^EtradeDownloader dl (S/get-bean "downloader")
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
  (let [^EtradeRepository e (S/get-bean "etrade")
        page (save-page ticker)]
    (.parseHtmlFor e ticker page)))

(defn-memb parse-html [ticker]
  (let [^EtradeRepository e (S/get-bean "etrade")]
    (.parseHtmlFor e ticker nil)))

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


(defn stock [ticker]
  (let [^Tuple3 parsed (parse-html ticker)]
    (.first parsed)))

(def option-cache (atom {}))

(defn populate-cache [options]
  (doseq [o options]
    (swap! option-cache assoc (.getTicker o) o)))

(defn-memb calls [ticker]
  (let [^Tuple3 parsed (parse-html ticker)
        result (.second parsed)]
        ;result (filter valid? (.second parsed))]
    (populate-cache result)
    result))

(defn-memb puts [ticker]
  (let [^Tuple3 parsed (parse-html ticker)
        result (.third parsed)]
        ;result (filter valid? (.third parsed))]
    (populate-cache result)
    result))

(defn vcalls [ticker]
  (filter valid? (calls ticker)))

(defn vputs [ticker]
  (filter valid? (puts ticker)))

; endregion


; region JSON
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
   :ask (.getSell o)
   :risc (.getCurrentRisc o)})

(defn purchase->json [^OptionPurchaseBean p]
  {:oid (.getOid p)
   :ticker (.getOptionName p)
   :dx (CU/ld->str (.getLocalDx p))
   :price (.getPrice p)
   :spot (.getSpotAtPurchase p)})

(defn purchasesales->json [^OptionPurchaseBean p]
  (let [calc (S/get-bean "calculator")
        oid (.getOid p)
        ticker (.getOptionName p)
        stock-ticker (.getTicker p)
        d0 (.getLocalDx p)
        ot (.getOptionType p)
        spot (.getSpotAtPurchase p)
        price (.getPrice p)
        bid (.getBuyAtPurchase p)
        x (.getX p)
        d1 (.getExpiry p)
        days (.between ChronoUnit/DAYS d0 d1)
        t (/ days 365.0)
        pvol (.getVolume p)
        svol (.volumeSold p)
        iv (if (= ot "c")
            (.ivCall calc spot x t bid)
            (.ivPut calc spot x t bid))
        cur-opt (let [items (if (= ot "c")
                              (calls stock-ticker)
                              (puts stock-ticker))]
                  (first (filter #(= (.getTicker %) ticker) items)))
        cur-ask (if (nil? cur-opt)
                  -1
                  (.getSell cur-opt))
        cur-bid (if (nil? cur-opt)
                  -1
                  (.getBuy cur-opt))
        cur-iv (if (nil? cur-opt)
                 (Optional/empty)
                 (.getIvBuy cur-opt))]
    {:oid oid
     :ot ot
     :ticker ticker
     :dx (CU/ld->str d0)
     :price price
     :bid bid
     :spot spot
     :pvol pvol
     :svol svol
     :iv (CU/double->decimal iv 1000.0)
     :cur-ask cur-ask
     :cur-bid cur-bid
     :cur-iv (if (true? (.isPresent cur-iv))
               (CU/double->decimal (.get cur-iv) 1000.0)
               -1)}))


; endregion JSON
