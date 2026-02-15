#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p ".teamcity/src/test/kotlin"
cp "/tests/.teamcity/src/test/kotlin/ApplyDefaultConfigurationTest.kt" ".teamcity/src/test/kotlin/ApplyDefaultConfigurationTest.kt"

# Run specific test class using Maven
cd /app/src/.teamcity
./mvnw test -Dtest=ApplyDefaultConfigurationTest
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
