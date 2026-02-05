#!/bin/bash

cd /app/src

export TESTCONTAINERS_RYUK_DISABLED=true
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "test-suite-kotlin-ksp/src/test/kotlin/io/micronaut/docs/config/properties"
cp "/tests/test-suite-kotlin-ksp/src/test/kotlin/io/micronaut/docs/config/properties/TestProperties1.kt" "test-suite-kotlin-ksp/src/test/kotlin/io/micronaut/docs/config/properties/TestProperties1.kt"
mkdir -p "test-suite-kotlin-ksp/src/test/kotlin/io/micronaut/docs/config/properties"
cp "/tests/test-suite-kotlin-ksp/src/test/kotlin/io/micronaut/docs/config/properties/TestProperties2.kt" "test-suite-kotlin-ksp/src/test/kotlin/io/micronaut/docs/config/properties/TestProperties2.kt"
mkdir -p "test-suite-kotlin-ksp/src/test/kotlin/io/micronaut/docs/config/properties"
cp "/tests/test-suite-kotlin-ksp/src/test/kotlin/io/micronaut/docs/config/properties/TestPropertiesSpec.kt" "test-suite-kotlin-ksp/src/test/kotlin/io/micronaut/docs/config/properties/TestPropertiesSpec.kt"

# Update timestamps to force Gradle to detect changes
touch test-suite-kotlin-ksp/src/test/kotlin/io/micronaut/docs/config/properties/*.kt 2>/dev/null || true

# Remove compiled test classes to force recompilation with the new test files
rm -rf test-suite-kotlin-ksp/build/classes/

# Run the specific tests for this PR
./gradlew \
    :test-suite-kotlin-ksp:cleanTest :test-suite-kotlin-ksp:test --tests "*TestProperties*" \
    --no-daemon --console=plain
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
