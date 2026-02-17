#!/bin/bash

cd /app/src

# Environment variables for Gradle
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "ktor-server/ktor-server-plugins/ktor-server-htmx/common/test/io/ktor/server/htmx"
cp "/tests/ktor-server/ktor-server-plugins/ktor-server-htmx/common/test/io/ktor/server/htmx/HxRoutingTest.kt" "ktor-server/ktor-server-plugins/ktor-server-htmx/common/test/io/ktor/server/htmx/HxRoutingTest.kt"
mkdir -p "ktor-shared/ktor-htmx/ktor-htmx-html/common/test/io/ktor/htmx/html"
cp "/tests/ktor-shared/ktor-htmx/ktor-htmx-html/common/test/io/ktor/htmx/html/HxAttributesTest.kt" "ktor-shared/ktor-htmx/ktor-htmx-html/common/test/io/ktor/htmx/html/HxAttributesTest.kt"

# Override Gradle memory settings to prevent OOM (container has 6GB total)
export GRADLE_OPTS="-Xms1g -Xmx4g -XX:MaxMetaspaceSize=1g -Dorg.gradle.daemon=false -Dorg.gradle.parallel=false -XX:+UseParallelGC"

# Clear Gradle caches to force it to see the updated test files
rm -rf .gradle/configuration-cache 2>/dev/null || true
rm -rf .gradle/*/kotlin 2>/dev/null || true
rm -rf ktor-server/ktor-server-plugins/ktor-server-htmx/build 2>/dev/null || true
rm -rf ktor-shared/ktor-htmx/ktor-htmx-html/build 2>/dev/null || true

# Run the specific tests - run modules sequentially to avoid OOM
./gradlew :ktor-server-htmx:jvmTest --tests "HxRoutingTest" --no-daemon --no-configuration-cache 2>&1 | tee /tmp/test_output1.txt
test_status1=${PIPESTATUS[0]}

./gradlew :ktor-htmx-html:jvmTest --tests "HxAttributesTest" --no-daemon --no-configuration-cache 2>&1 | tee /tmp/test_output2.txt
test_status2=${PIPESTATUS[0]}

# Combine outputs
cat /tmp/test_output1.txt /tmp/test_output2.txt > /tmp/test_output.txt

# Both tests must pass
if [ $test_status1 -eq 0 ] && [ $test_status2 -eq 0 ]; then
    test_status=0
else
    test_status=1
fi

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
