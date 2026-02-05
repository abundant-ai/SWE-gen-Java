#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/org/mockito"
cp "/tests/java/org/mockito/StaticMockingExperimentTest.java" "src/test/java/org/mockito/StaticMockingExperimentTest.java"
mkdir -p "src/test/java/org/mockito/internal/junit"
cp "/tests/java/org/mockito/internal/junit/ExceptionFactoryTest.java" "src/test/java/org/mockito/internal/junit/ExceptionFactoryTest.java"
mkdir -p "src/test/java/org/mockito/internal/verification"
cp "/tests/java/org/mockito/internal/verification/VerificationOverTimeImplTest.java" "src/test/java/org/mockito/internal/verification/VerificationOverTimeImplTest.java"
mkdir -p "src/test/java/org/mockito/internal/verification/checkers"
cp "/tests/java/org/mockito/internal/verification/checkers/MissingInvocationCheckerTest.java" "src/test/java/org/mockito/internal/verification/checkers/MissingInvocationCheckerTest.java"
mkdir -p "src/test/java/org/mockito/internal/verification/checkers"
cp "/tests/java/org/mockito/internal/verification/checkers/MissingInvocationInOrderCheckerTest.java" "src/test/java/org/mockito/internal/verification/checkers/MissingInvocationInOrderCheckerTest.java"
mkdir -p "src/test/java/org/mockitointegration"
cp "/tests/java/org/mockitointegration/NoJUnitDependenciesTest.java" "src/test/java/org/mockitointegration/NoJUnitDependenciesTest.java"
mkdir -p "src/test/java/org/mockitousage/basicapi"
cp "/tests/java/org/mockitousage/basicapi/UsingVarargsTest.java" "src/test/java/org/mockitousage/basicapi/UsingVarargsTest.java"
mkdir -p "src/test/java/org/mockitousage/matchers"
cp "/tests/java/org/mockitousage/matchers/CustomMatcherDoesYieldCCETest.java" "src/test/java/org/mockitousage/matchers/CustomMatcherDoesYieldCCETest.java"
mkdir -p "src/test/java/org/mockitousage/matchers"
cp "/tests/java/org/mockitousage/matchers/HamcrestMatchersTest.java" "src/test/java/org/mockitousage/matchers/HamcrestMatchersTest.java"
mkdir -p "src/test/java/org/mockitousage/matchers"
cp "/tests/java/org/mockitousage/matchers/MatchersTest.java" "src/test/java/org/mockitousage/matchers/MatchersTest.java"
mkdir -p "src/test/java/org/mockitousage/matchers"
cp "/tests/java/org/mockitousage/matchers/MoreMatchersTest.java" "src/test/java/org/mockitousage/matchers/MoreMatchersTest.java"
mkdir -p "src/test/java/org/mockitousage/matchers"
cp "/tests/java/org/mockitousage/matchers/ReflectionMatchersTest.java" "src/test/java/org/mockitousage/matchers/ReflectionMatchersTest.java"
mkdir -p "src/test/java/org/mockitousage/matchers"
cp "/tests/java/org/mockitousage/matchers/VarargsTest.java" "src/test/java/org/mockitousage/matchers/VarargsTest.java"
mkdir -p "src/test/java/org/mockitousage/stacktrace"
cp "/tests/java/org/mockitousage/stacktrace/ClickableStackTracesTest.java" "src/test/java/org/mockitousage/stacktrace/ClickableStackTracesTest.java"
mkdir -p "src/test/java/org/mockitousage/verification"
cp "/tests/java/org/mockitousage/verification/BasicVerificationInOrderTest.java" "src/test/java/org/mockitousage/verification/BasicVerificationInOrderTest.java"
mkdir -p "src/test/java/org/mockitousage/verification"
cp "/tests/java/org/mockitousage/verification/BasicVerificationTest.java" "src/test/java/org/mockitousage/verification/BasicVerificationTest.java"
mkdir -p "src/test/java/org/mockitousage/verification"
cp "/tests/java/org/mockitousage/verification/DescriptiveMessagesOnVerificationInOrderErrorsTest.java" "src/test/java/org/mockitousage/verification/DescriptiveMessagesOnVerificationInOrderErrorsTest.java"
mkdir -p "src/test/java/org/mockitousage/verification"
cp "/tests/java/org/mockitousage/verification/DescriptiveMessagesWhenVerificationFailsTest.java" "src/test/java/org/mockitousage/verification/DescriptiveMessagesWhenVerificationFailsTest.java"
mkdir -p "src/test/java/org/mockitousage/verification"
cp "/tests/java/org/mockitousage/verification/PrintingVerboseTypesWithArgumentsTest.java" "src/test/java/org/mockitousage/verification/PrintingVerboseTypesWithArgumentsTest.java"
mkdir -p "src/test/java/org/mockitousage/verification"
cp "/tests/java/org/mockitousage/verification/VerificationUsingMatchersTest.java" "src/test/java/org/mockitousage/verification/VerificationUsingMatchersTest.java"

# Run the specific test files for this PR
./gradlew :test \
  --tests org.mockito.StaticMockingExperimentTest \
  --tests org.mockito.internal.junit.ExceptionFactoryTest \
  --tests org.mockito.internal.verification.VerificationOverTimeImplTest \
  --tests org.mockito.internal.verification.checkers.MissingInvocationCheckerTest \
  --tests org.mockito.internal.verification.checkers.MissingInvocationInOrderCheckerTest \
  --tests org.mockitointegration.NoJUnitDependenciesTest \
  --tests org.mockitousage.basicapi.UsingVarargsTest \
  --tests org.mockitousage.matchers.CustomMatcherDoesYieldCCETest \
  --tests org.mockitousage.matchers.HamcrestMatchersTest \
  --tests org.mockitousage.matchers.MatchersTest \
  --tests org.mockitousage.matchers.MoreMatchersTest \
  --tests org.mockitousage.matchers.ReflectionMatchersTest \
  --tests org.mockitousage.matchers.VarargsTest \
  --tests org.mockitousage.stacktrace.ClickableStackTracesTest \
  --tests org.mockitousage.verification.BasicVerificationInOrderTest \
  --tests org.mockitousage.verification.BasicVerificationTest \
  --tests org.mockitousage.verification.DescriptiveMessagesOnVerificationInOrderErrorsTest \
  --tests org.mockitousage.verification.DescriptiveMessagesWhenVerificationFailsTest \
  --tests org.mockitousage.verification.PrintingVerboseTypesWithArgumentsTest \
  --tests org.mockitousage.verification.VerificationUsingMatchersTest \
  --no-daemon --rerun-tasks
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
