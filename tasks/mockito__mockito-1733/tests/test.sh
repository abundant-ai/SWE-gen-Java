#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/org/mockito"
cp "/tests/java/org/mockito/MockitoTest.java" "src/test/java/org/mockito/MockitoTest.java"
mkdir -p "src/test/java/org/mockito/internal"
cp "/tests/java/org/mockito/internal/InvalidStateDetectionTest.java" "src/test/java/org/mockito/internal/InvalidStateDetectionTest.java"
mkdir -p "src/test/java/org/mockito/internal/verification"
cp "/tests/java/org/mockito/internal/verification/NoInteractionsTest.java" "src/test/java/org/mockito/internal/verification/NoInteractionsTest.java"
mkdir -p "src/test/java/org/mockitousage/basicapi"
cp "/tests/java/org/mockitousage/basicapi/ResetTest.java" "src/test/java/org/mockitousage/basicapi/ResetTest.java"
mkdir -p "src/test/java/org/mockitousage/customization"
cp "/tests/java/org/mockitousage/customization/BDDMockitoTest.java" "src/test/java/org/mockitousage/customization/BDDMockitoTest.java"
mkdir -p "src/test/java/org/mockitousage/misuse"
cp "/tests/java/org/mockitousage/misuse/InvalidUsageTest.java" "src/test/java/org/mockitousage/misuse/InvalidUsageTest.java"
mkdir -p "src/test/java/org/mockitousage/stacktrace"
cp "/tests/java/org/mockitousage/stacktrace/StackTraceFilteringTest.java" "src/test/java/org/mockitousage/stacktrace/StackTraceFilteringTest.java"
mkdir -p "src/test/java/org/mockitousage/stubbing"
cp "/tests/java/org/mockitousage/stubbing/BasicStubbingTest.java" "src/test/java/org/mockitousage/stubbing/BasicStubbingTest.java"
mkdir -p "src/test/java/org/mockitousage/stubbing"
cp "/tests/java/org/mockitousage/stubbing/StubbingWithThrowablesTest.java" "src/test/java/org/mockitousage/stubbing/StubbingWithThrowablesTest.java"
mkdir -p "src/test/java/org/mockitousage/verification"
cp "/tests/java/org/mockitousage/verification/BasicVerificationInOrderTest.java" "src/test/java/org/mockitousage/verification/BasicVerificationInOrderTest.java"
mkdir -p "src/test/java/org/mockitousage/verification"
cp "/tests/java/org/mockitousage/verification/DescriptiveMessagesWhenVerificationFailsTest.java" "src/test/java/org/mockitousage/verification/DescriptiveMessagesWhenVerificationFailsTest.java"
mkdir -p "src/test/java/org/mockitousage/verification"
cp "/tests/java/org/mockitousage/verification/NoMoreInteractionsVerificationTest.java" "src/test/java/org/mockitousage/verification/NoMoreInteractionsVerificationTest.java"
mkdir -p "src/test/java/org/mockitousage/verification"
cp "/tests/java/org/mockitousage/verification/VerificationOnMultipleMocksUsingMatchersTest.java" "src/test/java/org/mockitousage/verification/VerificationOnMultipleMocksUsingMatchersTest.java"

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
./gradlew :test --tests org.mockito.MockitoTest \
  --tests org.mockito.internal.InvalidStateDetectionTest \
  --tests org.mockito.internal.verification.NoInteractionsTest \
  --tests org.mockitousage.basicapi.ResetTest \
  --tests org.mockitousage.customization.BDDMockitoTest \
  --tests org.mockitousage.misuse.InvalidUsageTest \
  --tests org.mockitousage.stacktrace.StackTraceFilteringTest \
  --tests org.mockitousage.stubbing.BasicStubbingTest \
  --tests org.mockitousage.stubbing.StubbingWithThrowablesTest \
  --tests org.mockitousage.verification.BasicVerificationInOrderTest \
  --tests org.mockitousage.verification.DescriptiveMessagesWhenVerificationFailsTest \
  --tests org.mockitousage.verification.NoMoreInteractionsVerificationTest \
  --tests org.mockitousage.verification.VerificationOnMultipleMocksUsingMatchersTest \
  --no-daemon --rerun-tasks
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
