#!/bin/bash

cd /app/src

# No additional environment variables needed for Gradle tests

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "share-coordinator/src/test/java/org/apache/kafka/coordinator/share"
cp "/tests/share-coordinator/src/test/java/org/apache/kafka/coordinator/share/ShareCoordinatorServiceTest.java" "share-coordinator/src/test/java/org/apache/kafka/coordinator/share/ShareCoordinatorServiceTest.java"

# CRITICAL: Run ONLY the specific test files from the PR, NOT the entire test suite!
# The test files to run are: "share-coordinator/src/test/java/org/apache/kafka/coordinator/share/ShareCoordinatorServiceTest.java"
#
# TODO: Fill in the actual test command to run ONLY these specific files
#
# DO NOT run the entire test suite - it's too slow and may have unrelated failures!
#
# Examples for different languages/frameworks:
#
# Python (pytest with uv):
#   # If using uv venv at /opt/venv:
#   source /opt/venv/bin/activate
#   uv pip install -e . --no-deps 2>/dev/null || true  # Reinstall to pick up changes
#   pytest -xvs path/to/test_file.py
#   # Or without venv activation:
#   /opt/venv/bin/pytest -xvs path/to/test_file.py
#
# JavaScript/TypeScript (IMPORTANT: disable coverage thresholds when running subset!):
#   npx jest path/to/test.js path/to/test2.js --coverage=false
#   npx vitest run path/to/test.ts --coverage.enabled=false
#   npx mocha path/to/test.js path/to/test2.js
#   npx borp path/to/test.js --no-check-coverage   # Used by fastify, pino, etc.
#   npx tap path/to/test.js --no-check-coverage    # Node TAP framework
#   npx ava path/to/test.js                        # AVA framework
#
#   CRITICAL for JS/TS: DO NOT use "npm test" or "npm run test" without args!
#   These run the ENTIRE suite. Pass specific files via the test runner directly.
#   If you must use npm: npm run test -- path/to/test.js (note the -- separator)
#
# Go:
#   go test -v ./path/to/package/...
#   go test -v -run TestSpecificName ./...
#
# Rust:
#   cargo test --test test_name -- --nocapture
#   cargo test specific_test_name -- --nocapture
#
# Ruby (RSpec/Minitest):
#   bundle exec rspec path/to/spec.rb
#   bundle exec ruby -Itest path/to/test.rb
#
# Java (JUnit/Maven/Gradle):
#   mvn test -Dtest=TestClassName
#   gradle test --tests TestClassName

# Restore coordinator-common test files that fix.patch doesn't update
# (bug.patch modifies them but fix.patch doesn't revert them, causing compilation errors)
cp /tmp/head-test-files/MockCoordinator*.java coordinator-common/src/test/java/org/apache/kafka/coordinator/common/runtime/

# Run the specific test class (gradle will automatically recompile changed sources)
./gradlew --no-daemon :share-coordinator:test --tests ShareCoordinatorServiceTest -x checkstyleMain -x checkstyleTest
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
