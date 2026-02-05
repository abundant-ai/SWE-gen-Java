#!/bin/bash

cd /app/src

export TESTCONTAINERS_RYUK_DISABLED=true
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "inject-groovy/src/test/groovy/io/micronaut/inject/failures"
cp "/tests/inject-groovy/src/test/groovy/io/micronaut/inject/failures/ConstructorCircularDependencyFailureSpec.groovy" "inject-groovy/src/test/groovy/io/micronaut/inject/failures/ConstructorCircularDependencyFailureSpec.groovy"
mkdir -p "inject-groovy/src/test/groovy/io/micronaut/inject/failures"
cp "/tests/inject-groovy/src/test/groovy/io/micronaut/inject/failures/ConstructorExceptionSpec.groovy" "inject-groovy/src/test/groovy/io/micronaut/inject/failures/ConstructorExceptionSpec.groovy"
mkdir -p "inject-groovy/src/test/groovy/io/micronaut/inject/failures"
cp "/tests/inject-groovy/src/test/groovy/io/micronaut/inject/failures/FactoryCircularDependencyFailureSpec.groovy" "inject-groovy/src/test/groovy/io/micronaut/inject/failures/FactoryCircularDependencyFailureSpec.groovy"
mkdir -p "inject-groovy/src/test/groovy/io/micronaut/inject/failures"
cp "/tests/inject-groovy/src/test/groovy/io/micronaut/inject/failures/FactoryDependencyFailureSpec.groovy" "inject-groovy/src/test/groovy/io/micronaut/inject/failures/FactoryDependencyFailureSpec.groovy"
mkdir -p "inject-groovy/src/test/groovy/io/micronaut/inject/failures"
cp "/tests/inject-groovy/src/test/groovy/io/micronaut/inject/failures/FieldCircularDependencyFailureSpec.groovy" "inject-groovy/src/test/groovy/io/micronaut/inject/failures/FieldCircularDependencyFailureSpec.groovy"
mkdir -p "inject-groovy/src/test/groovy/io/micronaut/inject/failures"
cp "/tests/inject-groovy/src/test/groovy/io/micronaut/inject/failures/NestedDependencyFailureSpec.groovy" "inject-groovy/src/test/groovy/io/micronaut/inject/failures/NestedDependencyFailureSpec.groovy"
mkdir -p "inject-groovy/src/test/groovy/io/micronaut/inject/failures"
cp "/tests/inject-groovy/src/test/groovy/io/micronaut/inject/failures/PostConstructExceptionSpec.groovy" "inject-groovy/src/test/groovy/io/micronaut/inject/failures/PostConstructExceptionSpec.groovy"
mkdir -p "inject-groovy/src/test/groovy/io/micronaut/inject/failures"
cp "/tests/inject-groovy/src/test/groovy/io/micronaut/inject/failures/PropertyCircularDependencyFailureSpec.groovy" "inject-groovy/src/test/groovy/io/micronaut/inject/failures/PropertyCircularDependencyFailureSpec.groovy"
mkdir -p "inject-groovy/src/test/groovy/io/micronaut/inject/field"
cp "/tests/inject-groovy/src/test/groovy/io/micronaut/inject/field/FieldInjectionSpec.groovy" "inject-groovy/src/test/groovy/io/micronaut/inject/field/FieldInjectionSpec.groovy"
mkdir -p "inject-java/src/test/groovy/io/micronaut/aop/adapter"
cp "/tests/inject-java/src/test/groovy/io/micronaut/aop/adapter/MethodAdapterSpec.groovy" "inject-java/src/test/groovy/io/micronaut/aop/adapter/MethodAdapterSpec.groovy"
mkdir -p "inject-java/src/test/groovy/io/micronaut/inject/beans"
cp "/tests/inject-java/src/test/groovy/io/micronaut/inject/beans/BeanDefinitionSpec.groovy" "inject-java/src/test/groovy/io/micronaut/inject/beans/BeanDefinitionSpec.groovy"
mkdir -p "inject-java/src/test/groovy/io/micronaut/inject/factory/beanfield"
cp "/tests/inject-java/src/test/groovy/io/micronaut/inject/factory/beanfield/FactoryBeanFieldSpec.groovy" "inject-java/src/test/groovy/io/micronaut/inject/factory/beanfield/FactoryBeanFieldSpec.groovy"
mkdir -p "inject-java/src/test/groovy/io/micronaut/inject/factory/beanmethod"
cp "/tests/inject-java/src/test/groovy/io/micronaut/inject/factory/beanmethod/FactoryBeanMethodSpec.groovy" "inject-java/src/test/groovy/io/micronaut/inject/factory/beanmethod/FactoryBeanMethodSpec.groovy"
mkdir -p "inject-java/src/test/groovy/io/micronaut/inject/failures/ctorcirculardependency"
cp "/tests/inject-java/src/test/groovy/io/micronaut/inject/failures/ctorcirculardependency/ConstructorCircularDependencyFailureSpec.groovy" "inject-java/src/test/groovy/io/micronaut/inject/failures/ctorcirculardependency/ConstructorCircularDependencyFailureSpec.groovy"
mkdir -p "inject-java/src/test/groovy/io/micronaut/inject/failures/ctorexception"
cp "/tests/inject-java/src/test/groovy/io/micronaut/inject/failures/ctorexception/ConstructorExceptionSpec.groovy" "inject-java/src/test/groovy/io/micronaut/inject/failures/ctorexception/ConstructorExceptionSpec.groovy"
mkdir -p "inject-java/src/test/groovy/io/micronaut/inject/failures/fieldcirculardependency"
cp "/tests/inject-java/src/test/groovy/io/micronaut/inject/failures/fieldcirculardependency/FieldCircularDependencyFailureSpec.groovy" "inject-java/src/test/groovy/io/micronaut/inject/failures/fieldcirculardependency/FieldCircularDependencyFailureSpec.groovy"
mkdir -p "inject-java/src/test/groovy/io/micronaut/inject/failures/nesteddependency"
cp "/tests/inject-java/src/test/groovy/io/micronaut/inject/failures/nesteddependency/NestedDependencyFailureSpec.groovy" "inject-java/src/test/groovy/io/micronaut/inject/failures/nesteddependency/NestedDependencyFailureSpec.groovy"
mkdir -p "inject-java/src/test/groovy/io/micronaut/inject/failures/postconstruct"
cp "/tests/inject-java/src/test/groovy/io/micronaut/inject/failures/postconstruct/PostConstructExceptionSpec.groovy" "inject-java/src/test/groovy/io/micronaut/inject/failures/postconstruct/PostConstructExceptionSpec.groovy"
mkdir -p "inject-java/src/test/groovy/io/micronaut/inject/field/simpleinjection"
cp "/tests/inject-java/src/test/groovy/io/micronaut/inject/field/simpleinjection/FieldInjectionSpec.groovy" "inject-java/src/test/groovy/io/micronaut/inject/field/simpleinjection/FieldInjectionSpec.groovy"
mkdir -p "inject-kotlin/src/test/groovy/io/micronaut/kotlin/processing/beans"
cp "/tests/inject-kotlin/src/test/groovy/io/micronaut/kotlin/processing/beans/BeanDefinitionSpec.groovy" "inject-kotlin/src/test/groovy/io/micronaut/kotlin/processing/beans/BeanDefinitionSpec.groovy"

