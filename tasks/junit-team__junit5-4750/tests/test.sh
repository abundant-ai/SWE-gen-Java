#!/bin/bash

cd /app/src

# This is an API signature change - the test is that the project compiles successfully
# The BASE state has the buggy interface that doesn't support covariant return types
# The HEAD state (after fix.patch) has the fixed interface that does support covariant return types
./gradlew testClasses --no-daemon --no-configuration-cache
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
