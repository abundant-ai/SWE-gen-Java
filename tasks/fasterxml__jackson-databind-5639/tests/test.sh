#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/tools/jackson/databind/type"
cp "/tests/java/tools/jackson/databind/type/WildcardBoundResolve5285Test.java" "src/test/java/tools/jackson/databind/type/WildcardBoundResolve5285Test.java"

# Run only the specific test class
./mvnw -B -ff -ntp test -Dtest=WildcardBoundResolve5285Test -DfailIfNoTests=false
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
