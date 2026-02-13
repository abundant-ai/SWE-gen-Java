#!/bin/bash

cd /app/src

export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "retrofit-adapters/rxjava/src/test/java/retrofit"
cp "/tests/retrofit-adapters/rxjava/src/test/java/retrofit/ObservableCallAdapterFactoryTest.java" "retrofit-adapters/rxjava/src/test/java/retrofit/ObservableCallAdapterFactoryTest.java"
mkdir -p "retrofit/src/test/java/retrofit"
cp "/tests/retrofit/src/test/java/retrofit/MethodInfoTest.java" "retrofit/src/test/java/retrofit/MethodInfoTest.java"
mkdir -p "retrofit/src/test/java/retrofit"
cp "/tests/retrofit/src/test/java/retrofit/RequestBuilderTest.java" "retrofit/src/test/java/retrofit/RequestBuilderTest.java"
mkdir -p "retrofit/src/test/java/retrofit"
cp "/tests/retrofit/src/test/java/retrofit/RestAdapterTest.java" "retrofit/src/test/java/retrofit/RestAdapterTest.java"

# Run the specific tests for this PR using Maven
# Note: Maven will automatically compile both source and test code when running tests

# First, recompile and install the retrofit module
mvn clean install -U -DskipTests -Dmaven.javadoc.skip=true -Dcheckstyle.skip=true -pl retrofit -am || true

# Run the specific test classes for this PR
# ObservableCallAdapterFactoryTest is in the retrofit-adapters/rxjava module
# MethodInfoTest, RequestBuilderTest, RestAdapterTest are in the retrofit module
mvn test -Dtest=ObservableCallAdapterFactoryTest -Dmaven.javadoc.skip=true -pl retrofit-adapters/rxjava
rxjava_status=$?

mvn test -Dtest=MethodInfoTest,RequestBuilderTest,RestAdapterTest -Dmaven.javadoc.skip=true -pl retrofit
retrofit_status=$?

# Both test runs must pass
if [ $rxjava_status -eq 0 ] && [ $retrofit_status -eq 0 ]; then
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
