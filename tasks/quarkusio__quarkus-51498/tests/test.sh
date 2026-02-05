#!/bin/bash

cd /app/src

# Set environment variables for test execution
export LANG=en_US.UTF-8

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "independent-projects/tools/registry-client/src/test/java/io/quarkus/registry/client/maven"
cp "/tests/independent-projects/tools/registry-client/src/test/java/io/quarkus/registry/client/maven/MavenRegistryClientCompleteConfigTest.java" "independent-projects/tools/registry-client/src/test/java/io/quarkus/registry/client/maven/MavenRegistryClientCompleteConfigTest.java"
mkdir -p "independent-projects/tools/registry-client/src/test/java/io/quarkus/registry/config"
cp "/tests/independent-projects/tools/registry-client/src/test/java/io/quarkus/registry/config/DevToolsConfigSerializationTest.java" "independent-projects/tools/registry-client/src/test/java/io/quarkus/registry/config/DevToolsConfigSerializationTest.java"
mkdir -p "independent-projects/tools/registry-client/src/test/resources/devtools-config"
cp "/tests/independent-projects/tools/registry-client/src/test/resources/devtools-config/registry-client-platform-extension-maven-config.json" "independent-projects/tools/registry-client/src/test/resources/devtools-config/registry-client-platform-extension-maven-config.json"

# Rebuild the affected modules after solve.sh applies fix.patch
# This is necessary because fix.patch modifies source files
mvn -e -B --settings .github/mvn-settings.xml -DskipTests -DskipITs -DskipDocs \
  -Dinvoker.skip -Dskip.gradle.tests -Djbang.skip -Dtruststore.skip -Dno-format \
  -DskipExtensionValidation -Dtcks -Prelocations \
  -pl independent-projects/tools/registry-client -am \
  clean install

# Run the specific test classes
mvn -e -B --settings .github/mvn-settings.xml \
  -Dtest=MavenRegistryClientCompleteConfigTest,DevToolsConfigSerializationTest \
  -pl independent-projects/tools/registry-client \
  test
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
