#!/bin/bash

cd /app/src

export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "retrofit/src/test/java/retrofit"
cp "/tests/retrofit/src/test/java/retrofit/CallTest.java" "retrofit/src/test/java/retrofit/CallTest.java"
mkdir -p "retrofit/src/test/java/retrofit"
cp "/tests/retrofit/src/test/java/retrofit/ExecutorCallAdapterFactoryTest.java" "retrofit/src/test/java/retrofit/ExecutorCallAdapterFactoryTest.java"
mkdir -p "retrofit/src/test/java/retrofit"
cp "/tests/retrofit/src/test/java/retrofit/RetrofitTest.java" "retrofit/src/test/java/retrofit/RetrofitTest.java"

# Run the specific tests for this PR using Maven
# Note: Maven will automatically compile both source and test code when running tests

# Rebuild OkHttp 2.5.0-SNAPSHOT in case it's not in the local Maven repo
cd /app/okhttp && mvn clean install -DskipTests -Dmaven.javadoc.skip=true -Dcheckstyle.skip=true || true
cd /app/src

# Temporarily move test files that have compilation errors due to missing MockWebServerRule
# CallTest and RetrofitTest use MockWebServerRule which is not available at this commit
# This allows us to compile and run only the ExecutorCallAdapterFactoryTest
mv retrofit/src/test/java/retrofit/CallTest.java retrofit/src/test/java/retrofit/CallTest.java.bak 2>/dev/null || true
mv retrofit/src/test/java/retrofit/RetrofitTest.java retrofit/src/test/java/retrofit/RetrofitTest.java.bak 2>/dev/null || true

# First, recompile and install only the retrofit module (not all submodules)
# This avoids compilation errors in other modules like adapter-rxjava
mvn clean install -U -pl retrofit -DskipTests -Dmaven.javadoc.skip=true -Dcheckstyle.skip=true || true

# Run the specific test class for this PR
# ExecutorCallAdapterFactoryTest is in the retrofit module (root)
mvn test -pl retrofit -Dtest=ExecutorCallAdapterFactoryTest -Dmaven.javadoc.skip=true
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
