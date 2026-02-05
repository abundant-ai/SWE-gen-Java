#!/bin/bash

cd /app/src

# Set environment variables for tests
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "retrofit-mock/src/test/java/retrofit"
cp "/tests/retrofit-mock/src/test/java/retrofit/MockRetrofitTest.java" "retrofit-mock/src/test/java/retrofit/MockRetrofitTest.java"
mkdir -p "retrofit/src/test/java/retrofit"
cp "/tests/retrofit/src/test/java/retrofit/CallTest.java" "retrofit/src/test/java/retrofit/CallTest.java"
mkdir -p "retrofit/src/test/java/retrofit"
cp "/tests/retrofit/src/test/java/retrofit/ExecutorCallAdapterFactoryTest.java" "retrofit/src/test/java/retrofit/ExecutorCallAdapterFactoryTest.java"
mkdir -p "retrofit/src/test/java/retrofit"
cp "/tests/retrofit/src/test/java/retrofit/RetrofitTest.java" "retrofit/src/test/java/retrofit/RetrofitTest.java"

# Run specific tests for this PR
# Clean and rebuild all modules to ensure all changes are picked up (skip samples to avoid compilation errors)
mvn clean install -Dmaven.test.skip=true -Dmaven.javadoc.skip=true -pl '!samples' && \
mvn test -Dtest=MockRetrofitTest -pl retrofit-mock && \
mvn test -Dtest=CallTest,ExecutorCallAdapterFactoryTest,RetrofitTest -pl retrofit
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
