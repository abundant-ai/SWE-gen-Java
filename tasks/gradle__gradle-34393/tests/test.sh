#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "platforms/core-configuration/configuration-cache/src/test/kotlin/org/gradle/internal/cc/impl"
cp "/tests/platforms/core-configuration/configuration-cache/src/test/kotlin/org/gradle/internal/cc/impl/ConfigurationCacheKeyTest.kt" "platforms/core-configuration/configuration-cache/src/test/kotlin/org/gradle/internal/cc/impl/ConfigurationCacheKeyTest.kt"

# Check that the resilientModelBuilding flag has been properly implemented.
# The fix adds resilientModelBuilding to DefaultBuildModelParameters and isResilientModelBuilding()
# to the BuildModelParameters interface.

BUILD_MODEL_PARAMS="platforms/core-configuration/configuration-cache/src/main/kotlin/org/gradle/internal/cc/impl/services/DefaultBuildModelParameters.kt"
BUILD_MODEL_INTERFACE="platforms/core-runtime/base-services/src/main/java/org/gradle/internal/buildtree/BuildModelParameters.java"
CONTROLLER_SERVICES="platforms/core-configuration/configuration-cache/src/main/kotlin/org/gradle/internal/cc/impl/DefaultBuildTreeModelControllerServices.kt"
TEST_FILE="platforms/core-configuration/configuration-cache/src/test/kotlin/org/gradle/internal/cc/impl/ConfigurationCacheKeyTest.kt"

test_status=0

# Check that resilientModelBuilding field is present in DefaultBuildModelParameters
if ! grep -q "resilientModelBuilding" "${BUILD_MODEL_PARAMS}"; then
    echo "ERROR: resilientModelBuilding parameter not present in DefaultBuildModelParameters" >&2
    test_status=1
fi

# Check that isResilientModelBuilding() is implemented in DefaultBuildModelParameters
if ! grep -q "isResilientModelBuilding" "${BUILD_MODEL_PARAMS}"; then
    echo "ERROR: isResilientModelBuilding() not implemented in DefaultBuildModelParameters" >&2
    test_status=1
fi

# Check that isResilientModelBuilding() is declared in BuildModelParameters interface
if ! grep -q "isResilientModelBuilding" "${BUILD_MODEL_INTERFACE}"; then
    echo "ERROR: isResilientModelBuilding() not declared in BuildModelParameters interface" >&2
    test_status=1
fi

# Check that resilientModelBuilding InternalFlag is defined in DefaultBuildTreeModelControllerServices
if ! grep -q "resilientModelBuilding" "${CONTROLLER_SERVICES}"; then
    echo "ERROR: resilientModelBuilding InternalFlag not present in DefaultBuildTreeModelControllerServices" >&2
    test_status=1
fi

# Check that test file (HEAD state) uses resilientModelBuilding parameter
if ! grep -q "resilientModelBuilding" "${TEST_FILE}"; then
    echo "ERROR: resilientModelBuilding not used in ConfigurationCacheKeyTest (expected HEAD state)" >&2
    test_status=1
fi

if [ $test_status -eq 0 ]; then
    echo "All resilientModelBuilding implementation checks passed."
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
