#!/bin/bash

cd /app/src

# Set environment variables for test execution
export LANG=en_US.UTF-8

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "extensions/resteasy-reactive/rest-jackson/deployment/src/test/java/io/quarkus/resteasy/reactive/jackson/deployment/test"
cp "/tests/extensions/resteasy-reactive/rest-jackson/deployment/src/test/java/io/quarkus/resteasy/reactive/jackson/deployment/test/SimpleJsonWithReflectionFreeSerializersTest.java" "extensions/resteasy-reactive/rest-jackson/deployment/src/test/java/io/quarkus/resteasy/reactive/jackson/deployment/test/SimpleJsonWithReflectionFreeSerializersTest.java"

# Rebuild the affected modules after solve.sh applies fix.patch
# This is necessary because fix.patch modifies source files
mvn -e -B --settings .github/mvn-settings.xml -DskipTests -DskipITs -DskipDocs \
  -Dinvoker.skip -Dskip.gradle.tests -Djbang.skip -Dtruststore.skip -Dno-format \
  -DskipExtensionValidation -Dtcks -Prelocations \
  -pl devtools/maven,extensions/resteasy-reactive/rest-jackson/deployment -am \
  clean install

# Run the specific test class
mvn -e -B --settings .github/mvn-settings.xml \
  -Dtest=SimpleJsonWithReflectionFreeSerializersTest \
  -pl extensions/resteasy-reactive/rest-jackson/deployment \
  test
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
