#!/bin/bash

cd /app/src

# Set environment variables for tests
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "retrofit/kotlin-test/src/test/java/retrofit2"
cp "/tests/retrofit/kotlin-test/src/test/java/retrofit2/KotlinRequestFactoryTest.java" "retrofit/kotlin-test/src/test/java/retrofit2/KotlinRequestFactoryTest.java"
mkdir -p "retrofit/kotlin-test/src/test/java/retrofit2"
cp "/tests/retrofit/kotlin-test/src/test/java/retrofit2/KotlinSuspendTest.kt" "retrofit/kotlin-test/src/test/java/retrofit2/KotlinSuspendTest.kt"
mkdir -p "retrofit/kotlin-test/src/test/java/retrofit2"
cp "/tests/retrofit/kotlin-test/src/test/java/retrofit2/KotlinUnitTest.java" "retrofit/kotlin-test/src/test/java/retrofit2/KotlinUnitTest.java"
mkdir -p "retrofit/src/test/java/retrofit2"
cp "/tests/retrofit/src/test/java/retrofit2/RequestFactoryTest.java" "retrofit/src/test/java/retrofit2/RequestFactoryTest.java"
mkdir -p "retrofit/test-helpers/src/main/java/retrofit2"
cp "/tests/retrofit/test-helpers/src/main/java/retrofit2/TestingUtils.java" "retrofit/test-helpers/src/main/java/retrofit2/TestingUtils.java"

# Run kotlin-test module tests
./gradlew :retrofit:kotlin-test:test --tests "retrofit2.KotlinRequestFactoryTest" --tests "retrofit2.KotlinSuspendTest" --tests "retrofit2.KotlinUnitTest" --no-daemon
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
