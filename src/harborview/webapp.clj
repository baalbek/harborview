(ns harborview.webapp
  (:require
    [harborview.service.htmlutils :as U]
    [harborview.critters.dbx :as DBX]
    [harborview.hourlist.html :as HRL]
    [net.cgrand.enlive-html :as HTML]
    [compojure.route :as R]
    [harborview.critters.html :as CRT]
    [harborview.derivatives.html :as OPX]
    [harborview.generaljournal.html :as GJ]
    [harborview.service.htmlutils :as UTIL]
    [harborview.templates.snippets :as SNIP])
  (:use
    [compojure.handler :only (api)]
    [compojure.core :only (GET defroutes context)]
    [ring.adapter.jetty :only (run-jetty)]
    [ring.middleware.params :only (wrap-params)]))

(HTML/deftemplate index "templates/index.html" []
  [:head] (HTML/substitute (SNIP/head))
  ;[:#sidebar-wrapper] (HTML/substitute (SNIP/menu))
  [:.scripts] (HTML/substitute (SNIP/scripts)))


(comment
  (HTML/deftemplate hourlist "templates/hourlist.html" []
    [:head] (HTML/substitute (SNIP/head))
    [:.scripts] (HTML/substitute (SNIP/scripts))
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
        (DBX/fetch-hourlist-groups))))
  )

(defroutes main-routes
  ;(GET "/" request (hourlist))
  (GET "/" request (CRT/overlook (DBX/active-purchases (U/rs 11))))
  (context "/generaljournal" [] GJ/my-routes)
  (context "/hourlist" [] HRL/my-routes)
  (context "/critters" [] CRT/my-routes)
  (context "/opx" [] OPX/my-routes)
  (R/files "/" {:root "public"})
  (R/resources "/" {:root "public"}))

(def webapp
  (-> main-routes
    api
    wrap-params))

(def server (run-jetty #'webapp {:port 8082 :join? false}))
