#!/bin/bash

cd /app/src

# Set environment variables for test execution
export LANG=en_US.UTF-8

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "extensions/arc/deployment/src/test/java/io/quarkus/arc/test/lookup"
cp "/tests/extensions/arc/deployment/src/test/java/io/quarkus/arc/test/lookup/LookupConditionOnInheritedStereotypeTest.java" "extensions/arc/deployment/src/test/java/io/quarkus/arc/test/lookup/LookupConditionOnInheritedStereotypeTest.java"
mkdir -p "extensions/arc/deployment/src/test/java/io/quarkus/arc/test/lookup"
cp "/tests/extensions/arc/deployment/src/test/java/io/quarkus/arc/test/lookup/LookupConditionOnStereotypeTest.java" "extensions/arc/deployment/src/test/java/io/quarkus/arc/test/lookup/LookupConditionOnStereotypeTest.java"
mkdir -p "extensions/arc/deployment/src/test/java/io/quarkus/arc/test/lookup"
cp "/tests/extensions/arc/deployment/src/test/java/io/quarkus/arc/test/lookup/LookupMultipleConditionsOnInheritedStereotypesTest.java" "extensions/arc/deployment/src/test/java/io/quarkus/arc/test/lookup/LookupMultipleConditionsOnInheritedStereotypesTest.java"
mkdir -p "extensions/arc/deployment/src/test/java/io/quarkus/arc/test/lookup"
cp "/tests/extensions/arc/deployment/src/test/java/io/quarkus/arc/test/lookup/LookupMultipleConditionsOnStereotypesTest.java" "extensions/arc/deployment/src/test/java/io/quarkus/arc/test/lookup/LookupMultipleConditionsOnStereotypesTest.java"
mkdir -p "extensions/arc/deployment/src/test/java/io/quarkus/arc/test/lookup"
cp "/tests/extensions/arc/deployment/src/test/java/io/quarkus/arc/test/lookup/LookupMultipleConditionsTest.java" "extensions/arc/deployment/src/test/java/io/quarkus/arc/test/lookup/LookupMultipleConditionsTest.java"

# Rebuild the test module and its dependencies after solve.sh applies fix.patch
# This is necessary because fix.patch modifies core source files
mvn -e -B --settings .github/mvn-settings.xml -DskipTests -DskipITs -DskipDocs \
  -Dinvoker.skip -Dskip.gradle.tests -Djbang.skip -Dtruststore.skip -Dno-format \
  -Dtcks -Prelocations \
  -pl extensions/arc/deployment -am \
  clean install

# Run the specific test classes (not the entire test suite)
# Use Maven Surefire to run only the specific test classes
mvn -e -B --settings .github/mvn-settings.xml \
  -Dformat.skip -Denforcer.skip -DskipDocs -Dforbiddenapis.skip \
  -DskipExtensionValidation -DskipCodestartValidation \
  -pl extensions/arc/deployment \
  test -Dtest=LookupConditionOnInheritedStereotypeTest,LookupConditionOnStereotypeTest,LookupMultipleConditionsOnInheritedStereotypesTest,LookupMultipleConditionsOnStereotypesTest,LookupMultipleConditionsTest

test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
