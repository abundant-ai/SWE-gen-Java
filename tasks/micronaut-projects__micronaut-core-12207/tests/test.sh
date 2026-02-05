#!/bin/bash

cd /app/src

export TESTCONTAINERS_RYUK_DISABLED=true
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "context-propagation/src/test/kotlin/io/micronaut/context/propagation/mdc"
cp "/tests/context-propagation/src/test/kotlin/io/micronaut/context/propagation/mdc/MdcPropagationSpec.kt" "context-propagation/src/test/kotlin/io/micronaut/context/propagation/mdc/MdcPropagationSpec.kt"
mkdir -p "http-client-tck/src/main/java/io/micronaut/http/client/tck/tests"
cp "/tests/http-client-tck/src/main/java/io/micronaut/http/client/tck/tests/Person.java" "http-client-tck/src/main/java/io/micronaut/http/client/tck/tests/Person.java"
mkdir -p "http-server-netty/src/test/groovy/io/micronaut/http/server/netty/binding"
cp "/tests/http-server-netty/src/test/groovy/io/micronaut/http/server/netty/binding/CustomParameterBindingSpec.groovy" "http-server-netty/src/test/groovy/io/micronaut/http/server/netty/binding/CustomParameterBindingSpec.groovy"
mkdir -p "http-server-netty/src/test/groovy/io/micronaut/http/server/netty/binding"
cp "/tests/http-server-netty/src/test/groovy/io/micronaut/http/server/netty/binding/ParameterBindingSpec.groovy" "http-server-netty/src/test/groovy/io/micronaut/http/server/netty/binding/ParameterBindingSpec.groovy"
mkdir -p "http-server-tck/src/main/java/io/micronaut/http/server/tck/tests"
cp "/tests/http-server-tck/src/main/java/io/micronaut/http/server/tck/tests/BodyTest.java" "http-server-tck/src/main/java/io/micronaut/http/server/tck/tests/BodyTest.java"
mkdir -p "http-server-tck/src/main/java/io/micronaut/http/server/tck/tests"
cp "/tests/http-server-tck/src/main/java/io/micronaut/http/server/tck/tests/ConsumesTest.java" "http-server-tck/src/main/java/io/micronaut/http/server/tck/tests/ConsumesTest.java"
mkdir -p "http-server-tck/src/main/java/io/micronaut/http/server/tck/tests"
cp "/tests/http-server-tck/src/main/java/io/micronaut/http/server/tck/tests/ErrorHandlerTest.java" "http-server-tck/src/main/java/io/micronaut/http/server/tck/tests/ErrorHandlerTest.java"
mkdir -p "http-server-tck/src/main/java/io/micronaut/http/server/tck/tests"
cp "/tests/http-server-tck/src/main/java/io/micronaut/http/server/tck/tests/HeadersTest.java" "http-server-tck/src/main/java/io/micronaut/http/server/tck/tests/HeadersTest.java"
mkdir -p "http-server-tck/src/main/java/io/micronaut/http/server/tck/tests"
cp "/tests/http-server-tck/src/main/java/io/micronaut/http/server/tck/tests/LocalErrorReadingBodyTest.java" "http-server-tck/src/main/java/io/micronaut/http/server/tck/tests/LocalErrorReadingBodyTest.java"
mkdir -p "http-server-tck/src/main/java/io/micronaut/http/server/tck/tests"
cp "/tests/http-server-tck/src/main/java/io/micronaut/http/server/tck/tests/MiscTest.java" "http-server-tck/src/main/java/io/micronaut/http/server/tck/tests/MiscTest.java"
mkdir -p "http-server-tck/src/main/java/io/micronaut/http/server/tck/tests"
cp "/tests/http-server-tck/src/main/java/io/micronaut/http/server/tck/tests/MissingBodyAnnotationTest.java" "http-server-tck/src/main/java/io/micronaut/http/server/tck/tests/MissingBodyAnnotationTest.java"
mkdir -p "http-server-tck/src/main/java/io/micronaut/http/server/tck/tests"
cp "/tests/http-server-tck/src/main/java/io/micronaut/http/server/tck/tests/NoBodyResponseTest.java" "http-server-tck/src/main/java/io/micronaut/http/server/tck/tests/NoBodyResponseTest.java"
mkdir -p "http-server-tck/src/main/java/io/micronaut/http/server/tck/tests/binding"
cp "/tests/http-server-tck/src/main/java/io/micronaut/http/server/tck/tests/binding/LocalDateTimeTest.java" "http-server-tck/src/main/java/io/micronaut/http/server/tck/tests/binding/LocalDateTimeTest.java"
mkdir -p "http-server-tck/src/main/java/io/micronaut/http/server/tck/tests/codec"
cp "/tests/http-server-tck/src/main/java/io/micronaut/http/server/tck/tests/codec/JsonCodecAdditionalType2Test.java" "http-server-tck/src/main/java/io/micronaut/http/server/tck/tests/codec/JsonCodecAdditionalType2Test.java"
mkdir -p "http-server-tck/src/main/java/io/micronaut/http/server/tck/tests/codec"
cp "/tests/http-server-tck/src/main/java/io/micronaut/http/server/tck/tests/codec/JsonCodecAdditionalTypeAutomaticTest.java" "http-server-tck/src/main/java/io/micronaut/http/server/tck/tests/codec/JsonCodecAdditionalTypeAutomaticTest.java"
mkdir -p "http-server-tck/src/main/java/io/micronaut/http/server/tck/tests/codec"
cp "/tests/http-server-tck/src/main/java/io/micronaut/http/server/tck/tests/codec/JsonCodecAdditionalTypeTest.java" "http-server-tck/src/main/java/io/micronaut/http/server/tck/tests/codec/JsonCodecAdditionalTypeTest.java"
mkdir -p "http-server-tck/src/main/java/io/micronaut/http/server/tck/tests/constraintshandler"
cp "/tests/http-server-tck/src/main/java/io/micronaut/http/server/tck/tests/constraintshandler/ControllerConstraintHandlerTest.java" "http-server-tck/src/main/java/io/micronaut/http/server/tck/tests/constraintshandler/ControllerConstraintHandlerTest.java"
mkdir -p "http-server-tck/src/main/java/io/micronaut/http/server/tck/tests/exceptions"
cp "/tests/http-server-tck/src/main/java/io/micronaut/http/server/tck/tests/exceptions/HtmlErrorPageTest.java" "http-server-tck/src/main/java/io/micronaut/http/server/tck/tests/exceptions/HtmlErrorPageTest.java"
mkdir -p "http-server-tck/src/main/java/io/micronaut/http/server/tck/tests/forms"
cp "/tests/http-server-tck/src/main/java/io/micronaut/http/server/tck/tests/forms/FormBindingUsingMethodParametersTest.java" "http-server-tck/src/main/java/io/micronaut/http/server/tck/tests/forms/FormBindingUsingMethodParametersTest.java"
mkdir -p "http-server-tck/src/main/java/io/micronaut/http/server/tck/tests/forms"
cp "/tests/http-server-tck/src/main/java/io/micronaut/http/server/tck/tests/forms/FormUrlEncodedBodyInRequestFilterTest.java" "http-server-tck/src/main/java/io/micronaut/http/server/tck/tests/forms/FormUrlEncodedBodyInRequestFilterTest.java"
mkdir -p "http-server-tck/src/main/java/io/micronaut/http/server/tck/tests/forms"
cp "/tests/http-server-tck/src/main/java/io/micronaut/http/server/tck/tests/forms/FormsInputNumberOptionalTest.java" "http-server-tck/src/main/java/io/micronaut/http/server/tck/tests/forms/FormsInputNumberOptionalTest.java"
mkdir -p "http-server-tck/src/main/java/io/micronaut/http/server/tck/tests/forms"
cp "/tests/http-server-tck/src/main/java/io/micronaut/http/server/tck/tests/forms/FormsJacksonAnnotationsTest.java" "http-server-tck/src/main/java/io/micronaut/http/server/tck/tests/forms/FormsJacksonAnnotationsTest.java"
mkdir -p "http-server-tck/src/main/java/io/micronaut/http/server/tck/tests/forms"
cp "/tests/http-server-tck/src/main/java/io/micronaut/http/server/tck/tests/forms/FormsSubmissionsWithListsTest.java" "http-server-tck/src/main/java/io/micronaut/http/server/tck/tests/forms/FormsSubmissionsWithListsTest.java"
mkdir -p "http-server-tck/src/main/java/io/micronaut/http/server/tck/tests/routing"
cp "/tests/http-server-tck/src/main/java/io/micronaut/http/server/tck/tests/routing/RootRoutingTest.java" "http-server-tck/src/main/java/io/micronaut/http/server/tck/tests/routing/RootRoutingTest.java"

