(ns harborview.service.db
  (:import
    [org.apache.ibatis.io Resources]
    [org.apache.ibatis.session
     SqlSession
     SqlSessionFactory
     SqlSessionFactoryBuilder]
    [java.io  Reader]))

(def get-factory
  (memoize
    (fn []
      (println "Initializing mybatis.conf.xml" )
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

