(ns harborview.maunaloa.html
  (:import
    [java.sql Date]
    [java.time LocalDate]
    [java.time.temporal ChronoUnit]
    [vega.filters.ehlers Itrend CyberCycle])
  (:use
    [compojure.core :only (GET POST defroutes)])
  (:require
    [clj-json.core :as json]
    [selmer.parser :as P]
    [harborview.maunaloa.dbx :as DBX]
    [harborview.service.htmlutils :as U]))

(def calc-itrend (Itrend.))

(def calc-cc (CyberCycle.))

(defn create-freqs [f data-values freqs]
  (map #(f data-values %) freqs))

(defn double->decimal [v]
  (/ (Math/round (* v 10)) 10.0))

(defn diff-days [d1 d2]
  (.between ChronoUnit/DAYS d1 d2))

(comment vruler-static [h min-val max-val]
  (let [pix-pr-v (/ h (- max-val min-val))]
    (fn [v]
      (let [diff (- max-val v)]
        (double->decimal (double (* pix-pr-v diff)))))))


(comment hruler-static [w min-dx max-dx]
  (let [days (diff-days min-dx max-dx)
        pix-pr-h (/ w days)]
    (fn [dx]
      (let [cur-diff (diff-days min-dx dx)]
        (double->decimal (double (* pix-pr-h cur-diff)))))))

(defn hruler [min-dx]
  (fn [dx]
    (let [cur-diff (diff-days min-dx dx)]
      cur-diff)))

(defn ld->str [v]
  (let [y (.getYear v)
        m (.getMonthValue v)
        d (.getDayOfMonth v)]
    (str y "-" m "-" d)))

(def min-dx (LocalDate/of 2012 1 1))

(comment ticker-chart-static [oid w h]
  (let [
        spot-objs (DBX/fetch-prices (U/rs oid) (Date/valueOf min-dx))
        spots (map #(.getCls %) spot-objs)
        itrend-20 (calc-itrend spots 10)
        dx (map #(.toLocalDate (.getDx %)) spot-objs)
        max-dx (last dx) ;(.plusWeeks (last dx) 7)
        ys (concat spots itrend-20)
        min-val (apply min ys)
        max-val (apply max ys)
        vr (vruler-static h min-val max-val)
        hr (hruler-static w min-dx max-dx)]
    (U/json-response
      {:spots (map vr spots)
       :itrend-20 (map vr itrend-20)
       ;:candlesticks [
       ;               {:o 3, :h 4, :l 1, :c 2.5}
       ;               {:o 3, :h 4, :l 1, :c 2.5}
       ;               {:o 3, :h 4, :l 1, :c 2.5}
       ;               {:o 3, :h 4, :l 1, :c 2.5}
       ;               {:o 3, :h 4, :l 1, :c 2.5}
       ;               {:o 3, :h 4, :l 1, :c 2.5}
       ;               {:o 3, :h 4, :l 1, :c 2.5}
       ;               {:o 3, :h 4, :l 1, :c 2.5}
       ;               {:o 3, :h 4, :l 1, :c 2.5}]

       :x-axis (map hr dx) ; [0 50 100 150 200]
       :min-val min-val
       :max-val max-val
       :min-dx (ld->str min-dx)
       :max-dx (ld->str max-dx)})))

(defn bean->candlestick [b]
  {:o (.getOpn b)
   :h (.getHi b)
   :l (.getLo b)
   :c (.getCls b)})


(defn ticker-chart_ [spot-objs]
  (let [spots (map #(.getCls %) spot-objs)
        itrend-50 (calc-itrend spots 50)
        itrend-200 (calc-itrend spots 200)
        cc-50 (calc-cc spots 50)
        cc-200 (calc-cc spots 200)
        dx (map #(.toLocalDate (.getDx %)) spot-objs)
        hr (hruler min-dx)]
    (U/json-response
      {
       :lines [(reverse spots)
               (reverse (map double->decimal itrend-50))
               (reverse (map double->decimal itrend-200))]
       :lines2 [
                (reverse (map double->decimal cc-50))
                (reverse (map double->decimal cc-200))]
       :x-axis (reverse (map hr dx))
       :min-dx (ld->str min-dx)
       :cndl (reverse (map #(bean->candlestick %) spot-objs))})))

(defn ticker-chart [oid]
  (let [spot-objs (DBX/fetch-prices-m (U/rs oid) (Date/valueOf min-dx))]
    (ticker-chart_ spot-objs)))

(defn ticker-chart-week [oid]
  (let [oidi (U/rs oid)
        spot-objs (DBX/fetch-prices-m oidi (Date/valueOf min-dx))
        weeks (DBX/candlestick-weeks-m oidi spot-objs)]
    (ticker-chart_ weeks)))

(comment tickers []
  (U/json-response
    (map (fn [s] {"t" (.getTicker s) "v" (str (.getOid s))})
      (DBX/fetch-tickers))))

(defn tickers []
  (U/json-response
    (map (fn [x] (let [[v t] x] {"t" t "v" v}))
      [["2" "STL"] ["1" "NHY"] ["3" "YAR"]])))

(defn init []
  (P/render-file "templates/maunaloa/charts.html" {}))


(defroutes my-routes
  (GET "/" request (init))
  (GET "/tickers" request (tickers))
  (GET "/ticker" [oid] (ticker-chart (U/rs oid)))
  (GET "/tickerweek" [oid] (ticker-chart-week (U/rs oid))))
