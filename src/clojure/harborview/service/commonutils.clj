(ns harborview.service.commonutils
  (:import
    [java.time LocalDate]))


(defmacro defn-memo [name & body]
  `(def ~name (memoize (fn ~body))))

(defn memoize-arg0 [f]
  (let [mem (atom {})]
    (fn [& args]
      (let [arg0 (first args)]
        (if-let [e (find @mem arg0)]
          (val e)
          (let [ret (apply f args)]
            (swap! mem assoc arg0 ret)
            ret))))))

(defn ld->str [^LocalDate v]
  (let [y (.getYear v)
        m (.getMonthValue v)
        d (.getDayOfMonth v)]
    (str y "-" m "-" d)))
