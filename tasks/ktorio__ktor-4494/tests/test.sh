#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "ktor-client/ktor-client-tests/common/test/io/ktor/client/tests"
cp "/tests/ktor-client/ktor-client-tests/common/test/io/ktor/client/tests/HttpTimeoutTest.kt" "ktor-client/ktor-client-tests/common/test/io/ktor/client/tests/HttpTimeoutTest.kt"
mkdir -p "ktor-server/ktor-server-tests/common/test/io/ktor/tests/server/http"
cp "/tests/ktor-server/ktor-server-tests/common/test/io/ktor/tests/server/http/RespondFunctionsTest.kt" "ktor-server/ktor-server-tests/common/test/io/ktor/tests/server/http/RespondFunctionsTest.kt"

# Run only the specific test classes from the PR
./gradlew :ktor-client:ktor-client-tests:jvmTest --tests "io.ktor.client.tests.HttpTimeoutTest" \
    :ktor-server:ktor-server-tests:jvmTest --tests "io.ktor.tests.server.http.RespondFunctionsTest" \
    --no-daemon 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
