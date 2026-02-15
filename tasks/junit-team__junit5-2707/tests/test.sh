#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "junit-jupiter-engine/src/main/java/org/junit/jupiter/engine/descriptor"
cp "/tests/junit-jupiter-engine/src/main/java/org/junit/jupiter/engine/descriptor/TestTemplateExtensionContext.java" "junit-jupiter-engine/src/main/java/org/junit/jupiter/engine/descriptor/TestTemplateExtensionContext.java"
mkdir -p "junit-jupiter-engine/src/test/java/org/junit/jupiter/engine/descriptor"
cp "/tests/junit-jupiter-engine/src/test/java/org/junit/jupiter/engine/descriptor/ExtensionContextTests.java" "junit-jupiter-engine/src/test/java/org/junit/jupiter/engine/descriptor/ExtensionContextTests.java"
mkdir -p "junit-jupiter-params/src/test/java/org/junit/jupiter/params"
cp "/tests/junit-jupiter-params/src/test/java/org/junit/jupiter/params/ParameterizedTestExtensionTests.java" "junit-jupiter-params/src/test/java/org/junit/jupiter/params/ParameterizedTestExtensionTests.java"

# Rebuild test classes to pick up the changes
./gradlew :junit-jupiter-engine:testClasses :junit-jupiter-params:testClasses -x compileModule --no-daemon --no-parallel

# Run the specific test classes from this PR
./gradlew :junit-jupiter-engine:test :junit-jupiter-params:test \
    --tests org.junit.jupiter.engine.descriptor.ExtensionContextTests \
    --tests org.junit.jupiter.params.ParameterizedTestExtensionTests \
    -x compileModule --no-daemon --no-parallel 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
