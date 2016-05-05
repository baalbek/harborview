(ns scaffold
  (:import
    [java.util ArrayList]
    [ranoraraku.beans.critters CritterBean AcceptRuleBean DenyRuleBean RuleTypeBean])
  (:require
    [harborview.critters.html :as H]
    [harborview.critters.dbx :as DBX]))


(defn jax []
  (DBX/active-purchases 11))


(defn cr []
  (let [p1 (first (jax))]
    (first (.getCritters p1))))

(defn crx []
  (let [p1 (first (jax))]
    (.getCritters p1)))

(defn critter-only [^CritterBean c]
  {
    :oid (.getOid c)
    :sell_vol (.getSellVolume c)
    :status (.getStatus c)
    :aoid nil
    :artyp nil
    :adesc nil
    :aval nil
    :aact nil
    :doid nil
    :drtyp nil
    :ddesc nil
    :dval nil
    :dact nil
    :mem nil
    })

(defn critter-with-denyrule [^CritterBean c, 
                             ^AcceptRuleBean acc,
                             ^DenyRuleBean dny]
  (if (nil? c)
    (if (nil? acc)
      {:oid nil
      :sell_vol nil
      :status nil
      :aoid nil
      :artyp nil
      :adesc nil
      :aval nil
      :aact nil
      :doid (.getOid dny)
      :drtyp (.getRtyp dny)
      :ddesc (.getRtypDesc dny)
      :dval (.getDenyValue dny)
      :dact (.getActive dny)
      :mem (.getMemory dny)}
      {:oid nil
       :sell_vol nil
       :status nil
       :aoid (.getOid acc)
       :artyp (.getRtyp acc)
       :adesc (.getRtypDesc acc)
       :aval (.getAccValue acc)
       :aact (.getActive acc)
       :doid (.getOid dny)
       :drtyp (.getRtyp dny)
       :ddesc (.getRtypDesc dny)
       :dval (.getDenyValue dny)
       :dact (.getActive dny)
       :mem (.getMemory dny)})
    {:oid (.getOid c)
     :sell_vol (.getSellVolume c)
     :status (.getStatus c)
     :aoid (.getOid acc)
     :artyp (.getRtyp acc)
     :adesc (.getRtypDesc acc)
     :aval (.getAccValue acc)
     :aact (.getActive acc)
     :doid (.getOid dny)
     :drtyp (.getRtyp dny)
     :ddesc (.getRtypDesc dny)
     :dval (.getDenyValue dny)
     :dact (.getActive dny)
     :mem (.getMemory dny)}))


(defn critter-acc-only [^CritterBean c, ^AcceptRuleBean  acc]
  (if (nil? c)
    {
       :oid nil
       :sell_vol nil
       :status nil
       :aoid (.getOid acc)
       :artyp (.getRtyp acc)
       :adesc (.getRtypDesc acc)
       :aval (.getAccValue acc)
       :aact (.getActive acc)
       :doid nil
       :drtyp nil
       :ddesc nil
       :dval nil
       :dact nil
       :mem nil
       }
    {
       :oid (.getOid c)
       :sell_vol (.getSellVolume c)
       :status (.getStatus c)
       :aoid (.getOid acc)
       :artyp (.getRtyp acc)
       :adesc (.getRtypDesc acc)
       :aval (.getAccValue acc)
       :aact (.getActive acc)
       :doid nil
       :drtyp nil
       :ddesc nil
       :dval nil
       :dact nil
       :mem nil
       }))

(defn critter-with-denyrules [^CritterBean c, ^AcceptRuleBean acc, ^ArrayList result]
  (let [denyx (.getDenyRules acc)]
    (.add result (critter-with-denyrule c acc (first denyx)))
    (doseq [deny denyx]
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

(defn run []
  (H/purchase-area (first (jax))))

  ;(let [px (jax)]
  ;  (map purchase-area px)))

