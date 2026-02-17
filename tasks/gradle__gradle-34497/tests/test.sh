#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "platforms/software/dependency-management/src/test/groovy/org/gradle/api/internal/artifacts/configurations"
cp "/tests/platforms/software/dependency-management/src/test/groovy/org/gradle/api/internal/artifacts/configurations/DefaultConfigurationContainerSpec.groovy" "platforms/software/dependency-management/src/test/groovy/org/gradle/api/internal/artifacts/configurations/DefaultConfigurationContainerSpec.groovy"
mkdir -p "platforms/software/dependency-management/src/test/groovy/org/gradle/api/internal/artifacts/configurations"
cp "/tests/platforms/software/dependency-management/src/test/groovy/org/gradle/api/internal/artifacts/configurations/DefaultConfigurationContainerTest.groovy" "platforms/software/dependency-management/src/test/groovy/org/gradle/api/internal/artifacts/configurations/DefaultConfigurationContainerTest.groovy"
mkdir -p "platforms/software/dependency-management/src/test/groovy/org/gradle/api/internal/artifacts/configurations"
cp "/tests/platforms/software/dependency-management/src/test/groovy/org/gradle/api/internal/artifacts/configurations/DefaultConfigurationSpec.groovy" "platforms/software/dependency-management/src/test/groovy/org/gradle/api/internal/artifacts/configurations/DefaultConfigurationSpec.groovy"

# Run specific test classes using Gradle
# Note: Using --no-daemon to avoid daemon startup issues in container
cd /app/src
./gradlew --no-daemon :dependency-management:test --tests "*.DefaultConfigurationContainerSpec" --tests "*.DefaultConfigurationContainerTest" --tests "*.DefaultConfigurationSpec"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
