#!/bin/bash

cd /app/src

export TESTCONTAINERS_RYUK_DISABLED=true
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "http-client-tck/src/main/java/io/micronaut/http/client/tck/tests"
cp "/tests/http-client-tck/src/main/java/io/micronaut/http/client/tck/tests/HeadersTest.java" "http-client-tck/src/main/java/io/micronaut/http/client/tck/tests/HeadersTest.java"
mkdir -p "http-server-tck/src/main/java/io/micronaut/http/server/tck/tests"
cp "/tests/http-server-tck/src/main/java/io/micronaut/http/server/tck/tests/HeadersTest.java" "http-server-tck/src/main/java/io/micronaut/http/server/tck/tests/HeadersTest.java"

# Update timestamps to force Gradle to detect changes
touch http-client-tck/src/main/java/io/micronaut/http/client/tck/tests/*.java
touch http-server-tck/src/main/java/io/micronaut/http/server/tck/tests/*.java

# Remove compiled classes to force recompilation with the new test files
rm -rf http-client-tck/build/classes/java/main/io/micronaut/http/client/tck/tests/*.class
rm -rf http-server-tck/build/classes/java/main/io/micronaut/http/server/tck/tests/*.class

# Run the TCK tests through the test-suite modules
# The test-suite modules have JUnit Suite classes that discover and run all TCK tests
# We filter to run only the HeadersTest using JUnit's test filtering
./gradlew \
  :test-suite-http-client-tck-netty:cleanTest :test-suite-http-client-tck-netty:test \
  --tests "*HeadersTest" \
  :test-suite-http-server-tck-netty:cleanTest :test-suite-http-server-tck-netty:test \
  --tests "*HeadersTest" \
  --no-daemon --console=plain
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
