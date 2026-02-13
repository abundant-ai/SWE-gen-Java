#!/bin/bash

cd /app/src

export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "retrofit-mock/src/test/java/retrofit"
# Remove old test file that conflicts (bug.patch adds MockRestAdapterTest.java which is incompatible)
rm -f retrofit-mock/src/test/java/retrofit/MockRestAdapterTest.java
cp "/tests/retrofit-mock/src/test/java/retrofit/MockRetrofitTest.java" "retrofit-mock/src/test/java/retrofit/MockRetrofitTest.java"

# Run the specific tests for this PR using Maven
# Note: Maven will automatically compile both source and test code when running tests

# The retrofit-mock module is commented out in the parent pom at this commit
# So we need to build it directly from its own directory
cd retrofit-mock

# First, recompile and install the module
mvn clean install -U -DskipTests -Dmaven.javadoc.skip=true -Dcheckstyle.skip=true || true

# Run the specific test class for this PR
mvn test -Dtest=MockRetrofitTest -Dmaven.javadoc.skip=true
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
