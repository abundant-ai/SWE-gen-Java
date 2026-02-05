#!/bin/bash

cd /app/src

# Set environment variables for tests (reduce memory to 1g to avoid crashes)
export GRADLE_OPTS="-Dorg.gradle.jvmargs=-Xmx1g -Dorg.gradle.daemon=false -Dkotlin.incremental=false"

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "okhttp/src/commonTest/kotlin/okhttp3/internal/publicsuffix"
cp "/tests/okhttp/src/commonTest/kotlin/okhttp3/internal/publicsuffix/PublicSuffixDatabaseTest.kt" "okhttp/src/commonTest/kotlin/okhttp3/internal/publicsuffix/PublicSuffixDatabaseTest.kt"

# Clean test build artifacts to force recompilation after copying test files
rm -rf okhttp/build/classes/kotlin/test
rm -rf build/classes/kotlin/test

# Run the specific test class for this PR
./gradlew --no-daemon \
  :okhttp:jvmTest --tests "okhttp3.internal.publicsuffix.PublicSuffixDatabaseTest" \
  --rerun-tasks -Djunit.jupiter.execution.parallel.enabled=false
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
