(defproject harborview "1.0"
  :locationName "FIXME: write locationName"
  :url "http://example.com/FIXME"
  :license {:name "Eclipse Public License"
            :url "http://www.eclipse.org/legal/epl-v10.html"}
  ;:dependencies [[enlive "1.1.6"]
  ;								 [compojure "1.4.0"]
  ;								 [clj-json "0.5.3"]
  ;								 [ring/ring-core "1.4.0"]
  ;								 [ring/ring-jetty-adapter "1.4.0"]
  ;								 [ring/ring-servlet "1.4.0"]
  ;								 ]
  :main ^:skip-aot harborview.webapp
  ;:compile 
  :target-path "target"
  :java-test-paths ["test-java"]
  :aot :all
  :resource-paths [
    
    
    
    ;deps
		    "/home/rcs/opt/java/stearnswharf-repos/build/libs/stearnswharf-1.0.jar"
		    "/home/rcs/opt/java/koteriku/build/libs/koteriku-5.3.1.jar"
		    "/home/rcs/opt/java/oahu/build/libs/oahu-5.3.1.jar"
		    "/home/rcs/opt/java/ranoraraku/build/libs/ranoraraku-5.3.5.jar"
		    "libs/selmer/selmer/1.0.4/f7ecad9bb123a4716c62ba9df4185e30973550ea/selmer-1.0.4.jar"
		    "libs/compojure/compojure/1.4.0/2b5ff46cc06d64eda9980735b5a51f19b2528e41/compojure-1.4.0.jar"
		    "libs/ring/ring-core/1.4.0/6ac9a134048f031e7067bf834ab9085a0c840386/ring-core-1.4.0.jar"
		    "libs/ring/ring-jetty-adapter/1.4.0/ab945c5b0dd09f33aa54458788983dc0ef54082b/ring-jetty-adapter-1.4.0.jar"
		    "libs/ring/ring-servlet/1.4.0/575fc5496ba7820b554fa29ad36e088fbdc482f9/ring-servlet-1.4.0.jar"
		    "libs/clj-json/clj-json/0.5.3/abf9e23935aab57987ab0e525767a14346b2dfb1/clj-json-0.5.3.jar"
		    "libs/org.clojure/clojure-contrib/1.2.0/8abe4fd53cf8b2481afca3e81974dd914eb41aee/clojure-contrib-1.2.0.jar"
		    "libs/org.clojure/math.numeric-tower/0.0.4/800736ac4101947663c788ce5b20c2103007e821/math.numeric-tower-0.0.4.jar"
		    "libs/commons-codec/commons-codec/1.10/4b95f4897fa13f2cd904aee711aeafc0c5295cd8/commons-codec-1.10.jar"
		    "libs/commons-logging/commons-logging/1.2/4bfc12adfe4842bf07b657f0369c4cb522955686/commons-logging-1.2.jar"
		    "libs/org.clojure/clojure/1.7.0/4953eb1ffa4adca22760c9324c9c26d2038c392a/clojure-1.7.0.jar"
		    "libs/log4j/log4j/1.2.17/5af35056b4d257e4b64b9e8069c0746e8b08629f/log4j-1.2.17.jar"
		    "libs/org.mybatis/mybatis/3.3.0/7c0e3582a1518b6d8e4e37ce2fc49b7bb6f2040f/mybatis-3.3.0.jar"
		    "libs/org.postgresql/postgresql/9.4-1206-jdbc42/e91af69cfb3390a73449d1157753ca4e7b97765c/postgresql-9.4-1206-jdbc42.jar"
		    "libs/junit/junit/4.11/4e031bb61df09069aeb2bffb4019e7a5034a4ee0/junit-4.11.jar"
		    "libs/joda-time/joda-time/2.9.2/36d6e77a419cb455e6fd5909f6f96b168e21e9d0/joda-time-2.9.2.jar"
		    "libs/json-html/json-html/0.3.9/fe636fe1d4566b6f4d8188810fb013698c6bd17/json-html-0.3.9.jar"
		    "libs/cheshire/cheshire/5.5.0/d9f9e2f0c53c744ddfbdb8042c134a2a6f222fe1/cheshire-5.5.0.jar"
		    "libs/org.clojure/tools.macro/0.1.5/925e200c906052e462e34a2c7e78a48ffec1dec4/tools.macro-0.1.5.jar"
		    "libs/clout/clout/2.1.2/87cc1bd24ec39a8572e66103039955d7570ce077/clout-2.1.2.jar"
		    "libs/medley/medley/0.6.0/c012ede5152466553277399a53eba80ebcde8bb5/medley-0.6.0.jar"
		    "libs/ring/ring-codec/1.0.0/e2e0be35ee22202a6da3769b606c485e4154f6e9/ring-codec-1.0.0.jar"
		    "libs/org.clojure/tools.reader/0.9.1/4635d289ae80e7eccfc5377bbfb2f78d36bec23a/tools.reader-0.9.1.jar"
		    "libs/commons-io/commons-io/2.4/b1b6ea3b7e4aa4f492509a4952029cd8e48019ad/commons-io-2.4.jar"
		    "libs/commons-fileupload/commons-fileupload/1.3.1/c621b54583719ac0310404463d6d99db27e1052c/commons-fileupload-1.3.1.jar"
		    "libs/clj-time/clj-time/0.9.0/e276b52745750ae4548cd7239cd9a4f338843dd7/clj-time-0.9.0.jar"
		    "libs/crypto-random/crypto-random/1.2.0/cd5ed1fa18919cc13f5ab5feabdff21cc4b0faf6/crypto-random-1.2.0.jar"
		    "libs/crypto-equality/crypto-equality/1.0.0/6728b7a444008fe576167fcadb92fea23bb17d42/crypto-equality-1.0.0.jar"
		    "libs/org.eclipse.jetty/jetty-server/9.2.10.v20150310/e6b8bff28b3e9ca6254415d2aa49603a5887fe8/jetty-server-9.2.10.v20150310.jar"
		    "libs/org.codehaus.jackson/jackson-core-asl/1.9.9/b198f9d20dcc5bd2fe211e10f4110639b8243d6/jackson-core-asl-1.9.9.jar"
		    "libs/org.hamcrest/hamcrest-core/1.3/42a25dc3219429f0e5d060061f71acb49bf010a0/hamcrest-core-1.3.jar"
		    "libs/hiccup/hiccup/1.0.5/75940a400111bbb8f80e43325e23100b6e2227bc/hiccup-1.0.5.jar"
		    "libs/hiccups/hiccups/0.3.0/350401390e43eb446bc2a452f41caa921e4f8916/hiccups-0.3.0.jar"
		    "libs/instaparse/instaparse/1.4.0/ade13d743d1ec8a6c5103fd0f5701b0f997e2cc4/instaparse-1.4.0.jar"
		    "libs/javax.servlet/javax.servlet-api/3.1.0/3cd63d075497751784b2fa84be59432f4905bf7c/javax.servlet-api-3.1.0.jar"
		    "libs/org.eclipse.jetty/jetty-http/9.2.10.v20150310/886b628f62cd518bbb04b37bd1b308fa19340a53/jetty-http-9.2.10.v20150310.jar"
		    "libs/org.eclipse.jetty/jetty-io/9.2.10.v20150310/29bc6a5e2049d9858bfa811f2728a7a8efcdc1c0/jetty-io-9.2.10.v20150310.jar"
		    "libs/org.clojure/clojurescript/0.0-2069/f22176595d0d8bb146f5172cad7f345bfda35a9a/clojurescript-0.0-2069.jar"
		    "libs/org.eclipse.jetty/jetty-util/9.2.10.v20150310/90cc75668dc9a9885108733d4d46420907cf863c/jetty-util-9.2.10.v20150310.jar"
		    "libs/com.google.javascript/closure-compiler/v20130603/b150c1666154435f43bc4665e202dee7c3c95eb7/closure-compiler-v20130603.jar"
		    "libs/org.clojure/google-closure-library/0.0-20130212-95c19e7f0f5f/e380ebc116dcbde00081a4376090904bfb795791/google-closure-library-0.0-20130212-95c19e7f0f5f.jar"
		    "libs/org.clojure/data.json/0.2.3/dab504d6287a9f1cf07eb3caeea5fdaaaee024cf/data.json-0.2.3.jar"
		    "libs/org.mozilla/rhino/1.7R4/e982f2136574b9a423186fbaeaaa98dc3e5a5288/rhino-1.7R4.jar"
		    "libs/args4j/args4j/2.0.16/9f00fb12820743b9e05c686eba543d64dd43f2b1/args4j-2.0.16.jar"
		    "libs/com.google.guava/guava/14.0.1/69e12f4c6aeac392555f1ea86fab82b5e5e31ad4/guava-14.0.1.jar"
		    "libs/com.google.protobuf/protobuf-java/2.4.1/c589509ec6fd86d5d2fda37e07c08538235d3b9/protobuf-java-2.4.1.jar"
		    "libs/org.json/json/20090211/c183aa3a2a6250293808bba12262c8920ce5a51c/json-20090211.jar"
		    "libs/com.google.code.findbugs/jsr305/1.3.9/40719ea6961c0cb6afaeb6a921eaa1f6afd4cfdf/jsr305-1.3.9.jar"
		    "libs/org.clojure/google-closure-library-third-party/0.0-20130212-95c19e7f0f5f/2e15e179205ac377156449e8124cd09a30f9f87/google-closure-library-third-party-0.0-20130212-95c19e7f0f5f.jar"
		    "libs/com.fasterxml.jackson.core/jackson-core/2.5.3/a8b8a6dfc8a17890e4c7ff8aed810763d265b68b/jackson-core-2.5.3.jar"
		    "libs/com.fasterxml.jackson.dataformat/jackson-dataformat-smile/2.5.3/8130f27e41d2bbe6ab4e9cde5f1162f8d51ed449/jackson-dataformat-smile-2.5.3.jar"
		    "libs/com.fasterxml.jackson.dataformat/jackson-dataformat-cbor/2.5.3/292edada1ec779903b9f45a8232533791588342/jackson-dataformat-cbor-2.5.3.jar"
		    "libs/tigris/tigris/0.1.1/187674e86c2e94eefb4f80c13a6b10345dd6ad2/tigris-0.1.1.jar"
    ;deps



                   ]
  :profiles {:uberjar {:aot :all}})
