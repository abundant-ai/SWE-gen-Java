#!/bin/bash

cd /app/src

export TESTCONTAINERS_RYUK_DISABLED=true
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "inject-java/src/test/groovy/io/micronaut/visitors"
cp "/tests/inject-java/src/test/groovy/io/micronaut/visitors/CollectingVisitor.groovy" "inject-java/src/test/groovy/io/micronaut/visitors/CollectingVisitor.groovy"
mkdir -p "inject-java/src/test/groovy/io/micronaut/visitors"
cp "/tests/inject-java/src/test/groovy/io/micronaut/visitors/GeneratorTrigger.java" "inject-java/src/test/groovy/io/micronaut/visitors/GeneratorTrigger.java"
mkdir -p "inject-java/src/test/groovy/io/micronaut/visitors"
cp "/tests/inject-java/src/test/groovy/io/micronaut/visitors/GeneratorVisitor.groovy" "inject-java/src/test/groovy/io/micronaut/visitors/GeneratorVisitor.groovy"
mkdir -p "inject-java/src/test/groovy/io/micronaut/visitors"
cp "/tests/inject-java/src/test/groovy/io/micronaut/visitors/IntroductionTestGenVisitor.java" "inject-java/src/test/groovy/io/micronaut/visitors/IntroductionTestGenVisitor.java"
mkdir -p "inject-java/src/test/groovy/io/micronaut/visitors"
cp "/tests/inject-java/src/test/groovy/io/micronaut/visitors/IntroductionTestVisitor.java" "inject-java/src/test/groovy/io/micronaut/visitors/IntroductionTestVisitor.java"
mkdir -p "inject-java/src/test/groovy/io/micronaut/visitors"
cp "/tests/inject-java/src/test/groovy/io/micronaut/visitors/PostponedVisitorsSpec.groovy" "inject-java/src/test/groovy/io/micronaut/visitors/PostponedVisitorsSpec.groovy"
mkdir -p "inject-java/src/test/resources/META-INF/services"
cp "/tests/inject-java/src/test/resources/META-INF/services/io.micronaut.inject.visitor.TypeElementVisitor" "inject-java/src/test/resources/META-INF/services/io.micronaut.inject.visitor.TypeElementVisitor"

# Remove compiled test classes to force recompilation with the new test files
rm -rf inject-java/build/classes/groovy/test/io/micronaut/visitors/*.class
rm -rf inject-java/build/classes/java/test/io/micronaut/visitors/*.class

# Run specific tests using Gradle
./gradlew \
  :micronaut-inject-java:test --tests "io.micronaut.visitors.PostponedVisitorsSpec" \
  --no-daemon --console=plain
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
