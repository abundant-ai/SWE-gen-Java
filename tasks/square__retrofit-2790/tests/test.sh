#!/bin/bash

cd /app/src

# Set environment variables for tests
export CI=true

# Remove BASE test files that conflict with HEAD test files
# The bug.patch renamed these tests, so we need to remove the old names
rm -f "retrofit/src/test/java/retrofit2/RequestBuilderAndroidTest.java"
rm -f "retrofit/src/test/java/retrofit2/RequestBuilderTest.java"
rm -f "retrofit/src/test/java/retrofit2/ServiceMethodTest.java"

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "retrofit/src/test/java/retrofit2"
cp "/tests/retrofit/src/test/java/retrofit2/RequestFactoryAndroidTest.java" "retrofit/src/test/java/retrofit2/RequestFactoryAndroidTest.java"
mkdir -p "retrofit/src/test/java/retrofit2"
cp "/tests/retrofit/src/test/java/retrofit2/RequestFactoryBuilderTest.java" "retrofit/src/test/java/retrofit2/RequestFactoryBuilderTest.java"
mkdir -p "retrofit/src/test/java/retrofit2"
cp "/tests/retrofit/src/test/java/retrofit2/RequestFactoryTest.java" "retrofit/src/test/java/retrofit2/RequestFactoryTest.java"

# Run specific tests for this PR
# Clean and rebuild all modules to ensure all changes are picked up
mvn clean install -Dmaven.test.skip=true -Dmaven.javadoc.skip=true && \
mvn test -Dtest=RequestFactoryAndroidTest,RequestFactoryBuilderTest,RequestFactoryTest -pl retrofit
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
