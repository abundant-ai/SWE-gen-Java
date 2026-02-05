#!/bin/bash

cd /app/src

# Set environment variables for tests
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
# No test files to copy

# Run specific tests for this PR - the protobuf converter tests
# Build dependencies without running their tests or generating javadoc, then run only the target test
mvn install -DskipTests -Dmaven.javadoc.skip=true -pl retrofit && \
mvn test -Dtest=ProtoConverterFactoryTest -pl retrofit-converters/protobuf
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
