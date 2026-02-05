#!/bin/bash

cd /app/src

# Set environment variables for tests
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "retrofit/java-test/src/test/java/retrofit2"
cp "/tests/retrofit/java-test/src/test/java/retrofit2/MethodParameterReflectionTest.java" "retrofit/java-test/src/test/java/retrofit2/MethodParameterReflectionTest.java"
mkdir -p "retrofit/java-test/src/test/java/retrofit2"
cp "/tests/retrofit/java-test/src/test/java/retrofit2/RequestFactoryTest.java" "retrofit/java-test/src/test/java/retrofit2/RequestFactoryTest.java"
mkdir -p "retrofit/java-test/src/test/java/retrofit2"
cp "/tests/retrofit/java-test/src/test/java/retrofit2/RetrofitTest.java" "retrofit/java-test/src/test/java/retrofit2/RetrofitTest.java"

# Touch the files to update timestamps so Gradle recognizes the changes
touch "retrofit/java-test/src/test/java/retrofit2/MethodParameterReflectionTest.java"
touch "retrofit/java-test/src/test/java/retrofit2/RequestFactoryTest.java"
touch "retrofit/java-test/src/test/java/retrofit2/RetrofitTest.java"

# Clean and recompile test classes after copying
rm -rf retrofit/java-test/build/
./gradlew :retrofit:java-test:compileTestJava --no-daemon

# Run only the specific test classes using the JDK21 test task
./gradlew :retrofit:java-test:testJdk21 --tests "retrofit2.MethodParameterReflectionTest" --tests "retrofit2.RequestFactoryTest" --tests "retrofit2.RetrofitTest" --no-daemon
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
