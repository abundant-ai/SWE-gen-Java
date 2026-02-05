#!/bin/bash

cd /app/src

export TESTCONTAINERS_RYUK_DISABLED=true
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "inject-java/src/test/groovy/io/micronaut/visitors"
cp "/tests/inject-java/src/test/groovy/io/micronaut/visitors/Builder.java" "inject-java/src/test/groovy/io/micronaut/visitors/Builder.java"
mkdir -p "inject-java/src/test/groovy/io/micronaut/visitors"
cp "/tests/inject-java/src/test/groovy/io/micronaut/visitors/BuilderVisitor.java" "inject-java/src/test/groovy/io/micronaut/visitors/BuilderVisitor.java"
mkdir -p "inject-java/src/test/groovy/io/micronaut/visitors"
cp "/tests/inject-java/src/test/groovy/io/micronaut/visitors/PostponedVisitorsSpec.groovy" "inject-java/src/test/groovy/io/micronaut/visitors/PostponedVisitorsSpec.groovy"
mkdir -p "inject-java/src/test/resources/META-INF/services"
cp "/tests/inject-java/src/test/resources/META-INF/services/io.micronaut.inject.visitor.TypeElementVisitor" "inject-java/src/test/resources/META-INF/services/io.micronaut.inject.visitor.TypeElementVisitor"

# Update timestamps to force Gradle to detect changes
touch inject-java/src/test/groovy/io/micronaut/visitors/Builder.java
touch inject-java/src/test/groovy/io/micronaut/visitors/BuilderVisitor.java
touch inject-java/src/test/groovy/io/micronaut/visitors/PostponedVisitorsSpec.groovy

# Remove compiled test classes to force recompilation with the new test files
rm -rf inject-java/build/classes/groovy/test/io/micronaut/visitors/*.class
rm -rf inject-java/build/classes/java/test/io/micronaut/visitors/*.class

# Run specific tests using Gradle
./gradlew \
  :inject-java:test --tests "io.micronaut.visitors.PostponedVisitorsSpec" \
  --no-daemon --console=plain
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
