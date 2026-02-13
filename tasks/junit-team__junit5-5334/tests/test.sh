#!/bin/bash

cd /app/src

# Set environment variables for tests
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "junit-platform-engine/src/testFixtures/java/org/junit/platform/fakes"
cp "/tests/junit-platform-engine/src/testFixtures/java/org/junit/platform/fakes/TestEngineStub.java" "junit-platform-engine/src/testFixtures/java/org/junit/platform/fakes/TestEngineStub.java"
mkdir -p "platform-tests/src/test/java/org/junit/platform/launcher/core"
cp "/tests/platform-tests/src/test/java/org/junit/platform/launcher/core/DiscoveryIssueCollectorTests.java" "platform-tests/src/test/java/org/junit/platform/launcher/core/DiscoveryIssueCollectorTests.java"
mkdir -p "platform-tests/src/test/java/org/junit/platform/launcher/core"
cp "/tests/platform-tests/src/test/java/org/junit/platform/launcher/core/DiscoveryIssueReportingDiscoveryListenerTests.java" "platform-tests/src/test/java/org/junit/platform/launcher/core/DiscoveryIssueReportingDiscoveryListenerTests.java"
mkdir -p "platform-tests/src/test/java/org/junit/platform/suite/engine"
cp "/tests/platform-tests/src/test/java/org/junit/platform/suite/engine/SuiteEngineTests.java" "platform-tests/src/test/java/org/junit/platform/suite/engine/SuiteEngineTests.java"
mkdir -p "platform-tests/src/test/java/org/junit/platform/suite/engine/error"
cp "/tests/platform-tests/src/test/java/org/junit/platform/suite/engine/error/ErrorSelector.java" "platform-tests/src/test/java/org/junit/platform/suite/engine/error/ErrorSelector.java"
mkdir -p "platform-tests/src/test/java/org/junit/platform/suite/engine/error"
cp "/tests/platform-tests/src/test/java/org/junit/platform/suite/engine/error/ErrorSelectorIdentifierParser.java" "platform-tests/src/test/java/org/junit/platform/suite/engine/error/ErrorSelectorIdentifierParser.java"
mkdir -p "platform-tests/src/test/java/org/junit/platform/suite/engine/error"
cp "/tests/platform-tests/src/test/java/org/junit/platform/suite/engine/error/SelectorProcessingErrorCausingEngine.java" "platform-tests/src/test/java/org/junit/platform/suite/engine/error/SelectorProcessingErrorCausingEngine.java"
mkdir -p "platform-tests/src/test/java/org/junit/platform/suite/engine/error"
cp "/tests/platform-tests/src/test/java/org/junit/platform/suite/engine/error/package-info.java" "platform-tests/src/test/java/org/junit/platform/suite/engine/error/package-info.java"
mkdir -p "platform-tests/src/test/java/org/junit/platform/suite/engine/testsuites"
cp "/tests/platform-tests/src/test/java/org/junit/platform/suite/engine/testsuites/SelectorProcessingErrorTestSuite.java" "platform-tests/src/test/java/org/junit/platform/suite/engine/testsuites/SelectorProcessingErrorTestSuite.java"
mkdir -p "platform-tests/src/test/resources/META-INF/services"
cp "/tests/platform-tests/src/test/resources/META-INF/services/org.junit.platform.engine.discovery.DiscoverySelectorIdentifierParser" "platform-tests/src/test/resources/META-INF/services/org.junit.platform.engine.discovery.DiscoverySelectorIdentifierParser"
mkdir -p "platform-tests/src/test/resources/error-engine/META-INF/services"
cp "/tests/platform-tests/src/test/resources/error-engine/META-INF/services/org.junit.platform.engine.TestEngine" "platform-tests/src/test/resources/error-engine/META-INF/services/org.junit.platform.engine.TestEngine"

# Recompile tests since we copied new test files
echo "==== Recompiling test classes ===="
./gradlew --no-daemon testClasses --no-configuration-cache 2>&1 | tee /tmp/compile.log
compile_exit=$?
echo "Compile exit code: $compile_exit"

# Run tests with explicit colon prefix
echo "==== Running tests with filters ===="
./gradlew --no-daemon :platform-tests:test \
  --tests "*DiscoveryIssueCollectorTests" \
  --tests "*DiscoveryIssueReportingDiscoveryListenerTests" \
  --tests "*SuiteEngineTests" \
  --no-configuration-cache 2>&1 | tee /tmp/test.log
test_status=$?
echo "==== Test exit code: $test_status ===="

# If tests didn't run, show more info
if [ $test_status -ne 0 ]; then
  echo "==== Showing last 50 lines of test log ===="
  tail -50 /tmp/test.log
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
