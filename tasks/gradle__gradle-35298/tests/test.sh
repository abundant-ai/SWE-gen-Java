#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "platforms/core-configuration/declarative-dsl-core/src/test/kotlin/org/gradle/internal/declarativedsl/dom/operations/overlay"
cp "/tests/platforms/core-configuration/declarative-dsl-core/src/test/kotlin/org/gradle/internal/declarativedsl/dom/operations/overlay/DocumentOverlayTest.kt" "platforms/core-configuration/declarative-dsl-core/src/test/kotlin/org/gradle/internal/declarativedsl/dom/operations/overlay/DocumentOverlayTest.kt"
mkdir -p "platforms/core-configuration/declarative-dsl-core/src/test/kotlin/org/gradle/internal/declarativedsl/parsing"
cp "/tests/platforms/core-configuration/declarative-dsl-core/src/test/kotlin/org/gradle/internal/declarativedsl/parsing/BasicParsingTest.kt" "platforms/core-configuration/declarative-dsl-core/src/test/kotlin/org/gradle/internal/declarativedsl/parsing/BasicParsingTest.kt"
mkdir -p "platforms/core-configuration/declarative-dsl-core/src/test/kotlin/org/gradle/internal/declarativedsl/parsing"
cp "/tests/platforms/core-configuration/declarative-dsl-core/src/test/kotlin/org/gradle/internal/declarativedsl/parsing/ErrorParsingTest.kt" "platforms/core-configuration/declarative-dsl-core/src/test/kotlin/org/gradle/internal/declarativedsl/parsing/ErrorParsingTest.kt"
mkdir -p "platforms/core-configuration/declarative-dsl-core/src/test/kotlin/org/gradle/internal/declarativedsl/parsing"
cp "/tests/platforms/core-configuration/declarative-dsl-core/src/test/kotlin/org/gradle/internal/declarativedsl/parsing/ImportTest.kt" "platforms/core-configuration/declarative-dsl-core/src/test/kotlin/org/gradle/internal/declarativedsl/parsing/ImportTest.kt"

# Run specific test classes using Gradle
./gradlew :declarative-dsl-core:test \
  --tests "org.gradle.internal.declarativedsl.dom.operations.overlay.DocumentOverlayTest" \
  --tests "org.gradle.internal.declarativedsl.parsing.BasicParsingTest" \
  --tests "org.gradle.internal.declarativedsl.parsing.ErrorParsingTest" \
  --tests "org.gradle.internal.declarativedsl.parsing.ImportTest"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