# Update timestamps to force Gradle to detect changes
touch context-propagation/src/test/kotlin/io/micronaut/context/propagation/mdc/*.kt 2>/dev/null || true
touch http-client-tck/src/main/java/io/micronaut/http/client/tck/tests/*.java 2>/dev/null || true
touch http-server-netty/src/test/groovy/io/micronaut/http/server/netty/binding/*.groovy 2>/dev/null || true
touch http-server-tck/src/main/java/io/micronaut/http/server/tck/tests/**/*.java 2>/dev/null || true

# Remove compiled classes to force recompilation with the new test files
rm -rf context-propagation/build/classes/ 2>/dev/null || true
rm -rf http-client-tck/build/classes/ 2>/dev/null || true
rm -rf http-server-netty/build/classes/ 2>/dev/null || true
rm -rf http-server-tck/build/classes/ 2>/dev/null || true

# Run the specific tests for this PR
set +e  # Don't exit on error, we'll check manually

# Run tests for each module separately
test_output=""

# context-propagation tests
cd context-propagation
test_output+=$(../gradlew test --tests "*MdcPropagationSpec*" --no-daemon --console=plain 2>&1)
cd ..

# http-server-netty tests
cd http-server-netty
test_output+=$(../gradlew test --tests "*CustomParameterBindingSpec*" --tests "*ParameterBindingSpec*" --no-daemon --console=plain 2>&1)
cd ..

