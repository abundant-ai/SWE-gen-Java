#!/bin/bash

cd /app/src

export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "retrofit-adapters/scala/src/test/java/retrofit2/adapter/scala"
cp "/tests/retrofit-adapters/scala/src/test/java/retrofit2/adapter/scala/FutureTest.java" "retrofit-adapters/scala/src/test/java/retrofit2/adapter/scala/FutureTest.java"
cp "/tests/retrofit-adapters/scala/src/test/java/retrofit2/adapter/scala/ScalaCallAdapterFactoryTest.java" "retrofit-adapters/scala/src/test/java/retrofit2/adapter/scala/ScalaCallAdapterFactoryTest.java"
cp "/tests/retrofit-adapters/scala/src/test/java/retrofit2/adapter/scala/StringConverterFactory.java" "retrofit-adapters/scala/src/test/java/retrofit2/adapter/scala/StringConverterFactory.java"

# Clean and rebuild to pick up the new test files
mvn clean install -DskipTests -Dmaven.javadoc.skip=true || true

# Run the specific tests for this PR using Maven
# Note: Maven -Dtest accepts comma-separated test class names without the .java extension
mvn test -pl retrofit-adapters/scala -Dtest=FutureTest,ScalaCallAdapterFactoryTest -Dmaven.javadoc.skip=true
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
