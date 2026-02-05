#!/bin/bash

cd /app/src

# Fix kotlinTest dependency on kotlinx-coroutines-core (0.14 no longer available, use 0.19)
test -f subprojects/kotlinTest/build.gradle && sed -i "s/kotlinx-coroutines-core:0.14/kotlinx-coroutines-core:0.19/" subprojects/kotlinTest/build.gradle || true
test -f subprojects/kotlinTest/kotlinTest.gradle && sed -i "s/kotlinx-coroutines-core:0.14/kotlinx-coroutines-core:0.19/" subprojects/kotlinTest/kotlinTest.gradle || true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/org/mockito/internal/exceptions/stacktrace"
cp "/tests/java/org/mockito/internal/exceptions/stacktrace/ConditionalStackTraceFilterTest.java" "src/test/java/org/mockito/internal/exceptions/stacktrace/ConditionalStackTraceFilterTest.java"
mkdir -p "src/test/java/org/mockito/internal/exceptions/stacktrace"
cp "/tests/java/org/mockito/internal/exceptions/stacktrace/StackTraceFilterTest.java" "src/test/java/org/mockito/internal/exceptions/stacktrace/StackTraceFilterTest.java"
mkdir -p "src/test/java/org/mockito/internal/invocation"
cp "/tests/java/org/mockito/internal/invocation/InvocationImplTest.java" "src/test/java/org/mockito/internal/invocation/InvocationImplTest.java"
mkdir -p "src/test/java/org/mockito/internal/invocation"
cp "/tests/java/org/mockito/internal/invocation/InvocationsFinderTest.java" "src/test/java/org/mockito/internal/invocation/InvocationsFinderTest.java"
mkdir -p "src/test/java/org/mockito/internal/matchers"
cp "/tests/java/org/mockito/internal/matchers/InstanceOfTest.java" "src/test/java/org/mockito/internal/matchers/InstanceOfTest.java"
mkdir -p "src/test/java/org/mockito/internal/util"
cp "/tests/java/org/mockito/internal/util/PrimitivesTest.java" "src/test/java/org/mockito/internal/util/PrimitivesTest.java"
mkdir -p "src/test/java/org/mockito/internal/util"
cp "/tests/java/org/mockito/internal/util/TimerTest.java" "src/test/java/org/mockito/internal/util/TimerTest.java"
mkdir -p "src/test/java/org/mockito/internal/util/collections"
cp "/tests/java/org/mockito/internal/util/collections/ListUtilTest.java" "src/test/java/org/mockito/internal/util/collections/ListUtilTest.java"
mkdir -p "src/test/java/org/mockitousage"
cp "/tests/java/org/mockitousage/IMethods.java" "src/test/java/org/mockitousage/IMethods.java"
mkdir -p "src/test/java/org/mockitousage"
cp "/tests/java/org/mockitousage/MethodsImpl.java" "src/test/java/org/mockitousage/MethodsImpl.java"
mkdir -p "src/test/java/org/mockitousage/basicapi"
cp "/tests/java/org/mockitousage/basicapi/ReplacingObjectMethodsTest.java" "src/test/java/org/mockitousage/basicapi/ReplacingObjectMethodsTest.java"
mkdir -p "src/test/java/org/mockitousage/internal/invocation/realmethod"
cp "/tests/java/org/mockitousage/internal/invocation/realmethod/CleanTraceRealMethodTest.java" "src/test/java/org/mockitousage/internal/invocation/realmethod/CleanTraceRealMethodTest.java"
mkdir -p "src/test/java/org/mockitousage/junitrunner"
cp "/tests/java/org/mockitousage/junitrunner/SilentRunnerTest.java" "src/test/java/org/mockitousage/junitrunner/SilentRunnerTest.java"
mkdir -p "src/test/java/org/mockitousage/junitrunner"
cp "/tests/java/org/mockitousage/junitrunner/StrictRunnerTest.java" "src/test/java/org/mockitousage/junitrunner/StrictRunnerTest.java"
mkdir -p "src/test/java/org/mockitousage/matchers"
cp "/tests/java/org/mockitousage/matchers/MatchersTest.java" "src/test/java/org/mockitousage/matchers/MatchersTest.java"
mkdir -p "src/test/java/org/mockitousage/matchers"
cp "/tests/java/org/mockitousage/matchers/MoreMatchersTest.java" "src/test/java/org/mockitousage/matchers/MoreMatchersTest.java"
mkdir -p "src/test/java/org/mockitousage/matchers"
cp "/tests/java/org/mockitousage/matchers/NewMatchersTest.java" "src/test/java/org/mockitousage/matchers/NewMatchersTest.java"
mkdir -p "src/test/java/org/mockitousage/puzzlers"
cp "/tests/java/org/mockitousage/puzzlers/BridgeMethodPuzzleTest.java" "src/test/java/org/mockitousage/puzzlers/BridgeMethodPuzzleTest.java"
mkdir -p "src/test/java/org/mockitousage/spies"
cp "/tests/java/org/mockitousage/spies/PartialMockingWithSpiesTest.java" "src/test/java/org/mockitousage/spies/PartialMockingWithSpiesTest.java"
mkdir -p "src/test/java/org/mockitousage/spies"
cp "/tests/java/org/mockitousage/spies/SpyingOnInterfacesTest.java" "src/test/java/org/mockitousage/spies/SpyingOnInterfacesTest.java"
mkdir -p "src/test/java/org/mockitousage/stacktrace"
cp "/tests/java/org/mockitousage/stacktrace/StackTraceFilteringTest.java" "src/test/java/org/mockitousage/stacktrace/StackTraceFilteringTest.java"
mkdir -p "src/test/java/org/mockitousage/verification"
cp "/tests/java/org/mockitousage/verification/DescriptiveMessagesWhenVerificationFailsTest.java" "src/test/java/org/mockitousage/verification/DescriptiveMessagesWhenVerificationFailsTest.java"
mkdir -p "src/test/java/org/mockitousage/verification"
cp "/tests/java/org/mockitousage/verification/PrintingVerboseTypesWithArgumentsTest.java" "src/test/java/org/mockitousage/verification/PrintingVerboseTypesWithArgumentsTest.java"
mkdir -p "src/test/java/org/mockitoutil"
cp "/tests/java/org/mockitoutil/Conditions.java" "src/test/java/org/mockitoutil/Conditions.java"
mkdir -p "src/test/java/org/mockitoutil"
cp "/tests/java/org/mockitoutil/JUnitResultAssert.java" "src/test/java/org/mockitoutil/JUnitResultAssert.java"

