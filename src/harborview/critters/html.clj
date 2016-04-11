(ns harborview.critters.html
  (:import
    [ranoraraku.beans.critters CritterBean AcceptRuleBean DenyRuleBean RuleTypeBean]
    [ranoraraku.beans.options OptionPurchaseBean])
  (:use
    [clojure.string :only (join)]
    [compojure.core :only (GET PUT defroutes)])
  (:require
    [harborview.service.logservice :as LOG]
    [harborview.service.htmlutils :as U]
    [harborview.critters.dbx :as DBX]
    [harborview.templates.snippets :as SNIP]
    [net.cgrand.enlive-html :as H]))


(def num-crit-items 4)
(def num-acc-items 6)

(defn th [v] {:tag :th :attrs nil :content [(str v)]})

(defn td
  [v & [attrs]]
  {:tag :td :attrs attrs :content [(str v)]})

(defn td-a
  [content & [attrs]]
  {:tag :td :attrs attrs :content content})

(defn crit->td
  [^CritterBean c]
  (let [oid (.getOid c)
        purchase-id (.getPurchaseId c)]
    [
      (td-a [{:tag :a :attrs {:href "#" :class "critoid" :data-critid (str oid)} :content [(str oid)]}])
      (td (.getSellVolume c))
      (td (.getStatus c))
      (td-a [{:tag :a :attrs {:href "#dlg-new-accrule" :class "newaccrule" :data-critid (str oid) :data-puid (str purchase-id)}
              :content ["New acc."]}])
      ]))

(defn acc->td [purchase-id, ^AcceptRuleBean a]
  (let [oid (.getOid a)]
    [
      (td oid {:class "acc-oid" :data-oid (str oid)})
      (td (.getRtyp a))
      (td (.getRtypDesc a))
      (td (.getAccValue a))
      (td (.getActive a))
      (td-a [{:tag :a :attrs {:href "#dlg-new-dnyrule" :class "newdenyrule" :data-accid (str oid) :data-puid (str purchase-id)}
              :content ["New deny"]}])
      ]))

(defn deny->td [^DenyRuleBean d]
  (let [oid (.getOid d)]
    [(td oid {:class "deny-oid" :data-oid (str oid)})
     (td (.getRtyp d))
     (td (.getRtypDesc d))
     (td (.getDenyValue d))
     (td (.getActive d))
     (td (.getMemory d))]))

;; Flattens a list of embedded lists upto but not including last leve
;; (almost-flatten [[[1 2] [3 4]]]) --> ([1 2] [3 4])
(defn almost-flatten
  [x]
  (filter #(and (sequential? %) (not-any? sequential? %))
    (rest (tree-seq #(and (sequential? %) (some sequential? %)) seq x))))

(defn staircase-acc [purchase-id, ^AcceptRuleBean a]
  (let [pre-acc (acc->td purchase-id a)
        pre-empty (repeat num-acc-items (td nil))
        rules (.getDenyRules a)
        dnys (if (> (count rules) 0)
               (map deny->td rules)
               [(repeat 6 (td nil))])]
    (loop [result (conj [] (concat pre-acc (first dnys)))
           dnx (rest dnys)]
      (if-not (seq dnx)
        result
        (recur
          (conj result (concat pre-empty (first dnx)))
          (rest dnx))))))


(defn staircase-crit [^CritterBean c]
  (let [pre-crit (crit->td c)
        pre-empty (repeat num-crit-items (td nil))
        rules (.getAcceptRules c)
        my-staircase-acc (partial staircase-acc (.getPurchaseId c))
        accs (if (> (count rules) 0)
               (almost-flatten (map my-staircase-acc rules))
               [(repeat num-acc-items (td nil))])]
    (loop [result (conj [] {:tag :tr :attrs nil :content (concat pre-crit (first accs))})
           acx (rest accs)]
      (if-not (seq acx)
        result
        (recur
          (conj result {:tag :tr :attrs nil :content (concat pre-empty (first acx))})
          (rest acx))))))

(defn opx->select [^OptionPurchaseBean v]
  (let [ticker (.getOptionName v)
        oid (.getOid v)]
    {:name (str oid " - " ticker) :value (str oid)}))

(defn ruletype->select [^RuleTypeBean v]
  (let [oid (.getOid v)
        desc (.getDesc v)]
    {:name (str oid " - " desc) :value (str oid)}))

(defn critter-area [^OptionPurchaseBean p]
  (let [crits (.getCritters p)
        crit-headers ["Oid" "Sell Volume" "Status" "-"
                      "Acc.oid" "Rtyp" "Desc" "Value" "Active" "-"
                      "Deny oid" "Rtyp" "Desc" "Value" "Active" "Memory"]
        thead (map th crit-headers)
        tbody (flatten (map staircase-crit crits))
        oid (.getOid p)
        result [
                 {:tag :div :attrs {:class "critter-area" :id (str "critter-area-" oid)}
                  :content [
                             {:tag :details :attrs nil :content [
                                                                  {:tag :summary :attrs nil :content [(str "[ " oid " ] " (.getOptionName p))]}
                                                                  {:tag :table :attrs {:class "table"}
                                                                   :content [
                                                                              {:tag :thead :attrs nil :content [{:tag :tr :attrs nil :content thead}]}
                                                                              {:tag :tbody :attrs nil :content tbody}
                                                                              ]}]}
                             ]}]
        ]
    result))

(defn make-critters [purchases]
  (map critter-area purchases))

(H/deftemplate overlook "templates/critters/overlook.html" [purchases]
  [:head] (H/substitute (SNIP/head)) ;(SNIP/head "Critters - overlook" "js/critters.js"))
  [:.scripts] (H/substitute (SNIP/scripts))
  [:.purchases] (H/substitute (make-critters purchases)))


(H/deftemplate new-critter "templates/critters/newcritter.html" [id]
  [:head] (H/substitute (SNIP/head)) ;(SNIP/head "Critters - new critter" "/js/newcritter.js"))
  [:#deny_rtyp] (U/populate-select (map ruletype->select (DBX/rule-types)))
  [:#acc_rtyp] (U/populate-select (map ruletype->select (DBX/rule-types)))
  [:#opx] (U/populate-select (map opx->select (DBX/active-purchases (U/rs id)))))


(defroutes my-routes
  (GET "/overlook/:id" [id] (overlook (DBX/active-purchases (U/rs id))))
  (GET "/new/:id" [id] (new-critter id))
  (GET "/rtyp" [] (U/json-response (map ruletype->select (DBX/rule-types))))
  (PUT "/addaccrule" [cid value rtyp]
    (let [opx (DBX/insert-accrule-2 (U/rs cid) (U/rs value) (U/rs rtyp))]
      (LOG/info (str "(addaccrule) Cid: " cid ", rtyp: " rtyp ", value: " value))
      (U/json-response {"result" (join (H/emit* (critter-area opx)))})))
  (PUT "/adddenyrule" [accid value rtyp hasmem]
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
