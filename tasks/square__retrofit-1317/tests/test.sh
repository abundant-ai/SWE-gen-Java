#!/bin/bash

cd /app/src

# Set environment variables for tests
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "retrofit-converters/scalars/src/test/java/retrofit"
cp "/tests/retrofit-converters/scalars/src/test/java/retrofit/ScalarsConverterFactoryTest.java" "retrofit-converters/scalars/src/test/java/retrofit/ScalarsConverterFactoryTest.java"

# Run specific tests for this PR
# Clean and rebuild all modules to ensure all changes are picked up (skip samples to avoid compilation errors)
mvn clean install -Dmaven.test.skip=true -Dmaven.javadoc.skip=true -pl '!samples' && \
mvn test -Dtest=ScalarsConverterFactoryTest -pl retrofit-converters/scalars
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
