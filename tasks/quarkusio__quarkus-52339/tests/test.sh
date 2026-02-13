#!/bin/bash

cd /app/src

# Set environment variables for test execution
export LANG=en_US.UTF-8

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "extensions/redis-client/runtime/src/test/java/io/quarkus/redis/datasource"
cp "/tests/extensions/redis-client/runtime/src/test/java/io/quarkus/redis/datasource/ValueCommandsTest.java" "extensions/redis-client/runtime/src/test/java/io/quarkus/redis/datasource/ValueCommandsTest.java"

# Run the specific test from the PR
mvn -e -B --settings .github/mvn-settings.xml \
    -DskipExtensionValidation \
    -pl extensions/redis-client/runtime \
    test -Dtest=ValueCommandsTest

test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
