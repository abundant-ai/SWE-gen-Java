#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/org/mockito/internal/exceptions"
cp "/tests/java/org/mockito/internal/exceptions/ReporterTest.java" "src/test/java/org/mockito/internal/exceptions/ReporterTest.java"
mkdir -p "src/test/java/org/mockito/internal/verification/checkers"
cp "/tests/java/org/mockito/internal/verification/checkers/AtLeastXNumberOfInvocationsCheckerTest.java" "src/test/java/org/mockito/internal/verification/checkers/AtLeastXNumberOfInvocationsCheckerTest.java"
mkdir -p "src/test/java/org/mockito/internal/verification/checkers"
cp "/tests/java/org/mockito/internal/verification/checkers/NumberOfInvocationsCheckerTest.java" "src/test/java/org/mockito/internal/verification/checkers/NumberOfInvocationsCheckerTest.java"
mkdir -p "src/test/java/org/mockito/internal/verification/checkers"
cp "/tests/java/org/mockito/internal/verification/checkers/NumberOfInvocationsInOrderCheckerTest.java" "src/test/java/org/mockito/internal/verification/checkers/NumberOfInvocationsInOrderCheckerTest.java"
mkdir -p "src/test/java/org/mockitousage/junitrunner"
cp "/tests/java/org/mockitousage/junitrunner/SilentRunnerTest.java" "src/test/java/org/mockitousage/junitrunner/SilentRunnerTest.java"
mkdir -p "src/test/java/org/mockitousage/spies"
cp "/tests/java/org/mockitousage/spies/SpyingOnRealObjectsTest.java" "src/test/java/org/mockitousage/spies/SpyingOnRealObjectsTest.java"
mkdir -p "src/test/java/org/mockitousage/stacktrace"
cp "/tests/java/org/mockitousage/stacktrace/ModellingDescriptiveMessagesTest.java" "src/test/java/org/mockitousage/stacktrace/ModellingDescriptiveMessagesTest.java"
mkdir -p "src/test/java/org/mockitousage/stacktrace"
cp "/tests/java/org/mockitousage/stacktrace/PointingStackTraceToActualInvocationChunkInOrderTest.java" "src/test/java/org/mockitousage/stacktrace/PointingStackTraceToActualInvocationChunkInOrderTest.java"
mkdir -p "src/test/java/org/mockitousage/stacktrace"
cp "/tests/java/org/mockitousage/stacktrace/PointingStackTraceToActualInvocationInOrderTest.java" "src/test/java/org/mockitousage/stacktrace/PointingStackTraceToActualInvocationInOrderTest.java"
mkdir -p "src/test/java/org/mockitousage/verification"
cp "/tests/java/org/mockitousage/verification/DescriptiveMessagesOnVerificationInOrderErrorsTest.java" "src/test/java/org/mockitousage/verification/DescriptiveMessagesOnVerificationInOrderErrorsTest.java"
mkdir -p "src/test/java/org/mockitousage/verification"
cp "/tests/java/org/mockitousage/verification/DescriptiveMessagesWhenTimesXVerificationFailsTest.java" "src/test/java/org/mockitousage/verification/DescriptiveMessagesWhenTimesXVerificationFailsTest.java"
mkdir -p "src/test/java/org/mockitousage/verification"
cp "/tests/java/org/mockitousage/verification/ExactNumberOfTimesVerificationTest.java" "src/test/java/org/mockitousage/verification/ExactNumberOfTimesVerificationTest.java"
mkdir -p "src/test/java/org/mockitousage/verification"
cp "/tests/java/org/mockitousage/verification/SelectedMocksInOrderVerificationTest.java" "src/test/java/org/mockitousage/verification/SelectedMocksInOrderVerificationTest.java"
mkdir -p "src/test/java/org/mockitousage/verification"
cp "/tests/java/org/mockitousage/verification/VerificationWithTimeoutTest.java" "src/test/java/org/mockitousage/verification/VerificationWithTimeoutTest.java"

# Fix jcenter issue (JCenter is shut down) and comment out shipkit plugin (requires unavailable dependencies)
# Also disable kotlinReleaseCoroutinesTest subproject (requires unavailable Kotlin 1.3.0-rc-57 from defunct bintray)
sed -i 's|jcenter()|mavenCentral()|g' build.gradle
test -f subprojects/osgi-test/osgi-test-bundles.gradle && sed -i 's|jcenter()|mavenCentral()|g' subprojects/osgi-test/osgi-test-bundles.gradle || true
sed -i '/classpath.*shipkit/s|^|//|' build.gradle
sed -i '/apply plugin.*shipkit/s|^|//|' build.gradle
sed -i '/bintrayUpload/s|^|//|' build.gradle
sed -i '/generatePomFileForJavaLibraryPublication/,/^}/s|^|//|' gradle/java-library.gradle
sed -i '/afterEvaluate.*{/,/^}$/{ /publishing\.publications/,/}/s|^|//| }' build.gradle
sed -i '/^description = /i version = "3.0.0"' build.gradle
sed -i '/kotlinReleaseCoroutinesTest/s|^|//|' settings.gradle.kts

# Run the specific test files for this PR (main project tests, not subprojects)
./gradlew :test --tests org.mockito.internal.exceptions.ReporterTest \
  --tests org.mockito.internal.verification.checkers.AtLeastXNumberOfInvocationsCheckerTest \
  --tests org.mockito.internal.verification.checkers.NumberOfInvocationsCheckerTest \
  --tests org.mockito.internal.verification.checkers.NumberOfInvocationsInOrderCheckerTest \
  --tests org.mockitousage.junitrunner.SilentRunnerTest \
  --tests org.mockitousage.spies.SpyingOnRealObjectsTest \
  --tests org.mockitousage.stacktrace.ModellingDescriptiveMessagesTest \
  --tests org.mockitousage.stacktrace.PointingStackTraceToActualInvocationChunkInOrderTest \
  --tests org.mockitousage.stacktrace.PointingStackTraceToActualInvocationInOrderTest \
  --tests org.mockitousage.verification.DescriptiveMessagesOnVerificationInOrderErrorsTest \
  --tests org.mockitousage.verification.DescriptiveMessagesWhenTimesXVerificationFailsTest \
  --tests org.mockitousage.verification.ExactNumberOfTimesVerificationTest \
  --tests org.mockitousage.verification.SelectedMocksInOrderVerificationTest \
  --tests org.mockitousage.verification.VerificationWithTimeoutTest \
  --no-daemon --rerun-tasks
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
