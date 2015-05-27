(ns harborview.service.db
  (:import
    [org.apache.ibatis.io Resources]
    [org.apache.ibatis.session
     SqlSession
     SqlSessionFactory
     SqlSessionFactoryBuilder]
    [java.io  Reader]))

(comment
  (def get-factory
    (memoize
      (fn []
        (println "Initializing mybatis.conf.xml")
        (with-open [reader ^Reader (Resources/getResourceAsReader "mybatis.conf.xml")]
          (let [builder ^SqlSessionFactoryBuilder (SqlSessionFactoryBuilder.)
                factory ^SqlSessionFactory (.build builder reader)]
            factory)))))

  (defmacro with-session [mapper & body]
    `(let [session# ^SqlSession (.openSession (get-factory))
           ~'it (.getMapper session# ~mapper)
           result# ~@body]
       (doto session# .commit .close)
       result#))
  )

(def mybatis-conf {:ranoraraku "ranoraraku-mybatis.conf.xml"
                   :koteriku "koteriku-mybatis.conf.xml"
                   :stearnswharf "mybatis.conf.xml"
                   })

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


(comment with-session-multi [mapper & body]
  `(let [session# ^SqlSession (.openSession (get-factory))
         ~'it (.getMapper session# ~mapper)]
     (loop [b# ~body]
       (if (seq? b#)
         (do (first b#) (recur (next b#)))))
   (doto session# .commit .close)))


(comment yax [v & body]
  (loop [b body]
    (if (seq? b)
      (do
        (println ((first b) v))
        (recur (next b))))))
