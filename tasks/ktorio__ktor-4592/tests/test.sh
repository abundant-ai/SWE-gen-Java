#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "ktor-client/ktor-client-plugins/ktor-client-logging/jvm/test/io/ktor/client/plugins/logging"
cp "/tests/ktor-client/ktor-client-plugins/ktor-client-logging/jvm/test/io/ktor/client/plugins/logging/OkHttpFormatTest.kt" "ktor-client/ktor-client-plugins/ktor-client-logging/jvm/test/io/ktor/client/plugins/logging/OkHttpFormatTest.kt"

# Run the specific test class for this PR
./gradlew :ktor-client:ktor-client-plugins:ktor-client-logging:jvmTest --tests "io.ktor.client.plugins.logging.OkHttpFormatTest" --no-daemon -x apiCheck 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
