#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/tools/jackson/databind/jsontype"
cp "/tests/java/tools/jackson/databind/jsontype/DefaultTypingOverride1391Test.java" "src/test/java/tools/jackson/databind/jsontype/DefaultTypingOverride1391Test.java"

# Remove conflicting tofix version if it exists (from bug.patch renaming the file)
rm -f "src/test/java/tools/jackson/databind/tofix/DefaultTypingOverride1391Test.java"

# Run only the specific test class using fully qualified name to avoid ambiguity
mvn test -Dtest="tools.jackson.databind.jsontype.DefaultTypingOverride1391Test" -B -ntp
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
