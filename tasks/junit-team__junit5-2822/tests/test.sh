#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "junit-platform-suite-engine/src/main/java/org/junit/platform/suite/engine"
cp "/tests/junit-platform-suite-engine/src/main/java/org/junit/platform/suite/engine/SuiteDidNotDiscoverAnyTests.java" "junit-platform-suite-engine/src/main/java/org/junit/platform/suite/engine/SuiteDidNotDiscoverAnyTests.java"
mkdir -p "platform-tests/src/test/java/org/junit/platform/launcher/core"
cp "/tests/platform-tests/src/test/java/org/junit/platform/launcher/core/CompositeEngineExecutionListenerTests.java" "platform-tests/src/test/java/org/junit/platform/launcher/core/CompositeEngineExecutionListenerTests.java"
mkdir -p "platform-tests/src/test/java/org/junit/platform/suite/engine"
cp "/tests/platform-tests/src/test/java/org/junit/platform/suite/engine/SuiteEngineTests.java" "platform-tests/src/test/java/org/junit/platform/suite/engine/SuiteEngineTests.java"
mkdir -p "platform-tests/src/test/java/org/junit/platform/suite/engine"
cp "/tests/platform-tests/src/test/java/org/junit/platform/suite/engine/SuiteTestDescriptorTests.java" "platform-tests/src/test/java/org/junit/platform/suite/engine/SuiteTestDescriptorTests.java"
mkdir -p "platform-tests/src/test/java/org/junit/platform/suite/engine/testcases"
cp "/tests/platform-tests/src/test/java/org/junit/platform/suite/engine/testcases/EmptyDynamicTestsTestCase.java" "platform-tests/src/test/java/org/junit/platform/suite/engine/testcases/EmptyDynamicTestsTestCase.java"
mkdir -p "platform-tests/src/test/java/org/junit/platform/suite/engine/testcases"
cp "/tests/platform-tests/src/test/java/org/junit/platform/suite/engine/testcases/EmptyTestTestCase.java" "platform-tests/src/test/java/org/junit/platform/suite/engine/testcases/EmptyTestTestCase.java"
mkdir -p "platform-tests/src/test/java/org/junit/platform/suite/engine/testsuites"
cp "/tests/platform-tests/src/test/java/org/junit/platform/suite/engine/testsuites/DynamicSuite.java" "platform-tests/src/test/java/org/junit/platform/suite/engine/testsuites/DynamicSuite.java"
mkdir -p "platform-tests/src/test/java/org/junit/platform/suite/engine/testsuites"
cp "/tests/platform-tests/src/test/java/org/junit/platform/suite/engine/testsuites/EmptyDynamicTestSuite.java" "platform-tests/src/test/java/org/junit/platform/suite/engine/testsuites/EmptyDynamicTestSuite.java"
mkdir -p "platform-tests/src/test/java/org/junit/platform/suite/engine/testsuites"
cp "/tests/platform-tests/src/test/java/org/junit/platform/suite/engine/testsuites/EmptyDynamicTestWithFailIfNoTestFalseSuite.java" "platform-tests/src/test/java/org/junit/platform/suite/engine/testsuites/EmptyDynamicTestWithFailIfNoTestFalseSuite.java"
mkdir -p "platform-tests/src/test/java/org/junit/platform/suite/engine/testsuites"
cp "/tests/platform-tests/src/test/java/org/junit/platform/suite/engine/testsuites/EmptyTestCaseSuite.java" "platform-tests/src/test/java/org/junit/platform/suite/engine/testsuites/EmptyTestCaseSuite.java"
mkdir -p "platform-tests/src/test/java/org/junit/platform/suite/engine/testsuites"
cp "/tests/platform-tests/src/test/java/org/junit/platform/suite/engine/testsuites/EmptyTestCaseWithFailIfNoTestFalseSuite.java" "platform-tests/src/test/java/org/junit/platform/suite/engine/testsuites/EmptyTestCaseWithFailIfNoTestFalseSuite.java"

# Rebuild test classes to pick up the changes
./gradlew :platform-tests:testClasses --no-daemon --no-parallel

# Run the specific test classes from this PR
./gradlew :platform-tests:test \
    --tests org.junit.platform.launcher.core.CompositeEngineExecutionListenerTests \
    --tests org.junit.platform.suite.engine.SuiteEngineTests \
    --tests org.junit.platform.suite.engine.SuiteTestDescriptorTests \
    --no-daemon --no-parallel 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
