#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/org/mockito"
cp "/tests/java/org/mockito/MockTest.java" "src/test/java/org/mockito/MockTest.java"
mkdir -p "src/test/java/org/mockitousage/strictness"
cp "/tests/java/org/mockitousage/strictness/StrictnessMockAnnotationTest.java" "src/test/java/org/mockitousage/strictness/StrictnessMockAnnotationTest.java"
mkdir -p "subprojects/junit-jupiter/src/test/java/org/mockitousage"
cp "/tests/subprojects/junit-jupiter/src/test/java/org/mockitousage/ProductionCode.java" "subprojects/junit-jupiter/src/test/java/org/mockitousage/ProductionCode.java"
mkdir -p "subprojects/junit-jupiter/src/test/java/org/mockitousage"
cp "/tests/subprojects/junit-jupiter/src/test/java/org/mockitousage/StrictnessTest.java" "subprojects/junit-jupiter/src/test/java/org/mockitousage/StrictnessTest.java"

# Recompile tests to pick up the updated test files
./gradlew testClasses :junit-jupiter:testClasses --no-daemon || true

# Run main project tests (using empty task name runs root project)
./gradlew :test \
  --tests org.mockito.MockTest \
  --tests org.mockitousage.strictness.StrictnessMockAnnotationTest \
  --no-daemon --rerun-tasks

test_status_1=$?

# junit-jupiter subproject test
./gradlew :junit-jupiter:test \
  --tests org.mockitousage.StrictnessTest \
  --no-daemon --rerun-tasks

test_status_2=$?

# Both test runs must pass
if [ $test_status_1 -eq 0 ] && [ $test_status_2 -eq 0 ]; then
  test_status=0
else
  test_status=1
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