# Disable buildSrc tests by renaming the test directory temporarily
test -d buildSrc/src/test && mv buildSrc/src/test buildSrc/src/test.disabled || true

# Reapply build fixes
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

# Disable errorprone and kotlinReleaseCoroutinesTest subprojects again
test -d subprojects/errorprone && mv subprojects/errorprone subprojects/errorprone.disabled || true
test -d subprojects/kotlinReleaseCoroutinesTest && mv subprojects/kotlinReleaseCoroutinesTest subprojects/kotlinReleaseCoroutinesTest.disabled || true

# Build main classes and process resources (root project only)
./gradlew :classes :processResources --no-daemon

# Clean and recompile tests to pick up the copied test files
./gradlew :cleanTest :testClasses --no-daemon

# Run the specific test classes for this PR (in root project)
# Note: Old Gradle doesn't support multiple --tests flags, so run them one by one
test_status=0
./gradlew :test --tests org.mockito.internal.exceptions.stacktrace.ConditionalStackTraceFilterTest --no-daemon || test_status=1
./gradlew :test --tests org.mockito.internal.exceptions.stacktrace.StackTraceFilterTest --no-daemon || test_status=1
./gradlew :test --tests org.mockito.internal.invocation.InvocationImplTest --no-daemon || test_status=1
./gradlew :test --tests org.mockito.internal.invocation.InvocationsFinderTest --no-daemon || test_status=1
./gradlew :test --tests org.mockito.internal.matchers.InstanceOfTest --no-daemon || test_status=1
./gradlew :test --tests org.mockito.internal.util.PrimitivesTest --no-daemon || test_status=1
./gradlew :test --tests org.mockito.internal.util.TimerTest --no-daemon || test_status=1
./gradlew :test --tests org.mockito.internal.util.collections.ListUtilTest --no-daemon || test_status=1
./gradlew :test --tests org.mockitousage.basicapi.ReplacingObjectMethodsTest --no-daemon || test_status=1
./gradlew :test --tests org.mockitousage.internal.invocation.realmethod.CleanTraceRealMethodTest --no-daemon || test_status=1
./gradlew :test --tests org.mockitousage.junitrunner.SilentRunnerTest --no-daemon || test_status=1
./gradlew :test --tests org.mockitousage.junitrunner.StrictRunnerTest --no-daemon || test_status=1
./gradlew :test --tests org.mockitousage.matchers.MatchersTest --no-daemon || test_status=1
./gradlew :test --tests org.mockitousage.matchers.MoreMatchersTest --no-daemon || test_status=1
./gradlew :test --tests org.mockitousage.matchers.NewMatchersTest --no-daemon || test_status=1
./gradlew :test --tests org.mockitousage.puzzlers.BridgeMethodPuzzleTest --no-daemon || test_status=1
./gradlew :test --tests org.mockitousage.spies.PartialMockingWithSpiesTest --no-daemon || test_status=1
./gradlew :test --tests org.mockitousage.spies.SpyingOnInterfacesTest --no-daemon || test_status=1
./gradlew :test --tests org.mockitousage.stacktrace.StackTraceFilteringTest --no-daemon || test_status=1
./gradlew :test --tests org.mockitousage.verification.DescriptiveMessagesWhenVerificationFailsTest --no-daemon || test_status=1
./gradlew :test --tests org.mockitousage.verification.PrintingVerboseTypesWithArgumentsTest --no-daemon || test_status=1

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
