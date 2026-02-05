#!/bin/bash

cd /app/src

# Remove files that were deleted/renamed in HEAD
rm -f "jupiter-tests/src/test/java/org/junit/jupiter/api/extension/MediaTypeTests.java"

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "documentation/src/test/java/example"
cp "/tests/documentation/src/test/java/example/TestReporterDemo.java" "documentation/src/test/java/example/TestReporterDemo.java"
mkdir -p "junit-jupiter-api/src/main/java/org/junit/jupiter/api"
cp "/tests/junit-jupiter-api/src/main/java/org/junit/jupiter/api/TestReporter.java" "junit-jupiter-api/src/main/java/org/junit/jupiter/api/TestReporter.java"
mkdir -p "jupiter-tests/src/test/java/org/junit/jupiter/api"
cp "/tests/jupiter-tests/src/test/java/org/junit/jupiter/api/MediaTypeTests.java" "jupiter-tests/src/test/java/org/junit/jupiter/api/MediaTypeTests.java"
mkdir -p "jupiter-tests/src/test/java/org/junit/jupiter/api/extension"
cp "/tests/jupiter-tests/src/test/java/org/junit/jupiter/api/extension/DeprecatedMediaTypeTests.java" "jupiter-tests/src/test/java/org/junit/jupiter/api/extension/DeprecatedMediaTypeTests.java"
mkdir -p "jupiter-tests/src/test/java/org/junit/jupiter/api/extension"
cp "/tests/jupiter-tests/src/test/java/org/junit/jupiter/api/extension/MediaTypeInteroperabilityTests.java" "jupiter-tests/src/test/java/org/junit/jupiter/api/extension/MediaTypeInteroperabilityTests.java"
mkdir -p "jupiter-tests/src/test/java/org/junit/jupiter/engine"
cp "/tests/jupiter-tests/src/test/java/org/junit/jupiter/engine/ReportingTests.java" "jupiter-tests/src/test/java/org/junit/jupiter/engine/ReportingTests.java"
mkdir -p "jupiter-tests/src/test/java/org/junit/jupiter/engine/descriptor"
cp "/tests/jupiter-tests/src/test/java/org/junit/jupiter/engine/descriptor/ExtensionContextTests.java" "jupiter-tests/src/test/java/org/junit/jupiter/engine/descriptor/ExtensionContextTests.java"
mkdir -p "jupiter-tests/src/test/java/org/junit/jupiter/engine/extension"
cp "/tests/jupiter-tests/src/test/java/org/junit/jupiter/engine/extension/DefaultTestReporterTests.java" "jupiter-tests/src/test/java/org/junit/jupiter/engine/extension/DefaultTestReporterTests.java"
mkdir -p "jupiter-tests/src/test/java/org/junit/jupiter/params"
cp "/tests/jupiter-tests/src/test/java/org/junit/jupiter/params/ParameterizedTestExtensionTests.java" "jupiter-tests/src/test/java/org/junit/jupiter/params/ParameterizedTestExtensionTests.java"
mkdir -p "platform-tests/src/test/java/org/junit/platform/launcher/jfr"
cp "/tests/platform-tests/src/test/java/org/junit/platform/launcher/jfr/FlightRecordingExecutionListenerIntegrationTests.java" "platform-tests/src/test/java/org/junit/platform/launcher/jfr/FlightRecordingExecutionListenerIntegrationTests.java"
mkdir -p "platform-tests/src/test/java/org/junit/platform/suite/engine/testcases"
cp "/tests/platform-tests/src/test/java/org/junit/platform/suite/engine/testcases/SingleTestTestCase.java" "platform-tests/src/test/java/org/junit/platform/suite/engine/testcases/SingleTestTestCase.java"
mkdir -p "platform-tooling-support-tests/src/archUnit/java/platform/tooling/support/tests"
cp "/tests/platform-tooling-support-tests/src/archUnit/java/platform/tooling/support/tests/ArchUnitTests.java" "platform-tooling-support-tests/src/archUnit/java/platform/tooling/support/tests/ArchUnitTests.java"
mkdir -p "platform-tooling-support-tests/src/test/java/platform/tooling/support/tests"
cp "/tests/platform-tooling-support-tests/src/test/java/platform/tooling/support/tests/OutputAttachingExtension.java" "platform-tooling-support-tests/src/test/java/platform/tooling/support/tests/OutputAttachingExtension.java"

# Run the specific tests for this PR
./gradlew :jupiter-tests:test --tests "*MediaTypeTests" --tests "*DeprecatedMediaTypeTests" --tests "*MediaTypeInteroperabilityTests" --tests "*ReportingTests" --tests "*ExtensionContextTests" --tests "*DefaultTestReporterTests" --tests "*ParameterizedTestExtensionTests" :platform-tests:test --tests "*FlightRecordingExecutionListenerIntegrationTests" --tests "*SingleTestTestCase" :platform-tooling-support-tests:archUnit --tests "*ArchUnitTests" --no-daemon --no-configuration-cache
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
