#!/bin/bash

cd /app/src

export TESTCONTAINERS_RYUK_DISABLED=true
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "inject-java/src/test/groovy/io/micronaut/inject/foreach/noqualifier"
cp "/tests/inject-java/src/test/groovy/io/micronaut/inject/foreach/noqualifier/Bar.java" "inject-java/src/test/groovy/io/micronaut/inject/foreach/noqualifier/Bar.java"
mkdir -p "inject-java/src/test/groovy/io/micronaut/inject/foreach/noqualifier"
cp "/tests/inject-java/src/test/groovy/io/micronaut/inject/foreach/noqualifier/EachBeanNoQualifierSpec.groovy" "inject-java/src/test/groovy/io/micronaut/inject/foreach/noqualifier/EachBeanNoQualifierSpec.groovy"
mkdir -p "inject-java/src/test/groovy/io/micronaut/inject/foreach/noqualifier"
cp "/tests/inject-java/src/test/groovy/io/micronaut/inject/foreach/noqualifier/Foo.java" "inject-java/src/test/groovy/io/micronaut/inject/foreach/noqualifier/Foo.java"
mkdir -p "inject-java/src/test/groovy/io/micronaut/inject/foreach/noqualifier"
cp "/tests/inject-java/src/test/groovy/io/micronaut/inject/foreach/noqualifier/MyEach1.java" "inject-java/src/test/groovy/io/micronaut/inject/foreach/noqualifier/MyEach1.java"
mkdir -p "inject-java/src/test/groovy/io/micronaut/inject/foreach/noqualifier"
cp "/tests/inject-java/src/test/groovy/io/micronaut/inject/foreach/noqualifier/MyEach1User.java" "inject-java/src/test/groovy/io/micronaut/inject/foreach/noqualifier/MyEach1User.java"
mkdir -p "inject-java/src/test/groovy/io/micronaut/inject/foreach/noqualifier"
cp "/tests/inject-java/src/test/groovy/io/micronaut/inject/foreach/noqualifier/MyEach2.java" "inject-java/src/test/groovy/io/micronaut/inject/foreach/noqualifier/MyEach2.java"
mkdir -p "inject-java/src/test/groovy/io/micronaut/inject/foreach/noqualifier"
cp "/tests/inject-java/src/test/groovy/io/micronaut/inject/foreach/noqualifier/MyEach2User.java" "inject-java/src/test/groovy/io/micronaut/inject/foreach/noqualifier/MyEach2User.java"
mkdir -p "inject-java/src/test/groovy/io/micronaut/inject/foreach/noqualifier"
cp "/tests/inject-java/src/test/groovy/io/micronaut/inject/foreach/noqualifier/MyEach3.java" "inject-java/src/test/groovy/io/micronaut/inject/foreach/noqualifier/MyEach3.java"
mkdir -p "inject-java/src/test/groovy/io/micronaut/inject/foreach/noqualifier"
cp "/tests/inject-java/src/test/groovy/io/micronaut/inject/foreach/noqualifier/MyEach3User.java" "inject-java/src/test/groovy/io/micronaut/inject/foreach/noqualifier/MyEach3User.java"
mkdir -p "inject-java/src/test/groovy/io/micronaut/inject/foreach/noqualifier"
cp "/tests/inject-java/src/test/groovy/io/micronaut/inject/foreach/noqualifier/MyMapEachUser.java" "inject-java/src/test/groovy/io/micronaut/inject/foreach/noqualifier/MyMapEachUser.java"
mkdir -p "inject-java/src/test/groovy/io/micronaut/inject/foreach/noqualifier"
cp "/tests/inject-java/src/test/groovy/io/micronaut/inject/foreach/noqualifier/MyService.java" "inject-java/src/test/groovy/io/micronaut/inject/foreach/noqualifier/MyService.java"
mkdir -p "inject-java/src/test/groovy/io/micronaut/inject/foreach/qualifier"
cp "/tests/inject-java/src/test/groovy/io/micronaut/inject/foreach/qualifier/Bar.java" "inject-java/src/test/groovy/io/micronaut/inject/foreach/qualifier/Bar.java"
mkdir -p "inject-java/src/test/groovy/io/micronaut/inject/foreach/qualifier"
cp "/tests/inject-java/src/test/groovy/io/micronaut/inject/foreach/qualifier/EachBeanQualifierSpec.groovy" "inject-java/src/test/groovy/io/micronaut/inject/foreach/qualifier/EachBeanQualifierSpec.groovy"
mkdir -p "inject-java/src/test/groovy/io/micronaut/inject/foreach/qualifier"
cp "/tests/inject-java/src/test/groovy/io/micronaut/inject/foreach/qualifier/Foo.java" "inject-java/src/test/groovy/io/micronaut/inject/foreach/qualifier/Foo.java"
mkdir -p "inject-java/src/test/groovy/io/micronaut/inject/foreach/qualifier"
cp "/tests/inject-java/src/test/groovy/io/micronaut/inject/foreach/qualifier/MyEach1.java" "inject-java/src/test/groovy/io/micronaut/inject/foreach/qualifier/MyEach1.java"
mkdir -p "inject-java/src/test/groovy/io/micronaut/inject/foreach/qualifier"
cp "/tests/inject-java/src/test/groovy/io/micronaut/inject/foreach/qualifier/MyEach1User.java" "inject-java/src/test/groovy/io/micronaut/inject/foreach/qualifier/MyEach1User.java"
mkdir -p "inject-java/src/test/groovy/io/micronaut/inject/foreach/qualifier"
cp "/tests/inject-java/src/test/groovy/io/micronaut/inject/foreach/qualifier/MyEach2.java" "inject-java/src/test/groovy/io/micronaut/inject/foreach/qualifier/MyEach2.java"
mkdir -p "inject-java/src/test/groovy/io/micronaut/inject/foreach/qualifier"
cp "/tests/inject-java/src/test/groovy/io/micronaut/inject/foreach/qualifier/MyEach2User.java" "inject-java/src/test/groovy/io/micronaut/inject/foreach/qualifier/MyEach2User.java"
mkdir -p "inject-java/src/test/groovy/io/micronaut/inject/foreach/qualifier"
cp "/tests/inject-java/src/test/groovy/io/micronaut/inject/foreach/qualifier/MyEach3.java" "inject-java/src/test/groovy/io/micronaut/inject/foreach/qualifier/MyEach3.java"
mkdir -p "inject-java/src/test/groovy/io/micronaut/inject/foreach/qualifier"
cp "/tests/inject-java/src/test/groovy/io/micronaut/inject/foreach/qualifier/MyEach3User.java" "inject-java/src/test/groovy/io/micronaut/inject/foreach/qualifier/MyEach3User.java"
mkdir -p "inject-java/src/test/groovy/io/micronaut/inject/foreach/qualifier"
cp "/tests/inject-java/src/test/groovy/io/micronaut/inject/foreach/qualifier/MyMapEachUser.java" "inject-java/src/test/groovy/io/micronaut/inject/foreach/qualifier/MyMapEachUser.java"
mkdir -p "inject-java/src/test/groovy/io/micronaut/inject/foreach/qualifier"
cp "/tests/inject-java/src/test/groovy/io/micronaut/inject/foreach/qualifier/MyService.java" "inject-java/src/test/groovy/io/micronaut/inject/foreach/qualifier/MyService.java"

# Update timestamps to force Gradle to detect changes
touch inject-java/src/test/groovy/io/micronaut/inject/foreach/noqualifier/*.java
touch inject-java/src/test/groovy/io/micronaut/inject/foreach/noqualifier/*.groovy
touch inject-java/src/test/groovy/io/micronaut/inject/foreach/qualifier/*.java
touch inject-java/src/test/groovy/io/micronaut/inject/foreach/qualifier/*.groovy

# Remove compiled test classes to force recompilation with the new test files
rm -rf inject-java/build/classes/groovy/test/io/micronaut/inject/foreach/

# Run the specific tests for this PR
./gradlew :inject-java:cleanTest :inject-java:test --tests "*EachBeanNoQualifierSpec" --tests "*EachBeanQualifierSpec" \
          --no-daemon --console=plain
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
