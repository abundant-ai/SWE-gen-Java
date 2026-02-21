#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "platforms/core-configuration/configuration-cache/src/test/kotlin/org/gradle/internal/cc/impl/fingerprint"
cp "/tests/platforms/core-configuration/configuration-cache/src/test/kotlin/org/gradle/internal/cc/impl/fingerprint/ConfigurationCacheFingerprintCheckerTest.kt" "platforms/core-configuration/configuration-cache/src/test/kotlin/org/gradle/internal/cc/impl/fingerprint/ConfigurationCacheFingerprintCheckerTest.kt"

CODEC_KT="platforms/core-configuration/graph-serialization/src/main/kotlin/org/gradle/internal/serialize/graph/Codec.kt"
CONTEXTS_KT="platforms/core-configuration/graph-serialization/src/main/kotlin/org/gradle/internal/serialize/graph/Contexts.kt"
GROOVY_CODECS_KT="platforms/core-configuration/core-serialization-codecs/src/main/kotlin/org/gradle/internal/serialize/codecs/core/GroovyCodecs.kt"
PROPERTY_PROBLEM_KT="platforms/core-configuration/configuration-problems-base/src/main/kotlin/org/gradle/internal/configuration/problems/PropertyProblem.kt"
FINGERPRINT_TEST="platforms/core-configuration/configuration-cache/src/test/kotlin/org/gradle/internal/cc/impl/fingerprint/ConfigurationCacheFingerprintCheckerTest.kt"

test_status=0

# The fix adds problemsListener property to the IsolateContext interface in Codec.kt
if ! grep -q 'val problemsListener: ProblemsListener' "${CODEC_KT}"; then
    echo "ERROR: Codec.kt is missing 'problemsListener' property in IsolateContext interface (fix not applied)" >&2
    test_status=1
fi

# The fix adds override val problemsListener implementation in Contexts.kt
if ! grep -q 'override val problemsListener: ProblemsListener' "${CONTEXTS_KT}"; then
    echo "ERROR: Contexts.kt is missing 'override val problemsListener' implementation (fix not applied)" >&2
    test_status=1
fi

# The fix adds ProblemsListener import and usage to GroovyCodecs.kt
if ! grep -q 'ProblemsListener' "${GROOVY_CODECS_KT}"; then
    echo "ERROR: GroovyCodecs.kt is missing ProblemsListener usage (fix not applied)" >&2
    test_status=1
fi

# The fix adds RequirementsGradleModelTypes enum entry to PropertyProblem.kt
if ! grep -q 'RequirementsGradleModelTypes' "${PROPERTY_PROBLEM_KT}"; then
    echo "ERROR: PropertyProblem.kt is missing RequirementsGradleModelTypes enum entry (fix not applied)" >&2
    test_status=1
fi

# The HEAD test file should have override val problemsListener (it was in the interface at HEAD)
if ! grep -q 'override val problemsListener: ProblemsListener' "${FINGERPRINT_TEST}"; then
    echo "ERROR: ConfigurationCacheFingerprintCheckerTest.kt is missing 'override val problemsListener' (HEAD test not copied correctly)" >&2
    test_status=1
fi

if [ $test_status -eq 0 ]; then
    echo "All checks passed: IsolateContext has problemsListener, Contexts.kt implements it, GroovyCodecs.kt uses ProblemsListener, PropertyProblem.kt has RequirementsGradleModelTypes, and test file is correct."
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
