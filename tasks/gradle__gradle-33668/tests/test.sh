#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "platforms/software/dependency-management/src/test/groovy/org/gradle/api/internal/catalog"
cp "/tests/platforms/software/dependency-management/src/test/groovy/org/gradle/api/internal/catalog/ProjectAccessorsSourceGeneratorTest.groovy" "platforms/software/dependency-management/src/test/groovy/org/gradle/api/internal/catalog/ProjectAccessorsSourceGeneratorTest.groovy"
mkdir -p "platforms/software/dependency-management/src/test/groovy/org/gradle/api/internal/notations"
cp "/tests/platforms/software/dependency-management/src/test/groovy/org/gradle/api/internal/notations/ProjectDependencyFactoryTest.groovy" "platforms/software/dependency-management/src/test/groovy/org/gradle/api/internal/notations/ProjectDependencyFactoryTest.groovy"
mkdir -p "subprojects/core/src/test/groovy/org/gradle/api/internal/artifacts/dependencies"
cp "/tests/subprojects/core/src/test/groovy/org/gradle/api/internal/artifacts/dependencies/DefaultProjectDependencyConstraintTest.groovy" "subprojects/core/src/test/groovy/org/gradle/api/internal/artifacts/dependencies/DefaultProjectDependencyConstraintTest.groovy"

# Run specific test classes using Gradle wrapper
./gradlew :dependency-management:test --tests "org.gradle.api.internal.catalog.ProjectAccessorsSourceGeneratorTest" --tests "org.gradle.api.internal.notations.ProjectDependencyFactoryTest" :core:test --tests "org.gradle.api.internal.artifacts.dependencies.DefaultProjectDependencyConstraintTest" --no-daemon
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
