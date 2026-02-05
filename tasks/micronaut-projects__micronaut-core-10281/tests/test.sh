#!/bin/bash

cd /app/src

export TESTCONTAINERS_RYUK_DISABLED=true
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "inject-java/src/test/groovy/io/micronaut/inject/beans"
cp "/tests/inject-java/src/test/groovy/io/micronaut/inject/beans/BeanDefinitionSpec.groovy" "inject-java/src/test/groovy/io/micronaut/inject/beans/BeanDefinitionSpec.groovy"
mkdir -p "inject-java/src/test/groovy/io/micronaut/visitors"
cp "/tests/inject-java/src/test/groovy/io/micronaut/visitors/ClassElementSpec.groovy" "inject-java/src/test/groovy/io/micronaut/visitors/ClassElementSpec.groovy"
mkdir -p "inject-java/src/test/java/test"
cp "/tests/inject-java/src/test/java/test/Middle.java" "inject-java/src/test/java/test/Middle.java"
mkdir -p "inject-java/src/test/java/test/another"
cp "/tests/inject-java/src/test/java/test/another/Base.java" "inject-java/src/test/java/test/another/Base.java"
mkdir -p "inject-java/src/test/java/test/another"
cp "/tests/inject-java/src/test/java/test/another/BeanWithPackagePrivate.java" "inject-java/src/test/java/test/another/BeanWithPackagePrivate.java"

# Update timestamps to force Gradle to detect changes
touch inject-java/src/test/groovy/io/micronaut/inject/beans/*.groovy 2>/dev/null || true
touch inject-java/src/test/groovy/io/micronaut/visitors/*.groovy 2>/dev/null || true

# Remove compiled test classes to force recompilation with the new test files
rm -rf inject-java/build/classes/ 2>/dev/null || true

# Run the specific tests for this PR
./gradlew \
    :inject-java:cleanTest :inject-java:test --tests "*BeanDefinitionSpec*" --tests "*ClassElementSpec*" \
    --no-daemon --console=plain
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
