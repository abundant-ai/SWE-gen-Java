#!/bin/bash

cd /app/src

# Re-apply JDK 17 toolchain patches (both buildSrc and main build default to JDK 8)
# Kotlin 1.8.22 supports jvmTarget up to 19, so 17 is safe; 21 would fail
sed -i 's/JavaLanguageVersion.of(8)/JavaLanguageVersion.of(17)/g' buildSrc/build.gradle.kts
sed -i '/fun Project.setupJvmToolchain/,/^}/s/else -> 8/else -> 17/' build.gradle.kts

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "ktor-client/ktor-client-core/jvm/test"
cp "/tests/ktor-client/ktor-client-core/jvm/test/HttpCacheTest.kt" "ktor-client/ktor-client-core/jvm/test/HttpCacheTest.kt"

# Run only the HttpCacheTest in the ktor-client-core JVM test suite
./gradlew :ktor-client:ktor-client-core:jvmTest --tests "HttpCacheTest" \
    --no-daemon --max-workers 1 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
