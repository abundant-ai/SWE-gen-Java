#!/bin/bash

cd /app/src

# Fix kotlinTest dependency on kotlinx-coroutines-core (0.14 no longer available, use 0.19)
# This needs to be done here because the fix.patch/oracle applies it
test -f subprojects/kotlinTest/build.gradle && sed -i "s/kotlinx-coroutines-core:0.14/kotlinx-coroutines-core:0.19/" subprojects/kotlinTest/build.gradle || true
test -f subprojects/kotlinTest/kotlinTest.gradle && sed -i "s/kotlinx-coroutines-core:0.14/kotlinx-coroutines-core:0.19/" subprojects/kotlinTest/kotlinTest.gradle || true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/org/mockito/internal/util"
cp "/tests/java/org/mockito/internal/util/PlatformTest.java" "src/test/java/org/mockito/internal/util/PlatformTest.java"

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

# Run the specific test class for this PR (in root project)
./gradlew :test \
  --tests org.mockito.internal.util.PlatformTest \
  --no-daemon
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
