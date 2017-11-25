(ns harborview.maunaloa.html
  (:import
    [java.sql Date]
    [java.time LocalDate]
    [java.time.temporal ChronoUnit]
    [ranoraraku.beans StockPriceBean]
    [vega.filters.ehlers
       Itrend
       CyberCycle
       SuperSmoother
       RoofingFilter])
  (:use
    [compojure.core :only (GET POST defroutes)])
  (:require
    [clj-json.core :as json]
    [selmer.parser :as P]
    [tongariki.common :as TCO]
    [harborview.maunaloa.dbx :as DBX]
    [harborview.maunaloa.options :as OPX]
    [harborview.service.db :as DB]
    [harborview.service.htmlutils :as U]
    [harborview.service.commonutils :as CU]))


(def calc-itrend-10 (Itrend. 10))
(def calc-itrend-50 (Itrend. 50))

(def calc-cc-10 (CyberCycle. 10))
(def calc-cc-10_ss (comp (CyberCycle. 10) (SuperSmoother. 10)))
(def calc-cc-10_rf (comp (CyberCycle. 10) (RoofingFilter.)))

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


(def min-dx (LocalDate/of 2008 1 1))

(defn bean->candlestick [b]
  {:o (.getOpn b)
   :h (.getHi b)
   :l (.getLo b)
   :c (.getCls b)})

(def normalize-dates (partial TCO/normalize-dates min-dx))

