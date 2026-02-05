#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "subprojects/junitJupiterExtensionTest/src/test/java/org/mockitousage"
cp "/tests/subprojects/junitJupiterExtensionTest/src/test/java/org/mockitousage/NoExtendsTest.java" "subprojects/junitJupiterExtensionTest/src/test/java/org/mockitousage/NoExtendsTest.java"
mkdir -p "subprojects/junitJupiterExtensionTest/src/test/resources/META-INF/services"
cp "/tests/subprojects/junitJupiterExtensionTest/src/test/resources/META-INF/services/org.junit.jupiter.api.extension.Extension" "subprojects/junitJupiterExtensionTest/src/test/resources/META-INF/services/org.junit.jupiter.api.extension.Extension"
mkdir -p "subprojects/junitJupiterExtensionTest/src/test/resources"
cp "/tests/subprojects/junitJupiterExtensionTest/src/test/resources/junit-platform.properties" "subprojects/junitJupiterExtensionTest/src/test/resources/junit-platform.properties"

# Clean and recompile tests to pick up the copied test files
./gradlew :junitJupiterExtensionTest:cleanTest --no-daemon

# Run the specific tests for this PR (in the junitJupiterExtensionTest subproject)
./gradlew :junitJupiterExtensionTest:test \
  --tests org.mockitousage.NoExtendsTest \
  --no-daemon
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
