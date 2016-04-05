(ns harborview.critters.dbx
  (:import
    [ranoraraku.beans.critters CritterBean GradientRuleBean AcceptRuleBean DenyRuleBean]
    [ranoraraku.models.mybatis CritterMapper])
  (:require
    [harborview.service.db :as DB]))


(defn active-purchases [purchase-type]
  (DB/with-session :ranoraraku CritterMapper
    (.activePurchasesAll it purchase-type)))


(comment find-purchase [purchase-id]
  (DB/with-session :ranoraraku CritterMapper
    (.findPurchase it purchase-id)))

(defn find-purchase-critid [critter-id]
  (DB/with-session :ranoraraku CritterMapper
    (.findPurchaseForCritId it critter-id)))

(defn find-purchase-accid [acc-id]
  (DB/with-session :ranoraraku CritterMapper
    (.findPurchaseForAccId it acc-id)))

(def rule-types
  (fn []
    (DB/with-session :ranoraraku CritterMapper
      (.ruleTypes it))))

(defn insert-critter [oid status opx sellvol]
  (let [result (CritterBean.)]
    (doto result
      (.setStatus status)
      (.setPurchaseId opx)
      (.setSellVolume sellvol))
    (DB/with-session :ranoraraku CritterMapper
      (.insertCritter it result))
    result))

(defn insert-gradrule [cid l1 l2 v1 v2]
  (let [result (GradientRuleBean.)]
    (doto result
      (.setCid cid)
      (.setLevel1 l1)
      (.setLevel2 l2)
      (.setValue1 v1)
      (.setValue2 v2))
    (DB/with-session :ranoraraku CritterMapper
      (.insertGradientRule it result))
    result))

(defn insert-accrule [cid value rtyp]
  (let [result (AcceptRuleBean.)]
    (doto result
      (.setCid cid)
      (.setAccValue value)
      (.setRtyp rtyp))
    (DB/with-session :ranoraraku CritterMapper
      (.insertAcceptRule it result))
    result))
  
(defn insert-denyrule [accid value rtyp hasmem]
  (let [result (DenyRuleBean.)]
    (doto result
      (.setGroupId accid)
      (.setDenyValue value)
      (.setRtyp rtyp)
      (.setMemory hasmem))
    (DB/with-session :ranoraraku CritterMapper
      (.insertDenyRule it result))
    result))

(defn insert-accrule-2 [cid value rtyp]
  (insert-accrule cid value rtyp)
  (find-purchase-critid cid))

(defn insert-denyrule-2 [accid value rtyp hasmem]
  (insert-denyrule accid value rtyp hasmem)
  (find-purchase-accid accid))
