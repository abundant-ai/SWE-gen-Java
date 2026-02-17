#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "ktor-client/ktor-client-tests/jvm/src/io/ktor/client/tests"
cp "/tests/ktor-client/ktor-client-tests/jvm/src/io/ktor/client/tests/HttpClientTest.kt" "ktor-client/ktor-client-tests/jvm/src/io/ktor/client/tests/HttpClientTest.kt"

# Verify the fix restores isGetOrHeadOrOptions handling in the request producers
APACHE_FILE="ktor-client/ktor-client-apache/jvm/src/io/ktor/client/engine/apache/ApacheRequestProducer.kt"
APACHE5_FILE="ktor-client/ktor-client-apache5/jvm/src/io/ktor/client/engine/apache5/ApacheRequestProducer.kt"
CIO_FILE="ktor-client/ktor-client-cio/common/src/io/ktor/client/engine/cio/utils.kt"
TEST_FILE="ktor-client/ktor-client-tests/jvm/src/io/ktor/client/tests/HttpClientTest.kt"
test_status=0

if ! grep -q "isGetOrHeadOrOptions" "$APACHE_FILE"; then
    echo "FAIL: isGetOrHeadOrOptions not found in apache ApacheRequestProducer.kt"
    test_status=1
fi

if ! grep -q "isGetOrHeadOrOptions" "$APACHE5_FILE"; then
    echo "FAIL: isGetOrHeadOrOptions not found in apache5 ApacheRequestProducer.kt"
    test_status=1
fi

if ! grep -q "isGetOrHeadOrOptions" "$CIO_FILE"; then
    echo "FAIL: isGetOrHeadOrOptions not found in CIO utils.kt"
    test_status=1
fi

if ! grep -q "testOptionsRequest" "$TEST_FILE"; then
    echo "FAIL: testOptionsRequest not found in HttpClientTest.kt"
    test_status=1
fi

if [ $test_status -eq 0 ]; then
    echo "PASS: All OPTIONS handling changes verified"
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
