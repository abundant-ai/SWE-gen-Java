#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/org/mockito/internal/creation/bytebuddy"
cp "/tests/java/org/mockito/internal/creation/bytebuddy/AbstractByteBuddyMockMakerTest.java" "src/test/java/org/mockito/internal/creation/bytebuddy/AbstractByteBuddyMockMakerTest.java"
mkdir -p "src/test/java/org/mockito/internal/creation/bytebuddy"
cp "/tests/java/org/mockito/internal/creation/bytebuddy/SubclassByteBuddyMockMakerTest.java" "src/test/java/org/mockito/internal/creation/bytebuddy/SubclassByteBuddyMockMakerTest.java"
mkdir -p "src/test/java/org/mockito/internal/creation/bytebuddy"
cp "/tests/java/org/mockito/internal/creation/bytebuddy/TypeCachingMockBytecodeGeneratorTest.java" "src/test/java/org/mockito/internal/creation/bytebuddy/TypeCachingMockBytecodeGeneratorTest.java"

# Clean and recompile tests to pick up the copied test files
./gradlew :cleanTest --no-daemon

# Run the specific test classes for this PR
./gradlew :test \
  --tests org.mockito.internal.creation.bytebuddy.AbstractByteBuddyMockMakerTest \
  --tests org.mockito.internal.creation.bytebuddy.SubclassByteBuddyMockMakerTest \
  --tests org.mockito.internal.creation.bytebuddy.TypeCachingMockBytecodeGeneratorTest \
  --no-daemon
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
