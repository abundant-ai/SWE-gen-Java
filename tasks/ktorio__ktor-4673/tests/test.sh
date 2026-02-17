#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "ktor-client/ktor-client-core/jvm/test"
cp "/tests/ktor-client/ktor-client-core/jvm/test/CachingCacheStorageTest.kt" "ktor-client/ktor-client-core/jvm/test/CachingCacheStorageTest.kt"
mkdir -p "ktor-client/ktor-client-tests/common/test/io/ktor/client/tests/plugins"
cp "/tests/ktor-client/ktor-client-tests/common/test/io/ktor/client/tests/plugins/CacheTest.kt" "ktor-client/ktor-client-tests/common/test/io/ktor/client/tests/plugins/CacheTest.kt"
mkdir -p "ktor-test-server/src/main/kotlin/test/server/tests"
cp "/tests/ktor-test-server/src/main/kotlin/test/server/tests/Cache.kt" "ktor-test-server/src/main/kotlin/test/server/tests/Cache.kt"

UNLIMITED_STORAGE="ktor-client/ktor-client-core/common/src/io/ktor/client/plugins/cache/storage/UnlimitedCacheStorage.kt"
FILE_CACHE_STORAGE="ktor-client/ktor-client-core/jvm/src/io/ktor/client/plugins/cache/storage/FileCacheStorage.kt"
test_status=0

# Verify UnlimitedCacheStorage uses varyKeys.size check (fix), not missing (bug)
if ! grep -q "varyKeys.size == it.varyKeys.size" "$UNLIMITED_STORAGE"; then
    echo "FAIL: UnlimitedCacheStorage.kt should use varyKeys.size == it.varyKeys.size check (fix)"
    test_status=1
fi

# Verify FileCacheStorage uses varyKeys.size check (fix), not missing (bug)
if ! grep -q "varyKeys.size == it.varyKeys.size" "$FILE_CACHE_STORAGE"; then
    echo "FAIL: FileCacheStorage.kt should use varyKeys.size == it.varyKeys.size check (fix)"
    test_status=1
fi

if [ $test_status -eq 0 ]; then
    echo "PASS: All cache vary keys size check fixes verified"
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
