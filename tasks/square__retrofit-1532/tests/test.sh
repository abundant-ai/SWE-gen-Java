#!/bin/bash

cd /app/src

# Set environment variables for tests
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "retrofit-adapters/java8/src/test/java/retrofit2/adapter/java8"
cp "/tests/retrofit-adapters/java8/src/test/java/retrofit2/adapter/java8/CompletableFutureTest.java" "retrofit-adapters/java8/src/test/java/retrofit2/adapter/java8/CompletableFutureTest.java"
mkdir -p "retrofit-adapters/java8/src/test/java/retrofit2/adapter/java8"
cp "/tests/retrofit-adapters/java8/src/test/java/retrofit2/adapter/java8/Java8CallAdapterFactoryTest.java" "retrofit-adapters/java8/src/test/java/retrofit2/adapter/java8/Java8CallAdapterFactoryTest.java"
mkdir -p "retrofit-adapters/java8/src/test/java/retrofit2/adapter/java8"
cp "/tests/retrofit-adapters/java8/src/test/java/retrofit2/adapter/java8/StringConverterFactory.java" "retrofit-adapters/java8/src/test/java/retrofit2/adapter/java8/StringConverterFactory.java"

# Run specific tests for this PR
# Clean and rebuild all modules to ensure all changes are picked up
mvn clean install -Dmaven.test.skip=true -Dmaven.javadoc.skip=true && \
mvn test -Dtest=CompletableFutureTest,Java8CallAdapterFactoryTest -pl retrofit-adapters/java8
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
