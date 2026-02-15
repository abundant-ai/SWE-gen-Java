#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "junit-jupiter-engine/src/test/java/org/junit/jupiter/engine/config"
cp "/tests/junit-jupiter-engine/src/test/java/org/junit/jupiter/engine/config/CachingJupiterConfigurationTests.java" "junit-jupiter-engine/src/test/java/org/junit/jupiter/engine/config/CachingJupiterConfigurationTests.java"
mkdir -p "junit-jupiter-engine/src/test/java/org/junit/jupiter/engine/config"
cp "/tests/junit-jupiter-engine/src/test/java/org/junit/jupiter/engine/config/DefaultJupiterConfigurationTests.java" "junit-jupiter-engine/src/test/java/org/junit/jupiter/engine/config/DefaultJupiterConfigurationTests.java"
mkdir -p "junit-jupiter-engine/src/test/java/org/junit/jupiter/engine/config"
cp "/tests/junit-jupiter-engine/src/test/java/org/junit/jupiter/engine/config/InstantiatingConfigurationParameterConverterTests.java" "junit-jupiter-engine/src/test/java/org/junit/jupiter/engine/config/InstantiatingConfigurationParameterConverterTests.java"
mkdir -p "junit-jupiter-engine/src/test/java/org/junit/jupiter/engine/extension"
cp "/tests/junit-jupiter-engine/src/test/java/org/junit/jupiter/engine/extension/OrderedMethodTests.java" "junit-jupiter-engine/src/test/java/org/junit/jupiter/engine/extension/OrderedMethodTests.java"

# Run the specific test files using Gradle
./gradlew :junit-jupiter-engine:test \
  --tests org.junit.jupiter.engine.config.CachingJupiterConfigurationTests \
  --tests org.junit.jupiter.engine.config.DefaultJupiterConfigurationTests \
  --tests org.junit.jupiter.engine.config.InstantiatingConfigurationParameterConverterTests \
  --tests org.junit.jupiter.engine.extension.OrderedMethodTests \
  -x compileModule --no-daemon --no-parallel 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
