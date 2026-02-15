#!/bin/bash

cd /app/src

# Set environment variables for tests
export CI=true
export NODE_ENV=test

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "generators/base-core/support"
cp "/tests/generators/base-core/support/needles.spec.ts" "generators/base-core/support/needles.spec.ts"

# Rebuild to compile the updated test files
npm run build

# Run only the specific test file for this PR
npx esmocha --no-insight --forbid-only --parallel --max-old-space-size=4096 \
  generators/base-core/support/needles.spec.ts
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
