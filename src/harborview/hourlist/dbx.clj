(ns harborview.hourlist.dbx
  (:import
    [koteriku.beans
      HourlistBean
      HourlistGroupBean]
    [koteriku.models.mybatis
      InvoiceMapper
      HourlistMapper
      HourlistGroupMapper])
  (:require
    [harborview.service.db :as DB]
    [harborview.service.htmlutils :as U]))


(defn fetch-group-sums [invoice]
  (DB/with-session :koteriku HourlistGroupMapper
    (let [result (.selectGroupBySpec it (U/rs invoice))
          sumTotalBean (HourlistGroupBean.)
          ]
      (doto sumTotalBean
        (.setDescription "Sum total:")
        (.setSumHours (reduce + (map #(.getSumHours %) result))))
      (.add result sumTotalBean)
      result)))

(defn fetch-hourlist-groups []
  (DB/with-session :koteriku HourlistGroupMapper
    (.selectHourlistGroups it)))

(defn fetch-invoices []
  (DB/with-session :koteriku InvoiceMapper
    (.selectInvoices it)))

(defn fetch-last-5 [invoice]
  (DB/with-session :koteriku HourlistMapper
    (.selectLast5 it (U/rs invoice))))

(defn fetch-all [invoice]
  (DB/with-session :koteriku HourlistMapper
    (.selectAll it (U/rs invoice))))

(defn insert-hourlist [fnr group curdate from_time to_time hours]
  (let [hb (HourlistBean.)]
    (doto hb
      (.setInvoiceNr (Integer. fnr))
      (.setGroupId (Integer. group))
      (.setLocalDate (U/str->date curdate))
      (.setFromTime from_time)
      (.setToTime to_time)
      (.setHours (Double. hours)))
    (DB/with-session :koteriku HourlistMapper
      (.insertHourlist it hb))))

(defn insert-hourlist-group [name]
  (let [hb (HourlistGroupBean.)]
    (.setDescription hb name)
    (DB/with-session :koteriku HourlistGroupMapper
                               (.insertHourlistGroup it hb))
    hb))

(comment
  (let [hb (HourlistBean.)
        f (KoterikuFacade.)]
    (doto hb
      (.setInvoiceNr (Integer. fnr))
      (.setGroupId (Integer. group))
      (.setSqlDate (U/str->date curdate))
      (.setFromTime from_time)
      (.setToTime to_time)
      (.setHours (Double. hours)))
    (.insertHourlist f hb)))


