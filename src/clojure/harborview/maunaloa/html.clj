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
    [harborview.service.db :as DB]
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

(defn bean->candlestick [b]
  {:o (.getOpn b)
   :h (.getHi b)
   :l (.getLo b)
   :c (.getCls b)})


(defn normalize [coll]
  (let [m (float (reduce max 0 coll))]
    (map #(/ % m) coll)))

(defn ticker-chart_ [spot-objs]
  (let [spots (map #(.getCls %) spot-objs)
        itrend-10 (calc-itrend spots 10)
        itrend-50 (calc-itrend spots 50)
        ;itrend-200 (calc-itrend spots 200)
        cc-10 (calc-cc spots 10)
        cc-50 (calc-cc spots 50)
        ;cc-200 (calc-cc spots 200)
        volume (map #(.getVolume %) spot-objs)
        vol-norm (normalize volume)
        dx (map #(.toLocalDate (.getDx %)) spot-objs)
        hr (hruler min-dx)]
    (U/json-response
      {
        :chart {:lines [
                        (reverse (map CU/double->decimal itrend-10))
                        (reverse (map CU/double->decimal itrend-50))]
                :cndl (reverse (map #(bean->candlestick %) spot-objs))
                 :bars nil}
        :chart2 {:lines [
                          (reverse (map CU/double->decimal cc-10))
                          (reverse (map CU/double->decimal cc-50))]
                 :bars nil
                 :cndl nil}
        :chart3 {:lines [(reverse (calc-itrend vol-norm 10))]
                 :cndl nil
                 :bars [(reverse vol-norm)]}
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

(defn spot [ticker]
  (let [tick-str ((tix->map) ticker)]
    (U/json-response
      (OPX/stock->json (.get (OPX/stock tick-str))))))

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
  (let [[url user] (DB/dbcp :ranoraraku-dbcp)]
    (P/render-file "templates/maunaloa/charts.html" {:db-url url :db-user user})))

  ;(P/render-file "templates/maunaloa/charts.html" {:c-width 1310 :c1-height 500 :c2-height 200}))

(defn init-options []
  (let [[url user] (DB/dbcp :ranoraraku-dbcp)]
    (P/render-file "templates/maunaloa/options.html" {:db-url url :db-user user})))

(defn ticker->options
  ([ticker]
   (let [stock-ticker ((tix->map) ticker)]
    (concat (OPX/calls stock-ticker) (OPX/puts stock-ticker))))
  ([ticker optype]
   (let [stock-ticker ((tix->map) ticker)]
    (if (= optype "calls")
      (OPX/calls stock-ticker)
      (OPX/puts stock-ticker)))))



(defn calculated-riscs [ticker]
  (let [options (ticker->options ticker)]
    (filter #(= (-> % .getCurrentRiscStockPrice .isPresent) true) options)))

(defn calc-risc-stockprices [jr]
  (let [risc-fn
          (fn [[a b]]
            (if-let [ax (@OPX/option-cache a)]
              (let [bx (- (.getSell ax) (U/rs b))
                    risc (.stockPriceFor ax bx)]
                (println "bx: " (str bx) ", risc: " (str risc))
                (if (.isPresent risc)
                  {:ticker a, :risc (.get risc)}
                  nil))))]
    (filter (complement nil?) (map risc-fn jr))))

(defn calc-optionprice-for-stockprice [ticker stockprice]
  (if-let [ax (@OPX/option-cache ticker)]
    (let [bx (U/rs stockprice)]
      {:optionprice (CU/double->decimal (.optionPriceFor ax bx) 100.0)
       :risc (.getCurrentRisc ax)})
    {:optionprice -1
     :risc -1}))

(defroutes my-routes
  (GET "/charts" request (init-charts))
  (GET "/optiontickers" request (init-options))
  (GET "/spot" [ticker] (spot ticker))
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
  (GET "/risclines" [ticker]
    (let [riscs (calculated-riscs ticker)]
      (U/json-response (map OPX/risc->json riscs))))
  (POST "/calc-risc-stockprices" request
    (let [jr (U/json-req-parse request)
          ;prm (:params request)
          ;ticker (:ticker prm)
          ;optype (:optype prm)
          result (calc-risc-stockprices jr)]
      (U/json-response result)))
  (GET "/optionprice" [ticker stockprice]
    (U/json-response (calc-optionprice-for-stockprice ticker stockprice)))
  (GET "/tickers" request (tickers))
  ;(GET "/th" [oid] (test-hruler (U/rs oid)))
  (GET "/ticker" [oid] (ticker-chart (U/rs oid)))
  (GET "/resetticker" [oid]
    (binding [CU/*reset-cache* true]
      (ticker-chart (U/rs oid))))
  (GET "/tickerweek" [oid] (ticker-chart-week (U/rs oid)))
  (GET "/resettickerweek" [oid]
    (binding [CU/*reset-cache* true]
      (ticker-chart-week (U/rs oid)))))
