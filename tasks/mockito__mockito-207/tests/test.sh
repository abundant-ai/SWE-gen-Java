#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "test/org/mockito/internal/util"
cp "/tests/org/mockito/internal/util/TimerTest.java" "test/org/mockito/internal/util/TimerTest.java"
mkdir -p "test/org/mockito/verification"
cp "/tests/org/mockito/verification/NegativeDurationTest.java" "test/org/mockito/verification/NegativeDurationTest.java"
mkdir -p "test/org/mockito/verification"
cp "/tests/org/mockito/verification/TimeoutTest.java" "test/org/mockito/verification/TimeoutTest.java"

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

# Try to compile main and test code, then run the specific tests
# Note: Gradle 2.4 doesn't support multiple --tests flags, so run them separately and combine results
./gradlew :test --tests org.mockito.internal.util.TimerTest --no-daemon
status1=$?
./gradlew :test --tests org.mockito.verification.NegativeDurationTest --no-daemon
status2=$?
./gradlew :test --tests org.mockito.verification.TimeoutTest --no-daemon
status3=$?

# All tests must pass (status 0) for overall success
if [ $status1 -eq 0 ] && [ $status2 -eq 0 ] && [ $status3 -eq 0 ]; then
    test_status=0
else
    test_status=1
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
