#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "platforms/jvm/testing-jvm/src/main/java/org/gradle/api/tasks/testing"
cp "/tests/platforms/jvm/testing-jvm/src/main/java/org/gradle/api/tasks/testing/Test.java" "platforms/jvm/testing-jvm/src/main/java/org/gradle/api/tasks/testing/Test.java"

JVMTESTSUITE_PLUGIN="platforms/jvm/plugins-jvm-test-suite/src/main/java/org/gradle/api/plugins/JvmTestSuitePlugin.java"
ANTLR_TASK="platforms/software/antlr/src/main/java/org/gradle/api/plugins/antlr/AntlrTask.java"

test_status=0

# The bug changes JvmTestSuitePlugin to use ConfigurableFileCollection.convention() which breaks
# self-referential classpath assignments. The fix reverts to conventionMapping.map().
# Check that JvmTestSuitePlugin.java uses conventionMapping.map (fix reverts from convention())
if ! grep -q 'getConventionMapping()\.map("testClassesDirs"' "${JVMTESTSUITE_PLUGIN}"; then
    echo "ERROR: JvmTestSuitePlugin.java is missing conventionMapping.map for testClassesDirs (fix not applied)" >&2
    test_status=1
fi

if ! grep -q 'getConventionMapping()\.map("classpath"' "${JVMTESTSUITE_PLUGIN}"; then
    echo "ERROR: JvmTestSuitePlugin.java is missing conventionMapping.map for classpath (fix not applied)" >&2
    test_status=1
fi

# Check that AntlrTask.java uses plain FileCollection (not ConfigurableFileCollection) for antlrClasspath
if grep -q 'ConfigurableFileCollection antlrClasspath' "${ANTLR_TASK}"; then
    echo "ERROR: AntlrTask.java has ConfigurableFileCollection antlrClasspath (fix not applied)" >&2
    test_status=1
fi

if [ $test_status -eq 0 ]; then
    echo "All checks passed: JvmTestSuitePlugin uses conventionMapping.map and AntlrTask uses plain FileCollection."
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
