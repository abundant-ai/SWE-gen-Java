#!/bin/bash

cd /app/src

# Set environment variables for tests
export CI=true
export NODE_ENV=test

# Apply fix.patch to restore the fixed state
patch -p1 < /solution/fix.patch

# Copy HEAD test template files from /tests (these are not in fix.patch but were reverted by bug.patch)
mkdir -p "generators/spring-boot/templates/src/test/java/_package_/_entityPackage_/service"
cp "/tests/generators/spring-boot/templates/src/test/java/_package_/_entityPackage_/service/UserServiceIT.java.ejs" "generators/spring-boot/templates/src/test/java/_package_/_entityPackage_/service/UserServiceIT.java.ejs"
mkdir -p "generators/spring-boot/templates/src/test/java/_package_/security/jwt"
cp "/tests/generators/spring-boot/templates/src/test/java/_package_/security/jwt/JwtAuthenticationTestUtils.java.ejs" "generators/spring-boot/templates/src/test/java/_package_/security/jwt/JwtAuthenticationTestUtils.java.ejs"
mkdir -p "generators/spring-boot/templates/src/test/java/_package_/security/oauth2"
cp "/tests/generators/spring-boot/templates/src/test/java/_package_/security/oauth2/CustomClaimConverterIT.java.ejs" "generators/spring-boot/templates/src/test/java/_package_/security/oauth2/CustomClaimConverterIT.java.ejs"
mkdir -p "generators/spring-boot/templates/src/test/java/_package_/service"
cp "/tests/generators/spring-boot/templates/src/test/java/_package_/service/MailServiceIT.java.ejs" "generators/spring-boot/templates/src/test/java/_package_/service/MailServiceIT.java.ejs"

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
