#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "junit-vintage-engine/src/main/java/org/junit/vintage/engine/descriptor"
cp "/tests/junit-vintage-engine/src/main/java/org/junit/vintage/engine/descriptor/TestSourceProvider.java" "junit-vintage-engine/src/main/java/org/junit/vintage/engine/descriptor/TestSourceProvider.java"
mkdir -p "junit-vintage-engine/src/test/java/org/junit/vintage/engine/descriptor"
cp "/tests/junit-vintage-engine/src/test/java/org/junit/vintage/engine/descriptor/TestSourceProviderTests.java" "junit-vintage-engine/src/test/java/org/junit/vintage/engine/descriptor/TestSourceProviderTests.java"
mkdir -p "junit-vintage-engine/src/test/java/org/junit/vintage/engine/descriptor"
cp "/tests/junit-vintage-engine/src/test/java/org/junit/vintage/engine/descriptor/VintageTestDescriptorTests.java" "junit-vintage-engine/src/test/java/org/junit/vintage/engine/descriptor/VintageTestDescriptorTests.java"
mkdir -p "junit-vintage-engine/src/test/java/org/junit/vintage/engine/discovery"
cp "/tests/junit-vintage-engine/src/test/java/org/junit/vintage/engine/discovery/RunnerTestDescriptorPostProcessorTests.java" "junit-vintage-engine/src/test/java/org/junit/vintage/engine/discovery/RunnerTestDescriptorPostProcessorTests.java"
mkdir -p "junit-vintage-engine/src/test/java/org/junit/vintage/engine/execution"
cp "/tests/junit-vintage-engine/src/test/java/org/junit/vintage/engine/execution/TestRunTests.java" "junit-vintage-engine/src/test/java/org/junit/vintage/engine/execution/TestRunTests.java"
mkdir -p "junit-vintage-engine/src/test/java/org/junit/vintage/engine/samples/junit4"
cp "/tests/junit-vintage-engine/src/test/java/org/junit/vintage/engine/samples/junit4/AbstractJUnit4TestCase.java" "junit-vintage-engine/src/test/java/org/junit/vintage/engine/samples/junit4/AbstractJUnit4TestCase.java"
mkdir -p "junit-vintage-engine/src/test/java/org/junit/vintage/engine/samples/junit4"
cp "/tests/junit-vintage-engine/src/test/java/org/junit/vintage/engine/samples/junit4/ConcreteJUnit4TestCase.java" "junit-vintage-engine/src/test/java/org/junit/vintage/engine/samples/junit4/ConcreteJUnit4TestCase.java"
mkdir -p "platform-tests/src/test/java/org/junit/platform/commons/util"
cp "/tests/platform-tests/src/test/java/org/junit/platform/commons/util/LruCacheTests.java" "platform-tests/src/test/java/org/junit/platform/commons/util/LruCacheTests.java"

# Run the specific test files using Gradle
./gradlew :junit-vintage-engine:test \
  --tests org.junit.vintage.engine.descriptor.TestSourceProviderTests \
  --tests org.junit.vintage.engine.descriptor.VintageTestDescriptorTests \
  --tests org.junit.vintage.engine.discovery.RunnerTestDescriptorPostProcessorTests \
  --tests org.junit.vintage.engine.execution.TestRunTests \
  -x compileModule -x verifyOSGi --no-daemon --no-parallel 2>&1
vintage_status=$?

./gradlew :platform-tests:test \
  --tests org.junit.platform.commons.util.LruCacheTests \
  -x compileModule -x verifyOSGi --no-daemon --no-parallel 2>&1
platform_status=$?

# Both test modules must pass
if [ $vintage_status -eq 0 ] && [ $platform_status -eq 0 ]; then
  test_status=0
else
  test_status=1
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
