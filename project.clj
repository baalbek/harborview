(defproject harborview "1.0"
  :description "FIXME: write description"
  :url "http://example.com/FIXME"
  :license {:name "Eclipse Public License"
            :url "http://www.eclipse.org/legal/epl-v10.html"}
  ;:dependencies [[org.clojure/clojure "1.7.0"]]
  ;:main ^:skip-aot kilauea.core
  :target-path "target"
  :java-test-paths ["test-java"]
  :aot :all
  :resource-paths [
		;deps
			"/home/rcs/opt/java/stearnswharf-repos/build/libs/stearnswharf-1.0.jar"
			"/home/rcs/opt/java/koteriku/build/libs/koteriku-5.1.1.jar"
			"libs/compojure/compojure/1.3.1/891b3ac823aba61a75e0a3d90f75d11ddbe6f812/compojure-1.3.1.jar"
			"libs/enlive/enlive/1.1.5/2a0104c467e2778ce5c1316da1f9a78b6bb5722c/enlive-1.1.5.jar"
			"libs/ring/ring-core/1.3.2/125f8c05b4768d16e5da46dc8fb62b0e77e1289d/ring-core-1.3.2.jar"
			"libs/ring/ring-jetty-adapter/1.3.2/71185d771b301c51ebcb02f6f53f8e7ff0fa6a04/ring-jetty-adapter-1.3.2.jar"
			"libs/ring/ring-servlet/1.3.2/59948e26e1b2972a7cc90991c9cf80f8cbffee1/ring-servlet-1.3.2.jar"
			"libs/clj-json/clj-json/0.5.3/abf9e23935aab57987ab0e525767a14346b2dfb1/clj-json-0.5.3.jar"
			"libs/org.clojure/clojure/1.6.0/1d95fb21562fa9d6df138a568ba5cab3e1dd3c98/clojure-1.6.0.jar"
			"libs/org.clojure/clojure-contrib/1.2.0/8abe4fd53cf8b2481afca3e81974dd914eb41aee/clojure-contrib-1.2.0.jar"
			"libs/org.clojure/math.numeric-tower/0.0.2/148570f3af27d151d3735719a2b1aacb71e2e135/math.numeric-tower-0.0.2.jar"
			"libs/commons-logging/commons-logging/1.2/4bfc12adfe4842bf07b657f0369c4cb522955686/commons-logging-1.2.jar"
			"libs/log4j/log4j/1.2.17/5af35056b4d257e4b64b9e8069c0746e8b08629f/log4j-1.2.17.jar"
			"libs/org.mybatis/mybatis/3.2.8/7b6bf82cea13570b5290d6ed841283a1fcce170/mybatis-3.2.8.jar"
			"libs/postgresql/postgresql/9.1-901.jdbc4/153f2f92a786f12fc111d0111f709012df87c808/postgresql-9.1-901.jdbc4.jar"
			"libs/org.clojure/tools.macro/0.1.5/925e200c906052e462e34a2c7e78a48ffec1dec4/tools.macro-0.1.5.jar"
			"libs/clout/clout/2.1.0/13340066edef8cb35726a49c9f86a5c172c2f0c8/clout-2.1.0.jar"
			"libs/medley/medley/0.5.3/41268a83e1f234869dff866f201e112ccb14e6e8/medley-0.5.3.jar"
			"libs/ring/ring-codec/1.0.0/e2e0be35ee22202a6da3769b606c485e4154f6e9/ring-codec-1.0.0.jar"
			"libs/org.ccil.cowan.tagsoup/tagsoup/1.2.1/5584627487e984c03456266d3f8802eb85a9ce97/tagsoup-1.2.1.jar"
			"libs/org.jsoup/jsoup/1.7.2/d7e275ba05aa380ca254f72d0c0ffebaedc3adcf/jsoup-1.7.2.jar"
			"libs/org.clojure/tools.reader/0.8.1/b2b847c94d445828517eb580da50851bb9a4beb/tools.reader-0.8.1.jar"
			"libs/commons-io/commons-io/2.4/b1b6ea3b7e4aa4f492509a4952029cd8e48019ad/commons-io-2.4.jar"
			"libs/commons-fileupload/commons-fileupload/1.3/c89e540e4a12cb034fb973e12135839b5de9a87e/commons-fileupload-1.3.jar"
			"libs/clj-time/clj-time/0.6.0/a922fbc265cf1e8fc01f811b6f7e106f85172cc3/clj-time-0.6.0.jar"
			"libs/crypto-random/crypto-random/1.2.0/cd5ed1fa18919cc13f5ab5feabdff21cc4b0faf6/crypto-random-1.2.0.jar"
			"libs/crypto-equality/crypto-equality/1.0.0/6728b7a444008fe576167fcadb92fea23bb17d42/crypto-equality-1.0.0.jar"
			"libs/org.eclipse.jetty/jetty-server/7.6.13.v20130916/c1d9d2842a7b2adc62806a8d069b8158209d8f25/jetty-server-7.6.13.v20130916.jar"
			"libs/org.codehaus.jackson/jackson-core-asl/1.9.9/b198f9d20dcc5bd2fe211e10f4110639b8243d6/jackson-core-asl-1.9.9.jar"
			"libs/instaparse/instaparse/1.3.4/c491a29091c5ee0ec6bf8f6d07fea87f8595c393/instaparse-1.3.4.jar"
			"libs/commons-codec/commons-codec/1.6/b7f0fc8f61ecadeb3695f0b9464755eee44374d4/commons-codec-1.6.jar"
			"libs/joda-time/joda-time/2.2/a5f29a7acaddea3f4af307e8cf2d0cc82645fd7d/joda-time-2.2.jar"
			"libs/org.eclipse.jetty.orbit/javax.servlet/2.5.0.v201103041518/9c16011c06bc6fe5e9dba080fcb40ddb4b75dc85/javax.servlet-2.5.0.v201103041518.jar"
			"libs/org.eclipse.jetty/jetty-continuation/7.6.13.v20130916/3346ee34fdfc3175b72ef63e36a453a7e536ab76/jetty-continuation-7.6.13.v20130916.jar"
			"libs/org.eclipse.jetty/jetty-http/7.6.13.v20130916/8e260a49227ca1d4ee0f0ea269b7ea844d49088c/jetty-http-7.6.13.v20130916.jar"
			"libs/org.eclipse.jetty/jetty-io/7.6.13.v20130916/54fddd31950e6a704ac13c63d2ba6b347723c948/jetty-io-7.6.13.v20130916.jar"
			"libs/org.eclipse.jetty/jetty-util/7.6.13.v20130916/414f76ca4810ec64e9db8cebdee74f7e7fc8a93b/jetty-util-7.6.13.v20130916.jar"
		;deps
                   ]
  :profiles {:uberjar {:aot :all}})
