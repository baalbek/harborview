(ns harborview.templates.snippets
  (:require
    [net.cgrand.enlive-html :as HTML]))



;(HTML/defsnippet ribbon "templates/snippets.html" [:.ribbon-area] []
;  [:.datasource]
;  (HTML/content (str "Ranoraraku: " (nth (DB/dbcp :ranoraraku-db) 1) ", Koteriku: " (nth (DB/dbcp :koteriku-db) 1))))

(HTML/defsnippet head "templates/snippets.html" [:head] [title & [myscript]]
  [:title] (HTML/content title))

;(HTML/defsnippet notifications "templates/snippets.html" [:#notifications] []
;  identity)
