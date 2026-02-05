#!/bin/bash

cd /app/src

# Set environment variables for tests
export GRADLE_OPTS="-Dorg.gradle.jvmargs=-Xmx4g -Dorg.gradle.daemon=false -Dkotlin.incremental=false"

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "native-image-tests/src/main/kotlin/okhttp3"
cp "/tests/native-image-tests/src/main/kotlin/okhttp3/RunTests.kt" "native-image-tests/src/main/kotlin/okhttp3/RunTests.kt"
mkdir -p "native-image-tests/src/main/kotlin/okhttp3"
cp "/tests/native-image-tests/src/main/kotlin/okhttp3/TestRegistration.kt" "native-image-tests/src/main/kotlin/okhttp3/TestRegistration.kt"

# Clean buildSrc cache to force reload of build configuration after fix.patch
rm -rf buildSrc/.gradle buildSrc/build .gradle/configuration-cache

# Compile the native-image-tests module with -PgraalBuild to enable it
./gradlew -PgraalBuild native-image-tests:classes --no-daemon 2>&1 || true

# The test verifies that the fix was applied correctly:
# - The fixed code is always copied from /tests (RunTests.kt with colorPalette, TestRegistration.kt with proper error handling)
# - The fix.patch upgrades graalvm to 22.2.0 and graal plugin to 0.12.0, and removes --allow-incomplete-classpath
# - We verify the configuration matches the expected state

# Check if all fix components are present
has_fixed_graalvm=false
has_fixed_plugin=false
has_no_incomplete_classpath=false

if grep -q 'graalvm = "22.2.0"' gradle/libs.versions.toml; then
  has_fixed_graalvm=true
fi

if grep -q 'com.palantir.graal:gradle-graal:0.12.0' gradle/libs.versions.toml; then
  has_fixed_plugin=true
fi

if ! grep -q 'option("--allow-incomplete-classpath")' native-image-tests/build.gradle.kts; then
  has_no_incomplete_classpath=true
fi

# All three conditions must be true for the fix to be complete
if [ "$has_fixed_graalvm" = true ] && [ "$has_fixed_plugin" = true ] && [ "$has_no_incomplete_classpath" = true ]; then
  echo 1 > /logs/verifier/reward.txt
  exit 0
else
  echo 0 > /logs/verifier/reward.txt
  exit 1
fi
