#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "platforms/core-configuration/configuration-cache/src/test/kotlin/org/gradle/internal/cc/impl"
cp "/tests/platforms/core-configuration/configuration-cache/src/test/kotlin/org/gradle/internal/cc/impl/ConfigurationCacheKeyTest.kt" "platforms/core-configuration/configuration-cache/src/test/kotlin/org/gradle/internal/cc/impl/ConfigurationCacheKeyTest.kt"
mkdir -p "subprojects/core/src/test/groovy/org/gradle/initialization"
cp "/tests/subprojects/core/src/test/groovy/org/gradle/initialization/DefaultSettingsLoaderTest.groovy" "subprojects/core/src/test/groovy/org/gradle/initialization/DefaultSettingsLoaderTest.groovy"
mkdir -p "subprojects/core/src/test/groovy/org/gradle/initialization/layout"
cp "/tests/subprojects/core/src/test/groovy/org/gradle/initialization/layout/BuildLayoutFactoryTest.groovy" "subprojects/core/src/test/groovy/org/gradle/initialization/layout/BuildLayoutFactoryTest.groovy"

CC_START_PARAM="platforms/core-configuration/configuration-cache/src/main/kotlin/org/gradle/internal/cc/impl/initialization/ConfigurationCacheStartParameter.kt"
CC_KEY="platforms/core-configuration/configuration-cache/src/main/kotlin/org/gradle/internal/cc/impl/ConfigurationCacheKey.kt"
IGNORED_INPUTS="platforms/core-configuration/configuration-cache/src/main/kotlin/org/gradle/internal/cc/impl/DefaultIgnoredConfigurationInputs.kt"

test_status=0

# Check that ConfigurationCacheStartParameter uses buildTreeLocations (not buildLayout) after the fix
if ! grep -q 'buildTreeLocations' "${CC_START_PARAM}"; then
    echo "ERROR: ConfigurationCacheStartParameter.kt does not use buildTreeLocations (fix not applied)" >&2
    test_status=1
fi

# Check that ConfigurationCacheStartParameter exposes buildTreeRootDirectory (not rootDirectory/settingsDirectory)
if ! grep -q 'buildTreeRootDirectory' "${CC_START_PARAM}"; then
    echo "ERROR: ConfigurationCacheStartParameter.kt does not expose buildTreeRootDirectory property (fix not applied)" >&2
    test_status=1
fi

# Check that the buggy rootDirectory property is NOT present in ConfigurationCacheStartParameter
if grep -q 'val rootDirectory' "${CC_START_PARAM}"; then
    echo "ERROR: ConfigurationCacheStartParameter.kt still has 'val rootDirectory' (fix not applied)" >&2
    test_status=1
fi

# Check that ConfigurationCacheKey.kt uses buildTreeRootDirectory (not rootDirectory) after the fix
if grep -q 'startParameter\.rootDirectory' "${CC_KEY}"; then
    echo "ERROR: ConfigurationCacheKey.kt still uses startParameter.rootDirectory (fix not applied)" >&2
    test_status=1
fi

if ! grep -q 'startParameter\.buildTreeRootDirectory' "${CC_KEY}"; then
    echo "ERROR: ConfigurationCacheKey.kt does not use startParameter.buildTreeRootDirectory (fix not applied)" >&2
    test_status=1
fi

# Check that DefaultIgnoredConfigurationInputs uses buildTreeRootDirectory (not rootDirectory)
if grep -q 'private val rootDirectory: File' "${IGNORED_INPUTS}"; then
    echo "ERROR: DefaultIgnoredConfigurationInputs.kt still uses 'val rootDirectory: File' (fix not applied)" >&2
    test_status=1
fi

if ! grep -q 'buildTreeRootDirectory' "${IGNORED_INPUTS}"; then
    echo "ERROR: DefaultIgnoredConfigurationInputs.kt does not use buildTreeRootDirectory (fix not applied)" >&2
    test_status=1
fi

if [ $test_status -eq 0 ]; then
    echo "All checks passed: buildTreeRootDirectory API correctly restored."
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
