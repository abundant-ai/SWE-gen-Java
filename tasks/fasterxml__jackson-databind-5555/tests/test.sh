#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/tools/jackson/databind/jsontype"
cp "/tests/java/tools/jackson/databind/jsontype/ExternalPropertyWithArrayShape4277Test.java" "src/test/java/tools/jackson/databind/jsontype/ExternalPropertyWithArrayShape4277Test.java"

# Recompile test sources to pick up the updated test file
mvn -B -ff -ntp test-compile -DskipTests

# Run only the specific test class from this PR
mvn -B -ff -ntp test -Dtest=ExternalPropertyWithArrayShape4277Test -DfailIfNoTests=false
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
