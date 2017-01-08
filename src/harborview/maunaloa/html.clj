(ns harborview.maunaloa.html
  (:import
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

(defn vruler [h min-val max-val]
  (let [pix-pr-v (/ h (- max-val min-val))]
    (fn [v]
      (let [diff (- max-val v)]
        (println pix-pr-v)
        (double (* pix-pr-v diff))))))

(defn ticker-chart [oid w h]
  (let [;stox (DBX/fetch-prices (U/rs oid))
        spots [50 70 20 30 80 100 120 90 140 180 170]
        min-val 20
        max-val 180
        vr (vruler w min-val max-val)]
    (U/json-response
      {:spots (map vr spots)
       :candlesticks [
                      {:o 3, :h 4, :l 1, :c 2.5}
                      {:o 3, :h 4, :l 1, :c 2.5}
                      {:o 3, :h 4, :l 1, :c 2.5}
                      {:o 3, :h 4, :l 1, :c 2.5}
                      {:o 3, :h 4, :l 1, :c 2.5}
                      {:o 3, :h 4, :l 1, :c 2.5}
                      {:o 3, :h 4, :l 1, :c 2.5}
                      {:o 3, :h 4, :l 1, :c 2.5}
                      {:o 3, :h 4, :l 1, :c 2.5}]

       :x-axis [10 30 50 70 90 110 150 170 190 210]
       :min-val min-val
       :max-val max-val
       :min-dx "2016-7-20"
       :max-dx "2016-8-18"})))


(defn tickers []
  (U/json-response
    ;(map (fn [s] {"t" (.getTicker s) "v" (.getOid s)})
    ;  (DBX/fetch-tickers))))
    (map (fn [x] (let [[v t] x] {"t" t "v" v}))
      [["2" "STL"] ["1" "NHY"] ["3" "YAR"]])))

(defn init []
  (P/render-file "templates/maunaloa/charts.html" {}))


(defroutes my-routes
  (GET "/" request (init))
  (GET "/tickers" request (tickers))
  (GET "/ticker" [oid] (ticker-chart (U/rs oid) 1200 600)))
