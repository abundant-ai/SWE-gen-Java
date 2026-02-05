#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "subprojects/groovyInlineTest/src/test/groovy/org/mockito/groovy"
cp "/tests/subprojects/groovyInlineTest/src/test/groovy/org/mockito/groovy/GroovyMockitoTest.groovy" "subprojects/groovyInlineTest/src/test/groovy/org/mockito/groovy/GroovyMockitoTest.groovy"

# Recompile tests to pick up the updated test files
./gradlew testClasses --no-daemon || true

# Run the specific test for this PR
./gradlew :groovyInlineTest:test \
  --tests org.mockito.groovy.GroovyMockitoTest \
  --no-daemon --rerun-tasks

test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
