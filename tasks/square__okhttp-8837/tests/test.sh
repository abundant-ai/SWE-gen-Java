#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "mockwebserver/src/test/java/mockwebserver3"
cp "/tests/mockwebserver/src/test/java/mockwebserver3/MockResponseSniTest.kt" "mockwebserver/src/test/java/mockwebserver3/MockResponseSniTest.kt"
mkdir -p "okhttp/src/jvmTest/kotlin/okhttp3"
cp "/tests/okhttp/src/jvmTest/kotlin/okhttp3/CallTest.kt" "okhttp/src/jvmTest/kotlin/okhttp3/CallTest.kt"
mkdir -p "okhttp/src/jvmTest/kotlin/okhttp3"
cp "/tests/okhttp/src/jvmTest/kotlin/okhttp3/URLConnectionTest.kt" "okhttp/src/jvmTest/kotlin/okhttp3/URLConnectionTest.kt"
mkdir -p "okhttp/src/jvmTest/kotlin/okhttp3/internal/http2"
cp "/tests/okhttp/src/jvmTest/kotlin/okhttp3/internal/http2/HttpOverHttp2Test.kt" "okhttp/src/jvmTest/kotlin/okhttp3/internal/http2/HttpOverHttp2Test.kt"

# Rebuild test classes to pick up the changes
./gradlew :mockwebserver:testClasses :okhttp:jvmTestClasses --no-daemon --no-configuration-cache -Porg.gradle.java.installations.auto-download=false

# Run the specific test classes from this PR using wildcard patterns
./gradlew :mockwebserver:test :okhttp:jvmTest \
    --tests "*MockResponseSniTest*" \
    --tests "*CallTest*" \
    --tests "*URLConnectionTest*" \
    --tests "*HttpOverHttp2Test*" \
    --no-daemon --no-configuration-cache -Porg.gradle.java.installations.auto-download=false 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
