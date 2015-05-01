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

(defn td [content]
  {:tag :td, :content content :attrs {:class "jax"}})

(defn num->td [content]
  (td (str content)))

(comment
  (defn td-a
    [content & [attrs]]
    {:tag :td :attrs attrs :content content})

  (defn num->td-a
    [content & [attrs]]
    (td-a (str content) attrs))
  )
