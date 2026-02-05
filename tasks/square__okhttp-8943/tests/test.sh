#!/bin/bash

cd /app/src

# Set environment variables for tests (reduce memory to 2g to avoid crashes)
export GRADLE_OPTS="-Dorg.gradle.jvmargs=-Xmx2g -Dorg.gradle.daemon=false -Dkotlin.incremental=false"

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "okhttp-zstd/src/test/java/okhttp3/zstd"
cp "/tests/okhttp-zstd/src/test/java/okhttp3/zstd/ZstdInterceptorTest.kt" "okhttp-zstd/src/test/java/okhttp3/zstd/ZstdInterceptorTest.kt"
mkdir -p "okhttp-zstd/src/test/java/okhttp3/zstd"
cp "/tests/okhttp-zstd/src/test/java/okhttp3/zstd/ZstdTestMain.kt" "okhttp-zstd/src/test/java/okhttp3/zstd/ZstdTestMain.kt"

# CRITICAL: Recompile test sources after copying to ensure Gradle picks up the changes
rm -rf okhttp-zstd/build/classes/kotlin/test
rm -rf build/classes/kotlin/test
./gradlew --no-daemon :okhttp-zstd:compileTestKotlin

# Run both test classes for this PR
./gradlew --no-daemon :okhttp-zstd:test --tests "okhttp3.zstd.ZstdInterceptorTest" --tests "okhttp3.zstd.ZstdTestMain" --rerun-tasks -Djunit.jupiter.execution.parallel.enabled=false
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
