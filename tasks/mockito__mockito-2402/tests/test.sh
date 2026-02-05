#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/org/mockito/internal/creation/bytebuddy"
cp "/tests/java/org/mockito/internal/creation/bytebuddy/TypeCachingMockBytecodeGeneratorTest.java" "src/test/java/org/mockito/internal/creation/bytebuddy/TypeCachingMockBytecodeGeneratorTest.java"
mkdir -p "src/test/java/org/mockitousage/spies"
cp "/tests/java/org/mockitousage/spies/SpyingOnRealObjectsTest.java" "src/test/java/org/mockitousage/spies/SpyingOnRealObjectsTest.java"
mkdir -p "subprojects/kotlinReleaseCoroutinesTest/src/test/kotlin/org/mockito/kotlin"
cp "/tests/subprojects/kotlinReleaseCoroutinesTest/src/test/kotlin/org/mockito/kotlin/SuspendTest.kt" "subprojects/kotlinReleaseCoroutinesTest/src/test/kotlin/org/mockito/kotlin/SuspendTest.kt"

# Recompile tests to pick up the updated test files
./gradlew testClasses --no-daemon || true

# Run the specific tests for this PR
./gradlew :test --tests org.mockito.internal.creation.bytebuddy.TypeCachingMockBytecodeGeneratorTest \
  --tests org.mockitousage.spies.SpyingOnRealObjectsTest \
  :kotlinReleaseCoroutinesTest:test --tests org.mockito.kotlin.SuspendTest \
  --no-daemon --rerun-tasks
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
