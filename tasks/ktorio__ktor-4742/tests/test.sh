#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "ktor-server/ktor-server-plugins/ktor-server-di/common/test/io/ktor/server/plugins/di"
cp "/tests/ktor-server/ktor-server-plugins/ktor-server-di/common/test/io/ktor/server/plugins/di/DependencyInjectionTest.kt" "ktor-server/ktor-server-plugins/ktor-server-di/common/test/io/ktor/server/plugins/di/DependencyInjectionTest.kt"
mkdir -p "ktor-server/ktor-server-plugins/ktor-server-di/jvm/test/io/ktor/server/plugins/di"
cp "/tests/ktor-server/ktor-server-plugins/ktor-server-di/jvm/test/io/ktor/server/plugins/di/DependencyInjectionJvmTest.kt" "ktor-server/ktor-server-plugins/ktor-server-di/jvm/test/io/ktor/server/plugins/di/DependencyInjectionJvmTest.kt"

# Verify the fix restores LastEntryWinsPolicy and related DI features
CONFLICT_POLICY_SRC="ktor-server/ktor-server-plugins/ktor-server-di/common/src/io/ktor/server/plugins/di/DependencyConflictPolicy.kt"
DI_SRC="ktor-server/ktor-server-plugins/ktor-server-di/common/src/io/ktor/server/plugins/di/DependencyInjection.kt"
PROVIDER_SRC="ktor-server/ktor-server-plugins/ktor-server-di/common/src/io/ktor/server/plugins/di/DependencyProvider.kt"
test_status=0

# The fix restores LastEntryWinsPolicy in DependencyConflictPolicy.kt
if ! grep -q "LastEntryWinsPolicy" "$CONFLICT_POLICY_SRC"; then
    echo "FAIL: LastEntryWinsPolicy not found in DependencyConflictPolicy.kt"
    test_status=1
fi

# The fix restores data object declarations in DependencyConflictPolicy.kt
if ! grep -q "data object KeepPrevious" "$CONFLICT_POLICY_SRC"; then
    echo "FAIL: data object KeepPrevious not found in DependencyConflictPolicy.kt"
    test_status=1
fi

if ! grep -q "data object Ambiguous" "$CONFLICT_POLICY_SRC"; then
    echo "FAIL: data object Ambiguous not found in DependencyConflictPolicy.kt"
    test_status=1
fi

# The fix restores isTestEngine() and LastEntryWinsPolicy usage in DependencyInjection.kt
if ! grep -q "isTestEngine" "$DI_SRC"; then
    echo "FAIL: isTestEngine not found in DependencyInjection.kt"
    test_status=1
fi

if ! grep -q "LastEntryWinsPolicy" "$DI_SRC"; then
    echo "FAIL: LastEntryWinsPolicy not found in DependencyInjection.kt"
    test_status=1
fi

# The fix restores providerChanged field in DependencyInjectionConfig
if ! grep -q "providerChanged" "$DI_SRC"; then
    echo "FAIL: providerChanged not found in DependencyInjection.kt"
    test_status=1
fi

# The fix restores Logger parameter in MapDependencyProvider
if ! grep -q "Logger" "$PROVIDER_SRC"; then
    echo "FAIL: Logger not found in DependencyProvider.kt"
    test_status=1
fi

if [ $test_status -eq 0 ]; then
    echo "PASS: All LastEntryWinsPolicy and DI test engine fix changes verified"
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
