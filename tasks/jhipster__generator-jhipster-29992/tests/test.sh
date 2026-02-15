#!/bin/bash

cd /app/src

# Set environment variables for tests
export CI=true
export NODE_ENV=test

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "generators/docker-compose"
cp "/tests/generators/docker-compose/docker-compose.spec.ts" "generators/docker-compose/docker-compose.spec.ts"
mkdir -p "generators/kubernetes-helm"
cp "/tests/generators/kubernetes-helm/kubernetes.helm.spec.ts" "generators/kubernetes-helm/kubernetes.helm.spec.ts"
mkdir -p "generators/kubernetes-knative"
cp "/tests/generators/kubernetes-knative/knative.spec.ts" "generators/kubernetes-knative/knative.spec.ts"
mkdir -p "generators/kubernetes"
cp "/tests/generators/kubernetes/kubernetes.spec.ts" "generators/kubernetes/kubernetes.spec.ts"

# Rebuild to compile the updated test files
npm run build

# Run only the specific test files for this PR
# Include lib/jdl directory in the command like the full test suite does
# This sets up the test environment properly for deployment tests
npx esmocha --no-insight --forbid-only --parallel --max-old-space-size=4096 \
  lib/jdl \
  generators/docker-compose/docker-compose.spec.ts \
  generators/kubernetes-helm/kubernetes.helm.spec.ts \
  generators/kubernetes-knative/knative.spec.ts \
  generators/kubernetes/kubernetes.spec.ts
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
