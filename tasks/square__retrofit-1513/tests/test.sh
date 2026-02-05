#!/bin/bash

cd /app/src

# Set environment variables for tests
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "retrofit-converters/protobuf/src/test/java/retrofit2"
cp "/tests/retrofit-converters/protobuf/src/test/java/retrofit2/ProtoConverterFactoryTest.java" "retrofit-converters/protobuf/src/test/java/retrofit2/ProtoConverterFactoryTest.java"
mkdir -p "retrofit-converters/scalars/src/test/java/retrofit2"
cp "/tests/retrofit-converters/scalars/src/test/java/retrofit2/ScalarsConverterFactoryTest.java" "retrofit-converters/scalars/src/test/java/retrofit2/ScalarsConverterFactoryTest.java"
mkdir -p "retrofit-converters/wire/src/test/java/retrofit2"
cp "/tests/retrofit-converters/wire/src/test/java/retrofit2/WireConverterFactoryTest.java" "retrofit-converters/wire/src/test/java/retrofit2/WireConverterFactoryTest.java"
mkdir -p "retrofit/src/test/java/retrofit2"
cp "/tests/retrofit/src/test/java/retrofit2/CallTest.java" "retrofit/src/test/java/retrofit2/CallTest.java"
mkdir -p "retrofit/src/test/java/retrofit2"
cp "/tests/retrofit/src/test/java/retrofit2/RequestBuilderTest.java" "retrofit/src/test/java/retrofit2/RequestBuilderTest.java"
mkdir -p "retrofit/src/test/java/retrofit2"
cp "/tests/retrofit/src/test/java/retrofit2/RetrofitTest.java" "retrofit/src/test/java/retrofit2/RetrofitTest.java"
mkdir -p "retrofit/src/test/java/retrofit2/helpers"
cp "/tests/retrofit/src/test/java/retrofit2/helpers/DelegatingCallAdapterFactory.java" "retrofit/src/test/java/retrofit2/helpers/DelegatingCallAdapterFactory.java"
mkdir -p "retrofit/src/test/java/retrofit2/helpers"
cp "/tests/retrofit/src/test/java/retrofit2/helpers/NonMatchingCallAdapterFactory.java" "retrofit/src/test/java/retrofit2/helpers/NonMatchingCallAdapterFactory.java"
mkdir -p "retrofit/src/test/java/retrofit2/helpers"
cp "/tests/retrofit/src/test/java/retrofit2/helpers/NonMatchingConverterFactory.java" "retrofit/src/test/java/retrofit2/helpers/NonMatchingConverterFactory.java"
mkdir -p "retrofit/src/test/java/retrofit2/helpers"
cp "/tests/retrofit/src/test/java/retrofit2/helpers/ToStringConverterFactory.java" "retrofit/src/test/java/retrofit2/helpers/ToStringConverterFactory.java"

# Run specific tests for this PR
# Clean and rebuild all modules to ensure all changes are picked up (skip samples to avoid compilation errors)
mvn clean install -Dmaven.test.skip=true -Dmaven.javadoc.skip=true -pl '!samples' && \
mvn test -Dtest=ProtoConverterFactoryTest -pl retrofit-converters/protobuf && \
mvn test -Dtest=ScalarsConverterFactoryTest -pl retrofit-converters/scalars && \
mvn test -Dtest=WireConverterFactoryTest -pl retrofit-converters/wire && \
mvn test -Dtest=CallTest,RequestBuilderTest,RetrofitTest -pl retrofit
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
