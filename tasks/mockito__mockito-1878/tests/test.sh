#!/bin/bash

cd /app/src

# Fix jcenter issue (JCenter is shut down) and comment out shipkit plugin (requires unavailable dependencies)
# Also disable kotlinReleaseCoroutinesTest subproject (requires unavailable Kotlin 1.3.0-rc-57 from defunct bintray)
sed -i 's|jcenter()|mavenCentral()|g' build.gradle
sed -i '/classpath.*shipkit/s|^|//|' build.gradle
sed -i '/apply plugin.*shipkit/s|^|//|' build.gradle
sed -i '/bintrayUpload/s|^|//|' build.gradle
sed -i '/generatePomFileForJavaLibraryPublication/,/^}/s|^|//|' gradle/java-library.gradle
sed -i '/afterEvaluate.*{/,/^}$/{ /publishing\.publications/,/}/s|^|//| }' build.gradle
sed -i '/^description = /i version = "3.0.0"' build.gradle
sed -i '/kotlinReleaseCoroutinesTest/s|^|//|' settings.gradle.kts

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/org/mockito/internal/reporting"
cp "/tests/java/org/mockito/internal/reporting/PluralizerTest.java" "src/test/java/org/mockito/internal/reporting/PluralizerTest.java"
mkdir -p "src/test/java/org/mockitousage/junitrule"
cp "/tests/java/org/mockitousage/junitrule/StrictJUnitRuleTest.java" "src/test/java/org/mockitousage/junitrule/StrictJUnitRuleTest.java"
mkdir -p "src/test/java/org/mockitousage/junitrunner"
cp "/tests/java/org/mockitousage/junitrunner/UnusedStubsExceptionMessageTest.java" "src/test/java/org/mockitousage/junitrunner/UnusedStubsExceptionMessageTest.java"
mkdir -p "src/test/java/org/mockitousage/stubbing"
cp "/tests/java/org/mockitousage/stubbing/StrictStubbingTest.java" "src/test/java/org/mockitousage/stubbing/StrictStubbingTest.java"

# Recompile tests to pick up the updated test files
./gradlew testClasses --no-daemon || true

# Run the specific tests for this PR
./gradlew :test --tests org.mockito.internal.reporting.PluralizerTest \
  --tests org.mockitousage.junitrule.StrictJUnitRuleTest \
  --tests org.mockitousage.junitrunner.UnusedStubsExceptionMessageTest \
  --tests org.mockitousage.stubbing.StrictStubbingTest \
  --no-daemon --rerun-tasks
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
