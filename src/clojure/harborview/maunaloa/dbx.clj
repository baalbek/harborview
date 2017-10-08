(ns harborview.maunaloa.dbx
  (:import
    [java.time.temporal IsoFields]
    [ranoraraku.beans StockPriceBean]
    [ranoraraku.models.mybatis StockMapper])
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

(defn candlestick-week [w]
  (let [lp (last w)
        dx (.getDx lp)
        opn (.getCls (first w))
        cls (.getCls lp)
        hi (apply max (map #(.getCls %) w))
        lo (apply min (map #(.getCls %) w))
        vol (apply + (map #(.getVolume %) w))]
       (StockPriceBean. dx opn hi lo cls vol)))

(defn candlestick-weeks-helper [prices-year]
  (map #(candlestick-week %) (filter #(seq %) (by-week prices-year))))

(defn candlestick-weeks [beans]
  (let [years (distinct (map #(extract-year %) beans))
        p-years (map #(get-year beans %) years)]
    (reduce concat () (map #(candlestick-weeks-helper %) p-years))))

(def candlestick-weeks-m
  (CU/memoize-arg0
    (fn [ticker beans]
      (candlestick-weeks beans))))

(defn candlestick-months [beans]
  (let [years (distinct (map #(extract-year %) beans))]
    years))
