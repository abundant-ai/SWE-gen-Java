#!/bin/bash

cd /app/src

export TESTCONTAINERS_RYUK_DISABLED=true
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "http/src/test/java/io/micronaut/http/form"
cp "/tests/http/src/test/java/io/micronaut/http/form/FormConfigurationTest.java" "http/src/test/java/io/micronaut/http/form/FormConfigurationTest.java"
mkdir -p "http/src/test/java/io/micronaut/http/form"
cp "/tests/http/src/test/java/io/micronaut/http/form/FormConfigurationViaPropertyTest.java" "http/src/test/java/io/micronaut/http/form/FormConfigurationViaPropertyTest.java"

# Update timestamps to force Gradle to detect changes
touch http/src/test/java/io/micronaut/http/form/*.java

# Remove compiled test classes to force recompilation with the new test files
rm -rf http/build/classes/java/test/io/micronaut/http/form/*.class

# Clean the test results to force Gradle to re-run the tests
rm -rf http/build/test-results/test/TEST-io.micronaut.http.form.FormConfigurationTest.xml
rm -rf http/build/test-results/test/TEST-io.micronaut.http.form.FormConfigurationViaPropertyTest.xml

# Run specific tests using Gradle, skip Groovy compilation
./gradlew \
  :micronaut-http:cleanTest :micronaut-http:test \
  --tests "io.micronaut.http.form.FormConfigurationTest" \
  --tests "io.micronaut.http.form.FormConfigurationViaPropertyTest" \
  -x compileTestGroovy \
  --no-daemon --console=plain
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
