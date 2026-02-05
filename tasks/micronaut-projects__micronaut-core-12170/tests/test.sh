#!/bin/bash

cd /app/src

export TESTCONTAINERS_RYUK_DISABLED=true
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "context-propagation/src/test/groovy/io/micronaut/context"
cp "/tests/context-propagation/src/test/groovy/io/micronaut/context/AnnotationReflectionUtilsSpec.groovy" "context-propagation/src/test/groovy/io/micronaut/context/AnnotationReflectionUtilsSpec.groovy"
mkdir -p "http/src/test/groovy/io/micronaut/http/filter"
cp "/tests/http/src/test/groovy/io/micronaut/http/filter/FilterRunnerSpec.groovy" "http/src/test/groovy/io/micronaut/http/filter/FilterRunnerSpec.groovy"
mkdir -p "http/src/test/groovy/io/micronaut/http/filter"
cp "/tests/http/src/test/groovy/io/micronaut/http/filter/LambdaExecutable.java" "http/src/test/groovy/io/micronaut/http/filter/LambdaExecutable.java"
mkdir -p "inject-groovy-test/src/main/groovy/io/micronaut/ast/transform/test"
cp "/tests/inject-groovy-test/src/main/groovy/io/micronaut/ast/transform/test/AbstractBeanDefinitionSpec.groovy" "inject-groovy-test/src/main/groovy/io/micronaut/ast/transform/test/AbstractBeanDefinitionSpec.groovy"
mkdir -p "inject-groovy/src/test/groovy/io/micronaut/aop/introduction"
cp "/tests/inject-groovy/src/test/groovy/io/micronaut/aop/introduction/MyRepoIntroductionSpec.groovy" "inject-groovy/src/test/groovy/io/micronaut/aop/introduction/MyRepoIntroductionSpec.groovy"
mkdir -p "inject-groovy/src/test/groovy/io/micronaut/ast/groovy/scan"
cp "/tests/inject-groovy/src/test/groovy/io/micronaut/ast/groovy/scan/ClassPathScannerSpec.groovy" "inject-groovy/src/test/groovy/io/micronaut/ast/groovy/scan/ClassPathScannerSpec.groovy"
mkdir -p "inject-groovy/src/test/groovy/io/micronaut/ast/groovy/scan/nested"
cp "/tests/inject-groovy/src/test/groovy/io/micronaut/ast/groovy/scan/nested/Foo2.groovy" "inject-groovy/src/test/groovy/io/micronaut/ast/groovy/scan/nested/Foo2.groovy"
mkdir -p "inject-groovy/src/test/groovy/io/micronaut/ast/groovy/scan2"
cp "/tests/inject-groovy/src/test/groovy/io/micronaut/ast/groovy/scan2/Foo3.groovy" "inject-groovy/src/test/groovy/io/micronaut/ast/groovy/scan2/Foo3.groovy"
mkdir -p "inject-groovy/src/test/groovy/io/micronaut/inject/annotation"
cp "/tests/inject-groovy/src/test/groovy/io/micronaut/inject/annotation/AnnotationMetadataWriterSpec.groovy" "inject-groovy/src/test/groovy/io/micronaut/inject/annotation/AnnotationMetadataWriterSpec.groovy"
mkdir -p "inject-groovy/src/test/groovy/io/micronaut/inject/generics"
cp "/tests/inject-groovy/src/test/groovy/io/micronaut/inject/generics/GenericTypeArgumentsSpec.groovy" "inject-groovy/src/test/groovy/io/micronaut/inject/generics/GenericTypeArgumentsSpec.groovy"
mkdir -p "inject-groovy/src/test/groovy/io/micronaut/inject/visitor"
cp "/tests/inject-groovy/src/test/groovy/io/micronaut/inject/visitor/ClassElementSpec.groovy" "inject-groovy/src/test/groovy/io/micronaut/inject/visitor/ClassElementSpec.groovy"
mkdir -p "inject-java-test/src/main/groovy/io/micronaut/annotation/processing/test"
cp "/tests/inject-java-test/src/main/groovy/io/micronaut/annotation/processing/test/AbstractTypeElementSpec.groovy" "inject-java-test/src/main/groovy/io/micronaut/annotation/processing/test/AbstractTypeElementSpec.groovy"
mkdir -p "inject/src/test/groovy/io/micronaut/context"
cp "/tests/inject/src/test/groovy/io/micronaut/context/BeanEventListenerOrderingSpec.groovy" "inject/src/test/groovy/io/micronaut/context/BeanEventListenerOrderingSpec.groovy"
mkdir -p "inject/src/test/groovy/io/micronaut/context/env"
cp "/tests/inject/src/test/groovy/io/micronaut/context/env/DefaultEnvironmentSpec.groovy" "inject/src/test/groovy/io/micronaut/context/env/DefaultEnvironmentSpec.groovy"
mkdir -p "management/src/test/groovy/io/micronaut/management/endpoint/env"
cp "/tests/management/src/test/groovy/io/micronaut/management/endpoint/env/EnvironmentEndpointSpec.groovy" "management/src/test/groovy/io/micronaut/management/endpoint/env/EnvironmentEndpointSpec.groovy"
mkdir -p "test-suite-groovy/src/test/groovy/io/micronaut/docs/inject/generics"
cp "/tests/test-suite-groovy/src/test/groovy/io/micronaut/docs/inject/generics/Engine.groovy" "test-suite-groovy/src/test/groovy/io/micronaut/docs/inject/generics/Engine.groovy"
mkdir -p "test-suite-groovy/src/test/groovy/io/micronaut/docs/ioc/introspection"
cp "/tests/test-suite-groovy/src/test/groovy/io/micronaut/docs/ioc/introspection/JakartaTransientSpec.groovy" "test-suite-groovy/src/test/groovy/io/micronaut/docs/ioc/introspection/JakartaTransientSpec.groovy"
mkdir -p "test-suite-groovy/src/test/groovy/io/micronaut/docs/ioc/introspection"
cp "/tests/test-suite-groovy/src/test/groovy/io/micronaut/docs/ioc/introspection/JavaxTransientSpec.groovy" "test-suite-groovy/src/test/groovy/io/micronaut/docs/ioc/introspection/JavaxTransientSpec.groovy"
mkdir -p "test-suite-groovy/src/test/groovy/io/micronaut/docs/ioc/mappers"
cp "/tests/test-suite-groovy/src/test/groovy/io/micronaut/docs/ioc/mappers/MappersSpec.groovy" "test-suite-groovy/src/test/groovy/io/micronaut/docs/ioc/mappers/MappersSpec.groovy"

