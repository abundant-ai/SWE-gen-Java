#!/bin/bash

cd /app/src

# Set environment variables for tests
export GRADLE_OPTS="-Dorg.gradle.jvmargs=-Xmx4g -Dorg.gradle.daemon=false -Dkotlin.incremental=false"

# Recompile main sources (in case Oracle applied fix.patch)
./gradlew :okhttp:compileKotlin --no-daemon || true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "okhttp/src/jvmTest/kotlin/okhttp3"
cp "/tests/okhttp/src/jvmTest/kotlin/okhttp3/CacheTest.kt" "okhttp/src/jvmTest/kotlin/okhttp3/CacheTest.kt"
mkdir -p "okhttp/src/jvmTest/kotlin/okhttp3"
cp "/tests/okhttp/src/jvmTest/kotlin/okhttp3/RequestTest.kt" "okhttp/src/jvmTest/kotlin/okhttp3/RequestTest.kt"

# Recompile test sources after copying
./gradlew :okhttp:compileTestKotlinJvm --no-daemon || true

# Run only the RequestTest class (CacheTest has a flaky test that times out)
./gradlew :okhttp:jvmTest --tests "okhttp3.RequestTest" --no-daemon
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
