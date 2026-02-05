#!/bin/bash

cd /app/src

export TESTCONTAINERS_RYUK_DISABLED=true
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "inject-java-test/src/test/groovy/io/micronaut/aop"
cp "/tests/inject-java-test/src/test/groovy/io/micronaut/aop/ContextualMyInterface.java" "inject-java-test/src/test/groovy/io/micronaut/aop/ContextualMyInterface.java"
mkdir -p "inject-java-test/src/test/groovy/io/micronaut/aop"
cp "/tests/inject-java-test/src/test/groovy/io/micronaut/aop/ContextualMyInterfaceAdvice.java" "inject-java-test/src/test/groovy/io/micronaut/aop/ContextualMyInterfaceAdvice.java"
mkdir -p "inject-java-test/src/test/groovy/io/micronaut/aop"
cp "/tests/inject-java-test/src/test/groovy/io/micronaut/aop/ContextualMyInterfaceInterceptor.java" "inject-java-test/src/test/groovy/io/micronaut/aop/ContextualMyInterfaceInterceptor.java"
mkdir -p "inject-java-test/src/test/groovy/io/micronaut/aop"
cp "/tests/inject-java-test/src/test/groovy/io/micronaut/aop/ContextualMyInterfaceInterceptorSpec.groovy" "inject-java-test/src/test/groovy/io/micronaut/aop/ContextualMyInterfaceInterceptorSpec.groovy"
mkdir -p "inject-java-test/src/test/groovy/io/micronaut/aop"
cp "/tests/inject-java-test/src/test/groovy/io/micronaut/aop/MyImpl.java" "inject-java-test/src/test/groovy/io/micronaut/aop/MyImpl.java"
mkdir -p "inject-java-test/src/test/groovy/io/micronaut/aop"
cp "/tests/inject-java-test/src/test/groovy/io/micronaut/aop/MyInterface.java" "inject-java-test/src/test/groovy/io/micronaut/aop/MyInterface.java"
mkdir -p "inject-java/src/test/groovy/io/micronaut/visitors"
cp "/tests/inject-java/src/test/groovy/io/micronaut/visitors/ClassElementSpec.groovy" "inject-java/src/test/groovy/io/micronaut/visitors/ClassElementSpec.groovy"

# Update timestamps to force Gradle to detect changes
touch inject-java-test/src/test/groovy/io/micronaut/aop/*.groovy 2>/dev/null || true
touch inject-java-test/src/test/groovy/io/micronaut/aop/*.java 2>/dev/null || true
touch inject-java/src/test/groovy/io/micronaut/visitors/*.groovy 2>/dev/null || true

# Remove compiled test classes to force recompilation with the new test files
rm -rf inject-java-test/build/classes/ 2>/dev/null || true
rm -rf inject-java/build/classes/ 2>/dev/null || true

# Run the specific tests for this PR
./gradlew \
    :inject-java-test:cleanTest :inject-java-test:test --tests "*ContextualMyInterfaceInterceptorSpec*" \
    :inject-java:cleanTest :inject-java:test --tests "*ClassElementSpec*" \
    --no-daemon --console=plain
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
