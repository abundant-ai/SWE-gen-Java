#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "platforms/core-configuration/configuration-cache/src/test/kotlin/org/gradle/internal/cc/impl/serialization/codecs"
cp "/tests/platforms/core-configuration/configuration-cache/src/test/kotlin/org/gradle/internal/cc/impl/serialization/codecs/AbstractUserTypeCodecTest.kt" "platforms/core-configuration/configuration-cache/src/test/kotlin/org/gradle/internal/cc/impl/serialization/codecs/AbstractUserTypeCodecTest.kt"
mkdir -p "platforms/software/dependency-management/src/test/groovy/org/gradle/api/internal/artifacts/configurations"
cp "/tests/platforms/software/dependency-management/src/test/groovy/org/gradle/api/internal/artifacts/configurations/DefaultConfigurationSpec.groovy" "platforms/software/dependency-management/src/test/groovy/org/gradle/api/internal/artifacts/configurations/DefaultConfigurationSpec.groovy"

# Run specific test classes using Gradle
# Note: Using --no-daemon to avoid daemon startup issues in container
cd /app/src
./gradlew --no-daemon :dependency-management:test --tests "*.DefaultConfigurationSpec" && \
./gradlew --no-daemon :configuration-cache:test --tests "*.UserTypesCodecTest"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
