#!/bin/bash

cd /app/src

# Set environment variables for tests
export CI=true
export NODE_ENV=test

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "generators/languages"
cp "/tests/generators/languages/generator-needles.spec.ts" "generators/languages/generator-needles.spec.ts"
mkdir -p "generators/liquibase"
cp "/tests/generators/liquibase/needles.spec.ts" "generators/liquibase/needles.spec.ts"
mkdir -p "generators/maven"
cp "/tests/generators/maven/needles.spec.ts" "generators/maven/needles.spec.ts"
mkdir -p "generators/server"
cp "/tests/generators/server/needle-logback.spec.ts" "generators/server/needle-logback.spec.ts"
mkdir -p "generators/spring-cache"
cp "/tests/generators/spring-cache/needles.spec.ts" "generators/spring-cache/needles.spec.ts"

# Rebuild to compile the updated test files
npm run build

# Run only the specific test files for this PR
npx esmocha --no-insight --forbid-only --parallel --max-old-space-size=4096 \
  lib/jdl \
  generators/languages/generator-needles.spec.ts \
  generators/liquibase/needles.spec.ts \
  generators/maven/needles.spec.ts \
  generators/server/needle-logback.spec.ts \
  generators/spring-cache/needles.spec.ts
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
