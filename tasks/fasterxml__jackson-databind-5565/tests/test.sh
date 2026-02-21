#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/tools/jackson/databind/deser/builder"
cp "/tests/java/tools/jackson/databind/deser/builder/BuilderAdvancedTest.java" "src/test/java/tools/jackson/databind/deser/builder/BuilderAdvancedTest.java"
mkdir -p "src/test/java/tools/jackson/databind/deser/builder"
cp "/tests/java/tools/jackson/databind/deser/builder/BuilderCreatorSubtype4742Test.java" "src/test/java/tools/jackson/databind/deser/builder/BuilderCreatorSubtype4742Test.java"
mkdir -p "src/test/java/tools/jackson/databind/jsontype/ext"
cp "/tests/java/tools/jackson/databind/jsontype/ext/ExternalTypeCustomResolver1288Test.java" "src/test/java/tools/jackson/databind/jsontype/ext/ExternalTypeCustomResolver1288Test.java"
mkdir -p "src/test/java/tools/jackson/databind/jsontype/ext"
cp "/tests/java/tools/jackson/databind/jsontype/ext/JsonValueExtTypeIdTest.java" "src/test/java/tools/jackson/databind/jsontype/ext/JsonValueExtTypeIdTest.java"

# Run only the specific test classes from this PR using fully-qualified names to avoid
# matching tofix/ versions (which have @JacksonTestFailureExpected and different behavior)
mvn -B -ff -ntp test \
  -Dtest="tools.jackson.databind.deser.builder.BuilderAdvancedTest,tools.jackson.databind.deser.builder.BuilderCreatorSubtype4742Test,tools.jackson.databind.jsontype.ext.ExternalTypeCustomResolver1288Test,tools.jackson.databind.jsontype.ext.JsonValueExtTypeIdTest" \
  -DfailIfNoTests=false
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
