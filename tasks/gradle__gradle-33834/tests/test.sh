#!/bin/bash

cd /app/src

# No test files to copy

BEAN_SER="platforms/core-configuration/bean-serialization-services/build.gradle.kts"
CORE_SER_CODECS="platforms/core-configuration/core-serialization-codecs/build.gradle.kts"
MODEL_CORE="platforms/core-configuration/model-core/build.gradle.kts"
TOOLING_API="platforms/ide/tooling-api/build.gradle.kts"
INTERNAL_INTEG="testing/internal-integ-testing/build.gradle.kts"
INTERNAL_TESTING="testing/internal-testing/build.gradle.kts"

test_status=0

# The fix introduces per-compilation nested blocks in bean-serialization-services
if ! grep -q 'compilations' "${BEAN_SER}"; then
    echo "ERROR: ${BEAN_SER} is missing the nested 'compilations' block (fix not applied)" >&2
    test_status=1
fi

# The fix introduces per-compilation nested blocks in core-serialization-codecs
if ! grep -q 'compilations' "${CORE_SER_CODECS}"; then
    echo "ERROR: ${CORE_SER_CODECS} is missing the nested 'compilations' block (fix not applied)" >&2
    test_status=1
fi

# The fix introduces per-compilation nested blocks in model-core
if ! grep -q 'compilations' "${MODEL_CORE}"; then
    echo "ERROR: ${MODEL_CORE} is missing the nested 'compilations' block (fix not applied)" >&2
    test_status=1
fi

# The fix adds jvmCompile block in internal-integ-testing targeting JVM 8 for tooling API compatibility
if ! grep -q 'targetJvmVersion = 8' "${INTERNAL_INTEG}"; then
    echo "ERROR: ${INTERNAL_INTEG} is missing 'targetJvmVersion = 8' (fix not applied)" >&2
    test_status=1
fi

# The fix adds jvmCompile block in internal-testing targeting JVM 8
if ! grep -q 'targetJvmVersion = 8' "${INTERNAL_TESTING}"; then
    echo "ERROR: ${INTERNAL_TESTING} is missing 'targetJvmVersion = 8' (fix not applied)" >&2
    test_status=1
fi

# The fix adds crossVersionTest compilation in tooling-api targeting JVM 8 for TAPI client compatibility
if ! grep -q 'named("crossVersionTest")' "${TOOLING_API}"; then
    echo "ERROR: ${TOOLING_API} is missing 'named(\"crossVersionTest\")' block for JVM 8 compat (fix not applied)" >&2
    test_status=1
fi

if [ $test_status -eq 0 ]; then
    echo "All checks passed: jvmCompile blocks use per-compilation API (nested compilations blocks with correct JVM version targets)."
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
