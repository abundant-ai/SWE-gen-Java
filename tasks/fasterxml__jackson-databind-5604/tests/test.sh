#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/tools/jackson/databind/introspect"
cp "/tests/java/tools/jackson/databind/introspect/AccessorNamingForBuilderTest.java" "src/test/java/tools/jackson/databind/introspect/AccessorNamingForBuilderTest.java"

./mvnw -B -ntp test -Dtest=AccessorNamingForBuilderTest -DfailIfNoTests=false
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
