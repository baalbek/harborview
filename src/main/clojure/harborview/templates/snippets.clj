(ns harborview.templates.snippets
  (:require
    [net.cgrand.enlive-html :as HTML]))


(comment
  (HTML/defsnippet ribbon "templates/snippets.html" [:.ribbon-area] []
    [:.datasource]
    (HTML/content (str "Ranoraraku: " (nth (DB/dbcp :ranoraraku-db) 1) ", Koteriku: " (nth (DB/dbcp :koteriku-db) 1))))
  )

(HTML/defsnippet head "templates/head.html" [:head] [title & [myscript]]
  [:title] (HTML/content title)
  [:#myscript] (when myscript (HTML/set-attr :src myscript)))

(HTML/defsnippet ribbon "templates/ribbon.html" [:.ribbon-area] []
  identity)
