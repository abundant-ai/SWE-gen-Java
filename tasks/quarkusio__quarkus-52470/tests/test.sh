#!/bin/bash

cd /app/src

# Set environment variables for test execution
export LANG=en_US.UTF-8

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "extensions/oidc-common/runtime/src/test/java/io/quarkus/oidc/common/runtime"
cp "/tests/extensions/oidc-common/runtime/src/test/java/io/quarkus/oidc/common/runtime/KubernetesServiceClientAssertionProviderTest.java" "extensions/oidc-common/runtime/src/test/java/io/quarkus/oidc/common/runtime/KubernetesServiceClientAssertionProviderTest.java"

# Remove the buggy test file that has compilation errors (it was renamed/modified by bug.patch)
rm -f "extensions/oidc-common/runtime/src/test/java/io/quarkus/oidc/common/runtime/ClientAssertionProviderTest.java"

# Rebuild modules to pick up test changes from fix.patch
mvn -e -B --settings .github/mvn-settings.xml -Dmaven.test.skip=true -DskipDocs \
    -Dinvoker.skip -Dskip.gradle.tests -Djbang.skip -Dtruststore.skip -Dno-format \
    -DskipExtensionValidation \
    -pl extensions/oidc-common/runtime,extensions/oidc-common/deployment \
    clean install

# Run the specific test files
mvn -e -B --settings .github/mvn-settings.xml \
    -Dtest=KubernetesServiceClientAssertionProviderTest \
    -pl extensions/oidc-common/runtime \
    test

test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
