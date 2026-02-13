#!/bin/bash

cd /app/src

export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "retrofit/src/test/java/retrofit"
cp "/tests/retrofit/src/test/java/retrofit/RetrofitTest.java" "retrofit/src/test/java/retrofit/RetrofitTest.java"

# Run the specific test for this PR using Maven
# Note: Maven will automatically compile both source and test code when running tests

# Remove EndpointsTest.java which was added by bug.patch but has compilation errors
# (it references Endpoint.createFixed() which doesn't exist in the buggy state)
rm -f retrofit/src/test/java/retrofit/EndpointsTest.java

# First, recompile and install the retrofit module
mvn clean install -U -DskipTests -Dmaven.javadoc.skip=true -Dcheckstyle.skip=true -pl retrofit -am || true

# Run the specific test class for this PR
mvn test -Dtest=RetrofitTest -Dmaven.javadoc.skip=true -pl retrofit
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
