#!/bin/bash

cd /app/src

# Fix kotlinTest dependency on kotlinx-coroutines-core (0.14 no longer available, use 0.19)
# This needs to be done here because the fix.patch/oracle applies it
test -f subprojects/kotlinTest/build.gradle && sed -i "s/kotlinx-coroutines-core:0.14/kotlinx-coroutines-core:0.19/" subprojects/kotlinTest/build.gradle || true
test -f subprojects/kotlinTest/kotlinTest.gradle && sed -i "s/kotlinx-coroutines-core:0.14/kotlinx-coroutines-core:0.19/" subprojects/kotlinTest/kotlinTest.gradle || true

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
mkdir -p "subprojects/testng/src/test/java/org/mockitousage/testng"
cp "/tests/subprojects/testng/src/test/java/org/mockitousage/testng/ResetMocksInParentTestClassTooTest.java" "subprojects/testng/src/test/java/org/mockitousage/testng/ResetMocksInParentTestClassTooTest.java"

# Disable buildSrc tests by renaming the test directory temporarily
test -d buildSrc/src/test && mv buildSrc/src/test buildSrc/src/test.disabled || true

# Reapply build fixes (fix.patch may have undone some of these)
# Empty out gradle/publish.gradle (it's full of bintray references which are no longer available)
test -f gradle/publish.gradle && echo "// Disabled - bintray is no longer available" > gradle/publish.gradle || true

sed -i 's|jcenter()|mavenCentral()|g' build.gradle
(test -f subprojects/osgi-test/osgi-test-bundles.gradle && sed -i 's|jcenter()|mavenCentral()|g' subprojects/osgi-test/osgi-test-bundles.gradle || true)
sed -i '/classpath.*mockito-release-tools/s|^|//|' build.gradle
sed -i '/classpath.*bintray/s|^|//|' build.gradle
sed -i '/classpath.*http-builder/s|^|//|' build.gradle
sed -i '/classpath.*shipkit/s|^|//|' build.gradle
sed -i '/apply plugin.*shipkit/s|^|//|' build.gradle
sed -i '/id.*com.gradle.build-scan/s|^|//|' build.gradle
sed -i '/id.*me.champeau.buildscan-recipes/s|^|//|' build.gradle
sed -i '/apply plugin.*me.champeau.buildscan-recipes/s|^|//|' build.gradle
sed -i '/buildScan {/,/^}/s|^|//|' build.gradle
sed -i '/release\.gradle/s|^|//|' build.gradle
sed -i '/release\.mustRunAfter/s|^|//|' build.gradle
sed -i '/publishable-java-library\.gradle/s|^|//|' build.gradle
sed -i '/bintrayUpload/s|^|//|' build.gradle
sed -i '/afterEvaluate.*{/,/^}$/{ /publishing\.publications/,/}/s|^|//| }' build.gradle
grep -q '^version = ' build.gradle || sed -i '/^description = /i version = "3.0.0"' build.gradle
sed -i '/classpath.*errorprone/s|^|//|' build.gradle
sed -i '/apply from.*errorprone/s|^|//|' build.gradle
sed -i '/apply plugin.*errorprone/s|^|//|' build.gradle
sed -i '/errorprone libraries\.errorprone/s|^|//|' build.gradle
sed -i '/coverage\.gradle/s|^|//|' build.gradle
(test -f subprojects/extTest/extTest.gradle && sed -i '/dependsOn.*publishToMavenLocal/s|^|//|' subprojects/extTest/extTest.gradle || true)
(test -f settings.gradle && sed -i "s/include 'errorprone'/\\/\\/ include 'errorprone'/" settings.gradle || true)

# Apply java plugin to root project but skip jar task
sed -i '/^group = /i apply plugin: '\''java'\''' build.gradle

# Disable errorprone and kotlinReleaseCoroutinesTest subprojects again
test -d subprojects/errorprone && mv subprojects/errorprone subprojects/errorprone.disabled || true
test -d subprojects/kotlinReleaseCoroutinesTest && mv subprojects/kotlinReleaseCoroutinesTest subprojects/kotlinReleaseCoroutinesTest.disabled || true

# Build the root mockito project classes first, skipping jar task
./gradlew :classes -x :jar --no-daemon

# Clean and recompile tests to pick up the copied test files
./gradlew :cleanTest --no-daemon

# Run the specific test classes for this PR (run in root project only)
./gradlew :test \
  --tests org.mockito.MockitoTest \
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
  --no-daemon

test_status=$?

# Also run the testng subproject test
if [ $test_status -eq 0 ]; then
  ./gradlew :testng:test \
    --tests org.mockitousage.testng.ResetMocksInParentTestClassTooTest \
    --no-daemon
  test_status=$?
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
