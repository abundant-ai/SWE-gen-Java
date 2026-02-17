#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "ktor-client/ktor-client-cio/jvm/test/io/ktor/client/engine/cio"
cp "/tests/ktor-client/ktor-client-cio/jvm/test/io/ktor/client/engine/cio/ConnectErrorsTest.kt" "ktor-client/ktor-client-cio/jvm/test/io/ktor/client/engine/cio/ConnectErrorsTest.kt"

# Verify the fix restores proper ClosedReadChannelException wrapping
UTILS_SRC="ktor-client/ktor-client-cio/common/src/io/ktor/client/engine/cio/utils.kt"
PIPELINE_SRC="ktor-client/ktor-client-cio/jvm/src/io/ktor/client/engine/cio/ConnectionPipeline.kt"
test_status=0

# The fix restores ClosedReadChannelException wrapping in utils.kt
if ! grep -q "ClosedReadChannelException" "$UTILS_SRC"; then
    echo "FAIL: ClosedReadChannelException not found in utils.kt"
    test_status=1
fi

# The fix restores EOFException import in utils.kt
if ! grep -q "import kotlinx.io.EOFException" "$UTILS_SRC"; then
    echo "FAIL: kotlinx.io.EOFException import not found in utils.kt"
    test_status=1
fi

# The fix restores ClosedReadChannelException wrapping in ConnectionPipeline.kt
if ! grep -q "ClosedReadChannelException" "$PIPELINE_SRC"; then
    echo "FAIL: ClosedReadChannelException not found in ConnectionPipeline.kt"
    test_status=1
fi

# The fix restores EOFException import in ConnectionPipeline.kt
if ! grep -q "import kotlinx.io.EOFException" "$PIPELINE_SRC"; then
    echo "FAIL: kotlinx.io.EOFException import not found in ConnectionPipeline.kt"
    test_status=1
fi

if [ $test_status -eq 0 ]; then
    echo "PASS: All ClosedReadChannelException fix changes verified"
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
