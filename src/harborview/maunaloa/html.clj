(ns harborview.maunaloa.html
  (:use
    [compojure.core :only (GET POST defroutes)])
  (:require
    [clj-json.core :as json]
    [selmer.parser :as P]
    [harborview.maunaloa.dbx :as DBX]
    [harborview.service.htmlutils :as U]))


(defn ticker-chart [oid]
  (U/json-response
    {:spots [50 70 20 30 80 100 120 90 140 180 170]
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

     :itrend1 [1 2 3 2 3 4 3 1 2]
     :y-coord [1 2 3 2 3 4 3 1 2]
     :min-dx "2016-7-20"
     :max-dx "2016-8-18"}))


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
  (GET "/ticker" [oid] (ticker-chart oid)))
