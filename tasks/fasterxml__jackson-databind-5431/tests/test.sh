#!/bin/bash

cd /app/src

# Copy test file from /tests (overwrites BASE state)
mkdir -p "src/test/java/com/fasterxml/jackson/databind/convert"
cp "/tests/java/com/fasterxml/jackson/databind/convert/ConvertFromTokenBufferTest.java" \
   "src/test/java/com/fasterxml/jackson/databind/convert/ConvertFromTokenBufferTest.java"

# Verify the TokenBuffer optimization is present in ObjectMapper._convert()
# (the optimization fast-paths TokenBuffer input to skip re-serialization)
if ! grep -q "fromValue.getClass() == TokenBuffer.class" \
     src/main/java/com/fasterxml/jackson/databind/ObjectMapper.java; then
  echo "FAIL: TokenBuffer optimization not found in ObjectMapper._convert()"
  echo 0 > /logs/verifier/reward.txt
  exit 1
fi

# Run ONLY the specific test class
mvn test -Dtest=ConvertFromTokenBufferTest -B -Denforcer.skip=true
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
