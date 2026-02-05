#!/bin/bash

cd /app/src

# Set environment variables for tests
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state test files)
mkdir -p "retrofit/src/test/java/retrofit2"
cp "/tests/retrofit/src/test/java/retrofit2/DefaultCallAdapterFactoryTest.java" "retrofit/src/test/java/retrofit2/DefaultCallAdapterFactoryTest.java"
cp "/tests/retrofit/src/test/java/retrofit2/RetrofitTest.java" "retrofit/src/test/java/retrofit2/RetrofitTest.java"

# Remove the old BASE test file that was renamed in bug.patch
rm -f "retrofit/src/test/java/retrofit2/ExecutorCallAdapterFactoryTest.java"

# Run specific tests for this PR - DefaultCallAdapterFactoryTest and RetrofitTest
# Build dependencies without running tests, then run only the target tests
mvn install -DskipTests -Dmaven.javadoc.skip=true -pl retrofit && \
mvn test -Dtest=DefaultCallAdapterFactoryTest,RetrofitTest -pl retrofit
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
