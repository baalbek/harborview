(ns harborview.maunaloa.dbx
  (:import
    [java.time LocalDate]
    [java.time.temporal IsoFields]
    [ranoraraku.beans StockPriceBean]
    [ranoraraku.beans.options OptionSaleBean OptionPurchaseBean]
    [ranoraraku.models.mybatis CritterMapper StockMapper DerivativeMapper])
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


(defn option-purchases [purchase-type status]
  (DB/with-session :ranoraraku CritterMapper
    (.purchasesWithSalesAll it purchase-type status nil)))


(defn cache-key [purchase-type status]
  (str purchase-type ":" status))

(def opx
  (let [cache (atom {})
        cache2 (atom {})]
    {:opx1
      (fn [purchase-type status]
        (if (= *reset-cache* true)
          (do
            (reset! cache {})
            (reset! cache2 {})))
        (let [key (cache-key purchase-type status)]
          (if-let [e (find @cache key)]
            (filter #(= (.getStatus %) status) (val e))
            (let [ret (option-purchases purchase-type status)]
              (doseq [r ret]
                (let [oid (.getOid r)]
                  (swap! cache2 assoc oid r)))
              (swap! cache assoc key ret)
              ret))))
     :opx2
      (fn [oid]
        (@cache2 oid))
     :opx3
      (fn [purchase-type status]
        (if (= *reset-cache* true)
          (do
            (reset! cache {})
            (reset! cache2 {}))))}))

(defn sell-purchase [oid price volume]
  (if-let [p ((:opx2 opx) oid)]
    (let [sale (OptionSaleBean. oid price volume)]
      (.addSale p sale)
      (DB/with-session :ranoraraku CritterMapper
        (do
          (if (.isFullySold p)
            (do
              (.setStatus p 2)
              (.registerPurchaseFullySold it p)))
          (.insertCritterSale it sale)))
      (.getOid sale))
    -1))

(comment create-option [ticker ask bid volume spot]
  (DB/with-session :ranoraraku DerivativeMapper
    ()))


;(defn buy-purchase [ticker ask bid volume spot])
(defn find-option-oid [ticker]
  (DB/with-session :ranoraraku DerivativeMapper
    (.findDerivativeId it ticker)))

; stockmarket.optionpurchase (opid, dx, price, volume, status, purchase_type, spot, buy)

(defn buy-option [soid ticker ask bid vol spot realtime]
  (if-let [oid (find-option-oid ticker)]
    (let [purchase (OptionPurchaseBean.)]
      (doto purchase
            (.setOptionId oid)
            (.setLocalDx (LocalDate/now))
            (.setPrice ask)
            (.setVolume vol)
            (.setStatus 1)
            (.setPurchaseType (if (= realtime true) 3 11))
            (.setSpotAtPurchase spot)
            (.setBuyAtPurchase bid))
      (DB/with-session :ranoraraku CritterMapper
        (.insertPurchase it purchase))
      {:ok true  :msg (str "Option purchase with oid: " oid)})
    {:ok false :msg "Option does not exist in database"}))




; endregion
