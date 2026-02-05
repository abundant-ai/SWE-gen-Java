#!/bin/bash

cd /app/src

# Set environment variables for tests
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "retrofit-response-type-keeper/src/test/kotlin/retrofit2/keeper"
cp "/tests/retrofit-response-type-keeper/src/test/kotlin/retrofit2/keeper/RetrofitResponseTypeKeepProcessorTest.kt" "retrofit-response-type-keeper/src/test/kotlin/retrofit2/keeper/RetrofitResponseTypeKeepProcessorTest.kt"

# Touch the files to update timestamps so Gradle recognizes the changes
touch "retrofit-response-type-keeper/src/test/kotlin/retrofit2/keeper/RetrofitResponseTypeKeepProcessorTest.kt"

# Clean and recompile test classes after copying
rm -rf retrofit-response-type-keeper/build/
./gradlew :retrofit-response-type-keeper:compileTestKotlin --no-daemon

# Run only the specific test class
./gradlew :retrofit-response-type-keeper:test --tests "retrofit2.keeper.RetrofitResponseTypeKeepProcessorTest" --no-daemon
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
