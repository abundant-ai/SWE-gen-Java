#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "ktor-network/nix/test/io/ktor/network/sockets/tests"
cp "/tests/ktor-network/nix/test/io/ktor/network/sockets/tests/TcpSocketTestNix.kt" "ktor-network/nix/test/io/ktor/network/sockets/tests/TcpSocketTestNix.kt"
mkdir -p "ktor-network/nix/test/io/ktor/network/sockets/tests"
cp "/tests/ktor-network/nix/test/io/ktor/network/sockets/tests/UdpSocketTestNix.kt" "ktor-network/nix/test/io/ktor/network/sockets/tests/UdpSocketTestNix.kt"

WORKER_SELECTOR="ktor-network/posix/src/io/ktor/network/selector/WorkerSelectorManager.kt"
SELECT_UTILS_NIX="ktor-network/nix/src/io/ktor/network/selector/SelectUtilsNix.kt"
SELECTOR_MANAGER="ktor-network/posix/src/io/ktor/network/selector/SelectorManager.kt"
test_status=0

# Verify WorkerSelectorManager uses provided dispatcher (fix), not newSingleThreadContext (bug)
if grep -q "newSingleThreadContext" "$WORKER_SELECTOR"; then
    echo "FAIL: WorkerSelectorManager.kt should not use newSingleThreadContext (bug: ignores provided dispatcher)"
    test_status=1
fi

# Verify WorkerSelectorManager accepts a CoroutineContext parameter (fix)
if ! grep -q "WorkerSelectorManager(context" "$WORKER_SELECTOR"; then
    echo "FAIL: WorkerSelectorManager.kt should accept CoroutineContext parameter (fix)"
    test_status=1
fi

# Verify SelectorManager factory passes dispatcher to WorkerSelectorManager (fix)
if ! grep -q "WorkerSelectorManager(dispatcher)" "$SELECTOR_MANAGER"; then
    echo "FAIL: SelectorManager.kt should pass dispatcher to WorkerSelectorManager (fix)"
    test_status=1
fi

# Verify SelectUtilsNix uses suspend selectionLoop (fix), not non-suspend (bug)
if ! grep -q "private suspend fun selectionLoop" "$SELECT_UTILS_NIX"; then
    echo "FAIL: SelectUtilsNix.kt should use private suspend fun selectionLoop (fix)"
    test_status=1
fi

if [ $test_status -eq 0 ]; then
    echo "PASS: All SelectorManager dispatcher fix verifications passed"
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
