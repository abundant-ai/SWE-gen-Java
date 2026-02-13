#!/bin/bash

cd /app/src

export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "retrofit-adapters/rxjava-mock/src/test/java/retrofit/mock"
cp "/tests/retrofit-adapters/rxjava-mock/src/test/java/retrofit/mock/RxJavaBehaviorAdapterTest.java" "retrofit-adapters/rxjava-mock/src/test/java/retrofit/mock/RxJavaBehaviorAdapterTest.java"
mkdir -p "retrofit-adapters/rxjava/src/test/java/retrofit"
cp "/tests/retrofit-adapters/rxjava/src/test/java/retrofit/RxJavaCallAdapterFactoryTest.java" "retrofit-adapters/rxjava/src/test/java/retrofit/RxJavaCallAdapterFactoryTest.java"

# Run the specific tests for this PR using Maven
# Note: Maven will automatically compile both source and test code when running tests

# Rebuild OkHttp 2.5.0-SNAPSHOT in case it's not in the local Maven repo
cd /app/okhttp && mvn clean install -DskipTests -Dmaven.javadoc.skip=true -Dcheckstyle.skip=true || true
cd /app/src

# First, recompile and install the entire project (needed for Oracle after applying fix.patch)
mvn clean install -U -DskipTests -Dmaven.javadoc.skip=true -Dcheckstyle.skip=true || true

# Run the specific test classes for this PR
# RxJavaBehaviorAdapterTest is in retrofit-adapters/rxjava-mock module
# RxJavaCallAdapterFactoryTest is in retrofit-adapters/rxjava module
mvn test -pl retrofit-adapters/rxjava-mock -Dtest=RxJavaBehaviorAdapterTest -Dmaven.javadoc.skip=true && \
mvn test -pl retrofit-adapters/rxjava -Dtest=RxJavaCallAdapterFactoryTest -Dmaven.javadoc.skip=true
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
