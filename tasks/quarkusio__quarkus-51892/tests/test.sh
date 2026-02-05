#!/bin/bash

cd /app/src

# Set environment variables for test execution
export LANG=en_US.UTF-8

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "extensions/oidc-client-filter/deployment/src/test/java/io/quarkus/oidc/client/filter"
cp "/tests/extensions/oidc-client-filter/deployment/src/test/java/io/quarkus/oidc/client/filter/ExtendedOidcClientRequestFilter.java" "extensions/oidc-client-filter/deployment/src/test/java/io/quarkus/oidc/client/filter/ExtendedOidcClientRequestFilter.java"
mkdir -p "extensions/oidc-client-filter/deployment/src/test/java/io/quarkus/oidc/client/filter"
cp "/tests/extensions/oidc-client-filter/deployment/src/test/java/io/quarkus/oidc/client/filter/ProtectedResourceServiceCustomProviderConfigPropOidcClient.java" "extensions/oidc-client-filter/deployment/src/test/java/io/quarkus/oidc/client/filter/ProtectedResourceServiceCustomProviderConfigPropOidcClient.java"

# Rebuild the affected modules after solve.sh applies fix.patch
# This is necessary because fix.patch modifies source files
mvn -e -B --settings .github/mvn-settings.xml -DskipTests -DskipITs -DskipDocs \
  -Dinvoker.skip -Dskip.gradle.tests -Djbang.skip -Dtruststore.skip -Dno-format \
  -DskipExtensionValidation -Dtcks -Prelocations \
  -pl devtools/maven,extensions/oidc-client-filter/deployment -am \
  clean install

# Run the specific test classes
mvn -e -B --settings .github/mvn-settings.xml \
  -Dtest=ExtendedOidcClientRequestFilter,ProtectedResourceServiceCustomProviderConfigPropOidcClient \
  -pl extensions/oidc-client-filter/deployment \
  test
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
