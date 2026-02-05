#!/bin/bash

cd /app/src

# Set environment variables for test execution
export LANG=en_US.UTF-8

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "extensions/opentelemetry/deployment/src/test/java/io/quarkus/opentelemetry/deployment"
cp "/tests/extensions/opentelemetry/deployment/src/test/java/io/quarkus/opentelemetry/deployment/OpenTelemetryMDCTest.java" "extensions/opentelemetry/deployment/src/test/java/io/quarkus/opentelemetry/deployment/OpenTelemetryMDCTest.java"
mkdir -p "extensions/vertx/deployment/src/test/java/io/quarkus/vertx/mdc"
cp "/tests/extensions/vertx/deployment/src/test/java/io/quarkus/vertx/mdc/AnotherVertxMdcTest.java" "extensions/vertx/deployment/src/test/java/io/quarkus/vertx/mdc/AnotherVertxMdcTest.java"

# Rebuild the extensions after solve.sh applies fix.patch
# This is necessary because fix.patch modifies source files
# Build vertx first (opentelemetry depends on vertx)
cd extensions/vertx
mvn -e -B --settings ../../.github/mvn-settings.xml -DskipTests -DskipITs -DskipDocs \
  -Dinvoker.skip -Dskip.gradle.tests -Djbang.skip -Dtruststore.skip -Dno-format \
  -DskipExtensionValidation -Dtcks -Prelocations \
  clean install
cd /app/src

# Build opentelemetry (which depends on vertx)
cd extensions/opentelemetry
mvn -e -B --settings ../../.github/mvn-settings.xml -DskipTests -DskipITs -DskipDocs \
  -Dinvoker.skip -Dskip.gradle.tests -Djbang.skip -Dtruststore.skip -Dno-format \
  -DskipExtensionValidation -Dtcks -Prelocations \
  clean install
cd /app/src

# Run the specific test classes from this PR
# OpenTelemetryMDCTest is in extensions/opentelemetry/deployment
cd extensions/opentelemetry/deployment
mvn -e -B --settings ../../../.github/mvn-settings.xml \
  -Dtest=OpenTelemetryMDCTest \
  test
opentelemetry_status=$?
cd /app/src

# AnotherVertxMdcTest is in extensions/vertx/deployment
cd extensions/vertx/deployment
mvn -e -B --settings ../../../.github/mvn-settings.xml \
  -Dtest=AnotherVertxMdcTest \
  test
vertx_status=$?
cd /app/src

# Both tests must pass
if [ $opentelemetry_status -eq 0 ] && [ $vertx_status -eq 0 ]; then
  test_status=0
else
  test_status=1
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
