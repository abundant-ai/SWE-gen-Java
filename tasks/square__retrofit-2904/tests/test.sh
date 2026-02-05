#!/bin/bash

cd /app/src

# Set environment variables for tests
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "retrofit-converters/guava/src/test/java/retrofit/converter/guava"
cp "/tests/retrofit-converters/guava/src/test/java/retrofit/converter/guava/GuavaOptionalConverterFactoryTest.java" "retrofit-converters/guava/src/test/java/retrofit/converter/guava/GuavaOptionalConverterFactoryTest.java"
mkdir -p "retrofit-converters/java8/src/test/java/retrofit/converter/java8"
cp "/tests/retrofit-converters/java8/src/test/java/retrofit/converter/java8/Java8OptionalConverterFactoryTest.java" "retrofit-converters/java8/src/test/java/retrofit/converter/java8/Java8OptionalConverterFactoryTest.java"

# Run specific tests for this PR
# Clean and rebuild all modules to ensure all changes are picked up
mvn clean install -DskipTests -Dmaven.javadoc.skip=true && \
mvn test -Dtest=GuavaOptionalConverterFactoryTest -pl retrofit-converters/guava && \
mvn test -Dtest=Java8OptionalConverterFactoryTest -pl retrofit-converters/java8
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
