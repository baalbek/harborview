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

(defroutes my-routes
  (GET "/steel" request (steel))
  (GET "/wood" request (wood))
  (GET "/elementsystems" [bid fid] (element-systems (U/rs bid) (U/rs fid))))
