#!/bin/bash

cd /app/src

# Set environment variables for test execution
export LANG=en_US.UTF-8

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "extensions/oidc-client/runtime/src/test/java/io/quarkus/oidc/client"
cp "/tests/extensions/oidc-client/runtime/src/test/java/io/quarkus/oidc/client/OidcClientConfigImpl.java" "extensions/oidc-client/runtime/src/test/java/io/quarkus/oidc/client/OidcClientConfigImpl.java"
mkdir -p "extensions/oidc-common/runtime/src/test/java/io/quarkus/oidc/common/runtime"
cp "/tests/extensions/oidc-common/runtime/src/test/java/io/quarkus/oidc/common/runtime/OidcClientCommonConfigBuilderTest.java" "extensions/oidc-common/runtime/src/test/java/io/quarkus/oidc/common/runtime/OidcClientCommonConfigBuilderTest.java"
mkdir -p "extensions/oidc-common/runtime/src/test/java/io/quarkus/oidc/common/runtime"
cp "/tests/extensions/oidc-common/runtime/src/test/java/io/quarkus/oidc/common/runtime/OidcCommonUtilsTest.java" "extensions/oidc-common/runtime/src/test/java/io/quarkus/oidc/common/runtime/OidcCommonUtilsTest.java"
mkdir -p "extensions/oidc/runtime/src/test/java/io/quarkus/oidc/runtime"
cp "/tests/extensions/oidc/runtime/src/test/java/io/quarkus/oidc/runtime/OidcTenantConfigImpl.java" "extensions/oidc/runtime/src/test/java/io/quarkus/oidc/runtime/OidcTenantConfigImpl.java"

# Run the specific test classes from this PR
# Maven will automatically compile the necessary sources before running tests
# Skip extension validation to avoid dependency issues during test-only builds
mvn -e -B --settings .github/mvn-settings.xml \
  -pl extensions/oidc-common/runtime \
  -Dtest=OidcClientCommonConfigBuilderTest,OidcCommonUtilsTest \
  -DskipExtensionValidation \
  test
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
