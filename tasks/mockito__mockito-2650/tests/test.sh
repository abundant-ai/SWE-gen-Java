#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/org/mockito/internal/creation"
cp "/tests/java/org/mockito/internal/creation/MockSettingsImplTest.java" "src/test/java/org/mockito/internal/creation/MockSettingsImplTest.java"
mkdir -p "src/test/java/org/mockitousage/strictness"
cp "/tests/java/org/mockitousage/strictness/StrictnessMockAnnotationTest.java" "src/test/java/org/mockitousage/strictness/StrictnessMockAnnotationTest.java"
cp "/tests/java/org/mockitousage/strictness/StrictnessWithSettingsTest.java" "src/test/java/org/mockitousage/strictness/StrictnessWithSettingsTest.java"

# Recompile tests to pick up the updated test files
./gradlew testClasses --no-daemon || true

# Run the specific tests for this PR
./gradlew :test \
  --tests org.mockito.internal.creation.MockSettingsImplTest \
  --tests org.mockitousage.strictness.StrictnessMockAnnotationTest \
  --tests org.mockitousage.strictness.StrictnessWithSettingsTest \
  --no-daemon --rerun-tasks

test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
