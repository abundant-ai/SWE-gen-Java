#!/bin/bash

cd /app/src

export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "retrofit/src/test/java/retrofit"
# Remove old test file that conflicts (bug.patch renames ExecutorCallAdapterFactoryTest.java to DefaultCallAdapterFactoryTest.java which is incompatible)
rm -f retrofit/src/test/java/retrofit/DefaultCallAdapterFactoryTest.java
cp "/tests/retrofit/src/test/java/retrofit/ExecutorCallAdapterFactoryTest.java" "retrofit/src/test/java/retrofit/ExecutorCallAdapterFactoryTest.java"
cp "/tests/retrofit/src/test/java/retrofit/RetrofitTest.java" "retrofit/src/test/java/retrofit/RetrofitTest.java"

# Run the specific tests for this PR using Maven
# Note: Maven will automatically compile both source and test code when running tests

# First, recompile and install the retrofit module only
mvn clean install -U -DskipTests -Dmaven.javadoc.skip=true -Dcheckstyle.skip=true -pl retrofit -am || true

# Run the specific test classes for this PR in the retrofit module only
mvn test -Dtest=ExecutorCallAdapterFactoryTest,RetrofitTest -Dmaven.javadoc.skip=true -pl retrofit
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
