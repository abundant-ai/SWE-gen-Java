#!/bin/bash

cd /app/src

# Set environment variables for test execution
export LANG=en_US.UTF-8

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "extensions/vertx-http/deployment/src/test/java/io/quarkus/vertx/http"
cp "/tests/extensions/vertx-http/deployment/src/test/java/io/quarkus/vertx/http/HttpStaticDirTest.java" "extensions/vertx-http/deployment/src/test/java/io/quarkus/vertx/http/HttpStaticDirTest.java"
mkdir -p "extensions/vertx-http/deployment/src/test/resources/conf"
cp "/tests/extensions/vertx-http/deployment/src/test/resources/conf/quarkus.http.static-dir.properties" "extensions/vertx-http/deployment/src/test/resources/conf/quarkus.http.static-dir.properties"
mkdir -p "extensions/vertx-http/deployment/src/test/resources/public-resources/subdir"
cp "/tests/extensions/vertx-http/deployment/src/test/resources/public-resources/subdir/test.txt" "extensions/vertx-http/deployment/src/test/resources/public-resources/subdir/test.txt"
mkdir -p "extensions/vertx-http/deployment/src/test/resources/public-resources"
cp "/tests/extensions/vertx-http/deployment/src/test/resources/public-resources/test.txt" "extensions/vertx-http/deployment/src/test/resources/public-resources/test.txt"

# Rebuild the modules to pick up any source changes (from fix.patch in Oracle mode)
mvn -e -B --settings .github/mvn-settings.xml -DskipTests -DskipITs -DskipDocs \
    -Dinvoker.skip -Dskip.gradle.tests -Djbang.skip -Dtruststore.skip -Dno-format \
    -DskipExtensionValidation -Dtcks -Prelocations \
    -pl extensions/vertx-http/deployment -am \
    clean install

# Run only the specific test class to verify the changes
mvn -e -B --settings .github/mvn-settings.xml \
  -pl extensions/vertx-http/deployment \
  -Dtest=HttpStaticDirTest \
  test
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
