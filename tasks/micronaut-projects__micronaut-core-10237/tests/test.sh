#!/bin/bash

cd /app/src

export TESTCONTAINERS_RYUK_DISABLED=true
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "inject-groovy/src/test/groovy/io/micronaut/aop/introduction"
cp "/tests/inject-groovy/src/test/groovy/io/micronaut/aop/introduction/IntroductionAdviceWithNewInterfaceSpec.groovy" "inject-groovy/src/test/groovy/io/micronaut/aop/introduction/IntroductionAdviceWithNewInterfaceSpec.groovy"
mkdir -p "inject-groovy/src/test/groovy/io/micronaut/inject/visitor"
cp "/tests/inject-groovy/src/test/groovy/io/micronaut/inject/visitor/ClassElementSpec.groovy" "inject-groovy/src/test/groovy/io/micronaut/inject/visitor/ClassElementSpec.groovy"
mkdir -p "inject-java/src/test/groovy/io/micronaut/visitors"
cp "/tests/inject-java/src/test/groovy/io/micronaut/visitors/ClassElementSpec.groovy" "inject-java/src/test/groovy/io/micronaut/visitors/ClassElementSpec.groovy"

# Update timestamps to force Gradle to detect changes
touch inject-groovy/src/test/groovy/io/micronaut/aop/introduction/*.groovy 2>/dev/null || true
touch inject-groovy/src/test/groovy/io/micronaut/inject/visitor/*.groovy 2>/dev/null || true
touch inject-java/src/test/groovy/io/micronaut/visitors/*.groovy 2>/dev/null || true

# Remove compiled test classes to force recompilation with the new test files
rm -rf inject-groovy/build/classes/ 2>/dev/null || true
rm -rf inject-java/build/classes/ 2>/dev/null || true

# Run the specific tests for this PR
./gradlew \
    :inject-groovy:cleanTest :inject-groovy:test --tests "*IntroductionAdviceWithNewInterfaceSpec*" --tests "*ClassElementSpec*" \
    :inject-java:cleanTest :inject-java:test --tests "*ClassElementSpec*" \
    --no-daemon --console=plain
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
