(ns harborview.maunaloa.options
  (:import
    [org.springframework.context.support ClassPathXmlApplicationContext])
  (:require
    [harborview.service.commonutils :as CU]))

(CU/defn-memo spring-context []
  (println "Initializing spring context: harborview.xml")
  (ClassPathXmlApplicationContext. "harborview.xml"))


(defn get-bean  [bn]
  (.getBean (spring-context) bn))
