#!/bin/bash

cd /app/src

# Fix kotlinTest dependency on kotlinx-coroutines-core (0.14 no longer available, use 0.19)
test -f subprojects/kotlinTest/build.gradle && sed -i "s/kotlinx-coroutines-core:0.14/kotlinx-coroutines-core:0.19/" subprojects/kotlinTest/build.gradle || true
test -f subprojects/kotlinTest/kotlinTest.gradle && sed -i "s/kotlinx-coroutines-core:0.14/kotlinx-coroutines-core:0.19/" subprojects/kotlinTest/kotlinTest.gradle || true

# No test files to copy for this PR (deprecation-only change)

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

# Verify that deprecations were applied correctly by checking:
# 1. Whitebox.java should NOT exist (it was removed in the fix)
# 2. JUnitFailureHacker should have @Deprecated annotation
# 3. VerboseMockitoJUnitRunner should have @Deprecated annotation
# 4. WhiteboxTest.java should NOT exist (it was removed in the fix)

test_status=0

# Check that Whitebox.java does NOT exist (buggy state has it, fixed state removes it)
if [ -f "src/main/java/org/mockito/internal/util/reflection/Whitebox.java" ]; then
  echo "FAIL: Whitebox.java should not exist (should be removed)" >&2
  test_status=1
fi

# Check that WhiteboxTest.java does NOT exist (buggy state has it, fixed state removes it)
if [ -f "src/test/java/org/mockito/internal/util/reflection/WhiteboxTest.java" ]; then
  echo "FAIL: WhiteboxTest.java should not exist (should be removed)" >&2
  test_status=1
fi

# Check that JUnitFailureHacker has @Deprecated annotation
if ! grep -q "^@Deprecated" src/main/java/org/mockito/internal/util/junit/JUnitFailureHacker.java; then
  echo "FAIL: JUnitFailureHacker should have @Deprecated annotation" >&2
  test_status=1
fi

# Check that VerboseMockitoJUnitRunner has @Deprecated annotation
if ! grep -q "^@Deprecated" src/main/java/org/mockito/runners/VerboseMockitoJUnitRunner.java; then
  echo "FAIL: VerboseMockitoJUnitRunner should have @Deprecated annotation" >&2
  test_status=1
fi

# Also verify the build compiles successfully
./gradlew :classes :processResources --no-daemon || test_status=1

if [ $test_status -eq 0 ]; then
  echo "PASS: All deprecation checks passed and build succeeded" >&2
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
