#!/bin/bash

cd /app/src

# Set environment variables for tests
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "retrofit/src/test/java/retrofit2"
cp "/tests/retrofit/src/test/java/retrofit2/KotlinSuspendTest.kt" "retrofit/src/test/java/retrofit2/KotlinSuspendTest.kt"

# Run specific tests for this PR - the KotlinSuspendTest
# Build dependencies without running their tests or generating javadoc, then run only the target test
mvn install -DskipTests -Dmaven.javadoc.skip=true -pl retrofit && \
mvn test -Dtest=KotlinSuspendTest -pl retrofit
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
