#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "platforms/core-runtime/internal-instrumentation-processor/src/test/groovy/org/gradle/internal/instrumentation/extensions/property"
cp "/tests/platforms/core-runtime/internal-instrumentation-processor/src/test/groovy/org/gradle/internal/instrumentation/extensions/property/PropertyUpgradeCodeGenTest.groovy" "platforms/core-runtime/internal-instrumentation-processor/src/test/groovy/org/gradle/internal/instrumentation/extensions/property/PropertyUpgradeCodeGenTest.groovy"
mkdir -p "platforms/core-runtime/internal-instrumentation-processor/src/test/groovy/org/gradle/internal/instrumentation/extensions/property"
cp "/tests/platforms/core-runtime/internal-instrumentation-processor/src/test/groovy/org/gradle/internal/instrumentation/extensions/property/PropertyUpgradeCustomInterceptorCodeGenTest.groovy" "platforms/core-runtime/internal-instrumentation-processor/src/test/groovy/org/gradle/internal/instrumentation/extensions/property/PropertyUpgradeCustomInterceptorCodeGenTest.groovy"
mkdir -p "subprojects/core/src/test/groovy/org/gradle/api/internal/tasks/util"
cp "/tests/subprojects/core/src/test/groovy/org/gradle/api/internal/tasks/util/DefaultJavaForkOptionsTest.groovy" "subprojects/core/src/test/groovy/org/gradle/api/internal/tasks/util/DefaultJavaForkOptionsTest.groovy"

PROPERTY_UPGRADE_TEST="platforms/core-runtime/internal-instrumentation-processor/src/test/groovy/org/gradle/internal/instrumentation/extensions/property/PropertyUpgradeCodeGenTest.groovy"
CUSTOM_INTERCEPTOR_TEST="platforms/core-runtime/internal-instrumentation-processor/src/test/groovy/org/gradle/internal/instrumentation/extensions/property/PropertyUpgradeCustomInterceptorCodeGenTest.groovy"
DEFAULT_JAVA_FORK_TEST="subprojects/core/src/test/groovy/org/gradle/api/internal/tasks/util/DefaultJavaForkOptionsTest.groovy"
PROPERTY_UPGRADE_SOURCE="platforms/core-runtime/internal-instrumentation-processor/src/main/java/org/gradle/internal/instrumentation/extensions/property/PropertyUpgradeClassSourceGenerator.java"
CODE_GEN_UTILS="platforms/core-runtime/internal-instrumentation-processor/src/main/java/org/gradle/internal/instrumentation/processor/codegen/CodeGenUtils.java"
DEFAULT_JAVA_FORK_OPTIONS="subprojects/core/src/main/java/org/gradle/process/internal/DefaultJavaForkOptions.java"

test_status=0

# Check that PropertyUpgradeCodeGenTest expects @SuppressWarnings("deprecation") in generated code (fix applied)
if ! grep -q '@SuppressWarnings("deprecation")' "${PROPERTY_UPGRADE_TEST}"; then
    echo "ERROR: PropertyUpgradeCodeGenTest.groovy does not expect @SuppressWarnings(\"deprecation\") annotation (fix not applied)" >&2
    test_status=1
fi

# Check that PropertyUpgradeCustomInterceptorCodeGenTest expects @SuppressWarnings("deprecation") (fix applied)
if ! grep -q '@SuppressWarnings("deprecation")' "${CUSTOM_INTERCEPTOR_TEST}"; then
    echo "ERROR: PropertyUpgradeCustomInterceptorCodeGenTest.groovy does not expect @SuppressWarnings(\"deprecation\") annotation (fix not applied)" >&2
    test_status=1
fi

# Check that DefaultJavaForkOptionsTest has deprecation logger setup (fix applied)
if ! grep -q 'DeprecationLogger' "${DEFAULT_JAVA_FORK_TEST}"; then
    echo "ERROR: DefaultJavaForkOptionsTest.groovy does not import/use DeprecationLogger (fix not applied)" >&2
    test_status=1
fi

# Check that DefaultJavaForkOptionsTest asserts deprecation warning is logged (fix applied)
if ! grep -q 'setAllJvmArgs method has been deprecated' "${DEFAULT_JAVA_FORK_TEST}"; then
    echo "ERROR: DefaultJavaForkOptionsTest.groovy does not assert deprecation warning for setAllJvmArgs (fix not applied)" >&2
    test_status=1
fi

# Check that PropertyUpgradeClassSourceGenerator adds SUPPRESS_DEPRECATIONS annotation (fix applied)
if ! grep -q 'SUPPRESS_DEPRECATIONS' "${PROPERTY_UPGRADE_SOURCE}"; then
    echo "ERROR: PropertyUpgradeClassSourceGenerator.java does not use SUPPRESS_DEPRECATIONS (fix not applied)" >&2
    test_status=1
fi

# Check that CodeGenUtils defines SUPPRESS_DEPRECATIONS (fix applied)
if ! grep -q 'SUPPRESS_DEPRECATIONS' "${CODE_GEN_UTILS}"; then
    echo "ERROR: CodeGenUtils.java does not define SUPPRESS_DEPRECATIONS (fix not applied)" >&2
    test_status=1
fi

# Check that DefaultJavaForkOptions.setAllJvmArgs has @Deprecated annotation (fix applied)
if ! grep -q '@Deprecated' "${DEFAULT_JAVA_FORK_OPTIONS}"; then
    echo "ERROR: DefaultJavaForkOptions.java does not have @Deprecated on setAllJvmArgs (fix not applied)" >&2
    test_status=1
fi

# Check that DefaultJavaForkOptions.setAllJvmArgs calls DeprecationLogger (fix applied)
if ! grep -q 'DeprecationLogger' "${DEFAULT_JAVA_FORK_OPTIONS}"; then
    echo "ERROR: DefaultJavaForkOptions.java does not call DeprecationLogger in setAllJvmArgs (fix not applied)" >&2
    test_status=1
fi

if [ $test_status -eq 0 ]; then
    echo "All checks passed: setAllJvmArgs is properly deprecated with DeprecationLogger and @SuppressWarnings(\"deprecation\") in generated adapters."
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
