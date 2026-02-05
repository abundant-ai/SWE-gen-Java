#!/bin/bash

cd /app/src

export TESTCONTAINERS_RYUK_DISABLED=true
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "test-suite-logback/src/test/groovy/io/micronaut/logback"
cp "/tests/test-suite-logback/src/test/groovy/io/micronaut/logback/LoggerClientExceptionSpec.groovy" "test-suite-logback/src/test/groovy/io/micronaut/logback/LoggerClientExceptionSpec.groovy"
mkdir -p "test-suite-logback/src/test/java/io/micronaut/logback/clients"
cp "/tests/test-suite-logback/src/test/java/io/micronaut/logback/clients/TeapotClient.java" "test-suite-logback/src/test/java/io/micronaut/logback/clients/TeapotClient.java"
mkdir -p "test-suite-logback/src/test/java/io/micronaut/logback/controllers"
cp "/tests/test-suite-logback/src/test/java/io/micronaut/logback/controllers/TeapotController.java" "test-suite-logback/src/test/java/io/micronaut/logback/controllers/TeapotController.java"

# Update timestamps to force Gradle to detect changes
touch test-suite-logback/src/test/groovy/io/micronaut/logback/*.groovy
touch test-suite-logback/src/test/java/io/micronaut/logback/clients/*.java
touch test-suite-logback/src/test/java/io/micronaut/logback/controllers/*.java

# Remove compiled test classes to force recompilation with the new test files
rm -rf test-suite-logback/build/classes/groovy/test/io/micronaut/logback/*.class
rm -rf test-suite-logback/build/classes/java/test/io/micronaut/logback/clients/*.class
rm -rf test-suite-logback/build/classes/java/test/io/micronaut/logback/controllers/*.class

# Clean the test results to force Gradle to re-run the tests
rm -rf test-suite-logback/build/test-results/test/TEST-io.micronaut.logback.LoggerClientExceptionSpec.xml

# Run specific tests using Gradle
./gradlew \
  :test-suite-logback:cleanTest :test-suite-logback:test \
  --tests "io.micronaut.logback.LoggerClientExceptionSpec" \
  --no-daemon --console=plain
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
