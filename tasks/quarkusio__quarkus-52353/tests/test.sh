#!/bin/bash

cd /app/src

# Set environment variables for test execution
export LANG=en_US.UTF-8

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "extensions/oidc/runtime/src/test/java/io/quarkus/oidc/runtime"
cp "/tests/extensions/oidc/runtime/src/test/java/io/quarkus/oidc/runtime/OidcTenantConfigBuilderTest.java" "extensions/oidc/runtime/src/test/java/io/quarkus/oidc/runtime/OidcTenantConfigBuilderTest.java"
mkdir -p "extensions/oidc/runtime/src/test/java/io/quarkus/oidc/runtime"
cp "/tests/extensions/oidc/runtime/src/test/java/io/quarkus/oidc/runtime/OidcTenantConfigImpl.java" "extensions/oidc/runtime/src/test/java/io/quarkus/oidc/runtime/OidcTenantConfigImpl.java"
mkdir -p "integration-tests/oidc-client-registration/src/test/java/io/quarkus/it/keycloak"
cp "/tests/integration-tests/oidc-client-registration/src/test/java/io/quarkus/it/keycloak/OidcRichAuthorizationRequestsTest.java" "integration-tests/oidc-client-registration/src/test/java/io/quarkus/it/keycloak/OidcRichAuthorizationRequestsTest.java"

# Run the specific tests from the PR
# Test 1: OidcTenantConfigBuilderTest
mvn -e -B --settings .github/mvn-settings.xml \
    -pl extensions/oidc/runtime \
    test -Dtest=OidcTenantConfigBuilderTest && \
# Test 2: OidcRichAuthorizationRequestsTest (integration test)
mvn -e -B --settings .github/mvn-settings.xml \
    -pl integration-tests/oidc-client-registration \
    verify -Dtest=OidcRichAuthorizationRequestsTest

test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
