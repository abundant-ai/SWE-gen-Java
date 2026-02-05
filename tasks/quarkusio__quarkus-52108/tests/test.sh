#!/bin/bash

cd /app/src

# Set environment variables for test execution
export LANG=en_US.UTF-8

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "integration-tests/oidc-tenancy/src/test/java/io/quarkus/it/keycloak"
cp "/tests/integration-tests/oidc-tenancy/src/test/java/io/quarkus/it/keycloak/TestSecurityWebSocketsNextTest.java" "integration-tests/oidc-tenancy/src/test/java/io/quarkus/it/keycloak/TestSecurityWebSocketsNextTest.java"
mkdir -p "test-framework/security/src/main/java/io/quarkus/test/security"
cp "/tests/test-framework/security/src/main/java/io/quarkus/test/security/QuarkusSecurityTestExtension.java" "test-framework/security/src/main/java/io/quarkus/test/security/QuarkusSecurityTestExtension.java"
mkdir -p "test-framework/security/src/main/java/io/quarkus/test/security"
cp "/tests/test-framework/security/src/main/java/io/quarkus/test/security/TestIdentityAssociation.java" "test-framework/security/src/main/java/io/quarkus/test/security/TestIdentityAssociation.java"
mkdir -p "test-framework/security/src/test/java/io/quarkus/test/security"
cp "/tests/test-framework/security/src/test/java/io/quarkus/test/security/TestIdentityAssociationTest.java" "test-framework/security/src/test/java/io/quarkus/test/security/TestIdentityAssociationTest.java"

# Rebuild the affected modules after solve.sh applies fix.patch
# This is necessary because fix.patch modifies source files
mvn -e -B --settings .github/mvn-settings.xml -DskipTests -DskipITs -DskipDocs \
  -Dinvoker.skip -Dskip.gradle.tests -Djbang.skip -Dtruststore.skip -Dno-format \
  -DskipExtensionValidation -Dtcks -Prelocations \
  -pl test-framework/security,extensions/websockets-next/deployment,integration-tests/oidc-tenancy -am \
  clean install

# Run the specific test classes from this PR
# TestSecurityWebSocketsNextTest (requires test-containers profile) and TestIdentityAssociationTest
mvn -e -B --settings .github/mvn-settings.xml \
  -pl integration-tests/oidc-tenancy,test-framework/security \
  -Dtest=TestSecurityWebSocketsNextTest,TestIdentityAssociationTest \
  -Dtest-containers \
  test
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
