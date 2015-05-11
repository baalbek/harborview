(ns harborview.nodes.html
  (:use
    [compojure.core :only (GET PUT defroutes)])
  (:require
    [net.cgrand.enlive-html :as HTML]
    [harborview.nodes.dbx :as DBF]
    [harborview.service.htmlutils :as U]
    [harborview.templates.snippets :as SNIP]))



(defroutes my-routes
  (GET "/nodes" [pid cosyid]
    (U/json-response {"nodes" (map U/bean->json (DBF/fetch-nodes (U/rs pid) (U/rs cosyid)))})))

(comment
  (GET "/coordsys" [pid]
    (U/json-response {"coordsys" (DBF/fetch-coord-sys (U/rs pid))}))
  )

(comment
  (defn coordys->json [c]
    {:oid c :text (str c)})

  (defn cosys [pid]
    (U/json-response {"coordsys" (map coordys->json (DBF/fetch-coord-sys (U/rs pid)))}))
  )
