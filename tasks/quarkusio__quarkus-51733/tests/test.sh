#!/bin/bash

cd /app/src

# Set environment variables for test execution
export LANG=en_US.UTF-8

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "extensions/picocli/deployment/src/test/java/io/quarkus/picocli/deployment"
cp "/tests/extensions/picocli/deployment/src/test/java/io/quarkus/picocli/deployment/AvailableConfigSourcesTest.java" "extensions/picocli/deployment/src/test/java/io/quarkus/picocli/deployment/AvailableConfigSourcesTest.java"
mkdir -p "extensions/resteasy-classic/rest-client-config/runtime/src/test/java/io/quarkus/restclient/config"
cp "/tests/extensions/resteasy-classic/rest-client-config/runtime/src/test/java/io/quarkus/restclient/config/RestClientConfigTest.java" "extensions/resteasy-classic/rest-client-config/runtime/src/test/java/io/quarkus/restclient/config/RestClientConfigTest.java"
mkdir -p "extensions/resteasy-classic/rest-client-config/runtime/src/test/resources"
cp "/tests/extensions/resteasy-classic/rest-client-config/runtime/src/test/resources/application.properties" "extensions/resteasy-classic/rest-client-config/runtime/src/test/resources/application.properties"
mkdir -p "extensions/resteasy-classic/resteasy-client/deployment/src/test/java/io/quarkus/restclient/configuration"
cp "/tests/extensions/resteasy-classic/resteasy-client/deployment/src/test/java/io/quarkus/restclient/configuration/RestClientOverrideRuntimeConfigTest.java" "extensions/resteasy-classic/resteasy-client/deployment/src/test/java/io/quarkus/restclient/configuration/RestClientOverrideRuntimeConfigTest.java"
mkdir -p "integration-tests/test-extension/extension/deployment/src/test/java/io/quarkus/config"
cp "/tests/integration-tests/test-extension/extension/deployment/src/test/java/io/quarkus/config/RecorderRuntimeConfigTest.java" "integration-tests/test-extension/extension/deployment/src/test/java/io/quarkus/config/RecorderRuntimeConfigTest.java"
mkdir -p "integration-tests/test-extension/extension/deployment/src/test/java/io/quarkus/extest"
cp "/tests/integration-tests/test-extension/extension/deployment/src/test/java/io/quarkus/extest/ConfiguredBeanTest.java" "integration-tests/test-extension/extension/deployment/src/test/java/io/quarkus/extest/ConfiguredBeanTest.java"
mkdir -p "integration-tests/test-extension/extension/deployment/src/test/java/io/quarkus/extest"
cp "/tests/integration-tests/test-extension/extension/deployment/src/test/java/io/quarkus/extest/RuntimeValuesTest.java" "integration-tests/test-extension/extension/deployment/src/test/java/io/quarkus/extest/RuntimeValuesTest.java"

# Rebuild the affected modules after solve.sh applies fix.patch
# This is necessary because fix.patch modifies source files
mvn -e -B --settings .github/mvn-settings.xml -DskipTests -DskipITs -DskipDocs \
  -Dinvoker.skip -Dskip.gradle.tests -Djbang.skip -Dtruststore.skip -Dno-format \
  -DskipExtensionValidation -Dtcks -Prelocations \
  -pl extensions/picocli/deployment,extensions/resteasy-classic/rest-client-config/runtime,extensions/resteasy-classic/resteasy-client/deployment,integration-tests/test-extension/extension/deployment -am \
  clean install

# Run the specific test classes
mvn -e -B --settings .github/mvn-settings.xml \
  -Dtest=AvailableConfigSourcesTest,RestClientConfigTest,RestClientOverrideRuntimeConfigTest,RecorderRuntimeConfigTest,ConfiguredBeanTest,RuntimeValuesTest \
  -pl extensions/picocli/deployment,extensions/resteasy-classic/rest-client-config/runtime,extensions/resteasy-classic/resteasy-client/deployment,integration-tests/test-extension/extension/deployment \
  test
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
