#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "resilience4j-all/src/test/java/io/github/resilience4j/decorators"
cp "/tests/resilience4j-all/src/test/java/io/github/resilience4j/decorators/DecoratorsTest.java" "resilience4j-all/src/test/java/io/github/resilience4j/decorators/DecoratorsTest.java"
mkdir -p "resilience4j-core/src/test/java/io/github/resilience4j/core"
cp "/tests/resilience4j-core/src/test/java/io/github/resilience4j/core/CheckedFunctionUtilsTest.java" "resilience4j-core/src/test/java/io/github/resilience4j/core/CheckedFunctionUtilsTest.java"
cp "/tests/resilience4j-core/src/test/java/io/github/resilience4j/core/FunctionUtilsTest.java" "resilience4j-core/src/test/java/io/github/resilience4j/core/FunctionUtilsTest.java"

# Run the specific test classes across the relevant modules
./gradlew :resilience4j-all:test \
          --tests io.github.resilience4j.decorators.DecoratorsTest \
          --no-daemon
test_status=$?

if [ $test_status -eq 0 ]; then
  ./gradlew :resilience4j-core:test \
            --tests io.github.resilience4j.core.CheckedFunctionUtilsTest \
            --tests io.github.resilience4j.core.FunctionUtilsTest \
            --no-daemon
  test_status=$?
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
