#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/org/mockito/internal/configuration/plugins"
cp "/tests/java/org/mockito/internal/configuration/plugins/DefaultMockitoPluginsTest.java" "src/test/java/org/mockito/internal/configuration/plugins/DefaultMockitoPluginsTest.java"

# Run the specific test for this PR (on root project)
./gradlew :test --tests org.mockito.internal.configuration.plugins.DefaultMockitoPluginsTest --no-daemon --rerun-tasks
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
