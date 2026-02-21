#!/bin/bash

cd /app/src

# Set environment variables for faster Maven builds
export JAVA_OPTS="-XX:+TieredCompilation -XX:TieredStopAtLevel=1"

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test-jdk17/java/com/fasterxml/jackson/databind/records"
cp "/tests/src/test-jdk17/java/com/fasterxml/jackson/databind/records/RecordBasicsTest.java" "src/test-jdk17/java/com/fasterxml/jackson/databind/records/RecordBasicsTest.java"
mkdir -p "src/test/java/com/fasterxml/jackson/databind/deser/inject"
cp "/tests/java/com/fasterxml/jackson/databind/deser/inject/JacksonInject2678Test.java" "src/test/java/com/fasterxml/jackson/databind/deser/inject/JacksonInject2678Test.java"
cp "/tests/java/com/fasterxml/jackson/databind/deser/inject/JacksonInject4218Test.java" "src/test/java/com/fasterxml/jackson/databind/deser/inject/JacksonInject4218Test.java"

# Remove tofix tests to avoid conflicts (bug.patch moved tests to tofix, but we restored them to deser.inject)
rm -f "src/test/java/com/fasterxml/jackson/databind/tofix/JacksonInject2678Test.java"
rm -f "src/test/java/com/fasterxml/jackson/databind/tofix/JacksonInject4218Test.java"

# Run ONLY the specific test classes from the PR (with full package names to avoid running tofix tests)
./mvnw -B -ntp test -Dtest=com.fasterxml.jackson.databind.records.RecordBasicsTest,com.fasterxml.jackson.databind.deser.inject.JacksonInject2678Test,com.fasterxml.jackson.databind.deser.inject.JacksonInject4218Test
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
