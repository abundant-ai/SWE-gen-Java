#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "testing/internal-integ-testing/src/main/groovy/org/gradle/test/fixtures/server/http"
cp "/tests/testing/internal-integ-testing/src/main/groovy/org/gradle/test/fixtures/server/http/HttpServerFixture.groovy" "testing/internal-integ-testing/src/main/groovy/org/gradle/test/fixtures/server/http/HttpServerFixture.groovy"
mkdir -p "testing/internal-integ-testing/src/main/groovy/org/gradle/test/fixtures/server/http"
cp "/tests/testing/internal-integ-testing/src/main/groovy/org/gradle/test/fixtures/server/http/TestProxyServer.groovy" "testing/internal-integ-testing/src/main/groovy/org/gradle/test/fixtures/server/http/TestProxyServer.groovy"

GRADLE_PROPERTIES="gradle.properties"
GRADLE_WRAPPER="gradle/wrapper/gradle-wrapper.properties"

test_status=0

# The fix adds kotlin.incremental.useClasspathSnapshot=true to gradle.properties
if ! grep -q 'kotlin.incremental.useClasspathSnapshot=true' "${GRADLE_PROPERTIES}"; then
    echo "ERROR: gradle.properties is missing kotlin.incremental.useClasspathSnapshot=true (fix not applied)" >&2
    test_status=1
fi

# The fix upgrades the Gradle wrapper from milestone-10 to rc-1
if ! grep -q 'gradle-9.0.0-rc-1-bin.zip' "${GRADLE_WRAPPER}"; then
    echo "ERROR: gradle-wrapper.properties is not using gradle-9.0.0-rc-1 (fix not applied)" >&2
    test_status=1
fi

if [ $test_status -eq 0 ]; then
    echo "All checks passed: gradle.properties and gradle-wrapper.properties reflect the fix."
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
