#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/tools/jackson/databind/deser/jdk"
cp "/tests/java/tools/jackson/databind/deser/jdk/StackTraceElementDeserTest.java" "src/test/java/tools/jackson/databind/deser/jdk/StackTraceElementDeserTest.java"

# Recompile test sources after copying updated test file, then run only this test class
mvn -B -ntp test-compile -DskipTests 2>&1 | tail -5

mvn -B -ntp test -Dtest=StackTraceElementDeserTest -DfailIfNoTests=false
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
