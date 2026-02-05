#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/org/mockito/internal/invocation"
cp "/tests/java/org/mockito/internal/invocation/InvocationBuilder.java" "src/test/java/org/mockito/internal/invocation/InvocationBuilder.java"
mkdir -p "src/test/java/org/mockitousage/internal/debugging"
cp "/tests/java/org/mockitousage/internal/debugging/LocationImplTest.java" "src/test/java/org/mockitousage/internal/debugging/LocationImplTest.java"
mkdir -p "src/test/java/org/mockitousage/junitrule"
cp "/tests/java/org/mockitousage/junitrule/StrictJUnitRuleTest.java" "src/test/java/org/mockitousage/junitrule/StrictJUnitRuleTest.java"
mkdir -p "src/test/java/org/mockitousage/junitrunner"
cp "/tests/java/org/mockitousage/junitrunner/StrictStubsRunnerTest.java" "src/test/java/org/mockitousage/junitrunner/StrictStubsRunnerTest.java"
mkdir -p "src/test/java/org/mockitousage/strictness"
cp "/tests/java/org/mockitousage/strictness/LenientMockAnnotationTest.java" "src/test/java/org/mockitousage/strictness/LenientMockAnnotationTest.java"
mkdir -p "src/test/java/org/mockitousage/strictness"
cp "/tests/java/org/mockitousage/strictness/PotentialStubbingSensitivityTest.java" "src/test/java/org/mockitousage/strictness/PotentialStubbingSensitivityTest.java"
mkdir -p "src/test/java/org/mockitousage/strictness"
cp "/tests/java/org/mockitousage/strictness/ProductionCode.java" "src/test/java/org/mockitousage/strictness/ProductionCode.java"
mkdir -p "src/test/java/org/mockitousage/strictness"
cp "/tests/java/org/mockitousage/strictness/StrictnessPerMockTest.java" "src/test/java/org/mockitousage/strictness/StrictnessPerMockTest.java"
mkdir -p "src/test/java/org/mockitousage/strictness"
cp "/tests/java/org/mockitousage/strictness/StrictnessPerStubbingTest.java" "src/test/java/org/mockitousage/strictness/StrictnessPerStubbingTest.java"
mkdir -p "src/test/java/org/mockitousage/strictness"
cp "/tests/java/org/mockitousage/strictness/StrictnessPerStubbingWithRunnerTest.java" "src/test/java/org/mockitousage/strictness/StrictnessPerStubbingWithRunnerTest.java"
mkdir -p "src/test/java/org/mockitousage/strictness"
cp "/tests/java/org/mockitousage/strictness/StrictnessWhenRuleStrictnessIsUpdatedTest.java" "src/test/java/org/mockitousage/strictness/StrictnessWhenRuleStrictnessIsUpdatedTest.java"
mkdir -p "src/test/java/org/mockitousage/strictness"
cp "/tests/java/org/mockitousage/strictness/StrictnessWithRulesTest.java" "src/test/java/org/mockitousage/strictness/StrictnessWithRulesTest.java"
mkdir -p "src/test/java/org/mockitousage/stubbing"
cp "/tests/java/org/mockitousage/stubbing/StrictStubbingEndToEndTest.java" "src/test/java/org/mockitousage/stubbing/StrictStubbingEndToEndTest.java"
mkdir -p "src/test/java/org/mockitousage/stubbing"
cp "/tests/java/org/mockitousage/stubbing/StrictStubbingTest.java" "src/test/java/org/mockitousage/stubbing/StrictStubbingTest.java"

# Clean and recompile tests to pick up the copied test files
./gradlew :cleanTest --no-daemon

# Run the specific test classes for this PR (in the root project)
./gradlew :test \
  --tests org.mockito.internal.invocation.InvocationBuilder \
  --tests org.mockitousage.internal.debugging.LocationImplTest \
  --tests org.mockitousage.junitrule.StrictJUnitRuleTest \
  --tests org.mockitousage.junitrunner.StrictStubsRunnerTest \
  --tests org.mockitousage.strictness.LenientMockAnnotationTest \
  --tests org.mockitousage.strictness.PotentialStubbingSensitivityTest \
  --tests org.mockitousage.strictness.StrictnessPerMockTest \
  --tests org.mockitousage.strictness.StrictnessPerStubbingTest \
  --tests org.mockitousage.strictness.StrictnessPerStubbingWithRunnerTest \
  --tests org.mockitousage.strictness.StrictnessWhenRuleStrictnessIsUpdatedTest \
  --tests org.mockitousage.strictness.StrictnessWithRulesTest \
  --tests org.mockitousage.stubbing.StrictStubbingEndToEndTest \
  --tests org.mockitousage.stubbing.StrictStubbingTest \
  --no-daemon
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
