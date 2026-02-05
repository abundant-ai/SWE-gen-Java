#!/bin/bash

cd /app/src

export TESTCONTAINERS_RYUK_DISABLED=true
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "inject-java-test/src/test/groovy/io/micronaut/inject/visitor/beans"
cp "/tests/inject-java-test/src/test/groovy/io/micronaut/inject/visitor/beans/BeanIntrospectionSpec.groovy" "inject-java-test/src/test/groovy/io/micronaut/inject/visitor/beans/BeanIntrospectionSpec.groovy"
mkdir -p "inject-java-test/src/test/groovy/io/micronaut/inject/visitor/beans"
cp "/tests/inject-java-test/src/test/groovy/io/micronaut/inject/visitor/beans/PackagePrivateConstructor.java" "inject-java-test/src/test/groovy/io/micronaut/inject/visitor/beans/PackagePrivateConstructor.java"

# Update timestamps to force Gradle to detect changes
touch inject-java-test/src/test/groovy/io/micronaut/inject/visitor/beans/BeanIntrospectionSpec.groovy
touch inject-java-test/src/test/groovy/io/micronaut/inject/visitor/beans/PackagePrivateConstructor.java

# Remove compiled test classes to force recompilation with the new test files
rm -rf inject-java-test/build/classes/groovy/test/io/micronaut/inject/visitor/beans/*.class
rm -rf inject-java-test/build/classes/java/test/io/micronaut/inject/visitor/beans/*.class

# Run specific tests using Gradle
./gradlew \
  :micronaut-inject-java-test:test --tests "io.micronaut.inject.visitor.beans.BeanIntrospectionSpec" \
  --no-daemon --console=plain
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
