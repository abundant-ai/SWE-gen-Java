#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "ktor-server/ktor-server-servlet-jakarta/jvm/test/io/ktor/tests/servlet/jakarta"
cp "/tests/ktor-server/ktor-server-servlet-jakarta/jvm/test/io/ktor/tests/servlet/jakarta/ServletWriterJakartaTest.kt" "ktor-server/ktor-server-servlet-jakarta/jvm/test/io/ktor/tests/servlet/jakarta/ServletWriterJakartaTest.kt"
mkdir -p "ktor-server/ktor-server-servlet/jvm/test/io/ktor/tests/servlet"
cp "/tests/ktor-server/ktor-server-servlet/jvm/test/io/ktor/tests/servlet/ServletWriterTest.kt" "ktor-server/ktor-server-servlet/jvm/test/io/ktor/tests/servlet/ServletWriterTest.kt"
mkdir -p "ktor-server/ktor-server-tests/jvm/test/io/ktor/server/plugins"
cp "/tests/ktor-server/ktor-server-tests/jvm/test/io/ktor/server/plugins/CompressionTest.kt" "ktor-server/ktor-server-tests/jvm/test/io/ktor/server/plugins/CompressionTest.kt"

# Run the specific test classes for this PR
./gradlew :ktor-server:ktor-server-servlet-jakarta:jvmTest --tests "io.ktor.tests.servlet.jakarta.ServletWriterJakartaTest" \
          :ktor-server:ktor-server-servlet:jvmTest --tests "io.ktor.tests.servlet.ServletWriterTest" \
          :ktor-server:ktor-server-tests:jvmTest --tests "io.ktor.server.plugins.CompressionTest" \
          --no-daemon -x apiCheck 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
