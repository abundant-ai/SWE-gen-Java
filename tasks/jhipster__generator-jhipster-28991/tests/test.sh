#!/bin/bash

cd /app/src

# Set environment variables for tests
export CI=true
export NODE_ENV=test

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "generators/java"
cp "/tests/generators/java/generator.spec.ts" "generators/java/generator.spec.ts"
mkdir -p "generators/java/support"
cp "/tests/generators/java/support/java-file-edit.spec.ts" "generators/java/support/java-file-edit.spec.ts"

# Rebuild to compile the updated test files
npm run build

# Link the generator globally so tests can find it
npm install -g .

# Run the new test file added in this PR
npx esmocha --no-insight --forbid-only --max-old-space-size=4096 \
  generators/java/support/java-file-edit.spec.ts
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
