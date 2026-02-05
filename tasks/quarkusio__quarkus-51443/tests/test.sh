#!/bin/bash

cd /app/src

# Set environment variables for test execution
export LANG=en_US.UTF-8

# Copy HEAD test files from /tests (overwrites BASE state)
# No test files to copy - new test files are already in the BASE state from bug.patch

# Run the specific test class from this PR
# NOTE: This test checks LEGACY (deprecated) behavior using quarkus.openshift.containers.*
# In the BUGGY state (BASE): deprecated support exists, so test PASSES
# In the FIXED state (HEAD): deprecated support removed, so test FAILS
# Therefore, we INVERT the result: failure = correct (reward=1), success = buggy (reward=0)
mvn -e -B --settings .github/mvn-settings.xml \
  -pl integration-tests/kubernetes/quarkus-standard-way \
  -Dtest=OpenshiftWithLegacySidecarTest \
  test
test_status=$?

if [ $test_status -eq 0 ]; then
  # Test passed = deprecated support works = BUGGY behavior
  echo 0 > /logs/verifier/reward.txt
else
  # Test failed = deprecated support removed = FIXED behavior
  echo 1 > /logs/verifier/reward.txt
fi

# Return success to Harbor regardless of test result
exit 0
