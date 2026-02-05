#!/bin/bash

cd /app/src

# Set environment variables for tests
export GRADLE_OPTS="-Dorg.gradle.jvmargs=-Xmx4g -Dorg.gradle.daemon=false -Dkotlin.incremental=false"

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "native-image-tests/src/main/kotlin/okhttp3"
cp "/tests/native-image-tests/src/main/kotlin/okhttp3/PublicSuffixDatabaseTest.kt" "native-image-tests/src/main/kotlin/okhttp3/PublicSuffixDatabaseTest.kt"
mkdir -p "okhttp/src/test/java/okhttp3/internal/publicsuffix"
cp "/tests/okhttp/src/test/java/okhttp3/internal/publicsuffix/PublicSuffixDatabaseTest.kt" "okhttp/src/test/java/okhttp3/internal/publicsuffix/PublicSuffixDatabaseTest.kt"
mkdir -p "okhttp/src/test/java/okhttp3/internal/publicsuffix"
cp "/tests/okhttp/src/test/java/okhttp3/internal/publicsuffix/PublicSuffixListGenerator.kt" "okhttp/src/test/java/okhttp3/internal/publicsuffix/PublicSuffixListGenerator.kt"
mkdir -p "okhttp/src/test/java/okhttp3/internal/publicsuffix"
cp "/tests/okhttp/src/test/java/okhttp3/internal/publicsuffix/ResourcePublicSuffixList.kt" "okhttp/src/test/java/okhttp3/internal/publicsuffix/ResourcePublicSuffixList.kt"
mkdir -p "okhttp/src/test/resources/okhttp3/internal/publicsuffix"
cp "/tests/okhttp/src/test/resources/okhttp3/internal/publicsuffix/NOTICE" "okhttp/src/test/resources/okhttp3/internal/publicsuffix/NOTICE"
mkdir -p "okhttp/src/test/resources/okhttp3/internal/publicsuffix"
cp "/tests/okhttp/src/test/resources/okhttp3/internal/publicsuffix/PublicSuffixDatabase.gz" "okhttp/src/test/resources/okhttp3/internal/publicsuffix/PublicSuffixDatabase.gz"

# Run only the specific test classes using Gradle with JUnit filter
./gradlew :okhttp:test --tests "okhttp3.internal.publicsuffix.PublicSuffixDatabaseTest" --no-daemon
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
