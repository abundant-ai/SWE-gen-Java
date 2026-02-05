#!/bin/bash

cd /app/src

# Set environment variables for tests
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "retrofit/kotlin-test/src/test/java/retrofit2"
cp "/tests/retrofit/kotlin-test/src/test/java/retrofit2/KotlinExtensionsTest.kt" "retrofit/kotlin-test/src/test/java/retrofit2/KotlinExtensionsTest.kt"
mkdir -p "retrofit/kotlin-test/src/test/java/retrofit2"
cp "/tests/retrofit/kotlin-test/src/test/java/retrofit2/KotlinSuspendRawTest.java" "retrofit/kotlin-test/src/test/java/retrofit2/KotlinSuspendRawTest.java"
mkdir -p "retrofit/kotlin-test/src/test/java/retrofit2"
cp "/tests/retrofit/kotlin-test/src/test/java/retrofit2/KotlinSuspendTest.kt" "retrofit/kotlin-test/src/test/java/retrofit2/KotlinSuspendTest.kt"
mkdir -p "retrofit/kotlin-test/src/test/java/retrofit2"
cp "/tests/retrofit/kotlin-test/src/test/java/retrofit2/KotlinUnitTest.java" "retrofit/kotlin-test/src/test/java/retrofit2/KotlinUnitTest.java"

# Run only the specific test classes
./gradlew :retrofit:kotlin-test:test --tests "retrofit2.KotlinExtensionsTest" --tests "retrofit2.KotlinSuspendRawTest" --tests "retrofit2.KotlinSuspendTest" --tests "retrofit2.KotlinUnitTest" --no-daemon
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
