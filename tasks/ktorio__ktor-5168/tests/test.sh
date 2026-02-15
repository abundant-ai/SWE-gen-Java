#!/bin/bash

cd /app/src

# Environment variables for Gradle tests
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "ktor-client/ktor-client-okhttp/jvm/test/io/ktor/client/engine/okhttp"
cp "/tests/ktor-client/ktor-client-okhttp/jvm/test/io/ktor/client/engine/okhttp/OkHttpHttp2Test.kt" "ktor-client/ktor-client-okhttp/jvm/test/io/ktor/client/engine/okhttp/OkHttpHttp2Test.kt"

# Override Gradle memory settings to prevent OOM
export GRADLE_OPTS="-Xms512m -Xmx3g -XX:MaxMetaspaceSize=512m -Dorg.gradle.daemon=false -Dorg.gradle.parallel=false"

# Clean test results to force rerun
echo "Cleaning test results..."
./gradlew :ktor-client-okhttp:cleanTest --no-daemon --quiet 2>&1 || true

# Run the specific test class using Gradle
echo "Running tests..."
./gradlew :ktor-client-okhttp:jvmTest \
  --tests "io.ktor.client.engine.okhttp.OkHttpHttp2Test" \
  --no-daemon \
  --console=plain \
  2>&1 | tee /tmp/test-output.txt | tail -200
test_status=${PIPESTATUS[0]}

echo "Test exit code: $test_status"
echo "Last 50 lines of full output:"
tail -50 /tmp/test-output.txt

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
