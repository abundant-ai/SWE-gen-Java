#!/bin/bash

cd /app/src

# Set environment variables for tests (reduce memory to 1g to avoid crashes)
export GRADLE_OPTS="-Dorg.gradle.jvmargs=-Xmx1g -Dorg.gradle.daemon=false -Dkotlin.incremental=false"
export OKHTTP_ROOT=/app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "mockwebserver-deprecated/src/test/java/okhttp3/mockwebserver"
cp "/tests/mockwebserver-deprecated/src/test/java/okhttp3/mockwebserver/MockWebServerTest.java" "mockwebserver-deprecated/src/test/java/okhttp3/mockwebserver/MockWebServerTest.java"
mkdir -p "mockwebserver-junit4/src/test/java/mockwebserver3/junit4"
cp "/tests/mockwebserver-junit4/src/test/java/mockwebserver3/junit4/MockWebServerRuleTest.kt" "mockwebserver-junit4/src/test/java/mockwebserver3/junit4/MockWebServerRuleTest.kt"
mkdir -p "mockwebserver/src/test/java/mockwebserver3"
cp "/tests/mockwebserver/src/test/java/mockwebserver3/CustomDispatcherTest.java" "mockwebserver/src/test/java/mockwebserver3/CustomDispatcherTest.java"
mkdir -p "mockwebserver/src/test/java/mockwebserver3"
cp "/tests/mockwebserver/src/test/java/mockwebserver3/MockWebServerTest.java" "mockwebserver/src/test/java/mockwebserver3/MockWebServerTest.java"
mkdir -p "okhttp/src/test/java/okhttp3"
cp "/tests/okhttp/src/test/java/okhttp3/CallTest.java" "okhttp/src/test/java/okhttp3/CallTest.java"
mkdir -p "okhttp/src/test/java/okhttp3"
cp "/tests/okhttp/src/test/java/okhttp3/DuplexTest.java" "okhttp/src/test/java/okhttp3/DuplexTest.java"
mkdir -p "okhttp/src/test/java/okhttp3/internal/http2"
cp "/tests/okhttp/src/test/java/okhttp3/internal/http2/HttpOverHttp2Test.java" "okhttp/src/test/java/okhttp3/internal/http2/HttpOverHttp2Test.java"

# Clean test build artifacts to force recompilation after copying test files
rm -rf mockwebserver-deprecated/build/classes/kotlin/test
rm -rf mockwebserver-junit4/build/classes/kotlin/test
rm -rf mockwebserver/build/classes/kotlin/test
rm -rf okhttp/build/classes/kotlin/test

# Run the specific test classes for this PR
./gradlew --no-daemon \
  :mockwebserver-deprecated:test --tests "okhttp3.mockwebserver.MockWebServerTest" \
  :mockwebserver-junit4:test --tests "mockwebserver3.junit4.MockWebServerRuleTest" \
  :mockwebserver:test --tests "mockwebserver3.CustomDispatcherTest" \
  --tests "mockwebserver3.MockWebServerTest" \
  :okhttp:test --tests "okhttp3.CallTest" \
  --tests "okhttp3.DuplexTest" \
  --tests "okhttp3.internal.http2.HttpOverHttp2Test" \
  --rerun-tasks -Djunit.jupiter.execution.parallel.enabled=false
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