# http-server-tck tests (most of the tests are here)
cd http-server-tck
test_output+=$(../gradlew test \
    --tests "*BodyTest*" --tests "*ConsumesTest*" --tests "*ErrorHandlerTest*" \
    --tests "*HeadersTest*" --tests "*LocalErrorReadingBodyTest*" --tests "*MiscTest*" \
    --tests "*MissingBodyAnnotationTest*" --tests "*NoBodyResponseTest*" \
    --tests "*LocalDateTimeTest*" \
    --tests "*JsonCodecAdditionalType2Test*" --tests "*JsonCodecAdditionalTypeAutomaticTest*" --tests "*JsonCodecAdditionalTypeTest*" \
    --tests "*ControllerConstraintHandlerTest*" \
    --tests "*HtmlErrorPageTest*" \
    --tests "*FormBindingUsingMethodParametersTest*" --tests "*FormUrlEncodedBodyInRequestFilterTest*" \
    --tests "*FormsInputNumberOptionalTest*" --tests "*FormsJacksonAnnotationsTest*" --tests "*FormsSubmissionsWithListsTest*" \
    --tests "*RootRoutingTest*" \
    --no-daemon --console=plain 2>&1)
cd ..

gradle_exit=$?
set -e

echo "$test_output"

# Check if tests passed (even if Gradle daemon crashes during cleanup)
if echo "$test_output" | grep -q "BUILD SUCCESSFUL"; then
    test_status=0
else
    test_status=$gradle_exit
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
