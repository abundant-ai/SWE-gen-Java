#!/bin/bash

cd /app/src

# Set environment variables for test execution
export LANG=en_US.UTF-8

# First, rebuild core/deployment module with the fix applied by Oracle agent
mvn -e -B --settings .github/mvn-settings.xml \
    -DskipExtensionValidation \
    -pl core/deployment -am \
    clean install -DskipTests -DskipITs -DskipDocs \
    -Dinvoker.skip -Dskip.gradle.tests -Djbang.skip -Dtruststore.skip -Dno-format

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "test-framework/junit/src/main/java/io/quarkus/test/junit"
cp "/tests/test-framework/junit/src/main/java/io/quarkus/test/junit/NativeDevServicesHandler.java" "test-framework/junit/src/main/java/io/quarkus/test/junit/NativeDevServicesHandler.java"

# Now recompile test-framework/junit module to verify the fix compiles correctly
mvn -e -B --settings .github/mvn-settings.xml \
    -DskipExtensionValidation \
    -pl test-framework/junit \
    clean install -DskipTests -DskipITs -DskipDocs \
    -Dinvoker.skip -Dskip.gradle.tests -Djbang.skip -Dtruststore.skip -Dno-format
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
