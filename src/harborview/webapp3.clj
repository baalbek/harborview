(ns harborview.webapp3
  (:require
    [clj-json.core :as json])
  (:use
   [compojure.handler :only (api)]
   [compojure.core :only (GET defroutes context)]
   [ring.adapter.jetty :only (run-jetty)]
   [ring.middleware.params :only (wrap-params)]))

(defn json-response [data & [status]]
  {:status (or status 200)
   :headers {"Content-Type" "application/json"}
   :body (json/generate-string data)})

(defn projects []
  (json-response 
    [
     {:v 1 :t "NEW: Oid 1"}
     {:v 2 :t "NEW: Oid 2"}
     {:v 3 :t "NEW: Oid 3"}
     ]))
  ;(json-response {"oid" "Success! 3"}))

(defroutes main-routes
  (GET "/" request (projects)))

(def webapp
  (-> main-routes
    api
    wrap-params))

;(def server (run-jetty #'webapp {:port 8082 :join? false}))
(def server (run-jetty #'webapp {:port 8443 :join? false :ssl? true :keystore "keystore" :key-password "q2uebec9"}))
