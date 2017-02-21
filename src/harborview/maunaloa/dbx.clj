(ns harborview.maunaloa.dbx
  (:import
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

(def fetch-prices-m
  (CU/memoize-arg0 fetch-prices))
