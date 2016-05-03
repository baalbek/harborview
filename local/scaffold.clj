(ns scaffold
  (:import
    [java.util ArrayList]
    [ranoraraku.beans.critters CritterBean AcceptRuleBean DenyRuleBean RuleTypeBean])
  (:require
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

(defn critter-with-accrules [^CritterBean c, ^ArrayList result]
  (let [accx (.getAcceptRules c)]
    (doseq [acc accx]
      (let [denys (.getDenyRules acc)]
        (if (nil? denys)
          (.add result (critter-acc-only c acc)))))))





       ;acc-1 (first accx)
       ;acc-n (rest accx)]
   ;(.add result (critter-acc-only c acc-1))
   ;(doseq [acc acc-n]
   ;  (.add result (critter-acc-only nil acc)))))

(defn run []
  (let [result (ArrayList.)
         px (jax)]
    (doseq [p px]
      (let [cx (.getCritters p)
            cx-1 (first cx)
            cx-n (rest cx)
            accx-1 (.getAcceptRules cx-1)]
        (if (nil? accx-1)
          (.add result (critter-only cx-1))
          (critter-with-accrules cx result))

          



        ;(doseq [c cx]
        ;  (let [accx (.getAcceptRules c)]
        ;    (if (nil? accx)
        ;      (.add result (critter-only c))
        ;      (critter-with-accrules c result))))))
    ;result))

 ;             (let [acc-1 (first accx)
 ;                   acc-n (rest accx)]
 ;               (.add result (critter-acc-only c acc-1))
 ;               (doseq [acc acc-n]
 ;                 (.add result (critter-acc-only nil acc)))))))))
 ;   result))

            ;(doseq [acc accx]
            ;  (println "[" (.getOid p) "] - " (.getOid c) " - " (.getOid acc))

(comment
  (defn critter-with-accrule [^CritterBean c, ^AcceptRuleBean acc]
    (let [dny-rules (.getDenyRules acc)]
      (if (= (.size dny-rules) 0)
        [(critter-acc-only c acc)]
        (do
          (let [dny-1 (first dny-rules)]
            (conj
              (map critter-with-denyrule (repeat nil) (repeat nil) (rest dny-rules))
              (critter-with-denyrule c acc dny-1)
              ))))))



  (defn critter-area [^CritterBean c]
    (let [acc-rules (.getAcceptRules c)]
      ;(doseq [r acc-rules] (println "acc oid: " (.getOid r)))
      (if (= (.size acc-rules) 0)
        [(critter-only c)]
        (do
          (let [acc-1 (first acc-rules)]
            (conj
              (map critter-with-accrule (repeat nil) (rest acc-rules))
              (critter-with-accrule c acc-1)
              ))))))

  (defn run []
    (critter-area (cr)))
  ;(map #(.getOid %) (crx)))
  ;(map critter-area (crx)))

  (defn purchase-area [p]
    (map critter-area (.getCritters p)))

  (defn run2 []
    (let [p (jax)]
      (map purchase-area p)))
  )
