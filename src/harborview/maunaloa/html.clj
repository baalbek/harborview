(ns harborview.maunaloa.html
  (:use
    [compojure.core :only (GET POST defroutes)])
  (:require
    [clj-json.core :as json]
    [selmer.parser :as P]
    [harborview.service.htmlutils :as U]))


(defn ticker-chart [oid]
  (U/json-response
    {:daily [1 2 3 2 3 4 3 1 2]
     :dx [0 1 2 3 4 5 6 7 8]}))
    

(defn tickers []
  (U/json-response
    (map (fn [x] (let [[v t] x] {"t" t "v" v}))
      [["2" "STL"] ["1" "NHY"] ["3" "YAR"]])))

(defn init []
  (P/render-file "templates/maunaloa/charts.html" {}))


(defroutes my-routes
  (GET "/" request (init))
  (GET "/tickers" request (tickers))
  (GET "/ticker" [oid] (ticker-chart oid)))

