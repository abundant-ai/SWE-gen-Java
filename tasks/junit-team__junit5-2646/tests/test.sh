#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "junit-jupiter-engine/src/test/java/org/junit/jupiter/api"
cp "/tests/junit-jupiter-engine/src/test/java/org/junit/jupiter/api/DisplayNameGenerationTests.java" "junit-jupiter-engine/src/test/java/org/junit/jupiter/api/DisplayNameGenerationTests.java"
mkdir -p "junit-jupiter-engine/src/test/java/org/junit/jupiter/api"
cp "/tests/junit-jupiter-engine/src/test/java/org/junit/jupiter/api/IndicativeSentencesNestedTestCase.java" "junit-jupiter-engine/src/test/java/org/junit/jupiter/api/IndicativeSentencesNestedTestCase.java"
mkdir -p "junit-jupiter-engine/src/test/java/org/junit/jupiter/api"
cp "/tests/junit-jupiter-engine/src/test/java/org/junit/jupiter/api/IndicativeSentencesTopLevelTestCase.java" "junit-jupiter-engine/src/test/java/org/junit/jupiter/api/IndicativeSentencesTopLevelTestCase.java"

# Rebuild test classes to pick up the changes
./gradlew :junit-jupiter-engine:testClasses -x compileModule --no-daemon --no-parallel

# Run the specific test classes from this PR
./gradlew :junit-jupiter-engine:test \
    --tests org.junit.jupiter.api.DisplayNameGenerationTests \
    --tests org.junit.jupiter.api.IndicativeSentencesNestedTestCase \
    --tests org.junit.jupiter.api.IndicativeSentencesTopLevelTestCase \
    -x compileModule --no-daemon --no-parallel 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
