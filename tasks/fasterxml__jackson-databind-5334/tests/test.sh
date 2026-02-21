#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/tools/jackson/databind/records/tofix"
cp "/tests/java/tools/jackson/databind/records/tofix/JsonIncludeNonDefaultOnRecord5312Test.java" "src/test/java/tools/jackson/databind/records/tofix/JsonIncludeNonDefaultOnRecord5312Test.java"

# Compile main and test sources. On buggy code (without fix), this will fail because
# TokenBuffer and TreeBuildingGenerator are missing required abstract method implementations.
./mvnw -B -ff -ntp -DskipTests compile test-compile
compile_status=$?

if [ $compile_status -ne 0 ]; then
  echo 0 > /logs/verifier/reward.txt
  exit 1
fi

# Run only the specific test class
./mvnw -B -ff -ntp test -Dtest=JsonIncludeNonDefaultOnRecord5312Test
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
