#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/com/fasterxml/jackson/databind/jsonschema"
cp "/tests/java/com/fasterxml/jackson/databind/jsonschema/FormatVisitor5393Test.java" "src/test/java/com/fasterxml/jackson/databind/jsonschema/FormatVisitor5393Test.java"

# Ensure parent POM version points to stable release (SNAPSHOT parent not yet published)
python3 /tmp/fix_parent_pom.py pom.xml

mvn -B -ff -ntp test -Dtest=FormatVisitor5393Test -DfailIfNoTests=false
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