(defn normalize [coll]
  (let [m (float (reduce max 0 coll))]
    (map #(/ % m) coll)))

(defn ticker-chart_ [spot-objs]
  (let [win-spot-objs (drop (- (count spot-objs) 400) spot-objs)
        spots (map #(.getCls %) win-spot-objs)
        itrend-10 (calc-itrend-10 spots)
        itrend-50 (calc-itrend-50 spots)
        ;cc-10 (TCO/normalize (calc-cc-10 spots))
        ;cc-10_rf (TCO/normalize (calc-cc-10_rf spots))
        cc-10 (calc-cc-10 spots)
        cc-10_rf (calc-cc-10_rf spots)
        volume (map #(.getVolume %) win-spot-objs)
        vol-norm (normalize volume)
        dx (map #(.toLocalDate (.getDx %)) win-spot-objs)
        hr (hruler min-dx)]
    (U/json-response
      {
        :chart {:lines [
                        (reverse (map CU/double->decimal itrend-10))
                        (reverse (map CU/double->decimal itrend-50))]
                :cndl (reverse (map #(bean->candlestick %) win-spot-objs))
                :bars nil}
        :chart2 {:lines [
                          ;(reverse (map CU/double->decimal cc-10))
                          ;(reverse (map CU/double->decimal cc-10_rf))
                          (reverse cc-10)
                          (reverse cc-10_rf)]

                 :bars nil
                 :cndl nil}
        :chart3 {:lines [(reverse (calc-itrend-10 vol-norm))]
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

(defn ticker-chart-month [oid]
  (let [oidi (U/rs oid)
        spot-objs (DBX/fetch-prices-m oidi (Date/valueOf min-dx))
        months (DBX/candlestick-months spot-objs)
        spots (map #(.getCls %) months)
        hr (hruler min-dx)
        itrend-10 (calc-itrend-10 spots)
        dx (map #(.toLocalDate (.getDx %)) months)]
    (U/json-response
      {
        :chart {:lines [
                        (reverse (map CU/double->decimal itrend-10))]
                :cndl (reverse (map #(bean->candlestick %) months))
                :bars nil}
        :chart2 nil
        :chart3 nil
        :x-axis (reverse (map hr dx))
        :min-dx (CU/ld->str min-dx)})))

(defn weeks [oid]
  (let [oidi (U/rs oid)
        spot-objs (DBX/fetch-prices-m oidi (Date/valueOf min-dx))
        weeks (DBX/candlestick-weeks-m oidi spot-objs)]
    weeks))

(CU/defn-memo tix->map []
  (let [tix (DBX/fetch-tickers)]
    (loop [result {}  t tix]
      (if (nil? t)
        result
        (let [tf (first t)
              oid (.getOid tf)
              ticker (.getTicker tf)
              comp-name (.getCompanyName tf)]
          (recur (assoc result (str oid) {:t ticker :c comp-name}) (next t)))))))

(defn tick-str [t]
  (:t ((tix->map) t)))

(comment db-tix []
  (map (fn [s] {"t" (.getTicker s) "v" (str (.getOid s))})
    (DBX/fetch-tickers)))

(CU/defn-memo tickers []
  (let [sorted (sort-by #(:t (second %)) (tix->map))]
    (U/json-response
      (for [[oid ticker] sorted]
        {"v" oid "t" (str "[" (:t ticker) "] " (:c ticker))}))))
;(let [tx (str "[" (:t ticker) "] " (:c ticker))]
;  (str "{\"v\":" oid ",\"t\":\"" tx "\"}")}))))


(defn spot [ticker]
  (U/json-response
    (OPX/stock->json (.get (OPX/stock (tick-str ticker))))))

(defn putscalls [ticker]
  (U/json-response
    {:puts (map OPX/option->json (OPX/puts ticker))
     :calls (map OPX/option->json (OPX/calls ticker))}))

(defn puts [ticker]
  (let [ts (tick-str ticker)]
    (U/json-response
      {:stock
        (OPX/stock->json (.get (OPX/stock ts)))
       :options
        (map OPX/option->json (OPX/puts ts))})))

(defn calls [ticker]
  (let [ts (tick-str ticker)]
    (U/json-response
      {:stock
        (OPX/stock->json (.get (OPX/stock ts)))
       :options
        (map OPX/option->json (OPX/calls ts))})))

; region SELMER

(defn init-charts []
  (let [[url user] (DB/dbcp :ranoraraku-dbcp)]
    (P/render-file "templates/maunaloa/charts.html" {:db-url url :db-user user})))

(defn init-options []
  (let [[url user] (DB/dbcp :ranoraraku-dbcp)]
    (P/render-file "templates/maunaloa/options.html" {:db-url url :db-user user})))

(defn init-purchases []
  (let [[url user] (DB/dbcp :ranoraraku-dbcp)]
    (P/render-file "templates/maunaloa/optionpurchases.html" {:db-url url :db-user user})))

; endregion

(defn ticker->options
  ([ticker]
   (let [stock-ticker (tick-str ticker)]
    (concat (OPX/calls stock-ticker) (OPX/puts stock-ticker))))
  ([ticker optype]
   (let [stock-ticker (tick-str ticker)]
    (if (= optype "calls")
      (OPX/calls stock-ticker)
      (OPX/puts stock-ticker)))))

; region RISC
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
    (let [bx (U/rs stockprice)] ; if-let == true
      {:optionprice (CU/double->decimal (.optionPriceFor ax bx) 100.0)
       :risc (.getCurrentRisc ax)})
    {:optionprice -1 ; if-let == false
     :risc -1}))
; endregion

; region R
(defn to_R_so [spot-objs]
  (let [spots (map #(.getCls ^StockPriceBean %) spot-objs)
        num-items 100
        num-drop (- (.size spot-objs) num-items)
        dx (map #(.toLocalDate ^Date (.getDx ^StockPriceBean %)) spot-objs)
        ndx (normalize-dates (drop num-drop dx))
        cc (TCO/normalize (drop num-drop (calc-cc-10 spots)))
        cc_ss (TCO/normalize (drop num-drop (calc-cc-10_ss spots)))
        cc_rf (TCO/normalize (drop num-drop (calc-cc-10_rf spots)))]
    [ndx cc cc_ss cc_rf]))

(defn to_R [oid]
  (let [days (DBX/fetch-prices-m oid (Date/valueOf min-dx))
        weeks (DBX/candlestick-weeks-m oid days)
        [d1,d2,d3,d4] (to_R_so days)
        [w1,w2,w3,w4] (to_R_so weeks)]
    (U/json-response
      {
        :ndx d1
        :cc d2
        :cc_ss d3
        :cc_rf d4
        :w_ndx w1
        :w_cc w2
        :w_cc_ss w3
        :w_cc_rf w4})))

; endregion

(def opx1 (:opx1 DBX/opx))

(defn fetchpurchases [oid ptype]
  (let [purchases (opx1 (U/rs oid) (U/rs ptype) 1)
        cur-stock (.get (OPX/stock (tick-str oid)))]
    (U/json-response {:purchases (map OPX/purchasesales->json purchases)
                      :cur-dx (CU/ld->str (.getLocalDx cur-stock))
                      :cur-spot (.getCls cur-stock)})))

(defroutes my-routes
  (GET "/to_r" [oid] (to_R (U/rs oid)))
  (GET "/charts" request (init-charts))
  (GET "/optiontickers" request (init-options))
  (GET "/optionpurchases" request (init-purchases))
  (GET "/spot" [ticker] (spot ticker))
  (GET "/puts" [ticker] (puts ticker))
  (GET "/calls" [ticker] (calls ticker))
  (GET "/resetcalls" [ticker]
    (binding [CU/*reset-cache* true]
      (reset! OPX/option-cache {})
      (calls ticker)))
  (GET "/resetputs" [ticker]
    (binding [CU/*reset-cache* true]
      (reset! OPX/option-cache {})
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
  ;(GET "/fetchpurchases" [oid ptype optype]
  ;  (fetchpurchases oid ptyp 1 optype))
  (GET "/fetchpurchases" [oid ptype]
    (fetchpurchases oid ptype))
  (GET "/resetfetchpurchases" [oid ptype]
    (binding [CU/*reset-cache* true]
      (fetchpurchases oid ptype)))
  (POST "/sellpurchase" request
    (let [jr (U/json-req-parse request)
          result (DBX/sell-purchase (jr "oid") (jr "price") (jr "vol"))]
      (U/json-response (str "Sold! Sale oid: " result))))
  (POST "/purchaseoption" request
    (let [jr (U/json-req-parse request)
          ticker (jr "ticker")
          ask (jr "ask")
          bid (jr "bid")
          vol (jr "vol")
          spot (jr "spot")
          rt (jr "rt")
          result (DBX/buy-option ticker ask bid vol spot rt)]
      (U/json-response result)))
  (GET "/ticker" [oid] (ticker-chart (U/rs oid)))
  (GET "/resetticker" [oid]
    (binding [CU/*reset-cache* true]
      (ticker-chart (U/rs oid))))
  (GET "/tickerweek" [oid] (ticker-chart-week (U/rs oid)))
  (GET "/tickermonth" [oid] (ticker-chart-month (U/rs oid)))
  (GET "/resettickerweek" [oid]
    (binding [CU/*reset-cache* true]
      (ticker-chart-week (U/rs oid)))))
