#!/bin/bash

cd /app/src

# Set environment variables for test execution
export LANG=en_US.UTF-8

# Copy HEAD source files from /tests (overwrites BASE state)
mkdir -p "core/deployment/src/main/java/io/quarkus/deployment/dev/testing"
cp "/tests/core/deployment/src/main/java/io/quarkus/deployment/dev/testing/TestHandler.java" "core/deployment/src/main/java/io/quarkus/deployment/dev/testing/TestHandler.java"

# Rebuild core/deployment module to verify the fixed code compiles
mvn -e -B --settings .github/mvn-settings.xml -DskipTests -DskipITs -DskipDocs \
    -Dinvoker.skip -Dskip.gradle.tests -Djbang.skip -Dtruststore.skip -Dno-format \
    -DskipExtensionValidation \
    -pl core/deployment \
    clean install

test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
