#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "ktor-client/ktor-client-tests/common/test/io/ktor/client/tests"
cp "/tests/ktor-client/ktor-client-tests/common/test/io/ktor/client/tests/LoggingMockedTests.kt" "ktor-client/ktor-client-tests/common/test/io/ktor/client/tests/LoggingMockedTests.kt"
mkdir -p "ktor-client/ktor-client-tests/common/test/io/ktor/client/tests"
cp "/tests/ktor-client/ktor-client-tests/common/test/io/ktor/client/tests/ResponseObserverTest.kt" "ktor-client/ktor-client-tests/common/test/io/ktor/client/tests/ResponseObserverTest.kt"

# Verify the fix restores proper ResponseObserver and Logging behavior
RESPONSE_OBSERVER_SRC="ktor-client/ktor-client-core/common/src/io/ktor/client/plugins/observer/ResponseObserver.kt"
LOGGING_SRC="ktor-client/ktor-client-plugins/ktor-client-logging/common/src/io/ktor/client/plugins/logging/Logging.kt"
LOGGING_UTILS_SRC="ktor-client/ktor-client-plugins/ktor-client-logging/common/src/io/ktor/client/plugins/logging/LoggingUtils.kt"
test_status=0

# The fix restores isSaved check in ResponseObserver.kt
if ! grep -q "isSaved" "$RESPONSE_OBSERVER_SRC"; then
    echo "FAIL: isSaved check not found in ResponseObserver.kt"
    test_status=1
fi

# The fix restores logResponseBody(response) call in Logging.kt
if ! grep -q "logResponseBody(response)" "$LOGGING_SRC"; then
    echo "FAIL: logResponseBody(response) call not found in Logging.kt"
    test_status=1
fi

# The fix restores appendResponseBody in LoggingUtils.kt
if ! grep -q "appendResponseBody" "$LOGGING_UTILS_SRC"; then
    echo "FAIL: appendResponseBody not found in LoggingUtils.kt"
    test_status=1
fi

if [ $test_status -eq 0 ]; then
    echo "PASS: All ResponseObserver and Logging fix changes verified"
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
