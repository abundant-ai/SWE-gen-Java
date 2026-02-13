#!/bin/bash

cd /app/src

export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "retrofit-converters/protobuf/src/test/java/retrofit"
cp "/tests/retrofit-converters/protobuf/src/test/java/retrofit/ProtoConverterFactoryTest.java" "retrofit-converters/protobuf/src/test/java/retrofit/ProtoConverterFactoryTest.java"
mkdir -p "retrofit-converters/wire/src/test/java/retrofit"
cp "/tests/retrofit-converters/wire/src/test/java/retrofit/WireConverterFactoryTest.java" "retrofit-converters/wire/src/test/java/retrofit/WireConverterFactoryTest.java"
mkdir -p "retrofit/src/test/java/retrofit"
cp "/tests/retrofit/src/test/java/retrofit/RequestBuilderTest.java" "retrofit/src/test/java/retrofit/RequestBuilderTest.java"
mkdir -p "retrofit/src/test/java/retrofit"
cp "/tests/retrofit/src/test/java/retrofit/RetrofitTest.java" "retrofit/src/test/java/retrofit/RetrofitTest.java"

# Run the specific tests for this PR using Maven
# Note: Maven will automatically compile both source and test code when running tests

# Rebuild OkHttp 3.0.0-SNAPSHOT in case it's not in the local Maven repo
cd /app/okhttp && mvn clean install -DskipTests -Dmaven.javadoc.skip=true -Dcheckstyle.skip=true || true
cd /app/src

# First, recompile and install the entire project (needed for Oracle after applying fix.patch)
mvn clean install -U -DskipTests -Dmaven.javadoc.skip=true -Dcheckstyle.skip=true || true

# Run the specific test classes
# ProtoConverterFactoryTest and WireConverterFactoryTest are in converter modules
# RequestBuilderTest and RetrofitTest are in the main retrofit module
mvn test -pl retrofit-converters/protobuf -Dtest=ProtoConverterFactoryTest -Dmaven.javadoc.skip=true || true
mvn test -pl retrofit-converters/wire -Dtest=WireConverterFactoryTest -Dmaven.javadoc.skip=true || true
mvn test -pl retrofit -Dtest=RequestBuilderTest,RetrofitTest -Dmaven.javadoc.skip=true
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
