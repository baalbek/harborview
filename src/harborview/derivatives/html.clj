(ns harborview.derivatives.html
  (:import
    [oahu.financial Derivative])
  (:use
    [compojure.core :only (GET PUT defroutes)])
  (:require
    [harborview.derivatives.dbx :as DBX]
    [harborview.service.htmlutils :as U]
    [harborview.templates.snippets :as SNIP]
    [net.cgrand.enlive-html :as H]))


(H/defsnippet data-row "templates/snippets.html" [:.opx-row] [oid ticker x exp series optype]
  [[:td (H/attr= :class "oid")]] (H/content (str oid))
  [:tr :td :a]
    (H/do->
      (H/content ticker)
      (H/set-attr :data-oid (str oid)))
  [[:td (H/attr= :class "x")]] (H/content (str x))
  [[:td (H/attr= :class "exp")]] (H/content (U/date->str exp))
  [[:td (H/attr= :class "series")]] (H/content series)
  [[:td (H/attr= :class "optype")]] (H/content optype))


(H/deftemplate overlook "templates/derivatives/overlook.html" [derivatives]
  [:head] (H/substitute (SNIP/head))
  [:.scripts] (H/substitute (SNIP/scripts))
  [[:tr (H/attr= :class "data-table")]]
    (H/clone-for [d derivatives]
      (let [oid (.getOid ^Derivative d)
            ticker (.getTicker ^Derivative d)
            x (.getX ^Derivative d)
            exp (.getExpiry ^Derivative d)
            series (.getSeries ^Derivative d)
            optype (.getOpTypeStr ^Derivative d)
            ]
        (H/substitute (data-row oid ticker x exp series optype)))))

(defn route-derivatives [tix opx-fn]
  (let [derivatives (opx-fn (read-string tix))]
    (overlook derivatives)))

(defroutes my-routes
  (GET "/calls/:tix" [tix] (route-derivatives tix DBX/calls))
  (GET "/puts/:tix" [tix] (route-derivatives tix DBX/puts))
  (PUT "/purchase" [opid price buy volume spot ptype]
    (let [d-bean (DBX/insert (U/rs opid) (U/rs price) (U/rs buy) (U/rs volume) (U/rs spot) (U/rs ptype))]
      (U/json-response {"oid" (.getOid d-bean)}))))
