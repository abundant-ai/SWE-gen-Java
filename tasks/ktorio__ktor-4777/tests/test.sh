#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "ktor-server/ktor-server-tests/jvm/test/io/ktor/server/plugins"
cp "/tests/ktor-server/ktor-server-tests/jvm/test/io/ktor/server/plugins/CompressionTest.kt" "ktor-server/ktor-server-tests/jvm/test/io/ktor/server/plugins/CompressionTest.kt"
mkdir -p "ktor-server/ktor-server-tests/jvm/test/io/ktor/server/plugins"
cp "/tests/ktor-server/ktor-server-tests/jvm/test/io/ktor/server/plugins/StaticContentTest.kt" "ktor-server/ktor-server-tests/jvm/test/io/ktor/server/plugins/StaticContentTest.kt"

# Verify the fix adds Vary: Accept-Encoding header support for compression
COMPRESSED_CONTENT_FILE="ktor-http/common/src/io/ktor/http/content/CompressedContent.kt"
PRECOMPRESSED_FILE="ktor-server/ktor-server-core/jvm/src/io/ktor/server/http/content/PreCompressed.kt"
COMPRESSION_TEST_FILE="ktor-server/ktor-server-tests/jvm/test/io/ktor/server/plugins/CompressionTest.kt"
STATIC_TEST_FILE="ktor-server/ktor-server-tests/jvm/test/io/ktor/server/plugins/StaticContentTest.kt"
test_status=0

if ! grep -q "HttpHeaders.Vary" "$COMPRESSED_CONTENT_FILE"; then
    echo "FAIL: Vary header not found in CompressedContent.kt"
    test_status=1
fi

if ! grep -q "HttpHeaders.Vary" "$PRECOMPRESSED_FILE"; then
    echo "FAIL: Vary header not found in PreCompressed.kt"
    test_status=1
fi

if ! grep -q "testVaryHeaderPresent" "$COMPRESSION_TEST_FILE"; then
    echo "FAIL: testVaryHeaderPresent not found in CompressionTest.kt"
    test_status=1
fi

if ! grep -q "testVaryHeaderWithPreCompressedStaticResources" "$STATIC_TEST_FILE"; then
    echo "FAIL: testVaryHeaderWithPreCompressedStaticResources not found in StaticContentTest.kt"
    test_status=1
fi

if [ $test_status -eq 0 ]; then
    echo "PASS: All Vary header changes verified"
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
