#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/org/mockito/internal/creation"
cp "/tests/java/org/mockito/internal/creation/AbstractMockMakerTest.java" "src/test/java/org/mockito/internal/creation/AbstractMockMakerTest.java"
mkdir -p "src/test/java/org/mockito/internal/creation/bytebuddy"
cp "/tests/java/org/mockito/internal/creation/bytebuddy/AbstractByteBuddyMockMakerTest.java" "src/test/java/org/mockito/internal/creation/bytebuddy/AbstractByteBuddyMockMakerTest.java"
mkdir -p "src/test/java/org/mockito/internal/creation/bytebuddy"
cp "/tests/java/org/mockito/internal/creation/bytebuddy/InlineDelegateByteBuddyMockMakerTest.java" "src/test/java/org/mockito/internal/creation/bytebuddy/InlineDelegateByteBuddyMockMakerTest.java"
mkdir -p "src/test/java/org/mockito/internal/creation/proxy"
cp "/tests/java/org/mockito/internal/creation/proxy/ProxyMockMakerTest.java" "src/test/java/org/mockito/internal/creation/proxy/ProxyMockMakerTest.java"

# Recompile tests to pick up the updated test files
./gradlew testClasses --no-daemon || true

# Run the specific tests for this PR
./gradlew :test --tests org.mockito.internal.creation.AbstractMockMakerTest \
  --tests org.mockito.internal.creation.bytebuddy.AbstractByteBuddyMockMakerTest \
  --tests org.mockito.internal.creation.bytebuddy.InlineDelegateByteBuddyMockMakerTest \
  --tests org.mockito.internal.creation.proxy.ProxyMockMakerTest \
  --no-daemon --rerun-tasks
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
