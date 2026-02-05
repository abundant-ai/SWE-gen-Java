#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "subprojects/errorprone/src/test/java/org/mockito/errorprone/bugpatterns"
cp "/tests/subprojects/errorprone/src/test/java/org/mockito/errorprone/bugpatterns/MockitoNotExtensibleTest.java" "subprojects/errorprone/src/test/java/org/mockito/errorprone/bugpatterns/MockitoNotExtensibleTest.java"

# Run the specific test files for this PR
./gradlew :errorprone:test --tests org.mockito.errorprone.bugpatterns.MockitoNotExtensibleTest \
  --no-daemon --rerun-tasks
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
