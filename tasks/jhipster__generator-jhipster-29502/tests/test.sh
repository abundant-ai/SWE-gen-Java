#!/bin/bash

cd /app/src

# Set environment variables for tests
export CI=true
export NODE_ENV=test

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "generators/angular"
cp "/tests/generators/angular/generator.spec.ts" "generators/angular/generator.spec.ts"
mkdir -p "generators/app"
cp "/tests/generators/app/generator.spec.ts" "generators/app/generator.spec.ts"
mkdir -p "generators/client"
cp "/tests/generators/client/generator.spec.ts" "generators/client/generator.spec.ts"
mkdir -p "generators/client"
cp "/tests/generators/client/prompts.spec.ts" "generators/client/prompts.spec.ts"
mkdir -p "generators/entity"
cp "/tests/generators/entity/database-changelog.spec.ts" "generators/entity/database-changelog.spec.ts"
mkdir -p "generators/entity"
cp "/tests/generators/entity/single-entity.spec.ts" "generators/entity/single-entity.spec.ts"
mkdir -p "generators/react"
cp "/tests/generators/react/generator.spec.ts" "generators/react/generator.spec.ts"
mkdir -p "generators/vue"
cp "/tests/generators/vue/generator.spec.ts" "generators/vue/generator.spec.ts"

# Rebuild to compile the updated test files
npm run build

# Run only the specific test files for this PR
# Include lib/jdl directory in the command to set up the test environment properly
npx esmocha --no-insight --forbid-only --parallel --max-old-space-size=4096 \
  lib/jdl \
  generators/angular/generator.spec.ts \
  generators/app/generator.spec.ts \
  generators/client/generator.spec.ts \
  generators/client/prompts.spec.ts \
  generators/entity/database-changelog.spec.ts \
  generators/entity/single-entity.spec.ts \
  generators/react/generator.spec.ts \
  generators/vue/generator.spec.ts
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
