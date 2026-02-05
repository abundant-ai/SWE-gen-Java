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
mkdir -p "src/test/java/org/mockito/internal/configuration"
cp "/tests/java/org/mockito/internal/configuration/MockAnnotationProcessorTest.java" "src/test/java/org/mockito/internal/configuration/MockAnnotationProcessorTest.java"
mkdir -p "subprojects/inline/src/test/java/org/mockitoinline"
cp "/tests/subprojects/inline/src/test/java/org/mockitoinline/StaticMockTest.java" "subprojects/inline/src/test/java/org/mockitoinline/StaticMockTest.java"
mkdir -p "subprojects/junitJupiterInlineMockMakerExtensionTest/src/test/java/org/mockitousage"
cp "/tests/subprojects/junitJupiterInlineMockMakerExtensionTest/src/test/java/org/mockitousage/NoExtendsTest.java" "subprojects/junitJupiterInlineMockMakerExtensionTest/src/test/java/org/mockitousage/NoExtendsTest.java"
mkdir -p "subprojects/junitJupiterInlineMockMakerExtensionTest/src/test/resources/META-INF/services"
cp "/tests/subprojects/junitJupiterInlineMockMakerExtensionTest/src/test/resources/META-INF/services/org.junit.jupiter.api.extension.Extension" "subprojects/junitJupiterInlineMockMakerExtensionTest/src/test/resources/META-INF/services/org.junit.jupiter.api.extension.Extension"
mkdir -p "subprojects/junitJupiterInlineMockMakerExtensionTest/src/test/resources"
cp "/tests/subprojects/junitJupiterInlineMockMakerExtensionTest/src/test/resources/junit-platform.properties" "subprojects/junitJupiterInlineMockMakerExtensionTest/src/test/resources/junit-platform.properties"
mkdir -p "subprojects/junitJupiterInlineMockMakerExtensionTest/src/test/resources/mockito-extensions"
cp "/tests/subprojects/junitJupiterInlineMockMakerExtensionTest/src/test/resources/mockito-extensions/org.mockito.plugins.MockMaker" "subprojects/junitJupiterInlineMockMakerExtensionTest/src/test/resources/mockito-extensions/org.mockito.plugins.MockMaker"

# Recompile tests to pick up the updated test files
./gradlew testClasses --no-daemon || true

# Run the specific tests for this PR
# Note: MockAnnotationProcessorTest is in root project, StaticMockTest is in :inline subproject,
# NoExtendsTest is in :junitJupiterInlineMockMakerExtensionTest subproject
./gradlew :test --tests org.mockito.internal.configuration.MockAnnotationProcessorTest \
  :inline:test --tests org.mockitoinline.StaticMockTest \
  :junitJupiterInlineMockMakerExtensionTest:test --tests org.mockitousage.NoExtendsTest \
  --no-daemon --rerun-tasks
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
