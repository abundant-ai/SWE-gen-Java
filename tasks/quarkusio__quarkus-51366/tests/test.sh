#!/bin/bash

cd /app/src

# Set environment variables for test execution
export LANG=en_US.UTF-8

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "extensions/oidc/runtime/src/test/java/io/quarkus/oidc/runtime"
cp "/tests/extensions/oidc/runtime/src/test/java/io/quarkus/oidc/runtime/OidcTenantConfigBuilderTest.java" "extensions/oidc/runtime/src/test/java/io/quarkus/oidc/runtime/OidcTenantConfigBuilderTest.java"
mkdir -p "extensions/oidc/runtime/src/test/java/io/quarkus/oidc/runtime"
cp "/tests/extensions/oidc/runtime/src/test/java/io/quarkus/oidc/runtime/OidcTenantConfigImpl.java" "extensions/oidc/runtime/src/test/java/io/quarkus/oidc/runtime/OidcTenantConfigImpl.java"

# Run the specific test class from this PR
mvn -e -B --settings .github/mvn-settings.xml \
  -pl extensions/oidc/runtime \
  -Dtest=OidcTenantConfigBuilderTest \
  test
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