# Update timestamps to force Gradle to detect changes
touch inject-groovy/src/test/groovy/io/micronaut/inject/failures/*.groovy 2>/dev/null || true
touch inject-groovy/src/test/groovy/io/micronaut/inject/field/*.groovy 2>/dev/null || true
touch inject-java/src/test/groovy/io/micronaut/aop/adapter/*.groovy 2>/dev/null || true
touch inject-java/src/test/groovy/io/micronaut/inject/beans/*.groovy 2>/dev/null || true
touch inject-java/src/test/groovy/io/micronaut/inject/factory/beanfield/*.groovy 2>/dev/null || true
touch inject-java/src/test/groovy/io/micronaut/inject/factory/beanmethod/*.groovy 2>/dev/null || true
touch inject-java/src/test/groovy/io/micronaut/inject/failures/ctorcirculardependency/*.groovy 2>/dev/null || true
touch inject-java/src/test/groovy/io/micronaut/inject/failures/ctorexception/*.groovy 2>/dev/null || true
touch inject-java/src/test/groovy/io/micronaut/inject/failures/fieldcirculardependency/*.groovy 2>/dev/null || true
touch inject-java/src/test/groovy/io/micronaut/inject/failures/nesteddependency/*.groovy 2>/dev/null || true
touch inject-java/src/test/groovy/io/micronaut/inject/failures/postconstruct/*.groovy 2>/dev/null || true
touch inject-java/src/test/groovy/io/micronaut/inject/field/simpleinjection/*.groovy 2>/dev/null || true
touch inject-kotlin/src/test/groovy/io/micronaut/kotlin/processing/beans/*.groovy 2>/dev/null || true

# Remove compiled classes to force recompilation with the new test files
rm -rf inject-groovy/build/classes/ 2>/dev/null || true
rm -rf inject-java/build/classes/ 2>/dev/null || true
rm -rf inject-kotlin/build/classes/ 2>/dev/null || true

# Run the specific tests for this PR
set +e  # Don't exit on error, we'll check manually

test_output=""

# Run inject-groovy module tests
cd inject-groovy
test_output+=$(../gradlew test --tests "*ConstructorCircularDependencyFailureSpec" \
  --tests "*ConstructorExceptionSpec" \
  --tests "*FactoryCircularDependencyFailureSpec" \
  --tests "*FactoryDependencyFailureSpec" \
  --tests "*FieldCircularDependencyFailureSpec" \
  --tests "*NestedDependencyFailureSpec" \
  --tests "*PostConstructExceptionSpec" \
  --tests "*PropertyCircularDependencyFailureSpec" \
  --tests "io.micronaut.inject.field.FieldInjectionSpec" \
  --no-daemon --console=plain 2>&1)
gradle_exit_1=$?
cd ..

# Run inject-java module tests
cd inject-java
test_output+=$(../gradlew test --tests "io.micronaut.aop.adapter.MethodAdapterSpec" \
  --tests "io.micronaut.inject.beans.BeanDefinitionSpec" \
  --tests "io.micronaut.inject.factory.beanfield.FactoryBeanFieldSpec" \
  --tests "io.micronaut.inject.factory.beanmethod.FactoryBeanMethodSpec" \
  --tests "*ConstructorCircularDependencyFailureSpec" \
  --tests "*ConstructorExceptionSpec" \
  --tests "*FieldCircularDependencyFailureSpec" \
  --tests "*NestedDependencyFailureSpec" \
  --tests "*PostConstructExceptionSpec" \
  --tests "io.micronaut.inject.field.simpleinjection.FieldInjectionSpec" \
  --no-daemon --console=plain 2>&1)
gradle_exit_2=$?
cd ..

# Run inject-kotlin module tests
cd inject-kotlin
test_output+=$(../gradlew test --tests "io.micronaut.kotlin.processing.beans.BeanDefinitionSpec" \
  --no-daemon --console=plain 2>&1)
gradle_exit_3=$?
cd ..

set -e

echo "$test_output"

# Check if all three gradle commands succeeded (all must pass)
if [ $gradle_exit_1 -eq 0 ] && [ $gradle_exit_2 -eq 0 ] && [ $gradle_exit_3 -eq 0 ]; then
    test_status=0
else
    test_status=1
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
