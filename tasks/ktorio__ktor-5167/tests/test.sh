#!/bin/bash

cd /app/src

# Environment variables for Gradle
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
# No test files to copy for this PR

# Override Gradle memory settings to prevent OOM
export GRADLE_OPTS="-Xms512m -Xmx3g -XX:MaxMetaspaceSize=512m -Dorg.gradle.daemon=false -Dorg.gradle.parallel=false"

# This PR removes unsupported targets (JVM, Linux, Windows) from webrtc module
# Verify that the JVM API file has been removed (it shouldn't exist after the fix)
echo "Checking that JVM target API file is removed..."
if [ -f "ktor-client/ktor-client-webrtc/api/jvm/ktor-client-webrtc.api" ]; then
    echo "FAIL: JVM API file still exists (should be removed)"
    test_status=1
else
    echo "PASS: JVM API file correctly removed"
    test_status=0
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
