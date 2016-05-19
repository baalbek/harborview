(ns harborview.critters.html
  (:import
    [java.util ArrayList]
    [ranoraraku.beans.critters CritterBean AcceptRuleBean DenyRuleBean RuleTypeBean]
    [ranoraraku.beans.options OptionPurchaseBean])
  (:use
    [clojure.string :only (join)]
    [compojure.core :only (GET PUT defroutes)])
  (:require
    [selmer.parser :as P]
    [harborview.service.logservice :as LOG]
    [harborview.service.htmlutils :as U]
    [harborview.critters.dbx :as DBX]))


(comment almost-flatten
  [x]
  (filter #(and (sequential? %) (not-any? sequential? %))
    (rest (tree-seq #(and (sequential? %) (some sequential? %)) seq x))))

(defn ruletype->select [^RuleTypeBean v]
  (let [oid (.getOid v)
        desc (.getDesc v)]
    {:name (str oid " - " desc) :value (str oid)}))

(defn purchase->select [^OptionPurchaseBean p])

(defn critter->map [^CritterBean c]
  (if (nil? c)
    {:oid nil
     :sell_vol nil
     :status nil}
    {
    :oid (.getOid c)
    :sell_vol (.getSellVolume c)
    :status (.getStatus c)}))

(defn acc->map [^AcceptRuleBean acc]
  (if (nil? acc)
    {:aoid nil
    :artyp nil
    :adesc nil
    :aval nil
    :aact nil}
    {:aoid (.getOid acc)
    :artyp (.getRtyp acc)
    :adesc (.getRtypDesc acc)
    :aval (.getAccValue acc)
    :aact (.getActive acc)}))

(defn deny->map [^DenyRuleBean dny]
  (if (nil? dny)
    {:doid nil
    :drtyp nil
    :ddesc nil
    :dval nil
    :dact nil
    :mem nil}
    {:doid (.getOid dny)
    :drtyp (.getRtyp dny)
    :ddesc (.getRtypDesc dny)
    :dval (.getDenyValue dny)
    :dact (.getActive dny)
    :mem (.getMemory dny)}))


(defn critter-only [^CritterBean c]
  (conj (critter->map c) (acc->map nil) (deny->map nil)))

(defn critter-with-denyrule [^CritterBean c,
                             ^AcceptRuleBean acc,
                             ^DenyRuleBean dny]
  (conj (critter->map c) (acc->map acc) (deny->map dny)))

(defn critter-acc-only [^CritterBean c, ^AcceptRuleBean  acc]
  (conj (critter->map c) (acc->map acc) (deny->map nil)))

(defn critter-with-denyrules [^CritterBean c, ^AcceptRuleBean acc, ^ArrayList result]
  (let [denyx (.getDenyRules acc)]
    (.add result (critter-with-denyrule c acc (first denyx)))
    (doseq [deny (rest denyx)]
      (.add result (critter-with-denyrule nil nil deny)))))


(defn critter-acc-denys [^CritterBean c, ^AcceptRuleBean acc, ^ArrayList result]
  (let [denyx (.getDenyRules acc)]
    (if (nil? denyx)
      (.add result (critter-acc-only c))
      (critter-with-denyrules c acc result))))

(defn critter-with-accrules [^CritterBean c, ^ArrayList result]
  (let [accx (.getAcceptRules c)]
    (critter-acc-denys c (first accx) result)
    (doseq [acc (rest accx)]
      (critter-acc-denys nil acc result))))


(defn critter-area [c]
  (let [result (ArrayList.)
        accs (.getAcceptRules c)]
    (if (nil? accs)
      (.add result (critter-only c))
      (critter-with-accrules c result))
    {:lines result}))

(defn purchase-area [p]
  (let [critters (.getCritters p)]
    {:oid (.getOid p)
     :opx (.getOptionName p)
     :critters
     (if
       (nil? critters) []
                       (map critter-area critters))}))

(defn overlook [purchases]
  (P/render-file "templates/critters/overlook.html"
    {:purchases (map purchase-area purchases)}))

(defroutes my-routes
  (GET "/overlook/:id" [id] (overlook(DBX/active-purchases (U/rs id))))
  ;(GET "/new/:id" [id] (new-critter id))
  (GET "/purchases" [ptyp] (U/json-response (map purchase->select (DBX/active-purchases ptyp))))
  (GET "/rtyp" [] (U/json-response (map ruletype->select (DBX/rule-types))))
  (PUT "/addaccrule" [cid value rtyp]
    (let [opx (DBX/insert-accrule-2 (U/rs cid) (U/rs value) (U/rs rtyp))]
      (LOG/info (str "(addaccrule) Cid: " cid ", rtyp: " rtyp ", value: " value))
      (U/json-response
        {"result" (P/render-file "templates/critters/purchase.html" {:purchases [opx]})})))
  ;(H/emit* (critter-area opx)))})))
  (comment PUT "/addaccrule" [cid value rtyp]
    (let [opx (DBX/insert-accrule-2 (U/rs cid) (U/rs value) (U/rs rtyp))]
      (LOG/info (str "(addaccrule) Cid: " cid ", rtyp: " rtyp ", value: " value))
      (U/json-response {"result" (join (H/emit* (critter-area opx)))})))
  (comment PUT "/adddenyrule" [accid value rtyp hasmem]
    (let [opx (DBX/insert-denyrule-2 (U/rs accid) (U/rs value) (U/rs rtyp) hasmem)]
      (LOG/info (str "(adddenyrule) Acc.Id: " accid ", rtyp: " rtyp ", value: " value ", mem: " hasmem))
      (U/json-response {"result" (join (H/emit* (critter-area opx)))})))
  (PUT "/upddenyrule" [groupid value rtyp hasmem]
    (let [denyrule (DBX/insert-denyrule (U/rs groupid) (U/rs value) (U/rs rtyp) hasmem)]
      (U/json-response {"oid" (.getOid denyrule)})))
  (PUT "/updaccrule" [cid value rtyp]
    (let [accrule (DBX/insert-accrule (U/rs cid) (U/rs value) (U/rs rtyp))]
      (U/json-response {"oid" (.getOid accrule)})))
  (PUT "/updgradrule" [gradname cid l1 l2 v1 v2]
    (let [gradrule (DBX/insert-gradrule (U/rs cid) (U/rs l1) (U/rs l2) (U/rs v1) (U/rs v2))]
      (U/json-response {"oid" (.getOid gradrule)})))
  (PUT "/updcritter" [oid status opx sellvol]
    (let [critter (DBX/insert-critter (U/rs oid) (U/rs status) (U/rs opx) (U/rs sellvol))]
      (U/json-response {"oid" (.getOid critter)}))))
