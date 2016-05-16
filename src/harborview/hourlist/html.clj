(ns harborview.hourlist.html
  (:import
   [koteriku.beans HourlistBean HourlistGroupBean])
  (:use
   [compojure.core :only (GET PUT defroutes)])
  (:require
   [selmer.parser :as P]
   [harborview.hourlist.dbx :as DBX]
   [harborview.service.htmlutils :as UTIL]
   [harborview.templates.snippets :as SNIP]))


(comment H/deftemplate hourlist "templates/hourlist.html" [ctx]
  [:head] (H/substitute (SNIP/head "Timeliste" "/js/hourlist.js"))
  [:#fnr]
  (UTIL/populate-select
    (map (fn [v]
           (let [fnr (.getInvoiceNum v)
                 cust (.getCustomerName v)
                 desc (.getDescription v)]
             {:name (str fnr " - " cust " - " desc) :value (str fnr)}))
      (DBX/fetch-invoices)))
  [:#group]
  (UTIL/populate-select
    (map (fn [v]
           {:name (str (.getId v) " - " (.getDescription v)) :value (str (.getId v))})
      (DBX/fetch-hourlist-groups)))
  [:p#message] (H/content (:message ctx)))

(comment H/defsnippet groupsums "templates/snippets.html" [:.groupsums] [fnr]
  [[:tr (H/attr= :class "rows")]]
    (H/substitute
      (map (fn [^HourlistGroupBean x]
             {:tag :tr, :content [
               {:tag :td, :content (.getDescription x)}
               {:tag :td, :content (str (.getSumHours x))}]})
        (DBX/fetch-group-sums fnr))))

(comment H/defsnippet overview "templates/snippets.html" [:.overview] [fnr sel-fn]
  [[:tr (H/attr= :class "rows")]]
    (H/substitute
      (map (fn [^HourlistBean x]
              {:tag :tr, :content [
                {:tag :td, :content (str (.getOid x))}
                {:tag :td, :content (.getDescription x)}
                {:tag :td, :content (str (.getInvoiceNr x))}
                {:tag :td, :content (UTIL/date->str (.getLocalDate x))}
                {:tag :td, :content (str (.getHours x))}
                {:tag :td, :content (.getFromTime x)}
                {:tag :td, :content (.getToTime x)}
              ]})
        (sel-fn fnr))))

(defn hourlist[]
  (P/render-file "templates/hourlist/hourlist.html"
    {:invoices
      (map (fn [v]
             (let [fnr (.getInvoiceNum v)
                   cust (.getCustomerName v)
                   desc (.getDescription v)]
               {:content (str fnr " - " cust " - " desc) :value (str fnr)}))
        (DBX/fetch-invoices))
     :hourlistgroups
       (map (fn [v]
              {:content (str (.getId v) " - " (.getDescription v)) :value (str (.getId v))})
         (DBX/fetch-hourlist-groups))}))

(defn overview [fnr select-fn]
  (P/render-file "templates/hourlist/hourlistitems.html"
    {:items
     (map (fn [^HourlistBean x]
            {:oid (str (.getOid x))
            :desc (.getDescription x)
            :fnr (str (.getInvoiceNr x))
            :date (UTIL/date->str (.getLocalDate x))
            :hours (str (.getHours x))
            :fromtime (.getFromTime x)
            :totime (.getToTime x)})
      (select-fn fnr))}))


(comment H/defsnippet overview "templates/snippets.html" [:.overview] [fnr sel-fn]
                      [[:tr (H/attr= :class "rows")]]
                      (H/substitute
                        (map (fn [^HourlistBean x]
                               {:tag :tr, :content [
                                                     {:tag :td, :content (str (.getOid x))}
                                                     {:tag :td, :content (.getDescription x)}
                                                     {:tag :td, :content (str (.getInvoiceNr x))}
                                                     {:tag :td, :content (UTIL/date->str (.getLocalDate x))}
                                                     {:tag :td, :content (str (.getHours x))}
                                                     {:tag :td, :content (.getFromTime x)}
                                                     {:tag :td, :content (.getToTime x)}
                                                     ]})
                          (sel-fn fnr))))

(defn hourlist[]
  (P/render-file "templates/hourlist/hourlist.html"
    {:invoices
     (map (fn [v]
            (let [fnr (.getInvoiceNum v)
                  cust (.getCustomerName v)
                  desc (.getDescription v)]
              {:content (str fnr " - " cust " - " desc) :value (str fnr)}))
       (DBX/fetch-invoices))
     :hourlistgroups
     (map (fn [v]
            {:content (str (.getId v) " - " (.getDescription v)) :value (str (.getId v))})
       (DBX/fetch-hourlist-groups))}))

(defn overview [fnr select-fn]
  (P/render-file "templates/hourlist/hourlistitems.html"
    {:items
     (map (fn [^HourlistBean x]
            {:oid (str (.getOid x))
             :desc (.getDescription x)
             :fnr (str (.getInvoiceNr x))
             :date (UTIL/date->str (.getLocalDate x))
             :hours (str (.getHours x))
             :fromtime (.getFromTime x)
             :totime (.getToTime x)})
       (select-fn fnr))}))

(defn groupsums [fnr]
  (P/render-file "templates/hourlist/groupsums.html"
    {:hourlistsums
      (map (fn [^HourlistGroupBean x]
               {:desc (.getDescription x)
               :sum (str (.getSumHours x))})
        (DBX/fetch-group-sums fnr))}))

(defroutes my-routes
  (GET "/" request (hourlist))
  ;(GET "/" request (hourlist {:message "Beginning"})))
  ;(GET "/groupsums" [fnr] (H/emit* (groupsums fnr)))
  ;(GET "/overview" [fnr] (H/emit* (overview fnr DBX/fetch-all)))
  (GET "/groupsums" [fnr] (groupsums fnr))
  (GET "/overview" [fnr] (overview fnr DBX/fetch-all))
  (PUT "/insert" [fnr group curdate from_time to_time hours]
                 (do
                   (DBX/insert-hourlist fnr group curdate from_time to_time hours)
                   (overview fnr DBX/fetch-last-5))))

;(U/json-response {"
(defroutes my-routes
  (GET "/" request (hourlist))
  ;(GET "/" request (hourlist {:message "Beginning"})))
  ;(GET "/groupsums" [fnr] (H/emit* (groupsums fnr)))
  ;(GET "/overview" [fnr] (H/emit* (overview fnr DBX/fetch-all)))
  (GET "/groupsums" [fnr] (groupsums fnr))
  (GET "/overview" [fnr] (overview fnr DBX/fetch-all))
  (PUT "/insert" [fnr group curdate from_time to_time hours]
    (do
      (DBX/insert-hourlist fnr group curdate from_time to_time hours)
      (overview fnr DBX/fetch-last-5))))

;(U/json-response {"
