#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/org/mockito/internal/creation/proxy"
cp "/tests/java/org/mockito/internal/creation/proxy/ProxyMockMakerTest.java" "src/test/java/org/mockito/internal/creation/proxy/ProxyMockMakerTest.java"
mkdir -p "subprojects/proxy/src/test/java/org/mockitoproxy"
cp "/tests/subprojects/proxy/src/test/java/org/mockitoproxy/MocksTest.java" "subprojects/proxy/src/test/java/org/mockitoproxy/MocksTest.java"

# Recompile tests to pick up the updated test files
./gradlew testClasses --no-daemon || true

# Run the specific tests for this PR
# Run both tests - ProxyMockMakerTest in root project and MocksTest in proxy subproject
./gradlew :test --tests org.mockito.internal.creation.proxy.ProxyMockMakerTest \
  :proxy:test --tests org.mockitoproxy.MocksTest \
  --no-daemon --rerun-tasks
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
