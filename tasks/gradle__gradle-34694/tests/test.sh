#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "platforms/software/dependency-management/src/test/groovy/org/gradle/api/internal/notations"
cp "/tests/platforms/software/dependency-management/src/test/groovy/org/gradle/api/internal/notations/ProjectDependencyFactoryTest.groovy" "platforms/software/dependency-management/src/test/groovy/org/gradle/api/internal/notations/ProjectDependencyFactoryTest.groovy"
mkdir -p "subprojects/core/src/test/groovy/org/gradle/api/internal/artifacts/dependencies"
cp "/tests/subprojects/core/src/test/groovy/org/gradle/api/internal/artifacts/dependencies/DefaultProjectDependencyConstraintTest.groovy" "subprojects/core/src/test/groovy/org/gradle/api/internal/artifacts/dependencies/DefaultProjectDependencyConstraintTest.groovy"

# Run specific test classes using Gradle
# Note: Using --no-daemon to avoid daemon startup issues in container
cd /app/src
./gradlew --no-daemon :dependency-management:test --tests "*.ProjectDependencyFactoryTest" :core:test --tests "*.DefaultProjectDependencyConstraintTest"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
