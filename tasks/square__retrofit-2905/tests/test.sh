#!/bin/bash

cd /app/src

# Set environment variables for tests
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "retrofit-converters/protobuf/src/test/java/retrofit2/converter/protobuf"
cp "/tests/retrofit-converters/protobuf/src/test/java/retrofit2/converter/protobuf/ProtoConverterFactoryTest.java" "retrofit-converters/protobuf/src/test/java/retrofit2/converter/protobuf/ProtoConverterFactoryTest.java"
mkdir -p "retrofit-converters/scalars/src/test/java/retrofit2/converter/scalars"
cp "/tests/retrofit-converters/scalars/src/test/java/retrofit2/converter/scalars/ScalarsConverterFactoryTest.java" "retrofit-converters/scalars/src/test/java/retrofit2/converter/scalars/ScalarsConverterFactoryTest.java"
mkdir -p "retrofit-converters/wire/src/test/java/retrofit2/converter/wire"
cp "/tests/retrofit-converters/wire/src/test/java/retrofit2/converter/wire/WireConverterFactoryTest.java" "retrofit-converters/wire/src/test/java/retrofit2/converter/wire/WireConverterFactoryTest.java"
mkdir -p "retrofit/src/test/java/retrofit2"
cp "/tests/retrofit/src/test/java/retrofit2/OptionalConverterFactoryTest.java" "retrofit/src/test/java/retrofit2/OptionalConverterFactoryTest.java"
mkdir -p "retrofit/src/test/java/retrofit2"
cp "/tests/retrofit/src/test/java/retrofit2/RetrofitTest.java" "retrofit/src/test/java/retrofit2/RetrofitTest.java"

# Run specific tests for this PR
# Clean and rebuild all modules to ensure all changes are picked up
mvn clean install -DskipTests -Dmaven.javadoc.skip=true && \
mvn test -Dtest=OptionalConverterFactoryTest,RetrofitTest -pl retrofit && \
mvn test -Dtest=ProtoConverterFactoryTest -pl retrofit-converters/protobuf && \
mvn test -Dtest=ScalarsConverterFactoryTest -pl retrofit-converters/scalars && \
mvn test -Dtest=WireConverterFactoryTest -pl retrofit-converters/wire
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
