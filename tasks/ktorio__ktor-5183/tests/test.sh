#!/bin/bash

cd /app/src

# Environment variables for Gradle tests
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "ktor-server/ktor-server-netty/jvm/test/io/ktor/tests/server/netty"
cp "/tests/ktor-server/ktor-server-netty/jvm/test/io/ktor/tests/server/netty/NettyConfigurationTest.kt" "ktor-server/ktor-server-netty/jvm/test/io/ktor/tests/server/netty/NettyConfigurationTest.kt"
mkdir -p "ktor-server/ktor-server-netty/jvm/test/io/ktor/tests/server/netty"
cp "/tests/ktor-server/ktor-server-netty/jvm/test/io/ktor/tests/server/netty/NettyEngineTest.kt" "ktor-server/ktor-server-netty/jvm/test/io/ktor/tests/server/netty/NettyEngineTest.kt"
mkdir -p "ktor-server/ktor-server-netty/jvm/test/io/ktor/tests/server/netty"
cp "/tests/ktor-server/ktor-server-netty/jvm/test/io/ktor/tests/server/netty/NettySpecificTest.kt" "ktor-server/ktor-server-netty/jvm/test/io/ktor/tests/server/netty/NettySpecificTest.kt"

# Override Gradle memory settings to prevent OOM
export GRADLE_OPTS="-Xms512m -Xmx3g -XX:MaxMetaspaceSize=512m -Dorg.gradle.daemon=false -Dorg.gradle.parallel=false"

# Clean test results to force rerun
echo "Cleaning test results..."
./gradlew :ktor-server-netty:cleanTest --no-daemon --quiet 2>&1 || true

# Run the specific test classes using Gradle
echo "Running tests..."
./gradlew :ktor-server-netty:jvmTest \
  --tests "io.ktor.tests.server.netty.NettyConfigurationTest" \
  --tests "io.ktor.tests.server.netty.NettyEngineTest" \
  --tests "io.ktor.tests.server.netty.NettySpecificTest" \
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
