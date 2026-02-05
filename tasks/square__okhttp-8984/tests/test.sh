#!/bin/bash

cd /app/src

# Set environment variables for tests (reduce memory to 2g to avoid crashes)
export GRADLE_OPTS="-Dorg.gradle.jvmargs=-Xmx2g -Dorg.gradle.daemon=false -Dkotlin.incremental=false"

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "okhttp-brotli/src/test/java/okhttp3/brotli"
cp "/tests/okhttp-brotli/src/test/java/okhttp3/brotli/BrotliInterceptorTest.kt" "okhttp-brotli/src/test/java/okhttp3/brotli/BrotliInterceptorTest.kt"
mkdir -p "okhttp-zstd/src/test/java/okhttp3/zstd"
cp "/tests/okhttp-zstd/src/test/java/okhttp3/zstd/ZstdInterceptorJavaTest.java" "okhttp-zstd/src/test/java/okhttp3/zstd/ZstdInterceptorJavaTest.java"
mkdir -p "okhttp-zstd/src/test/java/okhttp3/zstd"
cp "/tests/okhttp-zstd/src/test/java/okhttp3/zstd/ZstdInterceptorTest.kt" "okhttp-zstd/src/test/java/okhttp3/zstd/ZstdInterceptorTest.kt"

# Run specific test classes for this PR
./gradlew --no-daemon \
  :okhttp-brotli:test --tests okhttp3.brotli.BrotliInterceptorTest \
  :okhttp-zstd:test --tests okhttp3.zstd.ZstdInterceptorJavaTest --tests okhttp3.zstd.ZstdInterceptorTest
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
