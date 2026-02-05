#!/bin/bash

cd /app/src

# Fix kotlinTest dependency on kotlinx-coroutines-core (0.14 no longer available, use 0.19)
# This needs to be done here because the fix.patch/oracle applies it
test -f subprojects/kotlinTest/build.gradle && sed -i "s/kotlinx-coroutines-core:0.14/kotlinx-coroutines-core:0.19/" subprojects/kotlinTest/build.gradle || true
test -f subprojects/kotlinTest/kotlinTest.gradle && sed -i "s/kotlinx-coroutines-core:0.14/kotlinx-coroutines-core:0.19/" subprojects/kotlinTest/kotlinTest.gradle || true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/org/mockito/internal/stubbing/answers"
cp "/tests/java/org/mockito/internal/stubbing/answers/ReturnsArgumentAtTest.java" "src/test/java/org/mockito/internal/stubbing/answers/ReturnsArgumentAtTest.java"
mkdir -p "subprojects/kotlinTest/src/test/kotlin/org/mockito/kotlin"
cp "/tests/subprojects/kotlinTest/src/test/kotlin/org/mockito/kotlin/SuspendTest.kt" "subprojects/kotlinTest/src/test/kotlin/org/mockito/kotlin/SuspendTest.kt"

# Clean and recompile tests to pick up the copied test files
./gradlew :cleanTest --no-daemon

# Run the specific test classes for this PR
./gradlew :test \
  --tests org.mockito.internal.stubbing.answers.ReturnsArgumentAtTest \
  :kotlinTest:test \
  --tests org.mockito.kotlin.SuspendTest \
  --no-daemon
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
