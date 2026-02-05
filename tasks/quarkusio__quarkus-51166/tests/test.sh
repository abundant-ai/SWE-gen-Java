#!/bin/bash

cd /app/src

# Set environment variables for test execution
export LANG=en_US.UTF-8

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "extensions/arc/deployment/src/test/java/io/quarkus/arc/test/cdi/bcextensions"
cp "/tests/extensions/arc/deployment/src/test/java/io/quarkus/arc/test/cdi/bcextensions/SynthBeanForExternalClassTest.java" "extensions/arc/deployment/src/test/java/io/quarkus/arc/test/cdi/bcextensions/SynthBeanForExternalClassTest.java"
mkdir -p "extensions/arc/deployment/src/test/java/io/quarkus/arc/test/cdi/bcextensions"
cp "/tests/extensions/arc/deployment/src/test/java/io/quarkus/arc/test/cdi/bcextensions/SynthObserverAsIfInExternalClassTest.java" "extensions/arc/deployment/src/test/java/io/quarkus/arc/test/cdi/bcextensions/SynthObserverAsIfInExternalClassTest.java"
mkdir -p "extensions/arc/deployment/src/test/java/io/quarkus/arc/test/decorator"
cp "/tests/extensions/arc/deployment/src/test/java/io/quarkus/arc/test/decorator/DecoratorAsBeanDefiningAnnotationTest.java" "extensions/arc/deployment/src/test/java/io/quarkus/arc/test/decorator/DecoratorAsBeanDefiningAnnotationTest.java"
mkdir -p "extensions/arc/deployment/src/test/java/io/quarkus/arc/test/decorator"
cp "/tests/extensions/arc/deployment/src/test/java/io/quarkus/arc/test/decorator/DecoratorOfExternalBeanTest.java" "extensions/arc/deployment/src/test/java/io/quarkus/arc/test/decorator/DecoratorOfExternalBeanTest.java"
mkdir -p "extensions/arc/test-supplement/src/main/java/io/quarkus/arc/test/supplement"
cp "/tests/extensions/arc/test-supplement/src/main/java/io/quarkus/arc/test/supplement/ConsumerOfSomeBeanInExternalLibrary.java" "extensions/arc/test-supplement/src/main/java/io/quarkus/arc/test/supplement/ConsumerOfSomeBeanInExternalLibrary.java"
mkdir -p "extensions/arc/test-supplement/src/main/java/io/quarkus/arc/test/supplement"
cp "/tests/extensions/arc/test-supplement/src/main/java/io/quarkus/arc/test/supplement/ConsumerOfSomeDepBeanInExternalLibrary.java" "extensions/arc/test-supplement/src/main/java/io/quarkus/arc/test/supplement/ConsumerOfSomeDepBeanInExternalLibrary.java"
mkdir -p "extensions/arc/test-supplement/src/main/java/io/quarkus/arc/test/supplement"
cp "/tests/extensions/arc/test-supplement/src/main/java/io/quarkus/arc/test/supplement/SomeBeanInExternalLibrary.java" "extensions/arc/test-supplement/src/main/java/io/quarkus/arc/test/supplement/SomeBeanInExternalLibrary.java"
mkdir -p "extensions/arc/test-supplement/src/main/java/io/quarkus/arc/test/supplement"
cp "/tests/extensions/arc/test-supplement/src/main/java/io/quarkus/arc/test/supplement/SomeDepBeanInExternalLibrary.java" "extensions/arc/test-supplement/src/main/java/io/quarkus/arc/test/supplement/SomeDepBeanInExternalLibrary.java"
mkdir -p "extensions/arc/test-supplement/src/main/java/io/quarkus/arc/test/supplement"
cp "/tests/extensions/arc/test-supplement/src/main/java/io/quarkus/arc/test/supplement/SomeDependencyInExternalLibrary.java" "extensions/arc/test-supplement/src/main/java/io/quarkus/arc/test/supplement/SomeDependencyInExternalLibrary.java"
mkdir -p "extensions/arc/test-supplement/src/main/java/io/quarkus/arc/test/supplement"
cp "/tests/extensions/arc/test-supplement/src/main/java/io/quarkus/arc/test/supplement/SomeEventInExternalLibrary.java" "extensions/arc/test-supplement/src/main/java/io/quarkus/arc/test/supplement/SomeEventInExternalLibrary.java"
mkdir -p "extensions/arc/test-supplement/src/main/java/io/quarkus/arc/test/supplement"
cp "/tests/extensions/arc/test-supplement/src/main/java/io/quarkus/arc/test/supplement/SomeProducedDependencyInExternalLibrary.java" "extensions/arc/test-supplement/src/main/java/io/quarkus/arc/test/supplement/SomeProducedDependencyInExternalLibrary.java"
mkdir -p "independent-projects/arc/tests/src/test/java/io/quarkus/arc/test/decorators"
cp "/tests/independent-projects/arc/tests/src/test/java/io/quarkus/arc/test/decorators/MultipleSameDecoratedMethodsIndependentAndDefaultTest.java" "independent-projects/arc/tests/src/test/java/io/quarkus/arc/test/decorators/MultipleSameDecoratedMethodsIndependentAndDefaultTest.java"
mkdir -p "independent-projects/arc/tests/src/test/java/io/quarkus/arc/test/decorators"
cp "/tests/independent-projects/arc/tests/src/test/java/io/quarkus/arc/test/decorators/MultipleSameDecoratedMethodsIndependentTest.java" "independent-projects/arc/tests/src/test/java/io/quarkus/arc/test/decorators/MultipleSameDecoratedMethodsIndependentTest.java"
mkdir -p "independent-projects/arc/tests/src/test/java/io/quarkus/arc/test/decorators"
cp "/tests/independent-projects/arc/tests/src/test/java/io/quarkus/arc/test/decorators/MultipleSameDecoratedMethodsOverridenAndBridgeTest.java" "independent-projects/arc/tests/src/test/java/io/quarkus/arc/test/decorators/MultipleSameDecoratedMethodsOverridenAndBridgeTest.java"
mkdir -p "independent-projects/arc/tests/src/test/java/io/quarkus/arc/test/decorators"
cp "/tests/independent-projects/arc/tests/src/test/java/io/quarkus/arc/test/decorators/MultipleSameDecoratedMethodsOverridenAndDefaultTest.java" "independent-projects/arc/tests/src/test/java/io/quarkus/arc/test/decorators/MultipleSameDecoratedMethodsOverridenAndDefaultTest.java"
mkdir -p "independent-projects/arc/tests/src/test/java/io/quarkus/arc/test/decorators"
cp "/tests/independent-projects/arc/tests/src/test/java/io/quarkus/arc/test/decorators/MultipleSameDecoratedMethodsOverridenTest.java" "independent-projects/arc/tests/src/test/java/io/quarkus/arc/test/decorators/MultipleSameDecoratedMethodsOverridenTest.java"
mkdir -p "independent-projects/arc/tests/src/test/java/io/quarkus/arc/test/decorators/abstractimpl"
cp "/tests/independent-projects/arc/tests/src/test/java/io/quarkus/arc/test/decorators/abstractimpl/AbstractDecoratorDefaultMethodTest.java" "independent-projects/arc/tests/src/test/java/io/quarkus/arc/test/decorators/abstractimpl/AbstractDecoratorDefaultMethodTest.java"
mkdir -p "independent-projects/arc/tests/src/test/java/io/quarkus/arc/test/decorators/abstractimpl"
cp "/tests/independent-projects/arc/tests/src/test/java/io/quarkus/arc/test/decorators/abstractimpl/AbstractDecoratorNotInheritingNonPublicMethodTest.java" "independent-projects/arc/tests/src/test/java/io/quarkus/arc/test/decorators/abstractimpl/AbstractDecoratorNotInheritingNonPublicMethodTest.java"
mkdir -p "independent-projects/arc/tests/src/test/java/io/quarkus/arc/test/decorators/defaultmethod"
cp "/tests/independent-projects/arc/tests/src/test/java/io/quarkus/arc/test/decorators/defaultmethod/DecoratorDefaultMethodDirectlyImplementedTest.java" "independent-projects/arc/tests/src/test/java/io/quarkus/arc/test/decorators/defaultmethod/DecoratorDefaultMethodDirectlyImplementedTest.java"
mkdir -p "independent-projects/arc/tests/src/test/java/io/quarkus/arc/test/decorators/defaultmethod"
cp "/tests/independent-projects/arc/tests/src/test/java/io/quarkus/arc/test/decorators/defaultmethod/DecoratorDefaultMethodInheritedFromSuperclassTest.java" "independent-projects/arc/tests/src/test/java/io/quarkus/arc/test/decorators/defaultmethod/DecoratorDefaultMethodInheritedFromSuperclassTest.java"
mkdir -p "independent-projects/arc/tests/src/test/java/io/quarkus/arc/test/decorators/defaultmethod"
cp "/tests/independent-projects/arc/tests/src/test/java/io/quarkus/arc/test/decorators/defaultmethod/DecoratorDefaultMethodInheritedFromSuperinterfaceTest.java" "independent-projects/arc/tests/src/test/java/io/quarkus/arc/test/decorators/defaultmethod/DecoratorDefaultMethodInheritedFromSuperinterfaceTest.java"

