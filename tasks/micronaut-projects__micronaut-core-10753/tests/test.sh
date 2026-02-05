#!/bin/bash

cd /app/src

export TESTCONTAINERS_RYUK_DISABLED=true
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "inject-java/src/test/groovy/io/micronaut/aop/introduction"
cp "/tests/inject-java/src/test/groovy/io/micronaut/aop/introduction/InterceptorQualifierSpec.groovy" "inject-java/src/test/groovy/io/micronaut/aop/introduction/InterceptorQualifierSpec.groovy"
mkdir -p "inject-java/src/test/groovy/io/micronaut/aop/introduction"
cp "/tests/inject-java/src/test/groovy/io/micronaut/aop/introduction/MyDataSource.java" "inject-java/src/test/groovy/io/micronaut/aop/introduction/MyDataSource.java"
mkdir -p "inject-java/src/test/groovy/io/micronaut/aop/introduction"
cp "/tests/inject-java/src/test/groovy/io/micronaut/aop/introduction/MyDataSourceHelper.java" "inject-java/src/test/groovy/io/micronaut/aop/introduction/MyDataSourceHelper.java"
mkdir -p "inject-java/src/test/groovy/io/micronaut/aop/introduction"
cp "/tests/inject-java/src/test/groovy/io/micronaut/aop/introduction/MyDataSourceHelper2.java" "inject-java/src/test/groovy/io/micronaut/aop/introduction/MyDataSourceHelper2.java"
mkdir -p "inject-java/src/test/groovy/io/micronaut/aop/introduction"
cp "/tests/inject-java/src/test/groovy/io/micronaut/aop/introduction/MyDataSourceHelper3.java" "inject-java/src/test/groovy/io/micronaut/aop/introduction/MyDataSourceHelper3.java"
mkdir -p "inject-java/src/test/groovy/io/micronaut/aop/introduction"
cp "/tests/inject-java/src/test/groovy/io/micronaut/aop/introduction/MyInterceptedDataSourceFactory.java" "inject-java/src/test/groovy/io/micronaut/aop/introduction/MyInterceptedDataSourceFactory.java"
mkdir -p "inject-java/src/test/groovy/io/micronaut/aop/introduction"
cp "/tests/inject-java/src/test/groovy/io/micronaut/aop/introduction/MyInterceptedInterface.java" "inject-java/src/test/groovy/io/micronaut/aop/introduction/MyInterceptedInterface.java"
mkdir -p "inject-java/src/test/groovy/io/micronaut/aop/introduction"
cp "/tests/inject-java/src/test/groovy/io/micronaut/aop/introduction/MyInterceptedInterfaceWrapper.java" "inject-java/src/test/groovy/io/micronaut/aop/introduction/MyInterceptedInterfaceWrapper.java"
mkdir -p "inject-java/src/test/groovy/io/micronaut/aop/introduction"
cp "/tests/inject-java/src/test/groovy/io/micronaut/aop/introduction/MyInterceptedIntroducer.java" "inject-java/src/test/groovy/io/micronaut/aop/introduction/MyInterceptedIntroducer.java"
mkdir -p "inject-java/src/test/groovy/io/micronaut/aop/introduction"
cp "/tests/inject-java/src/test/groovy/io/micronaut/aop/introduction/MyInterceptedPoint.java" "inject-java/src/test/groovy/io/micronaut/aop/introduction/MyInterceptedPoint.java"

# Update timestamps to force Gradle to detect changes
touch inject-java/src/test/groovy/io/micronaut/aop/introduction/*.groovy 2>/dev/null || true

# Remove compiled test classes to force recompilation with the new test files
rm -rf inject-java/build/classes/

# Run the specific tests for this PR
./gradlew :inject-java:cleanTest :inject-java:test --tests "*InterceptorQualifierSpec" \
          --no-daemon --console=plain
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
