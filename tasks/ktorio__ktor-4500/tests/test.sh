#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "buildSrc/src/main/kotlin/test/server"
cp "/tests/buildSrc/src/main/kotlin/test/server/TestServer.kt" "buildSrc/src/main/kotlin/test/server/TestServer.kt"

# Compile buildSrc to verify the jakarta import resolves correctly
# Run as standalone buildSrc project (cache is pre-warmed by Docker build phase)
./gradlew -p buildSrc compileKotlin --no-daemon 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
