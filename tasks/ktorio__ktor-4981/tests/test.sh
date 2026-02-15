#!/bin/bash

cd /app/src

# Environment variables for Gradle
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "ktor-network/common/test/io/ktor/network/sockets/tests"
cp "/tests/ktor-network/common/test/io/ktor/network/sockets/tests/TCPSocketTest.kt" "ktor-network/common/test/io/ktor/network/sockets/tests/TCPSocketTest.kt"

# Override Gradle memory settings to prevent OOM (container has 2GB total)
export GRADLE_OPTS="-Xms512m -Xmx1536m -XX:MaxMetaspaceSize=512m -Dorg.gradle.daemon=false -Dorg.gradle.parallel=false -XX:+UseParallelGC"

# Clear Gradle caches to force it to see the updated test files
rm -rf .gradle/configuration-cache 2>/dev/null || true
rm -rf .gradle/*/kotlin 2>/dev/null || true
rm -rf ktor-network/build 2>/dev/null || true
rm -rf ktor-io/build 2>/dev/null || true

# Run the specific test
./gradlew :ktor-network:jvmTest --tests "io.ktor.network.sockets.tests.TCPSocketTest.testAutoFlush" --no-daemon --no-configuration-cache 2>&1 | tee /tmp/test_output.txt
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
