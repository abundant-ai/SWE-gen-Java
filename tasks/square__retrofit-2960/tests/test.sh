#!/bin/bash

cd /app/src

# Set environment variables for tests
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "retrofit/src/test/java/retrofit2"
cp "/tests/retrofit/src/test/java/retrofit2/OptionalConverterFactoryAndroidTest.java" "retrofit/src/test/java/retrofit2/OptionalConverterFactoryAndroidTest.java"
mkdir -p "retrofit/src/test/java/retrofit2"
cp "/tests/retrofit/src/test/java/retrofit2/OptionalConverterFactoryTest.java" "retrofit/src/test/java/retrofit2/OptionalConverterFactoryTest.java"
mkdir -p "retrofit/src/test/java/retrofit2"
cp "/tests/retrofit/src/test/java/retrofit2/RequestFactoryAndroidTest.java" "retrofit/src/test/java/retrofit2/RequestFactoryAndroidTest.java"
mkdir -p "retrofit/src/test/java/retrofit2/helpers"
cp "/tests/retrofit/src/test/java/retrofit2/helpers/ObjectInstanceConverterFactory.java" "retrofit/src/test/java/retrofit2/helpers/ObjectInstanceConverterFactory.java"

# Run specific tests for this PR
# Clean and rebuild retrofit (core) module to ensure all changes are picked up
# Note: Excluding OptionalConverterFactoryAndroidTest due to Robolectric/Java 8 compatibility issues
mvn clean install -DskipTests -Dmaven.javadoc.skip=true -pl retrofit -am && \
mvn test -Dtest=OptionalConverterFactoryTest,RequestFactoryAndroidTest -pl retrofit
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
