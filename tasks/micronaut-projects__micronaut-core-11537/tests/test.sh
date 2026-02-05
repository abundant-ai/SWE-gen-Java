#!/bin/bash

cd /app/src

export TESTCONTAINERS_RYUK_DISABLED=true
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "inject-java/src/test/groovy/io/micronaut/inject/annotation"
cp "/tests/inject-java/src/test/groovy/io/micronaut/inject/annotation/AnnotationMetadataWriterSpec.groovy" "inject-java/src/test/groovy/io/micronaut/inject/annotation/AnnotationMetadataWriterSpec.groovy"
mkdir -p "inject-java/src/test/groovy/io/micronaut/inject/annotation"
cp "/tests/inject-java/src/test/groovy/io/micronaut/inject/annotation/MyAnnotationX.java" "inject-java/src/test/groovy/io/micronaut/inject/annotation/MyAnnotationX.java"

# Update timestamps to force Gradle to detect changes
touch inject-java/src/test/groovy/io/micronaut/inject/annotation/AnnotationMetadataWriterSpec.groovy
touch inject-java/src/test/groovy/io/micronaut/inject/annotation/MyAnnotationX.java

# Remove compiled test classes to force recompilation with the new test files
rm -rf inject-java/build/classes/groovy/test/io/micronaut/inject/annotation/*.class
rm -rf inject-java/build/classes/java/test/io/micronaut/inject/annotation/*.class

# Run specific tests using Gradle
./gradlew \
  :inject-java:test --tests "io.micronaut.inject.annotation.AnnotationMetadataWriterSpec" \
  --no-daemon --console=plain
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
