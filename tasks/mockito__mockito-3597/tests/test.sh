#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "mockito-core/src/test/java/org/mockito/internal/creation/bytebuddy"
cp "/tests/mockito-core/src/test/java/org/mockito/internal/creation/bytebuddy/InlineDelegateByteBuddyMockMakerTest.java" "mockito-core/src/test/java/org/mockito/internal/creation/bytebuddy/InlineDelegateByteBuddyMockMakerTest.java"
mkdir -p "mockito-integration-tests/module-named-tests/src/test/java"
cp "/tests/mockito-integration-tests/module-named-tests/src/test/java/module-info.java" "mockito-integration-tests/module-named-tests/src/test/java/module-info.java"
mkdir -p "mockito-integration-tests/module-named-tests/src/test/java/org/mockito/modulenamedtest"
cp "/tests/mockito-integration-tests/module-named-tests/src/test/java/org/mockito/modulenamedtest/ModuleUseTest.java" "mockito-integration-tests/module-named-tests/src/test/java/org/mockito/modulenamedtest/ModuleUseTest.java"

# Clean and rebuild after fix.patch is applied (needed for resource relocation in JAR)
./gradlew clean build -x test --no-daemon || true

# Run the specific tests for this PR
./gradlew :mockito-core:test --tests org.mockito.internal.creation.bytebuddy.InlineDelegateByteBuddyMockMakerTest --no-daemon
core_status=$?

./gradlew :mockito-integration-tests:module-named-tests:test --tests org.mockito.modulenamedtest.ModuleUseTest --no-daemon
module_status=$?

# Overall test status (both must pass)
if [ $core_status -eq 0 ] && [ $module_status -eq 0 ]; then
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
