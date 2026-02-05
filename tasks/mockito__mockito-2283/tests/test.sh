#!/bin/bash

cd /app/src

# Fix jcenter issue (JCenter is shut down)
sed -i 's/jcenter()/mavenCentral()/g' build.gradle
sed -i '/gradle-bintray-plugin/d' build.gradle
sed -i '/apply plugin.*bintray/d' gradle/java-publication.gradle
sed -i '/^bintray {/,/^}/d' gradle/java-publication.gradle
sed -i '/bintrayPublish/d' gradle/shipkit.gradle

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/org/mockito/internal/creation/bytebuddy"
cp "/tests/java/org/mockito/internal/creation/bytebuddy/ByteBuddyMockMakerTest.java" "src/test/java/org/mockito/internal/creation/bytebuddy/ByteBuddyMockMakerTest.java"
mkdir -p "src/test/java/org/mockito/internal/creation/bytebuddy"
cp "/tests/java/org/mockito/internal/creation/bytebuddy/InlineByteBuddyMockMakerTest.java" "src/test/java/org/mockito/internal/creation/bytebuddy/InlineByteBuddyMockMakerTest.java"
mkdir -p "src/test/java/org/mockito/internal/creation/bytebuddy"
cp "/tests/java/org/mockito/internal/creation/bytebuddy/InlineDelegateByteBuddyMockMakerTest.java" "src/test/java/org/mockito/internal/creation/bytebuddy/InlineDelegateByteBuddyMockMakerTest.java"
mkdir -p "src/test/java/org/mockitointegration"
cp "/tests/java/org/mockitointegration/NoJUnitDependenciesTest.java" "src/test/java/org/mockitointegration/NoJUnitDependenciesTest.java"

# Recompile tests to pick up the updated test files
./gradlew testClasses --no-daemon || true

# Run the specific tests for this PR
./gradlew :test --tests org.mockito.internal.creation.bytebuddy.ByteBuddyMockMakerTest \
  --tests org.mockito.internal.creation.bytebuddy.InlineByteBuddyMockMakerTest \
  --tests org.mockito.internal.creation.bytebuddy.InlineDelegateByteBuddyMockMakerTest \
  --tests org.mockitointegration.NoJUnitDependenciesTest \
  --no-daemon --rerun-tasks
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
