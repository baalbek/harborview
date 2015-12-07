(ns harborview.service.htmlutils
  (:import
    [java.time LocalDate]
    [java.time.format DateTimeFormatter]
    [stearnswharf.systems ProjectBean])
  (:require
    [clj-json.core :as json]
    [net.cgrand.enlive-html :as HTML]))

(def p1 #"\d\d\d\d-\d+-\d+")

(def p2 #"\d+/\d+/\d\d\d\d")

(def date-fmt-1 (DateTimeFormatter/ofPattern "yyyy-MM-dd"))

(def date-fmt-2 (DateTimeFormatter/ofPattern "MM/dd/yyyy"))

(defn date-fmt [s]
  (cond
    (re-find p1 s) date-fmt-1
    (re-find p2 s) date-fmt-2))

(defn json-response [data & [status]]
  {:status (or status 200)
   :headers {"Content-Type" "application/json"}
   :body (json/generate-string data)})

(defn bean->json [b]
  {"oid" (.getOid b), "text" (.toHtml b)})

;(defmacro bean->json [b & [oid-fn]]
;  (if (nil? oid-fn)
;    `{"oid" (.getOid  ~b), "text" (.toHtml  ~b)}
;    `{"oid" (~oid-fn ~b), "text" (.toHtml  ~b)}

(defn populate-select [options]
  (fn [node]
    (HTML/at node [:option]
      (HTML/clone-for [option options]
        (HTML/do-> (HTML/set-attr :value (option :value))
          #(if (option :selected)
             ((HTML/set-attr :selected "selected") %) %)
          (HTML/content (option :name)))))))

(defn rs [v]
  (if (string? v)
    (let [vs (if-let [v (re-seq #"(\d+),(\d+)" v)]
               (let [[a b c] (first v)] (str b "." c))
               v)]
      (read-string vs))
    v))

(defn th [v & [attrs]]
  {:tag :th :attrs attrs :content [v]})

(defn th2 [v & [attrs]]
  {:tag :th :attrs attrs :content v})

(defn td [v & [attrs]]
  {:tag :td :attrs attrs :content [v]})

(defn td2 [v & [attrs]]
  {:tag :td :attrs attrs :content v})

  ;{:tag :td, :content content :attrs {:class "jax"}})

(defn num->td [content]
  (td (str content)))

(defn num2->td [content]
  (td (format "%.2f" content)))

(defn projects->select [^ProjectBean v]
  (let [oid (.getOid v)]
    {:name (.toHtml v) :value (str oid) :selected (.isSelected v)}))

(defn in?
  "true if seq contains elm"
  [seq elm]
  (some #(= elm %) seq))

(defn str->date [dx]
  (LocalDate/parse dx (date-fmt dx)))

(comment date->str [dx]
  (let [dxx (if (= (class dx) java.util.Date)
              (DateMidnight. dx)
              dx)]
    (.print date-fmt-1 dxx)))