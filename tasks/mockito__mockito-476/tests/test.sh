#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/org/mockito"
cp "/tests/java/org/mockito/MockitoTest.java" "src/test/java/org/mockito/MockitoTest.java"
mkdir -p "src/test/java/org/mockito"
cp "/tests/java/org/mockito/StateMaster.java" "src/test/java/org/mockito/StateMaster.java"
mkdir -p "src/test/java/org/mockito/internal/handler"
cp "/tests/java/org/mockito/internal/handler/MockHandlerImplTest.java" "src/test/java/org/mockito/internal/handler/MockHandlerImplTest.java"
mkdir -p "src/test/java/org/mockito/internal/progress"
cp "/tests/java/org/mockito/internal/progress/ThreadSafeMockingProgressTest.java" "src/test/java/org/mockito/internal/progress/ThreadSafeMockingProgressTest.java"
mkdir -p "src/test/java/org/mockito/internal/stubbing"
cp "/tests/java/org/mockito/internal/stubbing/InvocationContainerImplStubbingTest.java" "src/test/java/org/mockito/internal/stubbing/InvocationContainerImplStubbingTest.java"
mkdir -p "src/test/java/org/mockito/internal/stubbing"
cp "/tests/java/org/mockito/internal/stubbing/InvocationContainerImplTest.java" "src/test/java/org/mockito/internal/stubbing/InvocationContainerImplTest.java"
mkdir -p "src/test/java/org/mockito/internal/verification"
cp "/tests/java/org/mockito/internal/verification/NoMoreInteractionsTest.java" "src/test/java/org/mockito/internal/verification/NoMoreInteractionsTest.java"

# Fix kotlinTest dependency on kotlinx-coroutines-core (0.14 no longer available, use 0.19)
test -f subprojects/kotlinTest/build.gradle && sed -i "s/kotlinx-coroutines-core:0.14/kotlinx-coroutines-core:0.19/" subprojects/kotlinTest/build.gradle || true
test -f subprojects/kotlinTest/kotlinTest.gradle && sed -i "s/kotlinx-coroutines-core:0.14/kotlinx-coroutines-core:0.19/" subprojects/kotlinTest/kotlinTest.gradle || true

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

# Delete test file that was added in bug.patch (it tests buggy code and will fail to compile with HEAD source)
rm -f src/test/java/org/mockito/internal/matchers/VarargCapturingMatcherTest.java

# Recompile tests after copying HEAD test files
./gradlew compileTestJava --no-daemon
if [ $? -ne 0 ]; then
  echo "Test compilation failed"
  test_status=1
else
  # Run the specific test files for this PR (using :test task to run main project tests only)
  ./gradlew :test --tests "org.mockito.MockitoTest" --no-daemon
  test_status=$?
  ./gradlew :test --tests "org.mockito.internal.handler.MockHandlerImplTest" --no-daemon || test_status=$?
  ./gradlew :test --tests "org.mockito.internal.progress.ThreadSafeMockingProgressTest" --no-daemon || test_status=$?
  ./gradlew :test --tests "org.mockito.internal.stubbing.InvocationContainerImplStubbingTest" --no-daemon || test_status=$?
  ./gradlew :test --tests "org.mockito.internal.stubbing.InvocationContainerImplTest" --no-daemon || test_status=$?
  ./gradlew :test --tests "org.mockito.internal.verification.NoMoreInteractionsTest" --no-daemon || test_status=$?
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
