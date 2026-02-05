#!/bin/bash

cd /app/src

# Set environment variables for tests (reduce memory to 2g to avoid crashes)
export GRADLE_OPTS="-Dorg.gradle.jvmargs=-Xmx2g -Dorg.gradle.daemon=false -Dkotlin.incremental=false"

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "android-test/src/androidDeviceTest/java/okhttp/android/test"
cp "/tests/android-test/src/androidDeviceTest/java/okhttp/android/test/OkHttpTest.kt" "android-test/src/androidDeviceTest/java/okhttp/android/test/OkHttpTest.kt"
mkdir -p "android-test/src/androidDeviceTest/java/okhttp/android/test"
cp "/tests/android-test/src/androidDeviceTest/java/okhttp/android/test/SingleAndroidTest.kt" "android-test/src/androidDeviceTest/java/okhttp/android/test/SingleAndroidTest.kt"
mkdir -p "android-test/src/androidDeviceTest/java/okhttp/android/test"
cp "/tests/android-test/src/androidDeviceTest/java/okhttp/android/test/StrictModeTest.kt" "android-test/src/androidDeviceTest/java/okhttp/android/test/StrictModeTest.kt"
mkdir -p "android-test/src/androidDeviceTest/java/okhttp/android/test/alpn"
cp "/tests/android-test/src/androidDeviceTest/java/okhttp/android/test/alpn/AlpnOverrideTest.kt" "android-test/src/androidDeviceTest/java/okhttp/android/test/alpn/AlpnOverrideTest.kt"
mkdir -p "android-test/src/androidDeviceTest/java/okhttp/android/test/letsencrypt"
cp "/tests/android-test/src/androidDeviceTest/java/okhttp/android/test/letsencrypt/LetsEncryptClientTest.kt" "android-test/src/androidDeviceTest/java/okhttp/android/test/letsencrypt/LetsEncryptClientTest.kt"
mkdir -p "android-test/src/androidDeviceTest/java/okhttp/android/test/sni"
cp "/tests/android-test/src/androidDeviceTest/java/okhttp/android/test/sni/SniOverrideTest.kt" "android-test/src/androidDeviceTest/java/okhttp/android/test/sni/SniOverrideTest.kt"

# Simply verify the android-test module is recognized and can compile its main sources
# This validates the DSL configuration fix without needing to build the full test APK
./gradlew --no-daemon :android-test:compileDebugKotlin :android-test:compileDebugJavaWithJavac
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
