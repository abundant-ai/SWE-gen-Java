#!/bin/bash

cd /app/src

export TESTCONTAINERS_RYUK_DISABLED=true
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "inject-groovy/src/test/groovy/io/micronaut/ast/groovy/visitor"
cp "/tests/inject-groovy/src/test/groovy/io/micronaut/ast/groovy/visitor/GroovyEnumElementSpec.groovy" "inject-groovy/src/test/groovy/io/micronaut/ast/groovy/visitor/GroovyEnumElementSpec.groovy"
mkdir -p "inject-java/src/test/groovy/io/micronaut/annotation"
cp "/tests/inject-java/src/test/groovy/io/micronaut/annotation/JavaEnumElementSpec.groovy" "inject-java/src/test/groovy/io/micronaut/annotation/JavaEnumElementSpec.groovy"
mkdir -p "inject-kotlin/src/test/groovy/io/micronaut/kotlin/processing/ast/visitor"
cp "/tests/inject-kotlin/src/test/groovy/io/micronaut/kotlin/processing/ast/visitor/KotlinEnumElementSpec.groovy" "inject-kotlin/src/test/groovy/io/micronaut/kotlin/processing/ast/visitor/KotlinEnumElementSpec.groovy"

# Update timestamps to force Gradle to detect changes
touch inject-groovy/src/test/groovy/io/micronaut/ast/groovy/visitor/*.groovy 2>/dev/null || true
touch inject-java/src/test/groovy/io/micronaut/annotation/*.groovy 2>/dev/null || true
touch inject-kotlin/src/test/groovy/io/micronaut/kotlin/processing/ast/visitor/*.groovy 2>/dev/null || true

# Remove compiled test classes to force recompilation with the new test files
rm -rf inject-groovy/build/classes/
rm -rf inject-java/build/classes/
rm -rf inject-kotlin/build/classes/

# Run the specific tests for this PR
./gradlew \
    :inject-groovy:cleanTest :inject-groovy:test --tests "*GroovyEnumElementSpec" \
    :inject-java:cleanTest :inject-java:test --tests "*JavaEnumElementSpec" \
    :inject-kotlin:cleanTest :inject-kotlin:test --tests "*KotlinEnumElementSpec" \
    --no-daemon --console=plain
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
