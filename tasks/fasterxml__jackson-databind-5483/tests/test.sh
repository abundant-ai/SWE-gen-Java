#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/tools/jackson/databind/module"
cp "/tests/java/tools/jackson/databind/module/BuilderModuleReuse5481Test.java" "src/test/java/tools/jackson/databind/module/BuilderModuleReuse5481Test.java"

# Run only the specific test class from this PR
./mvnw -B -ntp test -Dtest=BuilderModuleReuse5481Test
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
