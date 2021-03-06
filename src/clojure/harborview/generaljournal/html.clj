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
  (map (fn [^GeneralJournalBean x]
        {:bilag (str (.getBilag x))
         :date (.getTransactionDate x)
         :debit (str (.getDebit x))
         :credit (str (.getCredit x))
         :text (.getText x)
         :amount (str (.getAmount x))})
     (DBX/fetch-by-bilag)))

(defn last-receipts-html []
  (P/render-file "templates/generaljournal/gjitems.html"
    {:items (last-receipts)}))

(defn general-journal []
  (let [bilag (first (DBX/fetch-by-bilag))
        bilag-dx (.getTransactionDate bilag)
        last-date (first (DBX/fetch-by-date))
        last-date-dx (.getTransactionDate last-date)
        [url user] (DB/dbcp :koteriku-dbcp)]
    (prn bilag-dx)
    (P/render-file "templates/generaljournal/generaljournal.html"
      {:db-url url
       :db-user user
       :ns4102 (map ns4102->select (DBX/fetch-ns4102))
       :bilag (-> bilag .getBilag inc str)
       :bilag-dx bilag-dx
       :last-date last-date-dx
       :items (last-receipts)})))


(defroutes my-routes
  (GET "/" request (general-journal))
  (PUT "/insert" [credit debit curdate bilag desc amount mva mvaamt]
    (let [gj-bean (DBX/insert bilag curdate credit debit desc amount mva mvaamt)]
      (U/json-response
         {"nextreceipt" (-> bilag read-string inc str)
          "lastreceipts" (last-receipts-html)})))
      ;(U/json-response {"beanId" (.getId gj-bean) "bilag" (-> bilag read-string inc str)})))
  (PUT "/insertinvoice" [curdate bilag amount invoicenum]
    (let [gj-bean (DBX/insert-invoice bilag curdate amount invoicenum)]
      (U/json-response
         {"nextreceipt" (-> bilag read-string inc str)
          "lastreceipts" (last-receipts-html)}))))
