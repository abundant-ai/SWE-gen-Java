#!/bin/bash

cd /app/src

# Environment variables for Gradle
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "ktor-server/ktor-server-plugins/ktor-server-di/common/test/io/ktor/server/plugins/di"
cp "/tests/ktor-server/ktor-server-plugins/ktor-server-di/common/test/io/ktor/server/plugins/di/DependencyInjectionTest.kt" "ktor-server/ktor-server-plugins/ktor-server-di/common/test/io/ktor/server/plugins/di/DependencyInjectionTest.kt"
mkdir -p "ktor-server/ktor-server-plugins/ktor-server-di/jvm/test/io/ktor/server/plugins/di"
cp "/tests/ktor-server/ktor-server-plugins/ktor-server-di/jvm/test/io/ktor/server/plugins/di/DependencyInjectionJvmTest.kt" "ktor-server/ktor-server-plugins/ktor-server-di/jvm/test/io/ktor/server/plugins/di/DependencyInjectionJvmTest.kt"
mkdir -p "ktor-server/ktor-server-plugins/ktor-server-di/jvm/test/io/ktor/server/plugins/di"
cp "/tests/ktor-server/ktor-server-plugins/ktor-server-di/jvm/test/io/ktor/server/plugins/di/DependencyInjectionTestModules.kt" "ktor-server/ktor-server-plugins/ktor-server-di/jvm/test/io/ktor/server/plugins/di/DependencyInjectionTestModules.kt"

# Override Gradle memory settings to prevent OOM (container has 6GB total)
export GRADLE_OPTS="-Dorg.gradle.daemon=false -Dorg.gradle.parallel=false -Xms256m -Xmx3g -XX:MaxMetaspaceSize=768m -XX:+UseParallelGC"

# Clear Gradle caches to force it to see the updated test files
rm -rf .gradle/configuration-cache 2>/dev/null || true
rm -rf .gradle/*/kotlin 2>/dev/null || true
rm -rf ktor-server/ktor-server-plugins/ktor-server-di/build 2>/dev/null || true
rm -rf ktor-server/build 2>/dev/null || true

# Run the specific tests for DependencyInjection on jvmTest target
./gradlew :ktor-server:ktor-server-plugins:ktor-server-di:jvmTest --tests "io.ktor.server.plugins.di.DependencyInjectionTest" --tests "io.ktor.server.plugins.di.DependencyInjectionJvmTest" --no-daemon --no-configuration-cache --no-build-cache 2>&1 | tee /tmp/test_output.txt
test_status=${PIPESTATUS[0]}

# Gradle might exit 0 even with test failures in some KMP setups
# Double-check by looking for test failure messages
if grep -q "tests completed,.*failed" /tmp/test_output.txt; then
    echo "Tests failed based on output analysis"
    test_status=1
elif grep -q "BUILD FAILED" /tmp/test_output.txt; then
    echo "Build failed"
    test_status=1
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
