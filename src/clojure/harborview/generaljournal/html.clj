(ns harborview.generaljournal.html
  (:import
    [koteriku.beans
      GeneralJournalBean
      Ns4102Bean])
  (:use
    [compojure.core :only (GET PUT defroutes)])
  (:require
    [selmer.parser :as P]
    [harborview.service.htmlutils :as U]
    [harborview.service.db :as DB]
    [harborview.generaljournal.dbx :as DBX]
    [clj-json.core :as json]))


(defn ns4102->select [^Ns4102Bean v]
  (let [text (.getText v)
        account (.getAccount v)]
    {:name (str account " - " text) :value (str account)}))

(defn last-receipts []
  (P/render-file "templates/generaljournal/gjitems.html"
    {:items
      (map (fn [^GeneralJournalBean x]
            {:oid (str (.getId x))
             :bilag (str (.getBilag x))
             :date (.getTransactionDate x)
             :debit (str (.getDebit x))
              :credit (str (.getCredit x))
             :text (str (.getText x))
             :amount (str (.getAmount x))})
         (DBX/fetch-by-bilag))}))

(defn general-journal []
  (let [bilag (first (DBX/fetch-by-bilag))
        bilag-dx (.getTransactionDate bilag)]
    (prn bilag-dx)
    (P/render-file "templates/generaljournal/generaljournal.html"
      {:ns4102 (map ns4102->select (DBX/fetch-ns4102))
       :bilag (-> bilag .getBilag inc str)
       :bilag-dx bilag-dx})))
       ;:items (last-receipts)})))


(defroutes my-routes
  (GET "/" request (general-journal))
  (PUT "/insert" [credit debit curdate bilag desc amount mva mvaamt]
    (let [gj-bean (DBX/insert bilag curdate credit debit desc amount mva mvaamt)]
      (U/json-response {"beanId" (.getId gj-bean) "bilag" (-> bilag read-string inc str)})))
  (PUT "/insertinvoice" [curdate bilag amount invoicenum]
    (let [gj-bean (DBX/insert-invoice bilag curdate amount invoicenum)]
      (U/json-response
         {"nextreceipt" (-> bilag read-string inc str)})))
  (PUT "/test" [bilag]
    (prn "Bilag "  bilag)
    (U/json-response
       {"nextreceipt" (-> "14" read-string inc str)})))
