(ns harborview.service.htmlutils
  (:require
    [clj-json.core :as json]
    [net.cgrand.enlive-html :as HTML]))


(defn json-response [data & [status]]
  {:status (or status 200)
   :headers {"Content-Type" "application/json"}
   :body (json/generate-string data)})


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
