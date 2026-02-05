#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "platform-tests/src/test/java/org/junit/platform/engine/discovery"
cp "/tests/platform-tests/src/test/java/org/junit/platform/engine/discovery/DiscoverySelectorsTests.java" "platform-tests/src/test/java/org/junit/platform/engine/discovery/DiscoverySelectorsTests.java"
mkdir -p "platform-tests/src/test/java/org/junit/platform/engine/support/descriptor"
cp "/tests/platform-tests/src/test/java/org/junit/platform/engine/support/descriptor/PackageSourceTests.java" "platform-tests/src/test/java/org/junit/platform/engine/support/descriptor/PackageSourceTests.java"
mkdir -p "platform-tests/src/test/java/org/junit/platform/launcher/core"
cp "/tests/platform-tests/src/test/java/org/junit/platform/launcher/core/DiscoveryIssueCollectorTests.java" "platform-tests/src/test/java/org/junit/platform/launcher/core/DiscoveryIssueCollectorTests.java"

# Run the specific tests for this PR
./gradlew :platform-tests:test --tests "*DiscoverySelectorsTests" --tests "*PackageSourceTests" --tests "*DiscoveryIssueCollectorTests" --no-daemon --no-configuration-cache
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
