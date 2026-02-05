#!/bin/bash

cd /app/src

export TESTCONTAINERS_RYUK_DISABLED=true
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "http-client/src/test/groovy/io/micronaut/http/client/netty"
cp "/tests/http-client/src/test/groovy/io/micronaut/http/client/netty/ConnectionManagerSpec.groovy" "http-client/src/test/groovy/io/micronaut/http/client/netty/ConnectionManagerSpec.groovy"
mkdir -p "management/src/test/groovy/io/micronaut/management/health/indicator/client"
cp "/tests/management/src/test/groovy/io/micronaut/management/health/indicator/client/ServiceHttpClientHealthIndicatorSpec.groovy" "management/src/test/groovy/io/micronaut/management/health/indicator/client/ServiceHttpClientHealthIndicatorSpec.groovy"
mkdir -p "test-suite-groovy/src/test/groovy/io/micronaut/docs/http/server/stream"
cp "/tests/test-suite-groovy/src/test/groovy/io/micronaut/docs/http/server/stream/StreamControllerSpec.groovy" "test-suite-groovy/src/test/groovy/io/micronaut/docs/http/server/stream/StreamControllerSpec.groovy"

# Update timestamps to force Gradle to detect changes
touch http-client/src/test/groovy/io/micronaut/http/client/netty/*.groovy
touch management/src/test/groovy/io/micronaut/management/health/indicator/client/*.groovy
touch test-suite-groovy/src/test/groovy/io/micronaut/docs/http/server/stream/*.groovy

# Remove compiled test classes to force recompilation with the new test files
rm -rf http-client/build/classes/groovy/test/io/micronaut/http/client/netty/*.class
rm -rf management/build/classes/groovy/test/io/micronaut/management/health/indicator/client/*.class
rm -rf test-suite-groovy/build/classes/groovy/test/io/micronaut/docs/http/server/stream/*.class

# Run the specific tests - each module separately to ensure they all run
./gradlew :http-client:cleanTest :http-client:test --tests "*ConnectionManagerSpec" --no-daemon --console=plain
test1_status=$?

./gradlew :management:cleanTest :management:test --tests "*ServiceHttpClientHealthIndicatorSpec" --no-daemon --console=plain
test2_status=$?

./gradlew :test-suite-groovy:cleanTest :test-suite-groovy:test --tests "*StreamControllerSpec" --no-daemon --console=plain
test3_status=$?

# All tests must pass
if [ $test1_status -eq 0 ] && [ $test2_status -eq 0 ] && [ $test3_status -eq 0 ]; then
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
