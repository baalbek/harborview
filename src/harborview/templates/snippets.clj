(ns harborview.templates.snippets
  (:require
    [net.cgrand.enlive-html :as HTML]))


(comment
  (HTML/defsnippet ribbon "templates/snippets.html" [:.ribbon-area] []
    [:.datasource]
    (HTML/content (str "Ranoraraku: " (nth (DB/dbcp :ranoraraku-db) 1) ", Koteriku: " (nth (DB/dbcp :koteriku-db) 1))))

(HTML/defsnippet head "templates/head.html" [:head] [title & [myscript]]
  [:title] (HTML/content title)
  [:#myscript] (when myscript (HTML/set-attr :src myscript)))

(HTML/defsnippet ribbon "templates/ribbon.html" [:.ribbon-area] []
  identity)
  )

(HTML/defsnippet head "templates/snippets.html" [:head] []
  identity)

(HTML/defsnippet scripts "templates/snippets.html" [:.scripts] []
  identity)

(HTML/defsnippet main-menu "templates/snippets.html" [:#main-menu] []
  identity)

(HTML/defsnippet menu "templates/snippets.html" [:#sidebar-wrapper] []
  identity)
