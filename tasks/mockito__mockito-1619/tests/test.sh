#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/org/mockito/internal/creation/bytebuddy"
cp "/tests/java/org/mockito/internal/creation/bytebuddy/InlineByteBuddyMockMakerTest.java" "src/test/java/org/mockito/internal/creation/bytebuddy/InlineByteBuddyMockMakerTest.java"
mkdir -p "src/test/java/org/mockito/internal/framework"
cp "/tests/java/org/mockito/internal/framework/DefaultMockitoFrameworkTest.java" "src/test/java/org/mockito/internal/framework/DefaultMockitoFrameworkTest.java"
mkdir -p "subprojects/inline/src/test/java/org/mockitoinline/bugs"
cp "/tests/subprojects/inline/src/test/java/org/mockitoinline/bugs/CyclicMockMethodArgumentMemoryLeakTest.java" "subprojects/inline/src/test/java/org/mockitoinline/bugs/CyclicMockMethodArgumentMemoryLeakTest.java"
mkdir -p "subprojects/inline/src/test/java/org/mockitoinline/bugs"
cp "/tests/subprojects/inline/src/test/java/org/mockitoinline/bugs/SelfSpyReferenceMemoryLeakTest.java" "subprojects/inline/src/test/java/org/mockitoinline/bugs/SelfSpyReferenceMemoryLeakTest.java"

# Run the specific test files for this PR
./gradlew :test \
  --tests org.mockito.internal.creation.bytebuddy.InlineByteBuddyMockMakerTest \
  --tests org.mockito.internal.framework.DefaultMockitoFrameworkTest \
  --tests org.mockitoinline.bugs.CyclicMockMethodArgumentMemoryLeakTest \
  --tests org.mockitoinline.bugs.SelfSpyReferenceMemoryLeakTest \
  --no-daemon --rerun-tasks
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
