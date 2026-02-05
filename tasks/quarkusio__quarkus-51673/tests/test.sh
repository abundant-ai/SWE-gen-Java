#!/bin/bash

cd /app/src

# Set environment variables for test execution
export LANG=en_US.UTF-8

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "extensions/security/runtime/src/test/java/io/quarkus/security/runtime"
cp "/tests/extensions/security/runtime/src/test/java/io/quarkus/security/runtime/QuarkusSecurityIdentityTest.java" "extensions/security/runtime/src/test/java/io/quarkus/security/runtime/QuarkusSecurityIdentityTest.java"
mkdir -p "extensions/security/test-utils/src/main/java/io/quarkus/security/test/utils"
cp "/tests/extensions/security/test-utils/src/main/java/io/quarkus/security/test/utils/IdentityMock.java" "extensions/security/test-utils/src/main/java/io/quarkus/security/test/utils/IdentityMock.java"
mkdir -p "test-framework/security/src/test/java/io/quarkus/test/security/callback"
cp "/tests/test-framework/security/src/test/java/io/quarkus/test/security/callback/AbstractSecurityCallbackTest.java" "test-framework/security/src/test/java/io/quarkus/test/security/callback/AbstractSecurityCallbackTest.java"

# Rebuild the affected modules after solve.sh applies fix.patch
# This is necessary because fix.patch modifies source files
mvn -e -B --settings .github/mvn-settings.xml -DskipTests -DskipITs -DskipDocs \
  -Dinvoker.skip -Dskip.gradle.tests -Djbang.skip -Dtruststore.skip -Dno-format \
  -DskipExtensionValidation -Dtcks -Prelocations \
  -pl extensions/security/deployment,extensions/security/runtime,extensions/security/test-utils,test-framework/security -am \
  clean install

# Run the specific test classes
mvn -e -B --settings .github/mvn-settings.xml \
  -Dtest=QuarkusSecurityIdentityTest,AbstractSecurityCallbackTest \
  -pl extensions/security/runtime,test-framework/security \
  test
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
