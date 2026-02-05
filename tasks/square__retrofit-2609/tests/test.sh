#!/bin/bash

cd /app/src

# Set environment variables for tests
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "retrofit-converters/jaxb/src/test/java/retrofit2/converter/jaxb"
cp "/tests/retrofit-converters/jaxb/src/test/java/retrofit2/converter/jaxb/Contact.java" "retrofit-converters/jaxb/src/test/java/retrofit2/converter/jaxb/Contact.java"
mkdir -p "retrofit-converters/jaxb/src/test/java/retrofit2/converter/jaxb"
cp "/tests/retrofit-converters/jaxb/src/test/java/retrofit2/converter/jaxb/JaxbConverterFactoryTest.java" "retrofit-converters/jaxb/src/test/java/retrofit2/converter/jaxb/JaxbConverterFactoryTest.java"
mkdir -p "retrofit-converters/jaxb/src/test/java/retrofit2/converter/jaxb"
cp "/tests/retrofit-converters/jaxb/src/test/java/retrofit2/converter/jaxb/PhoneNumber.java" "retrofit-converters/jaxb/src/test/java/retrofit2/converter/jaxb/PhoneNumber.java"
mkdir -p "retrofit-converters/jaxb/src/test/java/retrofit2/converter/jaxb"
cp "/tests/retrofit-converters/jaxb/src/test/java/retrofit2/converter/jaxb/Type.java" "retrofit-converters/jaxb/src/test/java/retrofit2/converter/jaxb/Type.java"

# Run specific tests for this PR
# Clean and rebuild all modules to ensure all changes are picked up
mvn clean install -Dmaven.test.skip=true -Dmaven.javadoc.skip=true && \
mvn test -Dtest=JaxbConverterFactoryTest -pl retrofit-converters/jaxb
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
