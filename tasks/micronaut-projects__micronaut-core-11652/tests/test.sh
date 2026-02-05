#!/bin/bash

cd /app/src

export TESTCONTAINERS_RYUK_DISABLED=true
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "inject-java/src/test/groovy/io/micronaut/visitors"
cp "/tests/inject-java/src/test/groovy/io/micronaut/visitors/IntroductionTest.java" "inject-java/src/test/groovy/io/micronaut/visitors/IntroductionTest.java"
mkdir -p "inject-java/src/test/groovy/io/micronaut/visitors"
cp "/tests/inject-java/src/test/groovy/io/micronaut/visitors/IntroductionTestGen.java" "inject-java/src/test/groovy/io/micronaut/visitors/IntroductionTestGen.java"
mkdir -p "inject-java/src/test/groovy/io/micronaut/visitors"
cp "/tests/inject-java/src/test/groovy/io/micronaut/visitors/IntroductionTestVisitor.java" "inject-java/src/test/groovy/io/micronaut/visitors/IntroductionTestVisitor.java"
mkdir -p "inject-java/src/test/groovy/io/micronaut/visitors"
cp "/tests/inject-java/src/test/groovy/io/micronaut/visitors/PostponedVisitorsSpec.groovy" "inject-java/src/test/groovy/io/micronaut/visitors/PostponedVisitorsSpec.groovy"
mkdir -p "inject-java/src/test/resources/META-INF/services"
cp "/tests/inject-java/src/test/resources/META-INF/services/io.micronaut.inject.visitor.TypeElementVisitor" "inject-java/src/test/resources/META-INF/services/io.micronaut.inject.visitor.TypeElementVisitor"

# Update timestamps to force Gradle to detect changes
touch inject-java/src/test/groovy/io/micronaut/visitors/*.groovy 2>/dev/null || true
touch inject-java/src/test/groovy/io/micronaut/visitors/*.java 2>/dev/null || true

# Remove compiled classes to force recompilation with the new test files
rm -rf inject-java/build/classes/ 2>/dev/null || true

# Run the specific tests for this PR
set +e  # Don't exit on error, we'll check manually

test_output=""

# Run inject-java module tests (PostponedVisitorsSpec)
cd inject-java
test_output+=$(../gradlew test --tests "*visitors.PostponedVisitorsSpec" --no-daemon --console=plain 2>&1)
gradle_exit=$?
cd ..

set -e

echo "$test_output"

# Check if tests passed (even if Gradle daemon crashes during cleanup)
if echo "$test_output" | grep -q "BUILD SUCCESSFUL"; then
    test_status=0
else
    # If gradle command failed, mark as failure
    if [ $gradle_exit -ne 0 ]; then
        test_status=1
    else
        test_status=0
    fi
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
