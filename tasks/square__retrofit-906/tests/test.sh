#!/bin/bash

cd /app/src

export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "retrofit-converters/gson/src/test/java/retrofit"
cp "/tests/retrofit-converters/gson/src/test/java/retrofit/GsonConverterTest.java" "retrofit-converters/gson/src/test/java/retrofit/GsonConverterTest.java"
mkdir -p "retrofit-converters/jackson/src/test/java/retrofit"
cp "/tests/retrofit-converters/jackson/src/test/java/retrofit/JacksonConverterTest.java" "retrofit-converters/jackson/src/test/java/retrofit/JacksonConverterTest.java"
mkdir -p "retrofit-converters/moshi/src/test/java/retrofit"
cp "/tests/retrofit-converters/moshi/src/test/java/retrofit/MoshiConverterTest.java" "retrofit-converters/moshi/src/test/java/retrofit/MoshiConverterTest.java"
mkdir -p "retrofit-converters/protobuf/src/test/java/retrofit"
cp "/tests/retrofit-converters/protobuf/src/test/java/retrofit/ProtoConverterTest.java" "retrofit-converters/protobuf/src/test/java/retrofit/ProtoConverterTest.java"
mkdir -p "retrofit-converters/simplexml/src/test/java/retrofit"
cp "/tests/retrofit-converters/simplexml/src/test/java/retrofit/MyObject.java" "retrofit-converters/simplexml/src/test/java/retrofit/MyObject.java"
mkdir -p "retrofit-converters/simplexml/src/test/java/retrofit"
cp "/tests/retrofit-converters/simplexml/src/test/java/retrofit/SimpleXmlConverterTest.java" "retrofit-converters/simplexml/src/test/java/retrofit/SimpleXmlConverterTest.java"
mkdir -p "retrofit-converters/wire/src/test/java/retrofit"
cp "/tests/retrofit-converters/wire/src/test/java/retrofit/Phone.java" "retrofit-converters/wire/src/test/java/retrofit/Phone.java"
mkdir -p "retrofit-converters/wire/src/test/java/retrofit"
cp "/tests/retrofit-converters/wire/src/test/java/retrofit/WireConverterTest.java" "retrofit-converters/wire/src/test/java/retrofit/WireConverterTest.java"

# Run the specific tests for this PR using Maven
# Note: Maven will automatically compile both source and test code when running tests

# First, recompile and install the retrofit module only
mvn clean install -U -DskipTests -Dmaven.javadoc.skip=true -Dcheckstyle.skip=true -pl retrofit -am || true

# Run the specific test classes for this PR
# Tests are in multiple converter modules: gson, jackson, moshi, protobuf, simplexml, wire
# Note: MyObject.java and Phone.java are test helper classes, not test classes themselves

# Run gson converter test
mvn test -Dtest=GsonConverterTest -Dmaven.javadoc.skip=true -pl retrofit-converters/gson
gson_status=$?

# Run jackson converter test
mvn test -Dtest=JacksonConverterTest -Dmaven.javadoc.skip=true -pl retrofit-converters/jackson
jackson_status=$?

# Run moshi converter test
mvn test -Dtest=MoshiConverterTest -Dmaven.javadoc.skip=true -pl retrofit-converters/moshi
moshi_status=$?

# Run protobuf converter test
mvn test -Dtest=ProtoConverterTest -Dmaven.javadoc.skip=true -pl retrofit-converters/protobuf
protobuf_status=$?

# Run simplexml converter test
mvn test -Dtest=SimpleXmlConverterTest -Dmaven.javadoc.skip=true -pl retrofit-converters/simplexml
simplexml_status=$?

# Run wire converter test
mvn test -Dtest=WireConverterTest -Dmaven.javadoc.skip=true -pl retrofit-converters/wire
wire_status=$?

# Exit with success only if all tests pass
if [ $gson_status -ne 0 ] || [ $jackson_status -ne 0 ] || [ $moshi_status -ne 0 ] || [ $protobuf_status -ne 0 ] || [ $simplexml_status -ne 0 ] || [ $wire_status -ne 0 ]; then
  test_status=1
else
  test_status=0
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
