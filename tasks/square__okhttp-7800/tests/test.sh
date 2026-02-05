#!/bin/bash

cd /app/src

# Set environment variables for tests (reduce memory to 1g to avoid crashes)
export GRADLE_OPTS="-Dorg.gradle.jvmargs=-Xmx1g -Dorg.gradle.daemon=false -Dkotlin.incremental=false"
export OKHTTP_ROOT=/app/src

# Workaround: Ensure kotlinSerialization is in buildscript classpath if plugin is used
if grep -q 'kotlin("plugin.serialization")' okhttp/build.gradle.kts; then
  if ! grep -q 'classpath(libs.gradlePlugin.kotlinSerialization)' build.gradle.kts; then
    sed -i '/classpath(libs.gradlePlugin.kotlin)/a\    classpath(libs.gradlePlugin.kotlinSerialization)' build.gradle.kts
  fi
fi

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "okhttp-testing-support/src/commonMain/kotlin/okhttp3"
cp "/tests/okhttp-testing-support/src/commonMain/kotlin/okhttp3/TestUtilCommon.kt" "okhttp-testing-support/src/commonMain/kotlin/okhttp3/TestUtilCommon.kt"
mkdir -p "okhttp-testing-support/src/jsMain/kotlin/okhttp3"
cp "/tests/okhttp-testing-support/src/jsMain/kotlin/okhttp3/TestUtilJs.kt" "okhttp-testing-support/src/jsMain/kotlin/okhttp3/TestUtilJs.kt"
mkdir -p "okhttp-testing-support/src/jvmMain/kotlin/okhttp3"
# Remove old TestUtil.kt if it exists (bug.patch renamed TestUtilJvm.kt to TestUtil.kt)
rm -f "okhttp-testing-support/src/jvmMain/kotlin/okhttp3/TestUtil.kt"
cp "/tests/okhttp-testing-support/src/jvmMain/kotlin/okhttp3/TestUtilJvm.kt" "okhttp-testing-support/src/jvmMain/kotlin/okhttp3/TestUtilJvm.kt"
mkdir -p "okhttp/src/commonTest/kotlin/okhttp3"
cp "/tests/okhttp/src/commonTest/kotlin/okhttp3/WebPlatformToAsciiTest.kt" "okhttp/src/commonTest/kotlin/okhttp3/WebPlatformToAsciiTest.kt"
# Remove jvmTest versions (bug.patch moved them there, fix.patch creates new ones in commonTest)
rm -f "okhttp/src/jvmTest/java/okhttp3/WebPlatformToAsciiData.kt"
rm -f "okhttp/src/jvmTest/java/okhttp3/WebPlatformToAsciiTest.kt"
rm -f "okhttp/src/jvmTest/resources/web-platform-test-toascii.json"

# Clean test build artifacts to force recompilation after copying test files
rm -rf okhttp/build/classes/kotlin/test
rm -rf okhttp-testing-support/build/classes/kotlin/test
rm -rf build/classes/kotlin/test

# Run the specific test class for this PR
./gradlew --no-daemon \
  :okhttp:jvmTest --tests "okhttp3.WebPlatformToAsciiTest" \
  --rerun-tasks -Djunit.jupiter.execution.parallel.enabled=false
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
