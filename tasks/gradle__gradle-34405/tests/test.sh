#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "platforms/software/dependency-management/src/test/groovy/org/gradle/api/internal/artifacts/repositories"
cp "/tests/platforms/software/dependency-management/src/test/groovy/org/gradle/api/internal/artifacts/repositories/DefaultBaseRepositoryFactoryTest.groovy" "platforms/software/dependency-management/src/test/groovy/org/gradle/api/internal/artifacts/repositories/DefaultBaseRepositoryFactoryTest.groovy"

# Check that JCenter-related code has been removed from the internal repository factory.
# The fix removes createJCenterRepository() from BaseRepositoryFactory interface,
# DefaultBaseRepositoryFactory implementation, and related constants from DefaultRepositoryHandler.

FACTORY_INTERFACE="platforms/software/dependency-management/src/main/java/org/gradle/api/internal/artifacts/BaseRepositoryFactory.java"
FACTORY_IMPL="platforms/software/dependency-management/src/main/java/org/gradle/api/internal/artifacts/repositories/DefaultBaseRepositoryFactory.java"
REPO_HANDLER="platforms/software/dependency-management/src/main/java/org/gradle/api/internal/artifacts/dsl/DefaultRepositoryHandler.java"

test_status=0

# Check that createJCenterRepository is NOT in the interface
if grep -q "createJCenterRepository" "${FACTORY_INTERFACE}"; then
    echo "ERROR: createJCenterRepository() still present in BaseRepositoryFactory interface" >&2
    test_status=1
fi

# Check that createJCenterRepository is NOT in the implementation
if grep -q "createJCenterRepository" "${FACTORY_IMPL}"; then
    echo "ERROR: createJCenterRepository() still present in DefaultBaseRepositoryFactory" >&2
    test_status=1
fi

# Check that JCenter constants are NOT in DefaultRepositoryHandler
if grep -q "BINTRAY_JCENTER_URL\|DEFAULT_BINTRAY_JCENTER_REPO_NAME" "${REPO_HANDLER}"; then
    echo "ERROR: JCenter constants still present in DefaultRepositoryHandler" >&2
    test_status=1
fi

# Check that testCreateJCenterRepo is NOT in the test file (fix state)
TEST_FILE="platforms/software/dependency-management/src/test/groovy/org/gradle/api/internal/artifacts/repositories/DefaultBaseRepositoryFactoryTest.groovy"
if grep -q "testCreateJCenterRepo\|createJCenterRepository" "${TEST_FILE}"; then
    echo "ERROR: JCenter test/reference still present in DefaultBaseRepositoryFactoryTest" >&2
    test_status=1
fi

if [ $test_status -eq 0 ]; then
    echo "All JCenter internal references have been properly removed."
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
