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
mkdir -p "src/test/java/org/mockito/internal/stubbing/answers"
cp "/tests/java/org/mockito/internal/stubbing/answers/AbstractThrowsExceptionTest.java" "src/test/java/org/mockito/internal/stubbing/answers/AbstractThrowsExceptionTest.java"
mkdir -p "src/test/java/org/mockito/internal/stubbing/answers"
cp "/tests/java/org/mockito/internal/stubbing/answers/ThrowsExceptionForClassTypeTest.java" "src/test/java/org/mockito/internal/stubbing/answers/ThrowsExceptionForClassTypeTest.java"
mkdir -p "src/test/java/org/mockito/internal/stubbing/answers"
cp "/tests/java/org/mockito/internal/stubbing/answers/ThrowsExceptionTest.java" "src/test/java/org/mockito/internal/stubbing/answers/ThrowsExceptionTest.java"
mkdir -p "src/test/java/org/mockitousage/stubbing"
cp "/tests/java/org/mockitousage/stubbing/StubbingWithThrowablesTest.java" "src/test/java/org/mockitousage/stubbing/StubbingWithThrowablesTest.java"

# Recompile tests to pick up the updated test files
./gradlew testClasses --no-daemon || true

# Run the specific tests for this PR
./gradlew :test --tests org.mockito.internal.stubbing.answers.AbstractThrowsExceptionTest \
  --tests org.mockito.internal.stubbing.answers.ThrowsExceptionForClassTypeTest \
  --tests org.mockito.internal.stubbing.answers.ThrowsExceptionTest \
  --tests org.mockitousage.stubbing.StubbingWithThrowablesTest \
  --no-daemon --rerun-tasks
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
