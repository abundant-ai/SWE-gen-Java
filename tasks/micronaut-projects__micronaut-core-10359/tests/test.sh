#!/bin/bash

cd /app/src

export TESTCONTAINERS_RYUK_DISABLED=true
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "inject-java/src/test/groovy/io/micronaut/aop/compile"
cp "/tests/inject-java/src/test/groovy/io/micronaut/aop/compile/AnnotatedConstructorArgumentSpec.groovy" "inject-java/src/test/groovy/io/micronaut/aop/compile/AnnotatedConstructorArgumentSpec.groovy"
mkdir -p "inject-kotlin/src/test/groovy/io/micronaut/kotlin/processing/aop/compile"
cp "/tests/inject-kotlin/src/test/groovy/io/micronaut/kotlin/processing/aop/compile/AnnotatedConstructorArgumentSpec.groovy" "inject-kotlin/src/test/groovy/io/micronaut/kotlin/processing/aop/compile/AnnotatedConstructorArgumentSpec.groovy"

# Update timestamps to force Gradle to detect changes
touch inject-java/src/test/groovy/io/micronaut/aop/compile/*.groovy 2>/dev/null || true
touch inject-kotlin/src/test/groovy/io/micronaut/kotlin/processing/aop/compile/*.groovy 2>/dev/null || true

# Remove compiled test classes to force recompilation with the new test files
rm -rf inject-java/build/classes/ 2>/dev/null || true
rm -rf inject-kotlin/build/classes/ 2>/dev/null || true

# Run the specific tests for this PR
./gradlew \
    :inject-java:cleanTest :inject-java:test --tests "*AnnotatedConstructorArgumentSpec*" \
    :inject-kotlin:cleanTest :inject-kotlin:test --tests "*AnnotatedConstructorArgumentSpec*" \
    --no-daemon --console=plain
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
