#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "junit-jupiter-engine/src/test/java/org/junit/jupiter/api"
cp "/tests/junit-jupiter-engine/src/test/java/org/junit/jupiter/api/AssertInstanceOfAssertionsTests.java" "junit-jupiter-engine/src/test/java/org/junit/jupiter/api/AssertInstanceOfAssertionsTests.java"

# Run the specific test file using Gradle
./gradlew :junit-jupiter-engine:test --tests org.junit.jupiter.api.AssertInstanceOfAssertionsTests -x compileModule --no-daemon --no-parallel 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
