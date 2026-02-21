#!/bin/bash

cd /app/src

# Set environment variables for Maven test execution
export MAVEN_OPTS="-XX:+TieredCompilation -XX:TieredStopAtLevel=1"

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/com/fasterxml/jackson/databind/deser"
cp "/tests/java/com/fasterxml/jackson/databind/deser/SetterlessPropertiesDeserTest.java" "src/test/java/com/fasterxml/jackson/databind/deser/SetterlessPropertiesDeserTest.java"

# Run the specific test class (JUnit 5 test via Maven)
# The pom.xml has <test>PrimarySuite</test> hardcoded, which we need to override
# Temporarily patch pom.xml to remove the hardcoded test suite
sed -i '/<test>com.fasterxml.jackson.databind.PrimarySuite<\/test>/d' pom.xml

# Recompile just the single test class to pick up the copied test file
javac -cp "$(./mvnw -B -q dependency:build-classpath -Dmdep.outputFile=/dev/stdout):target/classes:target/test-classes" \
    -d target/test-classes \
    src/test/java/com/fasterxml/jackson/databind/deser/SetterlessPropertiesDeserTest.java

# Run the specific test with maven surefire
./mvnw -B -ntp surefire:test -Dtest=com.fasterxml.jackson.databind.deser.SetterlessPropertiesDeserTest
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
