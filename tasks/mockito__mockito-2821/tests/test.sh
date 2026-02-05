#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "subprojects/subclass/src/test/java/org/mockitosubclass"
cp "/tests/subprojects/subclass/src/test/java/org/mockitosubclass/PluginTest.java" "subprojects/subclass/src/test/java/org/mockitosubclass/PluginTest.java"

# Run the specific test for this PR
./gradlew :subclass:test \
  --tests org.mockitosubclass.PluginTest \
  --no-daemon --rerun-tasks

test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
