#!/bin/bash

cd /app/src

# Set environment variables for tests
export CI=true
export NODE_ENV=test
export NODE_OPTIONS="--max-old-space-size=4096"

# Copy HEAD test snapshot from /tests (overwrites BASE state)
mkdir -p "test/__snapshots__"
cp "/tests/__snapshots__/api.spec.js.snap" "test/__snapshots__/api.spec.js.snap"

# Rebuild to ensure dist/ is up to date (needed after solve.sh applies fix.patch)
npm run build

# Link the generator globally so tests can find it
npm link

# Run the API snapshot test
npx esmocha --no-insight --forbid-only --max-old-space-size=4096 \
  test/api.spec.js
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
