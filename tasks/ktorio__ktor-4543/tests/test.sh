#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "ktor-server/ktor-server-plugins/ktor-server-sse/common/test/io/ktor/server/sse"
cp "/tests/ktor-server/ktor-server-plugins/ktor-server-sse/common/test/io/ktor/server/sse/ServerSentEventsTest.kt" "ktor-server/ktor-server-plugins/ktor-server-sse/common/test/io/ktor/server/sse/ServerSentEventsTest.kt"

# Run the specific test class for this PR
./gradlew :ktor-server:ktor-server-plugins:ktor-server-sse:jvmTest --tests "io.ktor.server.sse.ServerSentEventsTest" --no-daemon -x apiCheck 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
