#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "ktor-server/ktor-server-test-base/jsAndWasmShared/src/io/ktor/server/test/base"
cp "/tests/ktor-server/ktor-server-test-base/jsAndWasmShared/src/io/ktor/server/test/base/EngineTestBase.jsAndWasmShared.kt" "ktor-server/ktor-server-test-base/jsAndWasmShared/src/io/ktor/server/test/base/EngineTestBase.jsAndWasmShared.kt"

# Compile the JS source set for ktor-server-test-base to verify the fix
# In the buggy state, EngineTestBase uses startSuspend/stopSuspend which don't exist -> compile error
# In the fixed state, EngineTestBase uses start/stop which do exist -> compile succeeds
./gradlew :ktor-server:ktor-server-test-base:compileKotlinJs \
    --no-daemon --max-workers 1 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
