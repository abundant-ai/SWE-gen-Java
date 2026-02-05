#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "jupiter-tests/src/test/kotlin/org/junit/jupiter/api/kotlin"
cp "/tests/jupiter-tests/src/test/kotlin/org/junit/jupiter/api/kotlin/GenericInlineValueClassTests.kt" "jupiter-tests/src/test/kotlin/org/junit/jupiter/api/kotlin/GenericInlineValueClassTests.kt"
mkdir -p "jupiter-tests/src/test/kotlin/org/junit/jupiter/api/kotlin"
cp "/tests/jupiter-tests/src/test/kotlin/org/junit/jupiter/api/kotlin/PrimitiveWrapperInlineValueClassTests.kt" "jupiter-tests/src/test/kotlin/org/junit/jupiter/api/kotlin/PrimitiveWrapperInlineValueClassTests.kt"

# Run the specific tests for GenericInlineValueClassTests and PrimitiveWrapperInlineValueClassTests
./gradlew :jupiter-tests:test --tests "*GenericInlineValueClassTests" --tests "*PrimitiveWrapperInlineValueClassTests" --no-daemon --no-configuration-cache
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
