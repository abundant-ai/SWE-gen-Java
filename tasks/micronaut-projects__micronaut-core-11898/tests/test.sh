#!/bin/bash

cd /app/src

export TESTCONTAINERS_RYUK_DISABLED=true
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "http-server-netty/src/test/groovy/io/micronaut/http/server/netty"
cp "/tests/http-server-netty/src/test/groovy/io/micronaut/http/server/netty/BufferLeakDetectionExtension.java" "http-server-netty/src/test/groovy/io/micronaut/http/server/netty/BufferLeakDetectionExtension.java"
mkdir -p "http-server-netty/src/test/groovy/io/micronaut/http/server/netty/binding"
cp "/tests/http-server-netty/src/test/groovy/io/micronaut/http/server/netty/binding/FormDataDiskSpec.groovy" "http-server-netty/src/test/groovy/io/micronaut/http/server/netty/binding/FormDataDiskSpec.groovy"
mkdir -p "http-server-netty/src/test/groovy/io/micronaut/http/server/netty/fuzzing"
cp "/tests/http-server-netty/src/test/groovy/io/micronaut/http/server/netty/fuzzing/FlagAppender.java" "http-server-netty/src/test/groovy/io/micronaut/http/server/netty/fuzzing/FlagAppender.java"
mkdir -p "http-server-netty/src/test/groovy/io/micronaut/http/server/netty/fuzzing"
cp "/tests/http-server-netty/src/test/groovy/io/micronaut/http/server/netty/fuzzing/FuzzyInputSpec.groovy" "http-server-netty/src/test/groovy/io/micronaut/http/server/netty/fuzzing/FuzzyInputSpec.groovy"
mkdir -p "http-server-netty/src/test/groovy/io/micronaut/http/server/netty/resources"
cp "/tests/http-server-netty/src/test/groovy/io/micronaut/http/server/netty/resources/StaticResourceResolutionSpec2.groovy" "http-server-netty/src/test/groovy/io/micronaut/http/server/netty/resources/StaticResourceResolutionSpec2.groovy"
mkdir -p "http-server-tck/src/main/java/io/micronaut/http/server/tck/tests/forms"
cp "/tests/http-server-tck/src/main/java/io/micronaut/http/server/tck/tests/forms/UploadTest.java" "http-server-tck/src/main/java/io/micronaut/http/server/tck/tests/forms/UploadTest.java"
mkdir -p "http-tck/src/main/java/io/micronaut/http/tck/netty"
cp "/tests/http-tck/src/main/java/io/micronaut/http/tck/netty/TestLeakDetector.java" "http-tck/src/main/java/io/micronaut/http/tck/netty/TestLeakDetector.java"
mkdir -p "test-suite-http-server-tck-jdk/src/test/java/io/micronaut/http/server/tck/netty/tests"
cp "/tests/test-suite-http-server-tck-jdk/src/test/java/io/micronaut/http/server/tck/netty/tests/JdkHttpServerTestSuite.java" "test-suite-http-server-tck-jdk/src/test/java/io/micronaut/http/server/tck/netty/tests/JdkHttpServerTestSuite.java"

# Remove compiled test classes to force recompilation with the new test files
rm -rf build/classes/groovy/test/io/micronaut/http/server/netty/BufferLeakDetectionExtension.class
rm -rf http-server-netty/build/classes/groovy/test/io/micronaut/http/server/netty/binding/FormDataDiskSpec*.class
rm -rf http-server-netty/build/classes/groovy/test/io/micronaut/http/server/netty/fuzzing/FlagAppender.class
rm -rf http-server-netty/build/classes/groovy/test/io/micronaut/http/server/netty/fuzzing/FuzzyInputSpec*.class
rm -rf http-server-netty/build/classes/groovy/test/io/micronaut/http/server/netty/resources/StaticResourceResolutionSpec2*.class
rm -rf http-server-tck/build/classes/java/main/io/micronaut/http/server/tck/tests/forms/UploadTest*.class
rm -rf http-tck/build/classes/java/main/io/micronaut/http/tck/netty/TestLeakDetector*.class
rm -rf test-suite-http-server-tck-jdk/build/classes/java/test/io/micronaut/http/server/tck/netty/tests/JdkHttpServerTestSuite*.class

# Run specific tests using Gradle (only the actual test specs, not helper classes)
./gradlew \
  :micronaut-http-server-netty:test --tests "io.micronaut.http.server.netty.binding.FormDataDiskSpec" \
  --tests "io.micronaut.http.server.netty.fuzzing.FuzzyInputSpec" \
  --tests "io.micronaut.http.server.netty.resources.StaticResourceResolutionSpec2" \
  --no-daemon --console=plain
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
