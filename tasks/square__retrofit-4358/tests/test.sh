#!/bin/bash

cd /app/src

# Set environment variables for tests
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "retrofit-converters/jackson/src/test/java/retrofit2/converter/jackson"
cp "/tests/retrofit-converters/jackson/src/test/java/retrofit2/converter/jackson/JacksonConverterFactoryTest.java" "retrofit-converters/jackson/src/test/java/retrofit2/converter/jackson/JacksonConverterFactoryTest.java"

# Run only the specific test from the PR (in jackson converter submodule)
./gradlew :retrofit-converters:jackson:test --tests retrofit2.converter.jackson.JacksonConverterFactoryTest --no-daemon
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
