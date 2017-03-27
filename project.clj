(defproject harborview "1.0"
  :description "FIXME: write description"
  :url "http://example.com/FIXME"
  :license {:name "Eclipse Public License"
            :url "http://www.eclipse.org/legal/epl-v10.html"}
  :dependencies [
		[selmer/selmer "1.10.6"]
		[compojure/compojure "1.5.2"]
		[ring/ring-core "1.6.0-RC1"]
		[ring/ring-jetty-adapter "1.6.0-RC1"]
		[ring/ring-servlet "1.6.0-RC1"]
		[clj-json/clj-json "0.5.3"]
		[org.clojure/clojure-contrib "1.2.0"]
		[org.clojure/math.numeric-tower "0.0.4"]
		[org.clojure/clojure "1.8.0"]
		[colt/colt "1.2.0"]
		[commons-codec/commons-codec "1.10"]
		[commons-logging/commons-logging "1.2"]
		[org.mybatis/mybatis "3.4.2"]
		[org.postgresql/postgresql "42.0.0"]
		[log4j/log4j "1.2.17"]
		[jline/jline "0.9.94"]
		[org.springframework/spring-core "4.2.3.RELEASE"]
		[org.springframework/spring-context "4.2.3.RELEASE"]
		[org.aspectj/aspectjrt "1.8.9"]

    ]
  ;:main ^:skip-aot harborview.webapp
  ;:compile 
  :target-path "target"
  :source-paths ["src/clojure"]
  :test-paths ["test/clojure" "dist" "test/resources"]
  :java-source-paths ["src/java" "test/java"]
  :javac-options     ["-target" "1.8" "-source" "1.8"]
  :aot :all
  ;:test {:resource-paths ["test/resources" "dist"]}
  :resource-paths [
		"/home/rcs/opt/java/koteriku/build/libs/koteriku-5.3.1.jar"
		"/home/rcs/opt/java/netfonds-repos/build/libs/netfondsrepos-1.0.jar"
		"/home/rcs/opt/java/oahu/build/libs/oahu-5.3.1.jar"
		"/home/rcs/opt/java/ranoraraku/build/libs/ranoraraku-5.3.5.jar"
		"/home/rcs/opt/java/stearnswharf-repos/build/libs/stearnswharf-1.0.jar"
		"/home/rcs/opt/java/vega/build/libs/vega-5.3.0.jar"

                   ]
  :profiles {:uberjar {:aot :all}})
