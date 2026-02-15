#!/bin/bash

cd /app/src

# Set environment variables for tests
export CI=true
export NODE_ENV=test

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "generators/bootstrap-application"
cp "/tests/generators/bootstrap-application/generator.spec.ts" "generators/bootstrap-application/generator.spec.ts"

# Rebuild to compile the updated test files
npm run build

# Run only the specific test files for this PR
# Include lib/jdl directory in the command to set up the test environment properly
# Note: Not using --parallel to avoid potential race conditions in test setup
npx esmocha --no-insight --forbid-only --max-old-space-size=4096 \
  lib/jdl \
  generators/bootstrap-application/generator.spec.ts
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
