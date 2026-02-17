#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "ktor-test-server/src/main/kotlin/test/server/tests"
cp "/tests/ktor-test-server/src/main/kotlin/test/server/tests/Cookies.kt" "ktor-test-server/src/main/kotlin/test/server/tests/Cookies.kt"

# Verify the API file contains fetchOptions and configureRequest (restored by fix)
API_FILE="ktor-client/ktor-client-core/api/ktor-client-core.klib.api"
test_status=0

if ! grep -q "configureRequest" "$API_FILE"; then
    echo "FAIL: configureRequest not found in API file"
    test_status=1
fi

if ! grep -q "fetchOptions" "$API_FILE"; then
    echo "FAIL: fetchOptions not found in API file"
    test_status=1
fi

# Also verify CORS headers are present in the test server Cookies.kt
if ! grep -q "AccessControlAllowCredentials" "ktor-test-server/src/main/kotlin/test/server/tests/Cookies.kt"; then
    echo "FAIL: CORS headers not found in Cookies.kt"
    test_status=1
fi

if [ $test_status -eq 0 ]; then
    echo "PASS: All API and test server changes verified"
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
