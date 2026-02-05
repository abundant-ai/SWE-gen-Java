#!/bin/bash

cd /app/src

# Set environment variables for test execution
export LANG=en_US.UTF-8

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "core/deployment/src/test/java/io/quarkus/deployment/pkg"
cp "/tests/core/deployment/src/test/java/io/quarkus/deployment/pkg/NativeConfigTest.java" "core/deployment/src/test/java/io/quarkus/deployment/pkg/NativeConfigTest.java"
mkdir -p "independent-projects/tools/devtools-common/src/test/java/io/quarkus/devtools/project"
cp "/tests/independent-projects/tools/devtools-common/src/test/java/io/quarkus/devtools/project/JavaVersionTest.java" "independent-projects/tools/devtools-common/src/test/java/io/quarkus/devtools/project/JavaVersionTest.java"

# Rebuild the affected modules after solve.sh applies fix.patch
# This is necessary because fix.patch modifies source files
mvn -e -B --settings .github/mvn-settings.xml -DskipTests -DskipITs -DskipDocs \
  -Dinvoker.skip -Dskip.gradle.tests -Djbang.skip -Dtruststore.skip -Dno-format \
  -DskipExtensionValidation -Dtcks -Prelocations \
  -pl core/deployment,independent-projects/tools/devtools-common -am \
  clean install

# Run the specific test classes
mvn -e -B --settings .github/mvn-settings.xml \
  -Dtest=NativeConfigTest,JavaVersionTest \
  -pl core/deployment,independent-projects/tools/devtools-common \
  test
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
