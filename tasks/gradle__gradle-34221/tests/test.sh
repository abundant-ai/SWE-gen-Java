#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "platforms/software/testing-base-infrastructure/src/main/java/org/gradle/api/internal/tasks/testing/worker"
cp "/tests/platforms/software/testing-base-infrastructure/src/main/java/org/gradle/api/internal/tasks/testing/worker/TestWorker.java" "platforms/software/testing-base-infrastructure/src/main/java/org/gradle/api/internal/tasks/testing/worker/TestWorker.java"

SECURITY_MANAGER_REF_JAVA="platforms/software/testing-base-infrastructure/src/main/java/org/gradle/api/internal/tasks/testing/worker/SecurityManagerRef.java"

test_status=0

# Check that SecurityManagerRef.java exists (fix creates this file)
if [ ! -f "${SECURITY_MANAGER_REF_JAVA}" ]; then
    echo "ERROR: SecurityManagerRef.java does not exist (fix not applied - file was removed in bug state)" >&2
    test_status=1
fi

# Check that SecurityManagerRef.java has getOrFake() method (fix applied)
if [ -f "${SECURITY_MANAGER_REF_JAVA}" ] && ! grep -q 'getOrFake' "${SECURITY_MANAGER_REF_JAVA}"; then
    echo "ERROR: SecurityManagerRef.java does not have getOrFake() method (fix not applied)" >&2
    test_status=1
fi

# Check that SecurityManagerRef.java has reinstall() method (fix applied)
if [ -f "${SECURITY_MANAGER_REF_JAVA}" ] && ! grep -q 'reinstall' "${SECURITY_MANAGER_REF_JAVA}"; then
    echo "ERROR: SecurityManagerRef.java does not have reinstall() method (fix not applied)" >&2
    test_status=1
fi

if [ $test_status -eq 0 ]; then
    echo "All checks passed: SecurityManagerRef.java exists with proper getOrFake() and reinstall() implementation."
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
