#!/bin/bash

cd /app/src

# Set environment variables for test execution
export LANG=en_US.UTF-8

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "extensions/oidc-client/deployment/src/test/java/io/quarkus/oidc/client"
cp "/tests/extensions/oidc-client/deployment/src/test/java/io/quarkus/oidc/client/OidcClientProxyTest.java" "extensions/oidc-client/deployment/src/test/java/io/quarkus/oidc/client/OidcClientProxyTest.java"
mkdir -p "integration-tests/oidc-client-wiremock/src/test/java/io/quarkus/it/keycloak"
cp "/tests/integration-tests/oidc-client-wiremock/src/test/java/io/quarkus/it/keycloak/OidcClientTest.java" "integration-tests/oidc-client-wiremock/src/test/java/io/quarkus/it/keycloak/OidcClientTest.java"

# Rebuild the affected modules after solve.sh applies fix.patch
# This is necessary because fix.patch modifies source files
mvn -e -B --settings .github/mvn-settings.xml -DskipTests -DskipITs -DskipDocs \
  -Dinvoker.skip -Dskip.gradle.tests -Djbang.skip -Dtruststore.skip -Dno-format \
  -DskipExtensionValidation -Dtcks -Prelocations \
  -pl devtools/maven,extensions/oidc-client/deployment,integration-tests/oidc-client-wiremock -am \
  clean install

# Run the specific test classes for oidc-client/deployment
mvn -e -B --settings .github/mvn-settings.xml \
  -Dtest=OidcClientProxyTest \
  -pl extensions/oidc-client/deployment \
  test && \
mvn -e -B --settings .github/mvn-settings.xml \
  -Dtest=OidcClientTest \
  -pl integration-tests/oidc-client-wiremock \
  test
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
