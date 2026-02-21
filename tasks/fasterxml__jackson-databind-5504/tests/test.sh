#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/tools/jackson/databind/deser"
cp "/tests/java/tools/jackson/databind/deser/UnwrappedWithUnknown650Test.java" "src/test/java/tools/jackson/databind/deser/UnwrappedWithUnknown650Test.java"

# Run only the specific test class for this PR (fully qualified to avoid matching tofix package)
./mvnw -B -ff -ntp test -Dtest="tools.jackson.databind.deser.UnwrappedWithUnknown650Test"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
