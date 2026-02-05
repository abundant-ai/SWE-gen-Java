#!/bin/bash

cd /app/src

# Set environment variables for tests
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "retrofit-converters/protobuf/src/test/java/retrofit2/converter/protobuf"
cp "/tests/retrofit-converters/protobuf/src/test/java/retrofit2/converter/protobuf/ProtoConverterFactoryTest.java" "retrofit-converters/protobuf/src/test/java/retrofit2/converter/protobuf/ProtoConverterFactoryTest.java"

# Run only the specific test from the PR (in protobuf converter submodule)
./gradlew :retrofit-converters:protobuf:test --tests retrofit2.converter.protobuf.ProtoConverterFactoryTest --no-daemon
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
