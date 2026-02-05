#!/bin/bash

cd /app/src

# Set environment variables for tests (reduce memory to 2g to avoid crashes)
export GRADLE_OPTS="-Dorg.gradle.jvmargs=-Xmx2g -Dorg.gradle.daemon=false -Dkotlin.incremental=false"

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "okhttp/src/jvmTest/kotlin/okhttp3"
cp "/tests/okhttp/src/jvmTest/kotlin/okhttp3/CallTest.kt" "okhttp/src/jvmTest/kotlin/okhttp3/CallTest.kt"
mkdir -p "okhttp/src/jvmTest/kotlin/okhttp3/internal/http"
cp "/tests/okhttp/src/jvmTest/kotlin/okhttp3/internal/http/SocketFailureTest.kt" "okhttp/src/jvmTest/kotlin/okhttp3/internal/http/SocketFailureTest.kt"

# CRITICAL: Recompile test sources after copying to ensure Gradle picks up the changes
rm -rf okhttp/build/classes/kotlin/jvmTest
rm -rf build/classes/kotlin/jvmTest
./gradlew --no-daemon :okhttp:compileTestKotlinJvm

# Run both test classes for this PR
# SocketFailureTest has @Tag("Slowish") which requires --rerun-tasks to force execution
./gradlew --no-daemon :okhttp:jvmTest --tests "okhttp3.CallTest" --tests "okhttp3.internal.http.SocketFailureTest" --rerun-tasks -Djunit.jupiter.execution.parallel.enabled=false
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
