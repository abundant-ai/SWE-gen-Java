#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p ".teamcity/src/test/kotlin"
cp "/tests/.teamcity/src/test/kotlin/CIConfigIntegrationTests.kt" ".teamcity/src/test/kotlin/CIConfigIntegrationTests.kt"

# Run specific test class using Maven
cd .teamcity && ./mvnw test -Dtest=CIConfigIntegrationTests
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
