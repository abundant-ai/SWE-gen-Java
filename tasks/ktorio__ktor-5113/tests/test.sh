#!/bin/bash

cd /app/src

# Environment variables for Gradle
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "ktor-http/common/test/io/ktor/tests/http"
cp "/tests/ktor-http/common/test/io/ktor/tests/http/CommonHeadersTest.kt" "ktor-http/common/test/io/ktor/tests/http/CommonHeadersTest.kt"
mkdir -p "ktor-server/ktor-server-tests/common/test/io/ktor/tests/server/http"
cp "/tests/ktor-server/ktor-server-tests/common/test/io/ktor/tests/server/http/HeadersServerTest.kt" "ktor-server/ktor-server-tests/common/test/io/ktor/tests/server/http/HeadersServerTest.kt"

# Override Gradle memory settings to prevent OOM
export GRADLE_OPTS="-Xms1g -Xmx6g -XX:MaxMetaspaceSize=1g -Dorg.gradle.daemon=false -Dorg.gradle.parallel=false"

# Clear Gradle caches to force it to see the updated test files
rm -rf .gradle/configuration-cache 2>/dev/null || true
rm -rf ktor-http/build 2>/dev/null || true
rm -rf ktor-server/ktor-server-tests/build 2>/dev/null || true

# Run tests for both modules with specific test classes
./gradlew :ktor-http:jvmTest --tests "*CommonHeadersTest" --no-daemon 2>&1 | tee /tmp/test_output1.txt
test_status1=${PIPESTATUS[0]}

./gradlew :ktor-server-tests:jvmTest --tests "*HeadersServerTest" --no-daemon 2>&1 | tee /tmp/test_output2.txt
test_status2=${PIPESTATUS[0]}

# Combine test statuses (both must pass)
if [ $test_status1 -eq 0 ] && [ $test_status2 -eq 0 ]; then
    test_status=0
else
    test_status=1
fi

# Gradle might exit 0 even with test failures in some KMP setups
# Double-check by looking for test failure messages
if grep -q "tests completed,.*failed" /tmp/test_output1.txt || grep -q "tests completed,.*failed" /tmp/test_output2.txt; then
    echo "Tests failed based on output analysis"
    test_status=1
elif grep -q "BUILD FAILED" /tmp/test_output1.txt || grep -q "BUILD FAILED" /tmp/test_output2.txt; then
    echo "Build failed"
    test_status=1
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
