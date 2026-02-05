#!/bin/bash

cd /app/src

export TESTCONTAINERS_RYUK_DISABLED=true
export CI=true

# Apply fix.patch to restore module configuration (bug.patch removed the modules from settings.gradle)
patch -p1 < /solution/fix.patch

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "test-suite-annotation-remapper/src/test/java/example/micronaut"
cp "/tests/test-suite-annotation-remapper/src/test/java/example/micronaut/HelloController.java" "test-suite-annotation-remapper/src/test/java/example/micronaut/HelloController.java"
mkdir -p "test-suite-annotation-remapper/src/test/java/example/micronaut"
cp "/tests/test-suite-annotation-remapper/src/test/java/example/micronaut/HelloControllerTest.java" "test-suite-annotation-remapper/src/test/java/example/micronaut/HelloControllerTest.java"
mkdir -p "test-suite-annotation-remapper/src/test/java/example/micronaut"
cp "/tests/test-suite-annotation-remapper/src/test/java/example/micronaut/MyRecord.java" "test-suite-annotation-remapper/src/test/java/example/micronaut/MyRecord.java"
mkdir -p "test-suite-annotation-remapper/src/test/resources"
cp "/tests/test-suite-annotation-remapper/src/test/resources/logback.xml" "test-suite-annotation-remapper/src/test/resources/logback.xml"

# Update timestamps to force Gradle to detect changes
touch test-suite-annotation-remapper/src/test/java/example/micronaut/*.java 2>/dev/null || true

# Remove compiled classes to force recompilation with the new test files
rm -rf test-suite-annotation-remapper/build/classes/ 2>/dev/null || true

# Run the specific test for this PR
set +e  # Don't exit on error, we'll check manually

cd test-suite-annotation-remapper
test_output=$(../gradlew test --tests "example.micronaut.HelloControllerTest" \
  --no-daemon --console=plain 2>&1)
test_status=$?
cd ..

echo "$test_output"

set -e

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
