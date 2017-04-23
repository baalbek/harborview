(ns scaffold
  (:import
    [java.time LocalDate]
    [java.sql Date]
    [org.springframework.context.support ClassPathXmlApplicationContext])
  (:require
    [harborview.service.commonutils :as CU]
    [harborview.maunaloa.options :as OPX]))

  ;(:require))
    ;[harborview.vinapu.dbx :as VIN]
    ;[harborview.vinapu.html :as VH]
    ;[harborview.maunaloa.html :as MAU]
    ;[harborview.maunaloa.dbx :as MAUX]
    ;[harborview.service.db :as DB]
    ;[harborview.service.htmlutils :as U]))

(def factory
  (memoize
    (fn []
      (ClassPathXmlApplicationContext. "harborview.xml"))))

(defn etrade []
  (.getBean (factory) "etrade"))

(def dd CU/double->decimal)
(def dd2 CU/double->decimal2)
(def calls OPX/calls)
(def puts OPX/puts)
(def json OPX/option->json)

;(defn calls [ticker]
;  (let [e (etrade)]
;    (.calls e ticker)))

(defn htmlx [ticker]
  (let [e (etrade)]
    (.parseHtmlFor e ticker nil)))

(comment
  (def min-dx (LocalDate/of 2012 1 1))
  (def max-dx (LocalDate/of 2014 10 21))

  (def dd MAU/diff-days)

  (def pdx (Date/valueOf min-dx))

  (defn fp []
    (MAUX/fetch-prices 3 pdx))

  (defn dx [oid]
    (MAU/test-hruler oid))

  (defn weeks []
    (let [bx (MAUX/fetch-prices-m 3 pdx)]
      (MAUX/candlestick-weeks-m 3 bx)))

  (def jr U/json-response)
  (def bj U/bean->json)

  (defn proj []
    (VIN/fetch-projects))

  (defn projx []
    (VH/fetch-projects))

  (defn locs [oid]
    (VIN/fetch-locations oid))

  (defn sys [loc-id]
    (VIN/fetch-systems loc-id))

  (defn nodes [loc-id]
    (VIN/fetch-nodes loc-id))

  (defn elx []
    (VIN/fetch-element-loads 2))

  (defn loads []
    (VIN/fetch-loads))

  (defn celx []
    (VH/cur-element-loads 2))

  (defn tix []
    (MAU/tickers))

  (defn tixc []
    (MAUX/fetch-tickers)))


(comment gs [fnr]
  (DB/with-session :koteriku HourlistGroupMapper
                             (.selectGroupBySpec it fnr)))

(comment hb (HourlistBean.))


(comment pa [oid]
  (let [p (DBX/find-purchase-accid oid)]
    p))

(comment pa [accid]
  (let [p (DBX/find-purchase-accid accid)]
    (HTML/purchase-area p)))

(comment pax [accid]
  (P/render-file "templates/critters/purchase.html"
    {:purchase (pa accid)}))


(comment paxx [accid]
  (let [p (DBX/find-purchase-accid accid)]
    (HTML/overlook [p])))

(comment fp [purchase-id]
   (DB/with-session :ranoraraku CritterMapper
     (.findPurchase it purchase-id)))
