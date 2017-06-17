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
    [harborview.maunaloa.options :as OPX]
    [harborview.service.htmlutils :as U]
    [harborview.service.commonutils :as CU]))

(def calc-itrend (Itrend.))

(def calc-cc (CyberCycle.))

(defn create-freqs [f data-values freqs]
  (map #(f data-values %) freqs))


(defn diff-days [d1 d2]
  (.between ChronoUnit/DAYS d1 d2))

(comment vruler-static [h min-val max-val]
  (let [pix-pr-v (/ h (- max-val min-val))]
    (fn [v]
      (let [diff (- max-val v)]
        (CU/double->decimal (double (* pix-pr-v diff)))))))


(comment hruler-static [w min-dx max-dx]
  (let [days (diff-days min-dx max-dx)
        pix-pr-h (/ w days)]
    (fn [dx]
      (let [cur-diff (diff-days min-dx dx)]
        (CU/double->decimal (double (* pix-pr-h cur-diff)))))))

(defn hruler [min-dx]
  (fn [dx]
    (let [cur-diff (diff-days min-dx dx)]
      cur-diff)))


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
       :min-dx (CU/ld->str min-dx)
       :max-dx (CU/ld->str max-dx)})))

(defn bean->candlestick [b]
  {:o (.getOpn b)
   :h (.getHi b)
   :l (.getLo b)
   :c (.getCls b)})


(defn ticker-chart_ [spot-objs]
  (let [spots (map #(.getCls %) spot-objs)
        itrend-10 (calc-itrend spots 10)
        itrend-50 (calc-itrend spots 50)
        ;itrend-200 (calc-itrend spots 200)
        cc-10 (calc-cc spots 10)
        cc-50 (calc-cc spots 50)
        ;cc-200 (calc-cc spots 200)
        dx (map #(.toLocalDate (.getDx %)) spot-objs)
        hr (hruler min-dx)]
    (U/json-response
      {
        :chart {:lines [
                        (reverse (map CU/double->decimal itrend-10))
                        (reverse (map CU/double->decimal itrend-50))]
                :bars nil
                :cndl (reverse (map #(bean->candlestick %) spot-objs))}
        :chart2 {:lines [
                          (reverse (map CU/double->decimal cc-10))
                          (reverse (map CU/double->decimal cc-50))]
                 :bars nil
                 :cndl nil}
        :x-axis (reverse (map hr dx))
        :min-dx (CU/ld->str min-dx)})))



(defn ticker-chart [oid]
  (let [spot-objs (DBX/fetch-prices-m (U/rs oid) (Date/valueOf min-dx))]
    (ticker-chart_ spot-objs)))

(defn ticker-chart-week [oid]
  (let [oidi (U/rs oid)
        spot-objs (DBX/fetch-prices-m oidi (Date/valueOf min-dx))
        weeks (DBX/candlestick-weeks-m oidi spot-objs)]
    (ticker-chart_ weeks)))

(CU/defn-memo tix->map []
  (let [tix (DBX/fetch-tickers)]
    (loop [result {} t tix]
      (if (nil? t)
        result
        (let [tf (first t)
              oid (.getOid tf)
              ticker (.getTicker tf)]
          (recur (assoc result (str oid) ticker) (next t)))))))

(comment db-tix []
  (map (fn [s] {"t" (.getTicker s) "v" (str (.getOid s))})
    (DBX/fetch-tickers)))

(CU/defn-memo tickers []
  (U/json-response
    (for [[oid ticker] (tix->map)] {"v" oid "t" ticker})))

(defn putscalls [ticker]
  (U/json-response
    {:puts (map OPX/option->json (OPX/puts ticker))
     :calls (map OPX/option->json (OPX/calls ticker))}))

(defn puts [ticker]
  (let [tick-str ((tix->map) ticker)]
    (U/json-response
      {:stock
        (OPX/stock->json (.get (OPX/stock tick-str)))
       :options
        (map OPX/option->json (OPX/puts  tick-str))})))

(defn calls [ticker]
  (let [tick-str ((tix->map) ticker)]
    (U/json-response
      {:stock
        (OPX/stock->json (.get (OPX/stock tick-str)))
       :options
        (map OPX/option->json (OPX/calls tick-str))})))

(defn init-charts []
  (P/render-file "templates/maunaloa/charts.html" {}))

(defn init-options []
  (P/render-file "templates/maunaloa/options.html" {}))

(defn ticker->options [ticker optype]
  (let [stock-ticker ((tix->map) ticker)]
    (if (= optype "calls")
      (OPX/calls stock-ticker)
      (OPX/puts stock-ticker))))

(defn calculated-riscs [ticker optype]
  (let [options (ticker->options ticker optype)]
    (filter #(= (-> % .getCurrentRisc .isPresent) true) options)))

(comment calc-risc-stockprices [ticker optype jr]
  (let [options (ticker->options ticker optype)
        risc-fn
          (fn [[a b]]
            (let [ax (CU/find-first #(= (.getTicker %) a) options)
                  bx (U/rs b)
                  risc (.calcRisc ax bx)]
              (if (.isPresent risc)
                {:ticker a, :risc (.get risc)}
                nil)))]
    (filter (complement nil?) (map risc-fn jr))))

(defn calc-risc-stockprices [jr]
  (let [risc-fn
          (fn [[a b]]
            (if-let [ax (@OPX/option-cache a)]
              (let [bx (U/rs b)
                    risc (.stockPriceFor ax bx)]
                (if (.isPresent risc)
                  {:ticker a, :risc (.get risc)}
                  nil))))]
    (filter (complement nil?) (map risc-fn jr))))

(comment calc-risc-for-stockprice [stockticker ticker optype stockprice]
  (let [options (ticker->options stockticker optype)
        sp (U/rs stockprice)
        option (CU/find-first #(= (.getTicker %) ticker) options)]
    (.optionPriceFor option stockprice)))

(defn calc-risc-for-stockprice [ticker stockprice]
  (if-let [ax (@OPX/option-cache ticker)]
    (let [bx (U/rs stockprice)]
      (CU/double->decimal (.optionPriceFor ax bx) 100.0))
    -1))

(defroutes my-routes
  (GET "/charts" request (init-charts))
  (GET "/optiontickers" request (init-options))
  (GET "/puts" [ticker] (puts ticker))
  (GET "/calls" [ticker] (calls ticker))
  (GET "/resetcalls" [ticker]
    (binding [CU/*reset-cache* true]
      (reset! (OPX/option-cache {}))
      (calls ticker)))
  (GET "/resetputs" [ticker]
    (binding [CU/*reset-cache* true]
      (reset! (OPX/option-cache {}))
      (puts ticker)))
  (GET "/risclines" [ticker optype]
    (let [riscs (calculated-riscs ticker optype)]))
  (GET "/demo" request
    (U/json-response 2))
  (POST "/calc-risc-stockprices" request
    (let [jr (U/json-req-parse request)
          ;prm (:params request)
          ;ticker (:ticker prm)
          ;optype (:optype prm)
          result (calc-risc-stockprices jr)]
      (prn result)
      (U/json-response result))) ;(calc-risc-stockprices ticker optype jr))))
  (GET "/calcrisc" [ticker stockprice]
    (U/json-response (calc-risc-for-stockprice ticker stockprice)))
  (GET "/tickers" request (tickers))
  ;(GET "/th" [oid] (test-hruler (U/rs oid)))
  (GET "/ticker" [oid] (ticker-chart (U/rs oid)))
  (GET "/tickerweek" [oid] (ticker-chart-week (U/rs oid))))
