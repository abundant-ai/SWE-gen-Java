#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "platforms/jvm/plugins-application/src/test/groovy/org/gradle/api/internal/plugins"
cp "/tests/platforms/jvm/plugins-application/src/test/groovy/org/gradle/api/internal/plugins/UnixStartScriptGeneratorTest.groovy" "platforms/jvm/plugins-application/src/test/groovy/org/gradle/api/internal/plugins/UnixStartScriptGeneratorTest.groovy"
mkdir -p "platforms/jvm/plugins-application/src/test/groovy/org/gradle/api/internal/plugins"
cp "/tests/platforms/jvm/plugins-application/src/test/groovy/org/gradle/api/internal/plugins/WindowsStartScriptGeneratorTest.groovy" "platforms/jvm/plugins-application/src/test/groovy/org/gradle/api/internal/plugins/WindowsStartScriptGeneratorTest.groovy"

UNIX_SCRIPT_TEMPLATE="platforms/jvm/plugins-application/src/main/resources/org/gradle/api/internal/plugins/unixStartScript.txt"
WINDOWS_SCRIPT_TEMPLATE="platforms/jvm/plugins-application/src/main/resources/org/gradle/api/internal/plugins/windowsStartScript.txt"
BINDING_FACTORY="platforms/jvm/plugins-application/src/main/java/org/gradle/api/internal/plugins/StartScriptTemplateBindingFactory.java"
UNIX_TEST="platforms/jvm/plugins-application/src/test/groovy/org/gradle/api/internal/plugins/UnixStartScriptGeneratorTest.groovy"
WINDOWS_TEST="platforms/jvm/plugins-application/src/test/groovy/org/gradle/api/internal/plugins/WindowsStartScriptGeneratorTest.groovy"

test_status=0

# The fix wraps CLASSPATH in unix template with <% if ( classpath ) {%> conditional
if ! grep -q 'if ( classpath )' "${UNIX_SCRIPT_TEMPLATE}"; then
    echo "ERROR: unixStartScript.txt is missing classpath conditional check (fix not applied)" >&2
    test_status=1
fi

# The fix wraps CLASSPATH in windows template with <% if ( classpath ) {%> conditional
if ! grep -q 'if ( classpath )' "${WINDOWS_SCRIPT_TEMPLATE}"; then
    echo "ERROR: windowsStartScript.txt is missing classpath conditional check (fix not applied)" >&2
    test_status=1
fi

# The fix removes the empty path workaround from StartScriptTemplateBindingFactory
if grep -q '"\\\\\\\"\\\\\\\"\"' "${BINDING_FACTORY}"; then
    echo "ERROR: StartScriptTemplateBindingFactory.java still has empty path workaround (fix not applied)" >&2
    test_status=1
fi

# The HEAD test file adds "Do not set classpath if it is empty" test for Unix
if ! grep -q 'Do not set classpath if it is empty' "${UNIX_TEST}"; then
    echo "ERROR: UnixStartScriptGeneratorTest.groovy is missing 'Do not set classpath if it is empty' test (HEAD test not copied)" >&2
    test_status=1
fi

# The HEAD test file adds "Do not set classpath if it is empty" test for Windows
if ! grep -q 'Do not set classpath if it is empty' "${WINDOWS_TEST}"; then
    echo "ERROR: WindowsStartScriptGeneratorTest.groovy is missing 'Do not set classpath if it is empty' test (HEAD test not copied)" >&2
    test_status=1
fi

# The HEAD Unix test file uses @Issue annotation and accepts classpath parameter
if ! grep -q 'spock.lang.Issue' "${UNIX_TEST}"; then
    echo "ERROR: UnixStartScriptGeneratorTest.groovy is missing spock.lang.Issue import (HEAD test not copied)" >&2
    test_status=1
fi

# The HEAD Windows test file uses @Issue annotation
if ! grep -q 'spock.lang.Issue' "${WINDOWS_TEST}"; then
    echo "ERROR: WindowsStartScriptGeneratorTest.groovy is missing spock.lang.Issue import (HEAD test not copied)" >&2
    test_status=1
fi

if [ $test_status -eq 0 ]; then
    echo "All checks passed: Start script templates have classpath conditionals, binding factory no longer has empty path workaround, and test files include 'Do not set classpath if it is empty' tests."
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
