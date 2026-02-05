#!/bin/bash

cd /app/src

export TESTCONTAINERS_RYUK_DISABLED=true
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "test-suite/src/test/java/io/micronaut/test/lombok"
cp "/tests/test-suite/src/test/java/io/micronaut/test/lombok/LombokIntrospectedBuilderTest.java" "test-suite/src/test/java/io/micronaut/test/lombok/LombokIntrospectedBuilderTest.java"
mkdir -p "test-suite/src/test/java/io/micronaut/test/lombok"
cp "/tests/test-suite/src/test/java/io/micronaut/test/lombok/RobotEntity.java" "test-suite/src/test/java/io/micronaut/test/lombok/RobotEntity.java"

# Update timestamps to force Gradle to detect changes
touch test-suite/src/test/java/io/micronaut/test/lombok/*.java

# Remove compiled test classes to force recompilation with the new test files
rm -rf test-suite/build/classes/java/test/io/micronaut/test/lombok/*.class

# Clean the test results to force Gradle to re-run the tests
rm -rf test-suite/build/test-results/test/TEST-io.micronaut.test.lombok.LombokIntrospectedBuilderTest.xml

# Run specific tests using Gradle
./gradlew \
  :test-suite:cleanTest :test-suite:test \
  --tests "io.micronaut.test.lombok.LombokIntrospectedBuilderTest" \
  --no-daemon --console=plain
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
