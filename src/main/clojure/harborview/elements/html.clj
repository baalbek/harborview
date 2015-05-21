(ns harborview.elements.html
  (:use
    [compojure.core :only (GET PUT defroutes)])
  (:require
    [net.cgrand.enlive-html :as HTML]
    [harborview.service.htmlutils :as U]
    [harborview.templates.snippets :as SNIP]
    [harborview.elements.dbx :as DBX]
    [harborview.floorplans.dbx :as DBF]))

(HTML/deftemplate steel "templates/steelelements.html" []
  [:head] (HTML/substitute (SNIP/head "Harbor View - Steel Elements" "/js/steelelements.js"))
  [:.ribbon-area] (HTML/substitute (SNIP/ribbon))
  [:#project] (U/populate-select (map U/projects->select (DBF/fetch-projects))))

(HTML/deftemplate wood "templates/steelelements.html" []
  [:head] (HTML/substitute (SNIP/head "Harbor View - Wood Elements" "/js/woodelement.js"))
  [:.ribbon-area] (HTML/substitute (SNIP/ribbon)))

(defn element-systems [bid fid]
  (let [rows (DBF/fetch-floorplan-systems bid fid)]
    (U/json-response {"systems" (map U/bean->json rows)})))

(defn steelbeams []
  (let [rows (DBX/fetch-steel-beams)]
    (U/json-response {"steelbeams" (map U/bean->json rows)})))

(defn distloads [sysid]
  (let [rows (DBX/fetch-dist-loads (U/rs sysid))]
    (U/json-response {"distloads" (map U/bean->json rows)})))

(defroutes my-routes
  (GET "/steel" request (steel))
  (GET "/wood" request (wood))
  (GET "/steelbeams" request (steelbeams))
  (GET "/elementsystems" [bid fid] (element-systems (U/rs bid) (U/rs fid)))
  (GET "/distloads" [sysid] (distloads sysid))
  (PUT "/newsteel" [sysid steel nodes qloads nloads nlf]
    ;(println "sysid " sysid)
    ;(println "steel" steel)
    ;(println "nodes " (class nodes) nodes)
    ;(println "qloads " (class qloads) qloads)
    ;(println "nloads " (class nloads) nloads)
    ;(println "nlf " (class nlf) nlf)
    ;(U/json-response {"result" "result"})))
    (let [result (DBX/new-steel-elements sysid steel nodes qloads nloads nlf)]
      (U/json-response {"result" result})))
  (PUT "/newdistload" [sysid qx1 qx2 qy1 qy2 qz1 qz2 lf]
    (let [result (DBX/new-dist-load sysid qx1 qx2 qy1 qy2 qz1 qz2 lf)]
      (U/json-response {"result" (str (.getOid result))}))))
