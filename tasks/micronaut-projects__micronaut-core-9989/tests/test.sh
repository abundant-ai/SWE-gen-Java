#!/bin/bash

cd /app/src

export TESTCONTAINERS_RYUK_DISABLED=true
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "http-server-netty/src/test/groovy/io/micronaut/http/server/netty/threading"
cp "/tests/http-server-netty/src/test/groovy/io/micronaut/http/server/netty/threading/ThreadSelectionSpec.groovy" "http-server-netty/src/test/groovy/io/micronaut/http/server/netty/threading/ThreadSelectionSpec.groovy"
mkdir -p "inject-java/src/test/groovy/io/micronaut/inject/requires"
cp "/tests/inject-java/src/test/groovy/io/micronaut/inject/requires/RequiresSpec.groovy" "inject-java/src/test/groovy/io/micronaut/inject/requires/RequiresSpec.groovy"
mkdir -p "runtime/src/test/groovy/io/micronaut/runtime/executor"
cp "/tests/runtime/src/test/groovy/io/micronaut/runtime/executor/ExecutorServiceConfigSpec.groovy" "runtime/src/test/groovy/io/micronaut/runtime/executor/ExecutorServiceConfigSpec.groovy"

# Update timestamps to force Gradle to detect changes
touch http-server-netty/src/test/groovy/io/micronaut/http/server/netty/threading/*.groovy 2>/dev/null || true
touch inject-java/src/test/groovy/io/micronaut/inject/requires/*.groovy 2>/dev/null || true
touch runtime/src/test/groovy/io/micronaut/runtime/executor/*.groovy 2>/dev/null || true

# Remove compiled test classes to force recompilation with the new test files
rm -rf http-server-netty/build/classes/ 2>/dev/null || true
rm -rf inject-java/build/classes/ 2>/dev/null || true
rm -rf runtime/build/classes/ 2>/dev/null || true

# Run the specific tests for this PR
./gradlew \
    :http-server-netty:cleanTest :http-server-netty:test --tests "*ThreadSelectionSpec*" \
    :inject-java:cleanTest :inject-java:test --tests "*RequiresSpec*" \
    :runtime:cleanTest :runtime:test --tests "*ExecutorServiceConfigSpec*" \
    --no-daemon --console=plain
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
