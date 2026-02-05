#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/org/mockito"
cp "/tests/java/org/mockito/AnnotationsAreCopiedFromMockedTypeTest.java" "src/test/java/org/mockito/AnnotationsAreCopiedFromMockedTypeTest.java"
mkdir -p "src/test/java/org/mockito"
cp "/tests/java/org/mockito/MockitoTest.java" "src/test/java/org/mockito/MockitoTest.java"
mkdir -p "src/test/java/org/mockito"
cp "/tests/java/org/mockito/StaticMockingExperimentTest.java" "src/test/java/org/mockito/StaticMockingExperimentTest.java"
mkdir -p "src/test/java/org/mockito/internal"
cp "/tests/java/org/mockito/internal/InvalidStateDetectionTest.java" "src/test/java/org/mockito/internal/InvalidStateDetectionTest.java"
mkdir -p "src/test/java/org/mockito/internal/junit"
cp "/tests/java/org/mockito/internal/junit/JUnitRuleTest.java" "src/test/java/org/mockito/internal/junit/JUnitRuleTest.java"
mkdir -p "src/test/java/org/mockito/internal/progress"
cp "/tests/java/org/mockito/internal/progress/ThreadSafeMockingProgressTest.java" "src/test/java/org/mockito/internal/progress/ThreadSafeMockingProgressTest.java"
mkdir -p "src/test/java/org/mockito/internal/stubbing/defaultanswers"
cp "/tests/java/org/mockito/internal/stubbing/defaultanswers/ReturnsEmptyValuesTest.java" "src/test/java/org/mockito/internal/stubbing/defaultanswers/ReturnsEmptyValuesTest.java"
mkdir -p "src/test/java/org/mockito/internal/util"
cp "/tests/java/org/mockito/internal/util/PrimitivesTest.java" "src/test/java/org/mockito/internal/util/PrimitivesTest.java"
mkdir -p "src/test/java/org/mockitousage/basicapi"
cp "/tests/java/org/mockitousage/basicapi/ResetTest.java" "src/test/java/org/mockitousage/basicapi/ResetTest.java"
mkdir -p "src/test/java/org/mockitousage/bugs"
cp "/tests/java/org/mockitousage/bugs/ActualInvocationHasNullArgumentNPEBugTest.java" "src/test/java/org/mockitousage/bugs/ActualInvocationHasNullArgumentNPEBugTest.java"
mkdir -p "src/test/java/org/mockitousage/bugs/varargs"
cp "/tests/java/org/mockitousage/bugs/varargs/VarargsNotPlayingWithAnyObjectTest.java" "src/test/java/org/mockitousage/bugs/varargs/VarargsNotPlayingWithAnyObjectTest.java"
mkdir -p "src/test/java/org/mockitousage/junitrule"
cp "/tests/java/org/mockitousage/junitrule/StrictJUnitRuleTest.java" "src/test/java/org/mockitousage/junitrule/StrictJUnitRuleTest.java"
mkdir -p "src/test/java/org/mockitousage/junitrunner"
cp "/tests/java/org/mockitousage/junitrunner/SilentRunnerTest.java" "src/test/java/org/mockitousage/junitrunner/SilentRunnerTest.java"
mkdir -p "src/test/java/org/mockitousage/junitrunner"
cp "/tests/java/org/mockitousage/junitrunner/StubbingWarningsJUnitRunnerTest.java" "src/test/java/org/mockitousage/junitrunner/StubbingWarningsJUnitRunnerTest.java"
mkdir -p "src/test/java/org/mockitousage/matchers"
cp "/tests/java/org/mockitousage/matchers/MoreMatchersTest.java" "src/test/java/org/mockitousage/matchers/MoreMatchersTest.java"
mkdir -p "src/test/java/org/mockitousage/misuse"
cp "/tests/java/org/mockitousage/misuse/DescriptiveMessagesOnMisuseTest.java" "src/test/java/org/mockitousage/misuse/DescriptiveMessagesOnMisuseTest.java"
mkdir -p "src/test/java/org/mockitousage/misuse"
cp "/tests/java/org/mockitousage/misuse/DetectingMisusedMatchersTest.java" "src/test/java/org/mockitousage/misuse/DetectingMisusedMatchersTest.java"
mkdir -p "src/test/java/org/mockitousage/misuse"
cp "/tests/java/org/mockitousage/misuse/ExplicitFrameworkValidationTest.java" "src/test/java/org/mockitousage/misuse/ExplicitFrameworkValidationTest.java"
mkdir -p "src/test/java/org/mockitousage/misuse"
cp "/tests/java/org/mockitousage/misuse/InvalidUsageTest.java" "src/test/java/org/mockitousage/misuse/InvalidUsageTest.java"
mkdir -p "src/test/java/org/mockitousage/session"
cp "/tests/java/org/mockitousage/session/MockitoSessionTest.java" "src/test/java/org/mockitousage/session/MockitoSessionTest.java"
mkdir -p "src/test/java/org/mockitousage/stacktrace"
cp "/tests/java/org/mockitousage/stacktrace/ClickableStackTracesWhenFrameworkMisusedTest.java" "src/test/java/org/mockitousage/stacktrace/ClickableStackTracesWhenFrameworkMisusedTest.java"
mkdir -p "src/test/java/org/mockitousage/stacktrace"
cp "/tests/java/org/mockitousage/stacktrace/ModellingDescriptiveMessagesTest.java" "src/test/java/org/mockitousage/stacktrace/ModellingDescriptiveMessagesTest.java"
mkdir -p "src/test/java/org/mockitousage/stacktrace"
cp "/tests/java/org/mockitousage/stacktrace/StackTraceFilteringTest.java" "src/test/java/org/mockitousage/stacktrace/StackTraceFilteringTest.java"
mkdir -p "src/test/java/org/mockitousage/stubbing"
cp "/tests/java/org/mockitousage/stubbing/StubbingWarningsTest.java" "src/test/java/org/mockitousage/stubbing/StubbingWarningsTest.java"
mkdir -p "src/test/java/org/mockitousage/stubbing"
cp "/tests/java/org/mockitousage/stubbing/StubbingWithDelegateTest.java" "src/test/java/org/mockitousage/stubbing/StubbingWithDelegateTest.java"
mkdir -p "src/test/java/org/mockitousage/verification"
cp "/tests/java/org/mockitousage/verification/BasicVerificationTest.java" "src/test/java/org/mockitousage/verification/BasicVerificationTest.java"

