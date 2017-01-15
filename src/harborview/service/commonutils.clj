(ns harborview.service.commonutils)

(defn memoize-arg0 [f]
  (let [mem (atom {})]
    (fn [& args]
      (let [arg0 (first args)]
        (if-let [e (find @mem arg0)]
          (val e)
          (let [ret (apply f args)]
            (swap! mem assoc arg0 ret)
            ret))))))
