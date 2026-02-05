#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/org/mockito/internal/stubbing/defaultanswers"
cp "/tests/java/org/mockito/internal/stubbing/defaultanswers/ReturnsGenericDeepStubsTest.java" "src/test/java/org/mockito/internal/stubbing/defaultanswers/ReturnsGenericDeepStubsTest.java"
mkdir -p "src/test/java/org/mockito/internal/util/reflection"
cp "/tests/java/org/mockito/internal/util/reflection/GenericMetadataSupportTest.java" "src/test/java/org/mockito/internal/util/reflection/GenericMetadataSupportTest.java"
mkdir -p "src/test/java/org/mockitousage/serialization"
cp "/tests/java/org/mockitousage/serialization/DeepStubsSerializableTest.java" "src/test/java/org/mockitousage/serialization/DeepStubsSerializableTest.java"
mkdir -p "src/test/java/org/mockitousage/stubbing"
cp "/tests/java/org/mockitousage/stubbing/DeepStubbingTest.java" "src/test/java/org/mockitousage/stubbing/DeepStubbingTest.java"

# Run the specific test files for this PR
./gradlew :test \
  --tests org.mockito.internal.stubbing.defaultanswers.ReturnsGenericDeepStubsTest \
  --tests org.mockito.internal.util.reflection.GenericMetadataSupportTest \
  --tests org.mockitousage.serialization.DeepStubsSerializableTest \
  --tests org.mockitousage.stubbing.DeepStubbingTest \
  --no-daemon --rerun-tasks
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
