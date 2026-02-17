#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "ktor-client/ktor-client-tests/common/test/io/ktor/client/tests/plugins"
cp "/tests/ktor-client/ktor-client-tests/common/test/io/ktor/client/tests/plugins/ServerSentEventsTest.kt" "ktor-client/ktor-client-tests/common/test/io/ktor/client/tests/plugins/ServerSentEventsTest.kt"
mkdir -p "ktor-test-server/src/main/kotlin/test/server/tests"
cp "/tests/ktor-test-server/src/main/kotlin/test/server/tests/ServerSentEvents.kt" "ktor-test-server/src/main/kotlin/test/server/tests/ServerSentEvents.kt"

# Verify the fix restores correct SSE session cancellation behavior in OkHttpSSESession and DefaultClientSSESession
OKHTTP_SSE="ktor-client/ktor-client-okhttp/jvm/src/io/ktor/client/engine/okhttp/OkHttpSSESession.kt"
DEFAULT_SSE="ktor-client/ktor-client-core/common/src/io/ktor/client/plugins/sse/DefaultClientSSESession.kt"
test_status=0

# The fix restores consumeAsFlow() (not receiveAsFlow()) in OkHttpSSESession
if ! grep -q "consumeAsFlow" "$OKHTTP_SSE"; then
    echo "FAIL: consumeAsFlow() not found in OkHttpSSESession.kt (should be restored by fix)"
    test_status=1
fi

# The fix removes the buggy receiveAsFlow() getter pattern
if grep -q "get() = _incoming.receiveAsFlow()" "$OKHTTP_SSE"; then
    echo "FAIL: OkHttpSSESession.incoming should not use receiveAsFlow() getter (this is the bug)"
    test_status=1
fi

# The fix restores .onFailure CancellationException handling in onEvent (channels.onFailure import)
if ! grep -q "channels.onFailure" "$OKHTTP_SSE"; then
    echo "FAIL: channels.onFailure not found in OkHttpSSESession.kt (should be restored by fix)"
    test_status=1
fi

# The fix restores onCompletion operator in DefaultClientSSESession for proper cancellation propagation
if ! grep -q "onCompletion" "$DEFAULT_SSE"; then
    echo "FAIL: onCompletion operator not found in DefaultClientSSESession.kt (should be restored by fix)"
    test_status=1
fi

if [ $test_status -eq 0 ]; then
    echo "PASS: All SSE session cancellation fixes verified"
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