# Rebuild the modules to pick up any source changes (from fix.patch in Oracle mode)
mvn -e -B --settings .github/mvn-settings.xml -DskipTests -DskipITs -DskipDocs \
    -Dinvoker.skip -Dskip.gradle.tests -Djbang.skip -Dtruststore.skip -Dno-format \
    -DskipExtensionValidation -Dtcks -Prelocations \
    -pl extensions/arc/deployment,independent-projects/arc/tests -am \
    clean install

# Run the specific test classes from this PR
mvn -e -B --settings .github/mvn-settings.xml \
  -pl extensions/arc/deployment \
  -Dtest=SynthBeanForExternalClassTest,SynthObserverAsIfInExternalClassTest,DecoratorAsBeanDefiningAnnotationTest,DecoratorOfExternalBeanTest \
  test
deployment_test_status=$?

mvn -e -B --settings .github/mvn-settings.xml \
  -pl independent-projects/arc/tests \
  -Dtest=MultipleSameDecoratedMethodsIndependentAndDefaultTest,MultipleSameDecoratedMethodsIndependentTest,MultipleSameDecoratedMethodsOverridenAndBridgeTest,MultipleSameDecoratedMethodsOverridenAndDefaultTest,MultipleSameDecoratedMethodsOverridenTest,AbstractDecoratorDefaultMethodTest,AbstractDecoratorNotInheritingNonPublicMethodTest,DecoratorDefaultMethodDirectlyImplementedTest,DecoratorDefaultMethodInheritedFromSuperclassTest,DecoratorDefaultMethodInheritedFromSuperinterfaceTest \
  test
arc_test_status=$?

# Overall test status (fail if either failed)
if [ $deployment_test_status -eq 0 ] && [ $arc_test_status -eq 0 ]; then
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
