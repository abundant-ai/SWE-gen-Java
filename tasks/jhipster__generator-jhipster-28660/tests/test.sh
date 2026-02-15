#!/bin/bash

cd /app/src

# Set environment variables for tests
export CI=true
export NODE_ENV=test

# Apply fix.patch to restore the fixed state
patch -p1 < /solution/fix.patch

# Rebuild to compile the fix
npm run build

# Link the generator globally so tests can find it
npm link

# Run only the specific test file for this PR
npx esmocha --no-insight --forbid-only --max-old-space-size=4096 \
  lib/jdl \
  generators/spring-boot/generator.spec.ts
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
