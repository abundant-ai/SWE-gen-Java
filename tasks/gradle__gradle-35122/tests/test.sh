#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "testing/internal-integ-testing/src/test/groovy/org/gradle/internal/scan/config/fixtures"
cp "/tests/testing/internal-integ-testing/src/test/groovy/org/gradle/internal/scan/config/fixtures/ApplyDevelocityPluginFixtureTest.groovy" "testing/internal-integ-testing/src/test/groovy/org/gradle/internal/scan/config/fixtures/ApplyDevelocityPluginFixtureTest.groovy"

# Run the specific test class using Gradle
./gradlew :testing:internal-integ-testing:test --tests ApplyDevelocityPluginFixtureTest --no-daemon
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