# Run specific tests using Gradle
# Note: Gradle uses standardized project names with micronaut- prefix
./gradlew \
    :micronaut-context-propagation:test --tests "io.micronaut.context.AnnotationReflectionUtilsSpec" \
    :micronaut-http:test --tests "io.micronaut.http.filter.FilterRunnerSpec" \
    :micronaut-inject-groovy:test --tests "io.micronaut.aop.introduction.MyRepoIntroductionSpec" \
    :micronaut-inject-groovy:test --tests "io.micronaut.ast.groovy.scan.ClassPathScannerSpec" \
    :micronaut-inject-groovy:test --tests "io.micronaut.inject.annotation.AnnotationMetadataWriterSpec" \
    :micronaut-inject-groovy:test --tests "io.micronaut.inject.generics.GenericTypeArgumentsSpec" \
    :micronaut-inject-groovy:test --tests "io.micronaut.inject.visitor.ClassElementSpec" \
    :micronaut-inject:test --tests "io.micronaut.context.BeanEventListenerOrderingSpec" \
    :micronaut-inject:test --tests "io.micronaut.context.env.DefaultEnvironmentSpec" \
    :micronaut-management:test --tests "io.micronaut.management.endpoint.env.EnvironmentEndpointSpec" \
    :test-suite-groovy:test --tests "io.micronaut.docs.ioc.introspection.JakartaTransientSpec" \
    :test-suite-groovy:test --tests "io.micronaut.docs.ioc.introspection.JavaxTransientSpec" \
    :test-suite-groovy:test --tests "io.micronaut.docs.ioc.mappers.MappersSpec" \
    --no-daemon --console=plain --continue
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
