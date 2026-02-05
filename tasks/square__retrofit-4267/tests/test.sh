#!/bin/bash

cd /app/src

# Set environment variables for tests
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "retrofit-converters/wire/src/test/java/retrofit2/converter/wire"
cp "/tests/retrofit-converters/wire/src/test/java/retrofit2/converter/wire/CrashingPhone.java" "retrofit-converters/wire/src/test/java/retrofit2/converter/wire/CrashingPhone.java"
mkdir -p "retrofit-converters/wire/src/test/java/retrofit2/converter/wire"
cp "/tests/retrofit-converters/wire/src/test/java/retrofit2/converter/wire/WireConverterFactoryTest.java" "retrofit-converters/wire/src/test/java/retrofit2/converter/wire/WireConverterFactoryTest.java"

# Clean and recompile test classes after copying
./gradlew :retrofit-converters:wire:clean :retrofit-converters:wire:testClasses --no-daemon

# Run only the specific tests from the PR (CrashingPhone is a model, not a test)
./gradlew :retrofit-converters:wire:test --tests retrofit2.converter.wire.WireConverterFactoryTest --no-daemon
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
