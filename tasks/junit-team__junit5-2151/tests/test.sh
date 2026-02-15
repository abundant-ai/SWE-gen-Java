#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "platform-tooling-support-tests/src/test/java/platform/tooling/support/tests"
cp "/tests/platform-tooling-support-tests/src/test/java/platform/tooling/support/tests/ManifestTests.java" "platform-tooling-support-tests/src/test/java/platform/tooling/support/tests/ManifestTests.java"

# Run the specific test file using Gradle
# Note: platform-tooling-support-tests are disabled by default, must enable via system property
./gradlew :platform-tooling-support-tests:test \
  --tests platform.tooling.support.tests.ManifestTests \
  -Dplatform.tooling.support.tests.enabled=true \
  -x compileModule --no-daemon --no-parallel 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
