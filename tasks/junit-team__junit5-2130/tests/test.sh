#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "platform-tests/src/test/java/org/junit/platform/launcher"
cp "/tests/platform-tests/src/test/java/org/junit/platform/launcher/TagIntegrationTests.java" "platform-tests/src/test/java/org/junit/platform/launcher/TagIntegrationTests.java"
mkdir -p "platform-tests/src/test/java/org/junit/platform/launcher/tagexpression"
cp "/tests/platform-tests/src/test/java/org/junit/platform/launcher/tagexpression/ParserTests.java" "platform-tests/src/test/java/org/junit/platform/launcher/tagexpression/ParserTests.java"
mkdir -p "platform-tests/src/test/java/org/junit/platform/launcher/tagexpression"
cp "/tests/platform-tests/src/test/java/org/junit/platform/launcher/tagexpression/TagExpressionsTests.java" "platform-tests/src/test/java/org/junit/platform/launcher/tagexpression/TagExpressionsTests.java"
mkdir -p "platform-tests/src/test/java/org/junit/platform/launcher/tagexpression"
cp "/tests/platform-tests/src/test/java/org/junit/platform/launcher/tagexpression/TokenizerTests.java" "platform-tests/src/test/java/org/junit/platform/launcher/tagexpression/TokenizerTests.java"

# Run the specific test files using Gradle
./gradlew :platform-tests:test \
  --tests org.junit.platform.launcher.TagIntegrationTests \
  --tests org.junit.platform.launcher.tagexpression.ParserTests \
  --tests org.junit.platform.launcher.tagexpression.TagExpressionsTests \
  --tests org.junit.platform.launcher.tagexpression.TokenizerTests \
  -x compileModule --no-daemon --no-parallel 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
