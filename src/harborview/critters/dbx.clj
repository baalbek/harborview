(ns harborview.critters.dbx
  (:import
    [ranoraraku.beans.options OptionPurchaseBean]
    [ranoraraku.beans.critters RuleTypeBean]
    [ranoraraku.beans.critters CritterBean GradientRuleBean AcceptRuleBean DenyRuleBean]
    [ranoraraku.models.mybatis CritterMapper])
  (:require
    [harborview.service.db :as DB]))


(defn active-purchases [purchase-type]
  (DB/with-session :ranoraraku CritterMapper
    (.activePurchasesAll it purchase-type)))

(comment active-purchases [purchase-type]
  (let [a (OptionPurchaseBean.)
        c1 (CritterBean.)
        crittersA (java.util.ArrayList.)
        result (java.util.ArrayList.)]
    (doto c1
      (.setOid 11)
      (.setSellVolume 10)
      (.setPurchaseId 46)
      (.setName "YAR6E350"))
    (.add crittersA c1)
    (doto a
      (.setOid 46)
      (.setCritters crittersA)
      (.setLocalDx (java.time.LocalDate/of 2016 9 1)))
    (.add result a)
    result))


(comment find-purchase [purchase-id]
  (DB/with-session :ranoraraku CritterMapper
    (.findPurchase it purchase-id)))

(defn find-purchase-critid [critter-id]
  (DB/with-session :ranoraraku CritterMapper
    (.findPurchaseForCritId it critter-id)))

(defn find-purchase-accid [acc-id]
  (DB/with-session :ranoraraku CritterMapper
    (.findPurchaseForAccId it acc-id)))

(defn rule-types []
  (DB/with-session :ranoraraku CritterMapper
    (.ruleTypes it)))

(comment rule-types []
  (let [
         r1 (RuleTypeBean.)
         r2 (RuleTypeBean.)
         r3 (RuleTypeBean.)
         result (java.util.ArrayList.)
        ]
    (doto r1 (.setDesc "Diff from bought") (.setOid 7))
    (doto r2 (.setDesc "Diff from bought 2") (.setOid 8))
    (doto r3 (.setDesc "Diff from bought 3") (.setOid 9))
    (.add result r1)
    (.add result r2)
    (.add result r3)
    result))


(defn insert-critter [purchase-id status sellvol]
  (let [result (CritterBean.)]
    (doto result
      (.setPurchaseId purchase-id)
      (.setStatus status)
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

(defn toggle-rule [oid value is-acc]
  (DB/with-session :ranoraraku CritterMapper
    (if (= is-acc true)
      (.toggleAcceptRule it oid value)
      (.toggleDenyRule it oid value))))


