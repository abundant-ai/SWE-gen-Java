#!/bin/bash

cd /app/src

export TESTCONTAINERS_RYUK_DISABLED=true
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "http-client/src/test/groovy/io/micronaut/http/body"
cp "/tests/http-client/src/test/groovy/io/micronaut/http/body/BodyReadersSpec.groovy" "http-client/src/test/groovy/io/micronaut/http/body/BodyReadersSpec.groovy"
mkdir -p "http-client/src/test/groovy/io/micronaut/http/client/services"
cp "/tests/http-client/src/test/groovy/io/micronaut/http/client/services/ManualHttpServiceDefinitionSpec.groovy" "http-client/src/test/groovy/io/micronaut/http/client/services/ManualHttpServiceDefinitionSpec.groovy"
mkdir -p "test-suite/src/test/groovy/io/micronaut/docs/http/client/proxy"
cp "/tests/test-suite/src/test/groovy/io/micronaut/docs/http/client/proxy/ProxyRequestSpec.groovy" "test-suite/src/test/groovy/io/micronaut/docs/http/client/proxy/ProxyRequestSpec.groovy"

# Update timestamps to force Gradle to detect changes
touch http-client/src/test/groovy/io/micronaut/http/body/*.groovy 2>/dev/null || true
touch http-client/src/test/groovy/io/micronaut/http/body/*.java 2>/dev/null || true
touch http-client/src/test/groovy/io/micronaut/http/client/services/*.groovy 2>/dev/null || true
touch http-client/src/test/groovy/io/micronaut/http/client/services/*.java 2>/dev/null || true
touch test-suite/src/test/groovy/io/micronaut/docs/http/client/proxy/*.groovy 2>/dev/null || true
touch test-suite/src/test/groovy/io/micronaut/docs/http/client/proxy/*.java 2>/dev/null || true

# Remove compiled classes to force recompilation with the new test files
rm -rf http-client/build/classes/ 2>/dev/null || true
rm -rf test-suite/build/classes/ 2>/dev/null || true

# Run the specific tests for this PR
set +e  # Don't exit on error, we'll check manually

cd http-client
test_output=$(../gradlew test --tests "io.micronaut.http.body.BodyReadersSpec" \
  --tests "io.micronaut.http.client.services.ManualHttpServiceDefinitionSpec" \
  --no-daemon --console=plain 2>&1)
test_status_1=$?
cd ..

echo "$test_output"

cd test-suite
test_output=$(../gradlew test --tests "io.micronaut.docs.http.client.proxy.ProxyRequestSpec" \
  --no-daemon --console=plain 2>&1)
test_status_2=$?
cd ..

echo "$test_output"

set -e

# Both test commands must succeed
if [ $test_status_1 -eq 0 ] && [ $test_status_2 -eq 0 ]; then
  test_status=0
else
  test_status=1
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
