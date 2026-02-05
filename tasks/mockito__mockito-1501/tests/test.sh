#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "subprojects/kotlinReleaseCoroutinesTest/src/test/kotlin/org/mockito/kotlin"
cp "/tests/subprojects/kotlinReleaseCoroutinesTest/src/test/kotlin/org/mockito/kotlin/SuspendTest.kt" "subprojects/kotlinReleaseCoroutinesTest/src/test/kotlin/org/mockito/kotlin/SuspendTest.kt"
mkdir -p "subprojects/kotlinReleaseCoroutinesTest/src/test/resources/mockito-extensions"
cp "/tests/subprojects/kotlinReleaseCoroutinesTest/src/test/resources/mockito-extensions/org.mockito.plugins.MockMaker" "subprojects/kotlinReleaseCoroutinesTest/src/test/resources/mockito-extensions/org.mockito.plugins.MockMaker"

# Clean and recompile tests to pick up the copied test files
./gradlew :kotlinReleaseCoroutinesTest:cleanTest --no-daemon

# Run the specific test for this PR (in the kotlinReleaseCoroutinesTest subproject)
./gradlew :kotlinReleaseCoroutinesTest:test \
  --tests org.mockito.kotlin.SuspendTest \
  --no-daemon
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
