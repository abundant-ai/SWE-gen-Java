#!/bin/bash

cd /app/src

export TESTCONTAINERS_RYUK_DISABLED=true
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "inject-kotlin-test/src/main/groovy/io/micronaut/annotation/processing/test"
cp "/tests/inject-kotlin-test/src/main/groovy/io/micronaut/annotation/processing/test/AbstractKotlinCompilerSpec.groovy" "inject-kotlin-test/src/main/groovy/io/micronaut/annotation/processing/test/AbstractKotlinCompilerSpec.groovy"
mkdir -p "inject-kotlin-test/src/main/groovy/io/micronaut/annotation/processing/test"
cp "/tests/inject-kotlin-test/src/main/groovy/io/micronaut/annotation/processing/test/KotlinCompiler.java" "inject-kotlin-test/src/main/groovy/io/micronaut/annotation/processing/test/KotlinCompiler.java"
mkdir -p "inject-kotlin/src/test/groovy/io/micronaut/kotlin/processing/inject/ast"
cp "/tests/inject-kotlin/src/test/groovy/io/micronaut/kotlin/processing/inject/ast/ClassElementSpec.groovy" "inject-kotlin/src/test/groovy/io/micronaut/kotlin/processing/inject/ast/ClassElementSpec.groovy"

# Update timestamps to force Gradle to detect changes
touch inject-kotlin-test/src/main/groovy/io/micronaut/annotation/processing/test/*.java 2>/dev/null || true
touch inject-kotlin-test/src/main/groovy/io/micronaut/annotation/processing/test/*.groovy 2>/dev/null || true
touch inject-kotlin/src/test/groovy/io/micronaut/kotlin/processing/inject/ast/*.groovy 2>/dev/null || true

# Remove compiled test classes to force recompilation with the new test files
rm -rf inject-kotlin/build/classes/
rm -rf inject-kotlin-test/build/classes/

# Run the specific test for this PR
./gradlew :inject-kotlin:cleanTest :inject-kotlin:test --tests "*ClassElementSpec" \
          --no-daemon --console=plain
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
