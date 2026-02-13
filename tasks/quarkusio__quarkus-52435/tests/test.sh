#!/bin/bash

cd /app/src

# Set environment variables for test execution
export LANG=en_US.UTF-8

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "extensions/spring-cloud-config-client/runtime/src/test/java/io/quarkus/spring/cloud/config/client/runtime"
cp "/tests/extensions/spring-cloud-config-client/runtime/src/test/java/io/quarkus/spring/cloud/config/client/runtime/SpringCloudConfigClientConfigSourceFactoryTest.java" "extensions/spring-cloud-config-client/runtime/src/test/java/io/quarkus/spring/cloud/config/client/runtime/SpringCloudConfigClientConfigSourceFactoryTest.java"
mkdir -p "extensions/spring-cloud-config-client/runtime/src/test/resources"
cp "/tests/extensions/spring-cloud-config-client/runtime/src/test/resources/app-multiple.json" "extensions/spring-cloud-config-client/runtime/src/test/resources/app-multiple.json"
mkdir -p "integration-tests/spring-cloud-config-client/src/test/java/io/quarkus/spring/cloud/config/client/runtime"
cp "/tests/integration-tests/spring-cloud-config-client/src/test/java/io/quarkus/spring/cloud/config/client/runtime/CommonAndTestProfilesTest.java" "integration-tests/spring-cloud-config-client/src/test/java/io/quarkus/spring/cloud/config/client/runtime/CommonAndTestProfilesTest.java"
mkdir -p "integration-tests/spring-cloud-config-client/src/test/java/io/quarkus/spring/cloud/config/client/runtime"
cp "/tests/integration-tests/spring-cloud-config-client/src/test/java/io/quarkus/spring/cloud/config/client/runtime/OnlyTestProfileTest.java" "integration-tests/spring-cloud-config-client/src/test/java/io/quarkus/spring/cloud/config/client/runtime/OnlyTestProfileTest.java"
mkdir -p "integration-tests/spring-cloud-config-client/src/test/java/io/quarkus/spring/cloud/config/client/runtime"
cp "/tests/integration-tests/spring-cloud-config-client/src/test/java/io/quarkus/spring/cloud/config/client/runtime/SpringCloudConfigServerResource.java" "integration-tests/spring-cloud-config-client/src/test/java/io/quarkus/spring/cloud/config/client/runtime/SpringCloudConfigServerResource.java"
mkdir -p "integration-tests/spring-cloud-config-client/src/test/resources"
cp "/tests/integration-tests/spring-cloud-config-client/src/test/resources/config-common-prod.json" "integration-tests/spring-cloud-config-client/src/test/resources/config-common-prod.json"
mkdir -p "integration-tests/spring-cloud-config-client/src/test/resources"
cp "/tests/integration-tests/spring-cloud-config-client/src/test/resources/config-common-test.json" "integration-tests/spring-cloud-config-client/src/test/resources/config-common-test.json"
mkdir -p "integration-tests/spring-cloud-config-client/src/test/resources"
cp "/tests/integration-tests/spring-cloud-config-client/src/test/resources/config-test.json" "integration-tests/spring-cloud-config-client/src/test/resources/config-test.json"

# Rebuild modules to pick up test changes
mvn -e -B --settings .github/mvn-settings.xml -DskipTests -DskipITs -DskipDocs \
    -Dinvoker.skip -Dskip.gradle.tests -Djbang.skip -Dtruststore.skip -Dno-format \
    -DskipExtensionValidation \
    -pl extensions/spring-cloud-config-client/runtime,integration-tests/spring-cloud-config-client \
    clean install

# Run the specific test files from the runtime module
mvn -e -B --settings .github/mvn-settings.xml \
    -Dtest=SpringCloudConfigClientConfigSourceFactoryTest \
    -pl extensions/spring-cloud-config-client/runtime \
    test

test_status=$?

# Also run integration tests if unit tests pass
if [ $test_status -eq 0 ]; then
  mvn -e -B --settings .github/mvn-settings.xml \
      -Dtest=CommonAndTestProfilesTest,OnlyTestProfileTest \
      -pl integration-tests/spring-cloud-config-client \
      test
  test_status=$?
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
