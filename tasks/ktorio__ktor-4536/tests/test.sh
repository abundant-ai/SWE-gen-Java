#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "ktor-utils/jvm/test/io/ktor/tests/utils"
cp "/tests/ktor-utils/jvm/test/io/ktor/tests/utils/FileChannelTest.kt" "ktor-utils/jvm/test/io/ktor/tests/utils/FileChannelTest.kt"

# Run the specific test class for this PR
./gradlew :ktor-utils:jvmTest --tests "io.ktor.tests.utils.FileChannelTest" --no-daemon -x apiCheck 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
