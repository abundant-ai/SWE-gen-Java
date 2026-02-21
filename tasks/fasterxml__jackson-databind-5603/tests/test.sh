#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/tools/jackson/databind/convert"
cp "/tests/java/tools/jackson/databind/convert/ConverterFromInterface2617Test.java" "src/test/java/tools/jackson/databind/convert/ConverterFromInterface2617Test.java"

# Remove the tofix version (from bug.patch) to avoid conflicts with the same class name
rm -f "src/test/java/tools/jackson/databind/tofix/ConverterFromInterface2617Test.java"

# Run only the specific test class using fully qualified name to avoid package conflicts
mvn -B -ff -ntp test -Dtest="tools.jackson.databind.convert.ConverterFromInterface2617Test"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
