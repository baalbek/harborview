(ns harborview.derivatives.dbx
  (:import
    [java.util ArrayList]
    [oahu.financial Derivative]
    [ranoraraku.models.mybatis
      CritterMapper
      DerivativeMapper]
    [ranoraraku.beans.options OptionPurchaseWithDerivativeBean OptionPurchaseBean]
    [org.apache.ibatis.session SqlSession])
  (:require
    [harborview.service.db :as D]
    [harborview.service.htmlutils :as U]))

(defmacro new-purchase [{:keys [dx price buy volume ptype spot derivative opid]
                         :or {ptype 3
                              volume 0
                              spot 0.0}}]
                              ;dx (java.time.LocalDate/now)}}]
  (let [op-form (if (nil? derivative) `(.setOptionId ~opid) `(.setDerivative ~derivative))
        clazz (if (nil? derivative) `(OptionPurchaseBean.) `(OptionPurchaseWithDerivativeBean.))]
    `(let [opx# ~clazz]
       (doto opx#
         ~op-form
         (.setStatus 1)
         ;(.setLocalDx ~dx)
         (.setPrice ~price)
         (.setBuyAtPurchase ~buy)
         (.setVolume ~volume)
         (.setPurchaseType ~ptype)
         (.setSpotAtPurchase ~spot))
       opx#)))


(defn insert [opid price buy volume spot purchase-type]
  (let [opx (new-purchase {:price price
                             :buy buy,
                             :volume volume
                             :ptype purchase-type
                             :spot spot
                             :opid opid})]
    (D/with-session :ranoraraku CritterMapper
      (.insertPurchase it opx))
  opx))

(defmacro derivatives [ticker-id javafn from-dx]
  `(let [session# ^SqlSession (.openSession (D/get-factory :ranoraraku))
         mapper# (.getMapper session# DerivativeMapper)
         stock# (~javafn mapper# ~ticker-id (or ~from-dx (java.sql.Date/valueOf (java.time.LocalDate/now))))
         result# (if (nil? stock#) nil (.getDerivatives stock#))]
      (doto session# .commit .close)
      result#))

(defn calls [ticker-id & [from-dx]]
  (derivatives ticker-id .calls from-dx))

(defn puts [ticker-id & [from-dx]]
  (derivatives ticker-id .puts from-dx))
