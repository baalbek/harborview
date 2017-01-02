(ns harborview.maunaloa.dbx
  (:import
    [ranoraraku.models.mybatis StockMapper])
  (:require
    [harborview.service.db :as DB]))

(defn fetch-tickers []
  (DB/with-session :ranoraraku StockMapper
    (.selectStocks it)))
