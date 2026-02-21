#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "platforms/core-configuration/kotlin-dsl-integ-tests/src/integTest/kotlin/org/gradle/kotlin/dsl/integration"
cp "/tests/platforms/core-configuration/kotlin-dsl-integ-tests/src/integTest/kotlin/org/gradle/kotlin/dsl/integration/PrecompiledScriptPluginAccessorsIntegrationTest.kt" "platforms/core-configuration/kotlin-dsl-integ-tests/src/integTest/kotlin/org/gradle/kotlin/dsl/integration/PrecompiledScriptPluginAccessorsIntegrationTest.kt"
mkdir -p "platforms/core-configuration/kotlin-dsl-integ-tests/src/integTest/kotlin/org/gradle/kotlin/dsl/integration"
cp "/tests/platforms/core-configuration/kotlin-dsl-integ-tests/src/integTest/kotlin/org/gradle/kotlin/dsl/integration/PrecompiledScriptPluginIntegrationTest.kt" "platforms/core-configuration/kotlin-dsl-integ-tests/src/integTest/kotlin/org/gradle/kotlin/dsl/integration/PrecompiledScriptPluginIntegrationTest.kt"

GENERATE_ACCESSORS="platforms/core-configuration/kotlin-dsl-provider-plugins/src/main/kotlin/org/gradle/kotlin/dsl/provider/plugins/precompiled/tasks/GeneratePrecompiledScriptPluginAccessors.kt"
SUPPORT_FILE="platforms/core-configuration/kotlin-dsl-provider-plugins/src/main/kotlin/org/gradle/kotlin/dsl/provider/plugins/precompiled/DefaultPrecompiledScriptPluginsSupport.kt"

test_status=0

# Check that GeneratePrecompiledScriptPluginAccessors.kt uses accessorsGenerationClassPathArtifactCollection (fix renames runtimeClassPath* to accessorsGenerationClassPath*)
if ! grep -q 'accessorsGenerationClassPathArtifactCollection' "${GENERATE_ACCESSORS}"; then
    echo "ERROR: GeneratePrecompiledScriptPluginAccessors.kt does not have accessorsGenerationClassPathArtifactCollection (fix not applied - still using runtimeClassPathArtifactCollection)" >&2
    test_status=1
fi

# Check that the accessor generation uses the combined compileOnly+runtime classpath configuration (fix adds this)
if ! grep -q 'precompiledScriptPluginAccessorsGenerationClasspath' "${SUPPORT_FILE}"; then
    echo "ERROR: DefaultPrecompiledScriptPluginsSupport.kt does not have precompiledScriptPluginAccessorsGenerationClasspath (fix not applied)" >&2
    test_status=1
fi

# Check that getAccessorsGenerationClassPathFiles exists (renamed from getRuntimeClassPathFiles in fix)
if ! grep -q 'accessorsGenerationClassPathFiles' "${GENERATE_ACCESSORS}"; then
    echo "ERROR: GeneratePrecompiledScriptPluginAccessors.kt does not have accessorsGenerationClassPathFiles (fix not applied)" >&2
    test_status=1
fi

if [ $test_status -eq 0 ]; then
    echo "All checks passed: accessorsGenerationClassPathArtifactCollection exists, precompiledScriptPluginAccessorsGenerationClasspath configured, accessorsGenerationClassPathFiles present."
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
