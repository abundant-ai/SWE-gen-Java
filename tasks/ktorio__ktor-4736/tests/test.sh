#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "ktor-server/ktor-server-plugins/ktor-server-di/common/test/io/ktor/server/plugins/di"
cp "/tests/ktor-server/ktor-server-plugins/ktor-server-di/common/test/io/ktor/server/plugins/di/DependencyInjectionTest.kt" "ktor-server/ktor-server-plugins/ktor-server-di/common/test/io/ktor/server/plugins/di/DependencyInjectionTest.kt"
mkdir -p "ktor-server/ktor-server-plugins/ktor-server-di/jvm/test/io/ktor/server/plugins/di"
cp "/tests/ktor-server/ktor-server-plugins/ktor-server-di/jvm/test/io/ktor/server/plugins/di/DependencyInjectTestModules.kt" "ktor-server/ktor-server-plugins/ktor-server-di/jvm/test/io/ktor/server/plugins/di/DependencyInjectTestModules.kt"
mkdir -p "ktor-server/ktor-server-plugins/ktor-server-di/jvm/test/io/ktor/server/plugins/di"
cp "/tests/ktor-server/ktor-server-plugins/ktor-server-di/jvm/test/io/ktor/server/plugins/di/DependencyInjectionJvmTest.kt" "ktor-server/ktor-server-plugins/ktor-server-di/jvm/test/io/ktor/server/plugins/di/DependencyInjectionJvmTest.kt"

# Verify the fix restores ClasspathReference and related DI configuration features
DI_SRC="ktor-server/ktor-server-plugins/ktor-server-di/common/src/io/ktor/server/plugins/di/DependencyInjection.kt"
PROVIDER_SRC="ktor-server/ktor-server-plugins/ktor-server-di/common/src/io/ktor/server/plugins/di/DependencyProvider.kt"
REGISTRY_SRC="ktor-server/ktor-server-plugins/ktor-server-di/common/src/io/ktor/server/plugins/di/DependencyRegistry.kt"
CLASSPATH_REF="ktor-server/ktor-server-plugins/ktor-server-di/common/src/io/ktor/server/plugins/di/utils/ClasspathReference.kt"
CLASSPATH_REF_JVM="ktor-server/ktor-server-plugins/ktor-server-di/jvm/src/io/ktor/server/plugins/di/utils/ClasspathReference.jvm.kt"
test_status=0

# The fix restores ClasspathReference.kt (classpath reference feature)
if [ ! -f "$CLASSPATH_REF" ]; then
    echo "FAIL: ClasspathReference.kt not found (should be restored by fix)"
    test_status=1
fi

# The fix restores ClasspathReference.jvm.kt
if [ ! -f "$CLASSPATH_REF_JVM" ]; then
    echo "FAIL: ClasspathReference.jvm.kt not found (should be restored by fix)"
    test_status=1
fi

# The fix restores CircularDependencyException to take a Collection of DependencyKeys
if ! grep -q "Collection<DependencyKey>" "$DI_SRC"; then
    echo "FAIL: CircularDependencyException(Collection<DependencyKey>) not found in DependencyInjection.kt"
    test_status=1
fi

# The fix restores the 'Circular dependency found:' message format
if ! grep -q "Circular dependency found:" "$DI_SRC"; then
    echo "FAIL: 'Circular dependency found:' message not found in DependencyInjection.kt"
    test_status=1
fi

# The fix restores abstract val key in DependencyCreateFunction interface
if ! grep -q "public val key: DependencyKey" "$PROVIDER_SRC"; then
    echo "FAIL: abstract val key not found in DependencyCreateFunction (should be restored)"
    test_status=1
fi

# The fix restores resolveAll() in ProcessingDependencyResolver
if ! grep -q "resolveAll" "$REGISTRY_SRC"; then
    echo "FAIL: resolveAll() not found in DependencyRegistry.kt (should be restored)"
    test_status=1
fi

# The fix restores installReference import in DependencyInjection.kt
if ! grep -q "installReference" "$DI_SRC"; then
    echo "FAIL: installReference not found in DependencyInjection.kt (should be restored)"
    test_status=1
fi

if [ $test_status -eq 0 ]; then
    echo "PASS: All ClasspathReference and related DI configuration features verified"
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
