#!/bin/bash

cd /app/src

# Set environment variables for test execution
export LANG=en_US.UTF-8

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "extensions/oidc/runtime/src/test/java/io/quarkus/oidc/runtime"
cp "/tests/extensions/oidc/runtime/src/test/java/io/quarkus/oidc/runtime/OidcTenantConfigImpl.java" "extensions/oidc/runtime/src/test/java/io/quarkus/oidc/runtime/OidcTenantConfigImpl.java"
mkdir -p "integration-tests/oidc-code-flow/src/test/java/io/quarkus/it/keycloak"
cp "/tests/integration-tests/oidc-code-flow/src/test/java/io/quarkus/it/keycloak/CodeFlowTest.java" "integration-tests/oidc-code-flow/src/test/java/io/quarkus/it/keycloak/CodeFlowTest.java"

# Rebuild the modules to pick up any source changes (from fix.patch in Oracle mode)
mvn -e -B --settings .github/mvn-settings.xml -DskipTests -DskipITs -DskipDocs \
    -Dinvoker.skip -Dskip.gradle.tests -Djbang.skip -Dtruststore.skip -Dno-format \
    -DskipExtensionValidation -Dtcks -Prelocations \
    -pl extensions/oidc/runtime,integration-tests/oidc-code-flow -am \
    clean install

# Run the tests in the modules to verify the changes
mvn -e -B --settings .github/mvn-settings.xml \
  -pl extensions/oidc/runtime,integration-tests/oidc-code-flow \
  test
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
