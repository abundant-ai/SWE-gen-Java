#!/bin/bash

cd /app/src

export TESTCONTAINERS_RYUK_DISABLED=true
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "test-suite-kotlin-ksp-all-open/src/test/kotlin/io/micronaut/docs/aop/around"
cp "/tests/test-suite-kotlin-ksp-all-open/src/test/kotlin/io/micronaut/docs/aop/around/AnotherOpenSingleton.kt" "test-suite-kotlin-ksp-all-open/src/test/kotlin/io/micronaut/docs/aop/around/AnotherOpenSingleton.kt"
mkdir -p "test-suite-kotlin-ksp-all-open/src/test/kotlin/io/micronaut/docs/aop/around"
cp "/tests/test-suite-kotlin-ksp-all-open/src/test/kotlin/io/micronaut/docs/aop/around/AroundSpec.kt" "test-suite-kotlin-ksp-all-open/src/test/kotlin/io/micronaut/docs/aop/around/AroundSpec.kt"
mkdir -p "test-suite-kotlin-ksp-all-open/src/test/kotlin/io/micronaut/docs/aop/around"
cp "/tests/test-suite-kotlin-ksp-all-open/src/test/kotlin/io/micronaut/docs/aop/around/NotNull.kt" "test-suite-kotlin-ksp-all-open/src/test/kotlin/io/micronaut/docs/aop/around/NotNull.kt"
mkdir -p "test-suite-kotlin-ksp-all-open/src/test/kotlin/io/micronaut/docs/aop/around"
cp "/tests/test-suite-kotlin-ksp-all-open/src/test/kotlin/io/micronaut/docs/aop/around/NotNullExample.kt" "test-suite-kotlin-ksp-all-open/src/test/kotlin/io/micronaut/docs/aop/around/NotNullExample.kt"
mkdir -p "test-suite-kotlin-ksp-all-open/src/test/kotlin/io/micronaut/docs/aop/around"
cp "/tests/test-suite-kotlin-ksp-all-open/src/test/kotlin/io/micronaut/docs/aop/around/NotNullInterceptor.kt" "test-suite-kotlin-ksp-all-open/src/test/kotlin/io/micronaut/docs/aop/around/NotNullInterceptor.kt"
mkdir -p "test-suite-kotlin-ksp-all-open/src/test/kotlin/io/micronaut/docs/aop/around"
cp "/tests/test-suite-kotlin-ksp-all-open/src/test/kotlin/io/micronaut/docs/aop/around/NotNullMyInlineInnerExample.kt" "test-suite-kotlin-ksp-all-open/src/test/kotlin/io/micronaut/docs/aop/around/NotNullMyInlineInnerExample.kt"
mkdir -p "test-suite-kotlin-ksp-all-open/src/test/kotlin/io/micronaut/docs/aop/around"
cp "/tests/test-suite-kotlin-ksp-all-open/src/test/kotlin/io/micronaut/docs/aop/around/NotNullResultInnerExample.kt" "test-suite-kotlin-ksp-all-open/src/test/kotlin/io/micronaut/docs/aop/around/NotNullResultInnerExample.kt"
mkdir -p "test-suite-kotlin-ksp-all-open/src/test/kotlin/io/micronaut/docs/aop/around"
cp "/tests/test-suite-kotlin-ksp-all-open/src/test/kotlin/io/micronaut/docs/aop/around/OpenSingleton.kt" "test-suite-kotlin-ksp-all-open/src/test/kotlin/io/micronaut/docs/aop/around/OpenSingleton.kt"
mkdir -p "test-suite-kotlin-ksp-all-open/src/test/resources"
cp "/tests/test-suite-kotlin-ksp-all-open/src/test/resources/logback.xml" "test-suite-kotlin-ksp-all-open/src/test/resources/logback.xml"

# Update timestamps to force Gradle to detect changes
touch test-suite-kotlin-ksp-all-open/src/test/kotlin/io/micronaut/docs/aop/around/*.kt
touch test-suite-kotlin-ksp-all-open/src/test/resources/logback.xml

# Remove compiled test classes to force recompilation with the new test files
rm -rf test-suite-kotlin-ksp-all-open/build/classes/kotlin/test/io/micronaut/docs/aop/around/*.class

# Run specific tests using Gradle
./gradlew \
  :test-suite-kotlin-ksp-all-open:test --tests "io.micronaut.docs.aop.around.AroundSpec" \
  --no-daemon --console=plain
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
