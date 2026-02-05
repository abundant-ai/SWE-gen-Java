#!/bin/bash

cd /app/src

# Set environment variables for tests
export GRADLE_OPTS="-Dorg.gradle.jvmargs=-Xmx4g -Dorg.gradle.daemon=false -Dkotlin.incremental=false"

# Recompile main sources (in case Oracle applied fix.patch)
./gradlew :okhttp:compileKotlin --no-daemon || true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "okhttp-coroutines/src/test/kotlin/okhttp3/coroutines"
cp "/tests/okhttp-coroutines/src/test/kotlin/okhttp3/coroutines/ExecuteAsyncTest.kt" "okhttp-coroutines/src/test/kotlin/okhttp3/coroutines/ExecuteAsyncTest.kt"
mkdir -p "okhttp/src/test/java/okhttp3/internal/publicsuffix"
cp "/tests/okhttp/src/test/java/okhttp3/internal/publicsuffix/PublicSuffixListGenerator.kt" "okhttp/src/test/java/okhttp3/internal/publicsuffix/PublicSuffixListGenerator.kt"

# Recompile test sources after copying
./gradlew :okhttp-coroutines:compileTestKotlin --no-daemon || true
./gradlew :okhttp:compileTestKotlin --no-daemon || true

# Run only the test class for this PR
# Note: PublicSuffixListGenerator is not a test class, just a utility with an import change
# The actual test is ExecuteAsyncTest (renamed to SuspendCallTest after bug.patch)
./gradlew :okhttp-coroutines:test --tests "okhttp3.coroutines.ExecuteAsyncTest" --no-daemon
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
