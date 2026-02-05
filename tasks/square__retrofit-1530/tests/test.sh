#!/bin/bash

cd /app/src

# Set environment variables for tests
export CI=true

# After fix.patch is applied, delete any remaining files in the wrong location
# (bug.patch moved them to retrofit2/* but fix.patch creates new ones at retrofit2/adapter/rxjava/* or retrofit2/converter/*)
rm -f retrofit-adapters/rxjava/src/main/java/retrofit2/HttpException.java
rm -f retrofit-adapters/rxjava/src/main/java/retrofit2/Result.java
rm -f retrofit-adapters/rxjava/src/main/java/retrofit2/RxJavaCallAdapterFactory.java
rm -f retrofit-adapters/rxjava/src/main/java/retrofit2/SingleHelper.java
rm -f retrofit-adapters/rxjava/src/test/java/retrofit2/ObservableTest.java
rm -f retrofit-adapters/rxjava/src/test/java/retrofit2/ResultTest.java
rm -f retrofit-adapters/rxjava/src/test/java/retrofit2/RxJavaCallAdapterFactoryTest.java
rm -f retrofit-adapters/rxjava/src/test/java/retrofit2/SingleTest.java
rm -f retrofit-adapters/rxjava/src/test/java/retrofit2/StringConverterFactory.java
rm -f retrofit-converters/gson/src/main/java/retrofit2/GsonConverterFactory.java
rm -f retrofit-converters/gson/src/main/java/retrofit2/GsonRequestBodyConverter.java
rm -f retrofit-converters/gson/src/main/java/retrofit2/GsonResponseBodyConverter.java
rm -f retrofit-converters/gson/src/test/java/retrofit2/GsonConverterFactoryTest.java
rm -f retrofit-converters/jackson/src/main/java/retrofit2/JacksonConverterFactory.java
rm -f retrofit-converters/jackson/src/main/java/retrofit2/JacksonRequestBodyConverter.java
rm -f retrofit-converters/jackson/src/main/java/retrofit2/JacksonResponseBodyConverter.java
rm -f retrofit-converters/jackson/src/test/java/retrofit2/JacksonConverterFactoryTest.java
rm -f retrofit-converters/moshi/src/main/java/retrofit2/MoshiConverterFactory.java
rm -f retrofit-converters/moshi/src/main/java/retrofit2/MoshiRequestBodyConverter.java
rm -f retrofit-converters/moshi/src/main/java/retrofit2/MoshiResponseBodyConverter.java
rm -f retrofit-converters/moshi/src/test/java/retrofit2/MoshiConverterFactoryTest.java
rm -f retrofit-converters/protobuf/src/main/java/retrofit2/ProtoConverterFactory.java
rm -f retrofit-converters/protobuf/src/main/java/retrofit2/ProtoRequestBodyConverter.java
rm -f retrofit-converters/protobuf/src/main/java/retrofit2/ProtoResponseBodyConverter.java
rm -f retrofit-converters/protobuf/src/test/java/retrofit2/PhoneProtos.java
rm -f retrofit-converters/protobuf/src/test/java/retrofit2/ProtoConverterFactoryTest.java
rm -f retrofit-converters/scalars/src/main/java/retrofit2/ScalarRequestBodyConverter.java
rm -f retrofit-converters/scalars/src/main/java/retrofit2/ScalarResponseBodyConverters.java
rm -f retrofit-converters/scalars/src/main/java/retrofit2/ScalarsConverterFactory.java
rm -f retrofit-converters/scalars/src/test/java/retrofit2/ScalarsConverterFactoryTest.java
rm -f retrofit-converters/simplexml/src/main/java/retrofit2/SimpleXmlConverterFactory.java
rm -f retrofit-converters/simplexml/src/main/java/retrofit2/SimpleXmlRequestBodyConverter.java
rm -f retrofit-converters/simplexml/src/main/java/retrofit2/SimpleXmlResponseBodyConverter.java
rm -f retrofit-converters/simplexml/src/test/java/retrofit2/MyObject.java
rm -f retrofit-converters/simplexml/src/test/java/retrofit2/SimpleXmlConverterFactoryTest.java
rm -f retrofit-converters/wire/src/main/java/retrofit2/WireConverterFactory.java
rm -f retrofit-converters/wire/src/main/java/retrofit2/WireRequestBodyConverter.java
rm -f retrofit-converters/wire/src/main/java/retrofit2/WireResponseBodyConverter.java
rm -f retrofit-converters/wire/src/test/java/retrofit2/Phone.java
rm -f retrofit-converters/wire/src/test/java/retrofit2/WireConverterFactoryTest.java

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "retrofit-adapters/rxjava/src/test/java/retrofit2/adapter/rxjava"
cp "/tests/retrofit-adapters/rxjava/src/test/java/retrofit2/adapter/rxjava/ObservableTest.java" "retrofit-adapters/rxjava/src/test/java/retrofit2/adapter/rxjava/ObservableTest.java"
mkdir -p "retrofit-adapters/rxjava/src/test/java/retrofit2/adapter/rxjava"
cp "/tests/retrofit-adapters/rxjava/src/test/java/retrofit2/adapter/rxjava/ResultTest.java" "retrofit-adapters/rxjava/src/test/java/retrofit2/adapter/rxjava/ResultTest.java"
mkdir -p "retrofit-adapters/rxjava/src/test/java/retrofit2/adapter/rxjava"
cp "/tests/retrofit-adapters/rxjava/src/test/java/retrofit2/adapter/rxjava/RxJavaCallAdapterFactoryTest.java" "retrofit-adapters/rxjava/src/test/java/retrofit2/adapter/rxjava/RxJavaCallAdapterFactoryTest.java"
mkdir -p "retrofit-adapters/rxjava/src/test/java/retrofit2/adapter/rxjava"
cp "/tests/retrofit-adapters/rxjava/src/test/java/retrofit2/adapter/rxjava/SingleTest.java" "retrofit-adapters/rxjava/src/test/java/retrofit2/adapter/rxjava/SingleTest.java"
mkdir -p "retrofit-adapters/rxjava/src/test/java/retrofit2/adapter/rxjava"
cp "/tests/retrofit-adapters/rxjava/src/test/java/retrofit2/adapter/rxjava/StringConverterFactory.java" "retrofit-adapters/rxjava/src/test/java/retrofit2/adapter/rxjava/StringConverterFactory.java"
mkdir -p "retrofit/src/test/java/retrofit2"
cp "/tests/retrofit/src/test/java/retrofit2/RetrofitTest.java" "retrofit/src/test/java/retrofit2/RetrofitTest.java"
mkdir -p "retrofit/src/test/java/retrofit2/helpers"
cp "/tests/retrofit/src/test/java/retrofit2/helpers/DelegatingCallAdapterFactory.java" "retrofit/src/test/java/retrofit2/helpers/DelegatingCallAdapterFactory.java"
mkdir -p "retrofit/src/test/java/retrofit2/helpers"
cp "/tests/retrofit/src/test/java/retrofit2/helpers/NonMatchingCallAdapterFactory.java" "retrofit/src/test/java/retrofit2/helpers/NonMatchingCallAdapterFactory.java"

# Run specific tests for this PR
# Clean and rebuild all modules to ensure all changes are picked up (skip samples to avoid compilation errors)
mvn clean install -Dmaven.test.skip=true -Dmaven.javadoc.skip=true -pl '!samples' && \
mvn test -Dtest=ObservableTest,ResultTest,RxJavaCallAdapterFactoryTest,SingleTest -pl retrofit-adapters/rxjava && \
mvn test -Dtest=RetrofitTest -pl retrofit
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
