(ns harborview.maunaloa.dbx
  (:import
    [java.time LocalDate]
    [java.time.temporal IsoFields]
    [ranoraraku.beans StockPriceBean]
    [ranoraraku.beans.options OptionSaleBean]
    [ranoraraku.models.mybatis CritterMapper StockMapper])
  (:use
    [harborview.service.commonutils :only (*reset-cache*)])
  (:require
    [harborview.service.commonutils :as CU]
    [harborview.service.db :as DB]))


;(defn fetch-tickers []
(CU/defn-memo fetch-tickers []
  (println "fetch-tickers")
  (DB/with-session :ranoraraku StockMapper
    (.selectStocks it)))

(defn fetch-prices [oid from-date]
  (println "fetch-prices, ticker: " oid)
  (DB/with-session :ranoraraku StockMapper
    (.selectStockPrices it oid from-date)))

(CU/defn-memb fetch-prices-m [oid from-date]
  (println "fetch-prices-m: " oid ", " from-date)
  (fetch-prices oid  from-date))

(defn extract-year [^StockPriceBean price]
  (-> price .getLocalDx .getYear))

(defn extract-month [^StockPriceBean price]
  (-> price .getLocalDx .getMonthValue))

(defn extract-week [^StockPriceBean price]
  (let [dx (.getLocalDx price)]
    (.get dx IsoFields/WEEK_OF_WEEK_BASED_YEAR)))

(defn week-1-in-december [price]
  (and (= (extract-week price) 1) (= (-> price .getLocalDx .getMonthValue) 12)))

(defn get-year [prices year]
  (remove week-1-in-december (filter #(= (extract-year %) year) prices)))

(defn get-week [prices week]
  (filter #(= (extract-week %) week) prices))

(defn by-week [prices-year]
  (map #(get-week prices-year %) (range 1 54)))

(defn get-year-week [beans year week]
  (let [year-beans (get-year beans year)
        result (get-week year-beans week)]
    result))

; region Candlesticks Weeks

(defn candlestick-collection [date-fn w]
  (let [lp (last w)
        dx (let [my-dx (.getDx lp)]
             (if (nil? date-fn)
               my-dx
               (date-fn my-dx)))
        opn (.getCls (first w))
        cls (.getCls lp)
        hi (apply max (map #(.getCls %) w))
        lo (apply min (map #(.getCls %) w))
        vol (apply + (map #(.getVolume %) w))]
       (StockPriceBean. dx opn hi lo cls vol)))

(def candlestick-coll->week (partial candlestick-collection nil))
(def candlestick-coll->month
  (partial candlestick-collection
    (fn [dx]
      (let [locd (.toLocalDate dx)
            y (.getYear locd)
            m (.getMonthValue locd)]
        (LocalDate/of y m 1)))))




(defn candlestick-weeks-helper [prices-year]
  (map #(candlestick-coll->week %) (filter #(seq %) (by-week prices-year))))

(defn candlestick-weeks [beans]
  (let [years (distinct (map #(extract-year %) beans))
        p-years (map #(get-year beans %) years)]
    (reduce concat () (map #(candlestick-weeks-helper %) p-years))))

(def candlestick-weeks-m
  (CU/memoize-arg0
    (fn [ticker beans]
      (candlestick-weeks beans))))

; endregion


;(defn by-year [prices years]
;  (map #(get-year prices %) years))

;(defn by-month [prices-year]
;  (map #(get-month prices-year %) (range 1 12)))

(defn get-month [prices month]
  (filter #(= (extract-month %) month) prices))

(defn candlestick-months [beans]
  (let [distinct-years (distinct (map #(extract-year %) beans))
        years (map #(get-year beans %) distinct-years)
        result (for [y years]
                 (map candlestick-coll->month (filter #(> (count %) 0) (map #(get-month y %) (range 1 13)))))]
    (flatten result)))
        ;months (for [y years] (map #(get-month y %) (range 1 13)))

;region OPTION PURCHASES


(defn option-purchases [stock-id purchase-type status optype]
  (DB/with-session :ranoraraku CritterMapper
    (.purchasesWithSales it stock-id purchase-type status optype)))


(defn cache-key [stock-id purchase-type status optype]
  (str stock-id ":" purchase-type ":" status ":" optype))

(def opx
  (let [cache (atom {})
        cache2 (atom {})]
    {:opx1
      (fn [stock-id purchase-type status optype]
        (if (= *reset-cache* true)
          (do
            (reset! cache {})
            (reset! cache2 {})))
        (let [key (cache-key stock-id purchase-type status optype)]
          (if-let [e (find @cache key)]
            (val e)
            (let [ret (option-purchases stock-id purchase-type status optype)]
              (doseq [r ret]
                (let [oid (.getOid r)]
                  (swap! cache2 assoc oid r)))
              (swap! cache assoc key ret)
              ret))))
     :opx2
      (fn [oid]
        (@cache2 oid))}))

(defn sell-purchase [oid price volume]
  (if-let [p ((:opx2 opx) oid)]
    (let [sale (OptionSaleBean. oid price volume)]
      (.addSale p sale)
      (DB/with-session :ranoraraku CritterMapper
        (do
          (if (.isFullySold p)
            (.registerPurchaseFullySold it p))
          (.insertCritterSale it sale)))
      (.getOid sale))
    -1))




; endregion
