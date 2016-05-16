(ns harborview.generaljournal.html
  (:import
    [koteriku.beans Ns4102Bean])
  (:use
    [compojure.core :only (GET PUT defroutes)])
  (:require
    [selmer.parser :as P]
    [harborview.service.htmlutils :as U]
    [harborview.service.db :as DB]
    [harborview.templates.snippets :as SNIP]
    [harborview.generaljournal.dbx :as DBX]
    [clj-json.core :as json]))


(defn ns4102->select [^Ns4102Bean v]
  (let [text (.getText v)
        account (.getAccount v)]
    {:name (str account " - " text) :value (str account)}))

(comment HTML/deftemplate  general-journal "templates/generaljournal.html" []
  ;[:head] (HTML/substitute (SNIP/head "Kassadagbok" "/js/generaljournal.js"))
  [:.scripts] (HTML/substitute (SNIP/scripts))
  [:#bilag] (HTML/set-attr :value (-> (DBX/fetch-by-bilag) first .getBilag inc str))
  [:#debit] (U/populate-select (map ns4102->select (DBX/fetch-ns4102)))
  [:#credit] (U/populate-select (map ns4102->select (DBX/fetch-ns4102))))

(defn general-journal []
  (P/render-file "templates/generaljournal/generaljournal.html" {}))


(defroutes my-routes
  (GET "/" request (general-journal)))

  ;(PUT "/insert" [credit debit curdate bilag desc amount mva mvaamt]
  ;  (let [gj-bean (DBX/insert bilag curdate credit debit desc amount mva mvaamt)]
  ;    (U/json-response {"beanId" (.getId gj-bean) "bilag" (-> bilag read-string inc str)})))
  ;(PUT "/insertinvoice" [curdate bilag amount invoicenum]
  ;  (let [gj-bean (DBX/insert-invoice bilag curdate amount invoicenum)]
  ;    (U/json-response {"beanId" (.getId gj-bean) "bilag" (-> bilag read-string inc str)}))))
