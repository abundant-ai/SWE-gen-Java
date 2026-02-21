#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/com/fasterxml/jackson/databind/deser/enums"
cp "/tests/java/com/fasterxml/jackson/databind/deser/enums/EnumSetDeserializer5203Test.java" "src/test/java/com/fasterxml/jackson/databind/deser/enums/EnumSetDeserializer5203Test.java"
mkdir -p "src/test/java/com/fasterxml/jackson/databind/deser/jdk"
cp "/tests/java/com/fasterxml/jackson/databind/deser/jdk/EnumMapDeserializer5165Test.java" "src/test/java/com/fasterxml/jackson/databind/deser/jdk/EnumMapDeserializer5165Test.java"

# bug.patch moves EnumSetDeserializer5203Test to tofix/ with @JacksonTestFailureExpected.
# Remove it from tofix/ so PrimarySuite (hardcoded in pom.xml) doesn't encounter it there.
# In NOP state (buggy code): deser/enums version fails -> reward=0
# In Oracle state (fixed code): deser/enums version passes -> reward=1
rm -f "src/test/java/com/fasterxml/jackson/databind/tofix/EnumSetDeserializer5203Test.java"

# Recompile test classes after copying updated test files and removing the tofix version
mvn -B -ntp -DskipTests test-compile

mvn -B -ntp test
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
