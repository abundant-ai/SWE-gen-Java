#!/bin/bash

cd /app/src

export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "retrofit/src/test/java/retrofit"
cp "/tests/retrofit/src/test/java/retrofit/ExecutorCallAdapterFactoryTest.java" "retrofit/src/test/java/retrofit/ExecutorCallAdapterFactoryTest.java"
mkdir -p "retrofit/src/test/java/retrofit"
cp "/tests/retrofit/src/test/java/retrofit/RetrofitTest.java" "retrofit/src/test/java/retrofit/RetrofitTest.java"

# Run the specific tests for this PR using Maven
# Note: Maven will automatically compile both source and test code when running tests

# Rebuild OkHttp 3.0.0-SNAPSHOT in case it's not in the local Maven repo
cd /app/okhttp && mvn clean install -DskipTests -Dmaven.javadoc.skip=true -Dcheckstyle.skip=true || true
cd /app/src

# First, recompile and install the entire project (needed for Oracle after applying fix.patch)
mvn clean install -U -DskipTests -Dmaven.javadoc.skip=true -Dcheckstyle.skip=true || true

# Run the specific test classes for this PR
mvn test -pl retrofit -Dtest=ExecutorCallAdapterFactoryTest,RetrofitTest -Dmaven.javadoc.skip=true
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
