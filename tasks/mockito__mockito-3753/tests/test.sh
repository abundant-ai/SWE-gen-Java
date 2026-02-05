#!/bin/bash

cd /app/src

# Set environment variables for Android tests
export ANDROID_HOME=${ANDROID_SDK_ROOT}

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "mockito-integration-tests/android-tests/src/androidTest/java/org/mockitousage/androidtest"
cp "/tests/mockito-integration-tests/android-tests/src/androidTest/java/org/mockitousage/androidtest/BasicInstrumentedTests.kt" "mockito-integration-tests/android-tests/src/androidTest/java/org/mockitousage/androidtest/BasicInstrumentedTests.kt"

# Compile the Android instrumented test to verify the fix
# The test uses primitive arrays with generics, which requires proper handling in GenericMetadataSupport
./gradlew :mockito-integration-tests:android-tests:compileDebugAndroidTestKotlin --no-daemon
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
