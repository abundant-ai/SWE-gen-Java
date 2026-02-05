#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/org/mockito/internal/verification"
cp "/tests/java/org/mockito/internal/verification/SmartPrinterTest.java" "src/test/java/org/mockito/internal/verification/SmartPrinterTest.java"
mkdir -p "src/test/java/org/mockito/internal/verification/checkers"
cp "/tests/java/org/mockito/internal/verification/checkers/MissingInvocationCheckerTest.java" "src/test/java/org/mockito/internal/verification/checkers/MissingInvocationCheckerTest.java"
mkdir -p "src/test/java/org/mockito/internal/verification/checkers"
cp "/tests/java/org/mockito/internal/verification/checkers/MissingInvocationInOrderCheckerTest.java" "src/test/java/org/mockito/internal/verification/checkers/MissingInvocationInOrderCheckerTest.java"
mkdir -p "src/test/java/org/mockitousage/verification"
cp "/tests/java/org/mockitousage/verification/DescriptiveMessagesOnVerificationInOrderErrorsTest.java" "src/test/java/org/mockitousage/verification/DescriptiveMessagesOnVerificationInOrderErrorsTest.java"
mkdir -p "src/test/java/org/mockitousage/verification"
cp "/tests/java/org/mockitousage/verification/DescriptiveMessagesWhenVerificationFailsTest.java" "src/test/java/org/mockitousage/verification/DescriptiveMessagesWhenVerificationFailsTest.java"
mkdir -p "src/test/java/org/mockitousage/verification"
cp "/tests/java/org/mockitousage/verification/VerifyPrintsAllInvocationsOnErrorTest.java" "src/test/java/org/mockitousage/verification/VerifyPrintsAllInvocationsOnErrorTest.java"

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
test -f settings.gradle.kts && sed -i '/kotlinReleaseCoroutinesTest/s|^|//|' settings.gradle.kts || true
test -f settings.gradle && sed -i "/include 'kotlinReleaseCoroutinesTest'/s|^|//|" settings.gradle || true

# Run the specific test files for this PR (main project tests, not subprojects)
./gradlew :test --tests org.mockito.internal.verification.SmartPrinterTest \
  --tests org.mockito.internal.verification.checkers.MissingInvocationCheckerTest \
  --tests org.mockito.internal.verification.checkers.MissingInvocationInOrderCheckerTest \
  --tests org.mockitousage.verification.DescriptiveMessagesOnVerificationInOrderErrorsTest \
  --tests org.mockitousage.verification.DescriptiveMessagesWhenVerificationFailsTest \
  --tests org.mockitousage.verification.VerifyPrintsAllInvocationsOnErrorTest \
  --no-daemon --rerun-tasks
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
