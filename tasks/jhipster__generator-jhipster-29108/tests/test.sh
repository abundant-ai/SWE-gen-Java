#!/bin/bash

cd /app/src

# Set environment variables for tests
export CI=true
export NODE_ENV=test

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "generators/spring-boot/templates/src/test/java/_package_/security"
cp "/tests/generators/spring-boot/templates/src/test/java/_package_/security/SecurityUtilsUnitTest_imperative.java.ejs" "generators/spring-boot/templates/src/test/java/_package_/security/SecurityUtilsUnitTest_imperative.java.ejs"
mkdir -p "generators/spring-boot/templates/src/test/java/_package_/security"
cp "/tests/generators/spring-boot/templates/src/test/java/_package_/security/SecurityUtilsUnitTest_reactive.java.ejs" "generators/spring-boot/templates/src/test/java/_package_/security/SecurityUtilsUnitTest_reactive.java.ejs"
mkdir -p "generators/spring-boot/templates/src/test/java/_package_/security/jwt"
cp "/tests/generators/spring-boot/templates/src/test/java/_package_/security/jwt/JwtAuthenticationTestUtils.java.ejs" "generators/spring-boot/templates/src/test/java/_package_/security/jwt/JwtAuthenticationTestUtils.java.ejs"

# Rebuild to compile the updated test files
npm run build

# Link the generator globally so tests can find it
npm link

# Run only the specific test files for this PR
# The PR modified security test templates in spring-boot generator and updated app snapshots
# Include lib/jdl directory in the command to set up the test environment properly
npx esmocha --no-insight --forbid-only --max-old-space-size=4096 \
  lib/jdl \
  generators/spring-boot/generator.spec.ts \
  generators/app/generator.spec.ts
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
