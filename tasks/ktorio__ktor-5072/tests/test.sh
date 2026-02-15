#!/bin/bash

cd /app/src

# Environment variables for Gradle
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "ktor-client/ktor-client-okhttp/jvm/test/io/ktor/client/engine/okhttp"
cp "/tests/ktor-client/ktor-client-okhttp/jvm/test/io/ktor/client/engine/okhttp/OkHttpHttpClientTest.kt" "ktor-client/ktor-client-okhttp/jvm/test/io/ktor/client/engine/okhttp/OkHttpHttpClientTest.kt"
mkdir -p "ktor-client/ktor-client-tests/common/test/io/ktor/client/tests/plugins"
cp "/tests/ktor-client/ktor-client-tests/common/test/io/ktor/client/tests/plugins/ServerSentEventsTest.kt" "ktor-client/ktor-client-tests/common/test/io/ktor/client/tests/plugins/ServerSentEventsTest.kt"
mkdir -p "ktor-test-server/src/main/kotlin/test/server/tests"
cp "/tests/ktor-test-server/src/main/kotlin/test/server/tests/ServerSentEvents.kt" "ktor-test-server/src/main/kotlin/test/server/tests/ServerSentEvents.kt"

# Override Gradle memory settings to prevent OOM
export GRADLE_OPTS="-Xms1g -Xmx6g -XX:MaxMetaspaceSize=1g -Dorg.gradle.daemon=false -Dorg.gradle.parallel=false"

# Clear Gradle caches to force it to see the updated test files
rm -rf .gradle/configuration-cache 2>/dev/null || true
rm -rf ktor-client/ktor-client-okhttp/build 2>/dev/null || true
rm -rf ktor-client/ktor-client-tests/build 2>/dev/null || true
rm -rf ktor-test-server/build 2>/dev/null || true

# Compile the test (validates that the API change works correctly)
./gradlew :ktor-client-okhttp:compileTestKotlinJvm --no-daemon --no-configuration-cache 2>&1 | tee /tmp/test_output.txt
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
