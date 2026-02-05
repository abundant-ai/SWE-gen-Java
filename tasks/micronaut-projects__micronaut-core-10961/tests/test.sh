#!/bin/bash

cd /app/src

export TESTCONTAINERS_RYUK_DISABLED=true
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "http-client-tck/src/main/java/io/micronaut/http/client/tck/tests"
cp "/tests/http-client-tck/src/main/java/io/micronaut/http/client/tck/tests/ContentLengthHeaderTest.java" "http-client-tck/src/main/java/io/micronaut/http/client/tck/tests/ContentLengthHeaderTest.java"
mkdir -p "http-server-tck/src/main/java/io/micronaut/http/server/tck/tests/filter"
cp "/tests/http-server-tck/src/main/java/io/micronaut/http/server/tck/tests/filter/RequestFilterTest.java" "http-server-tck/src/main/java/io/micronaut/http/server/tck/tests/filter/RequestFilterTest.java"

# Update timestamps to force Gradle to detect changes
touch http-client-tck/src/main/java/io/micronaut/http/client/tck/tests/*.java
touch http-server-tck/src/main/java/io/micronaut/http/server/tck/tests/filter/*.java

# Remove compiled test classes to force recompilation with the new test files
rm -rf http-client-tck/build/classes/java/test/io/micronaut/http/client/tck/tests/*.class
rm -rf http-server-tck/build/classes/java/test/io/micronaut/http/server/tck/tests/filter/*.class

# Run the specific tests
./gradlew :http-client-tck:cleanTest :http-client-tck:test --tests "*ContentLengthHeaderTest" \
          :http-server-tck:cleanTest :http-server-tck:test --tests "*RequestFilterTest" \
          --no-daemon --console=plain
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
