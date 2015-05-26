(ns harborview.elements.dbx
  (:import
    [stearnswharf.elements SteelBeam DistLoad SteelElement NodeLoad WoodElement]
    [stearnswharf.mybatis ElementsMapper])
  (:require
    [harborview.service.htmlutils :as U]
    [harborview.service.db :as DB]))

(def r U/rs)

(def fetch-steel-beams
  (memoize
    (fn []
      (DB/with-session ElementsMapper
        (.fetchSteelBeams it)))))

(def fetch-wood-stclass
  (memoize
    (fn []
      (DB/with-session ElementsMapper
        (.fetchWoodStClass it)))))

(defn fetch-steel-elements [sysid]
  (DB/with-session ElementsMapper
    (.fetchSteelElements it (r sysid))))

(defn new-steel-element [sysid steel [n1 n2] qload]
  (if (and (> n1 0) (> n2 0))
    (let [s (SteelElement.)]
      (doto s
        (.setSysId sysid)
        (.setN1 n1)
        (.setN2 n2)
        (.setProfileId steel)
        (.setLoadId qload)
        (.setStatus 0))
      s)
    nil))


(defn new-node-load [sysid angle n1 p lf]
  (if (> (Math/abs p) 0)
    (let [node-load (NodeLoad.)]
      (doto node-load
        (.setSysId sysid)
        (.setAngle angle)
        (.setN1 n1)
        (.setP p)
        (.setLoadFactor lf))
      node-load)
    nil))

(defn new-node-loads [mapper sysid nodes nloads nlf]
  (let [nloads* (map r nloads)
        nlf* (map r nlf)
        new-node-load-fn (partial new-node-load sysid 90)
        node-elements (filter #(not= nil %) (map new-node-load-fn nodes nloads* nlf*))]
    (doseq [p node-elements]
      (.newNodeLoad mapper p))))

(defn new-steel-elements  [sysid steel nodes qloads nloads nlf]
  (let [sysid* (r sysid)
        steel* (r steel)
        qloads* (map r qloads)
        nodes* (map r nodes)
        nodepairs* (partition 2 1 nodes*)
        new-steel-fn (partial new-steel-element sysid* steel*)
        elx (filter #(not= nil %) (map new-steel-fn nodepairs* qloads*))]
    (DB/with-session ElementsMapper
      (do
        (new-node-loads it sysid* nodes* nloads nlf)
        (doseq [e elx]
          (.newSteelElement it e)
          (if (= (.hasElementLoad e) true)
            (.newSteelElementLoad it (.createElementLoad e))))))))


(defn new-wood-element [sysid stclass w h [n1 n2] qload]
  (if (and (> n1 0) (> n2 0))
    (let [s (WoodElement.)]
      (doto s
        (.setSysId sysid)
        (.setN1 n1)
        (.setN2 n2)
        (.setStClass stclass)
        (.setW w)
        (.setH h)
        (.setLoadId qload)
        (.setStatus 0))
      s)
    nil))


(defn new-wood-elements [sysid stclass w h nodes qloads nloads nlf]
  (let [sysid* (r sysid)
        w* (r w)
        h* (r h)
        qloads* (map r qloads)
        stclass* (r stclass)
        nodes* (map r nodes)
        nodepairs* (partition 2 1 nodes*)
        new-wood-fn (partial new-wood-element sysid* stclass* w* h*)
        elx (filter #(not= nil %) (map new-wood-fn nodepairs* qloads*))]
    (DB/with-session ElementsMapper
      (do
        (new-node-loads it sysid* nodes* nloads nlf)
        (doseq [e elx]
          (.newWoodElement it e)
          (if (= (.hasElementLoad e) true)
            (.newWoodElementLoad it (.createElementLoad e))))))))

(defn new-dist-load [sysid qx1 qx2 qy1 qy2 qz1 qz2 lf]
  (let [d (DistLoad.)]
    (doto d
      (.setSysId (r sysid))
      (.setQx1 (r qx1))
      (.setQx2 (r qx2))
      (.setQy1 (r qy1))
      (.setQy2 (r qy2))
      (.setQz1 (r qz1))
      (.setQz2 (r qz2))
      (.setLoadFactor (r lf)))
    (DB/with-session ElementsMapper
      (.newDistLoad it d))
    d))


(defn fetch-dist-loads [sysid]
  (DB/with-session ElementsMapper
    (.fetchDistLoads it sysid)))
