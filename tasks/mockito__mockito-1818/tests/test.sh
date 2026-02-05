#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/org/mockito/internal/util"
cp "/tests/java/org/mockito/internal/util/TimerTest.java" "src/test/java/org/mockito/internal/util/TimerTest.java"
mkdir -p "src/test/java/org/mockito/internal/verification"
cp "/tests/java/org/mockito/internal/verification/VerificationOverTimeImplTest.java" "src/test/java/org/mockito/internal/verification/VerificationOverTimeImplTest.java"
mkdir -p "src/test/java/org/mockito/verification"
cp "/tests/java/org/mockito/verification/TimeoutTest.java" "src/test/java/org/mockito/verification/TimeoutTest.java"
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

# Run the specific tests for this PR (use :test to target root project only)
./gradlew :test --tests org.mockito.internal.util.TimerTest \
  --tests org.mockito.internal.verification.VerificationOverTimeImplTest \
  --tests org.mockito.verification.TimeoutTest \
  --tests org.mockitousage.verification.VerificationWithTimeoutTest \
  --no-daemon --rerun-tasks
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
