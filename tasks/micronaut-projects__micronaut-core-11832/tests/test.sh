#!/bin/bash

cd /app/src

export TESTCONTAINERS_RYUK_DISABLED=true
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "inject-groovy/src/test/groovy/io/micronaut/ast/groovy/visitor"
cp "/tests/inject-groovy/src/test/groovy/io/micronaut/ast/groovy/visitor/GroovyBeanPropertiesSpec.groovy" "inject-groovy/src/test/groovy/io/micronaut/ast/groovy/visitor/GroovyBeanPropertiesSpec.groovy"
mkdir -p "inject-groovy/src/test/groovy/io/micronaut/ast/groovy/visitor"
cp "/tests/inject-groovy/src/test/groovy/io/micronaut/ast/groovy/visitor/GroovyRecord.groovy" "inject-groovy/src/test/groovy/io/micronaut/ast/groovy/visitor/GroovyRecord.groovy"
mkdir -p "inject-groovy/src/test/java/io/micronaut/sample"
cp "/tests/inject-groovy/src/test/java/io/micronaut/sample/EmptyRecord.java" "inject-groovy/src/test/java/io/micronaut/sample/EmptyRecord.java"
mkdir -p "inject-groovy/src/test/java/io/micronaut/sample"
cp "/tests/inject-groovy/src/test/java/io/micronaut/sample/JavaRecord.java" "inject-groovy/src/test/java/io/micronaut/sample/JavaRecord.java"

# Remove compiled test classes to force recompilation with the new test files
rm -rf inject-groovy/build/classes/groovy/test/io/micronaut/ast/groovy/visitor/GroovyBeanPropertiesSpec*.class
rm -rf inject-groovy/build/classes/java/test/io/micronaut/sample/EmptyRecord*.class
rm -rf inject-groovy/build/classes/java/test/io/micronaut/sample/JavaRecord*.class

# Run specific tests using Gradle
./gradlew \
  :micronaut-inject-groovy:test --tests "io.micronaut.ast.groovy.visitor.GroovyBeanPropertiesSpec" \
  --no-daemon --console=plain
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
