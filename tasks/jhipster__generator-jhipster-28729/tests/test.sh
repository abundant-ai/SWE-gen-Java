#!/bin/bash

cd /app/src

# Set environment variables for tests
export CI=true
export NODE_ENV=test

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "generators/spring-boot/templates/src/test/java/_package_/security/jwt"
cp "/tests/generators/spring-boot/templates/src/test/java/_package_/security/jwt/TestAuthenticationResource.java.ejs" "generators/spring-boot/templates/src/test/java/_package_/security/jwt/TestAuthenticationResource.java.ejs"
mkdir -p "generators/spring-boot/templates/src/test/java/_package_/security/jwt"
cp "/tests/generators/spring-boot/templates/src/test/java/_package_/security/jwt/TokenAuthenticationIT.java.ejs" "generators/spring-boot/templates/src/test/java/_package_/security/jwt/TokenAuthenticationIT.java.ejs"
mkdir -p "generators/spring-boot/templates/src/test/java/_package_/security/jwt"
cp "/tests/generators/spring-boot/templates/src/test/java/_package_/security/jwt/TokenAuthenticationSecurityMetersIT.java.ejs" "generators/spring-boot/templates/src/test/java/_package_/security/jwt/TokenAuthenticationSecurityMetersIT.java.ejs"
mkdir -p "generators/spring-boot/templates/src/test/java/_package_/web/filter"
cp "/tests/generators/spring-boot/templates/src/test/java/_package_/web/filter/SpaWebFilterIT_imperative.java.ejs" "generators/spring-boot/templates/src/test/java/_package_/web/filter/SpaWebFilterIT_imperative.java.ejs"
mkdir -p "generators/spring-boot/templates/src/test/java/_package_/web/filter"
cp "/tests/generators/spring-boot/templates/src/test/java/_package_/web/filter/SpaWebFilterIT_reactive.java.ejs" "generators/spring-boot/templates/src/test/java/_package_/web/filter/SpaWebFilterIT_reactive.java.ejs"
mkdir -p "generators/spring-boot/templates/src/test/java/_package_/web/rest"
cp "/tests/generators/spring-boot/templates/src/test/java/_package_/web/rest/AccountResourceIT.java.ejs" "generators/spring-boot/templates/src/test/java/_package_/web/rest/AccountResourceIT.java.ejs"
mkdir -p "generators/spring-boot/templates/src/test/java/_package_/web/rest"
cp "/tests/generators/spring-boot/templates/src/test/java/_package_/web/rest/AccountResourceIT_oauth2.java.ejs" "generators/spring-boot/templates/src/test/java/_package_/web/rest/AccountResourceIT_oauth2.java.ejs"
mkdir -p "generators/spring-boot/templates/src/test/java/_package_/web/rest"
cp "/tests/generators/spring-boot/templates/src/test/java/_package_/web/rest/AccountResourceIT_skipUserManagement.java.ejs" "generators/spring-boot/templates/src/test/java/_package_/web/rest/AccountResourceIT_skipUserManagement.java.ejs"

# Rebuild to compile the updated test templates
npm run build

# Link the generator globally so tests can find it
npm install -g .

# Run only the specific test file for this PR
# The spring-boot generator test will use the updated template files
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