# Clean and recompile tests to pick up the copied test files
./gradlew :cleanTest --no-daemon

# Run the specific test files for this PR (in the root project)
./gradlew :test \
  --tests org.mockito.AnnotationsAreCopiedFromMockedTypeTest \
  --tests org.mockito.MockitoTest \
  --tests org.mockito.StaticMockingExperimentTest \
  --tests org.mockito.internal.InvalidStateDetectionTest \
  --tests org.mockito.internal.junit.JUnitRuleTest \
  --tests org.mockito.internal.progress.ThreadSafeMockingProgressTest \
  --tests org.mockito.internal.stubbing.defaultanswers.ReturnsEmptyValuesTest \
  --tests org.mockito.internal.util.PrimitivesTest \
  --tests org.mockitousage.basicapi.ResetTest \
  --tests org.mockitousage.bugs.ActualInvocationHasNullArgumentNPEBugTest \
  --tests org.mockitousage.bugs.varargs.VarargsNotPlayingWithAnyObjectTest \
  --tests org.mockitousage.junitrule.StrictJUnitRuleTest \
  --tests org.mockitousage.junitrunner.SilentRunnerTest \
  --tests org.mockitousage.junitrunner.StubbingWarningsJUnitRunnerTest \
  --tests org.mockitousage.matchers.MoreMatchersTest \
  --tests org.mockitousage.misuse.DescriptiveMessagesOnMisuseTest \
  --tests org.mockitousage.misuse.DetectingMisusedMatchersTest \
  --tests org.mockitousage.misuse.ExplicitFrameworkValidationTest \
  --tests org.mockitousage.misuse.InvalidUsageTest \
  --tests org.mockitousage.session.MockitoSessionTest \
  --tests org.mockitousage.stacktrace.ClickableStackTracesWhenFrameworkMisusedTest \
  --tests org.mockitousage.stacktrace.ModellingDescriptiveMessagesTest \
  --tests org.mockitousage.stacktrace.StackTraceFilteringTest \
  --tests org.mockitousage.stubbing.StubbingWarningsTest \
  --tests org.mockitousage.stubbing.StubbingWithDelegateTest \
  --tests org.mockitousage.verification.BasicVerificationTest \
  --no-daemon
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
