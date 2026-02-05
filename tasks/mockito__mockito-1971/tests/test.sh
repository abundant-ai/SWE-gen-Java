#!/bin/bash

cd /app/src

# Fix jcenter issue (JCenter is shut down) and comment out shipkit plugin (requires unavailable dependencies)
sed -i 's|jcenter()|mavenCentral()|g' build.gradle
sed -i '/classpath.*shipkit/s|^|//|' build.gradle
sed -i '/apply plugin.*shipkit/s|^|//|' build.gradle
sed -i '/bintrayUpload/s|^|//|' build.gradle
sed -i '/generatePomFileForJavaLibraryPublication/,/^}/s|^|//|' gradle/java-library.gradle
sed -i '/afterEvaluate.*{/,/^}$/{ /publishing\.publications/,/}/s|^|//| }' build.gradle
sed -i '/^description = /i version = "3.0.0"' build.gradle

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/org/mockito/internal/creation/bytebuddy"
cp "/tests/java/org/mockito/internal/creation/bytebuddy/InlineByteBuddyMockMakerTest.java" "src/test/java/org/mockito/internal/creation/bytebuddy/InlineByteBuddyMockMakerTest.java"

# Recompile tests to pick up the updated test files
./gradlew testClasses --no-daemon || true

# Run the specific test for this PR (InlineByteBuddyMockMakerTest in root project)
./gradlew :test --tests org.mockito.internal.creation.bytebuddy.InlineByteBuddyMockMakerTest \
  --no-daemon --rerun-tasks
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
