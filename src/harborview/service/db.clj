(ns harborview.service.db
  (:import
    [org.apache.ibatis.io Resources]
    [org.apache.ibatis.session
     SqlSession
     SqlSessionFactory
     SqlSessionFactoryBuilder]
    [java.io  Reader]))

(def mybatis-conf {:ranoraraku "ranoraraku-mybatis.conf.xml"
                   :koteriku "koteriku-mybatis.conf.xml"
                   :stearnswharf "mybatis.conf.xml"})


(def get-factory
  (memoize
    (fn [model]
      (let [conf-xml (model mybatis-conf)]
        (println "Initializing " conf-xml)
        (with-open [reader ^Reader (Resources/getResourceAsReader conf-xml)]
          (let [builder ^SqlSessionFactoryBuilder (SqlSessionFactoryBuilder.)
                factory ^SqlSessionFactory (.build builder reader)]
            factory))))))

(defmacro with-session [model mapper & body]
  `(let [session# ^SqlSession (.openSession (get-factory ~model))
         ~'it (.getMapper session# ~mapper)
         result# ~@body]
     (doto session# .commit .close)
     result#))
