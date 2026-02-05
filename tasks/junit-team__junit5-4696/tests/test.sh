#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "junit-jupiter-engine/src/main/java/org/junit/jupiter/engine/discovery/predicates"
cp "/tests/junit-jupiter-engine/src/main/java/org/junit/jupiter/engine/discovery/predicates/TestClassPredicates.java" "junit-jupiter-engine/src/main/java/org/junit/jupiter/engine/discovery/predicates/TestClassPredicates.java"
mkdir -p "junit-vintage-engine/src/test/java/org/junit/vintage/engine"
cp "/tests/junit-vintage-engine/src/test/java/org/junit/vintage/engine/VintageTestEngineExecutionTests.java" "junit-vintage-engine/src/test/java/org/junit/vintage/engine/VintageTestEngineExecutionTests.java"
mkdir -p "jupiter-tests/src/test/java/org/junit/jupiter/engine/discovery"
cp "/tests/jupiter-tests/src/test/java/org/junit/jupiter/engine/discovery/DiscoveryTests.java" "jupiter-tests/src/test/java/org/junit/jupiter/engine/discovery/DiscoveryTests.java"
mkdir -p "jupiter-tests/src/test/java/org/junit/jupiter/engine/extension"
cp "/tests/jupiter-tests/src/test/java/org/junit/jupiter/engine/extension/TimeoutInvocationFactoryTests.java" "jupiter-tests/src/test/java/org/junit/jupiter/engine/extension/TimeoutInvocationFactoryTests.java"
mkdir -p "jupiter-tests/src/test/kotlin/org/junit/jupiter/engine/kotlin"
cp "/tests/jupiter-tests/src/test/kotlin/org/junit/jupiter/engine/kotlin/KotlinDefaultImplsTestCase.kt" "jupiter-tests/src/test/kotlin/org/junit/jupiter/engine/kotlin/KotlinDefaultImplsTestCase.kt"
mkdir -p "jupiter-tests/src/test/kotlin/org/junit/jupiter/engine/kotlin"
cp "/tests/jupiter-tests/src/test/kotlin/org/junit/jupiter/engine/kotlin/KotlinInterfaceImplementationTestCase.kt" "jupiter-tests/src/test/kotlin/org/junit/jupiter/engine/kotlin/KotlinInterfaceImplementationTestCase.kt"
mkdir -p "jupiter-tests/src/test/kotlin/org/junit/jupiter/engine/kotlin"
cp "/tests/jupiter-tests/src/test/kotlin/org/junit/jupiter/engine/kotlin/KotlinInterfaceTestCase.kt" "jupiter-tests/src/test/kotlin/org/junit/jupiter/engine/kotlin/KotlinInterfaceTestCase.kt"
mkdir -p "platform-tests/src/test/java/org/junit/platform/commons/support/scanning"
cp "/tests/platform-tests/src/test/java/org/junit/platform/commons/support/scanning/DefaultClasspathScannerTests.java" "platform-tests/src/test/java/org/junit/platform/commons/support/scanning/DefaultClasspathScannerTests.java"
mkdir -p "platform-tests/src/test/java/org/junit/platform/launcher/core"
cp "/tests/platform-tests/src/test/java/org/junit/platform/launcher/core/ClasspathAlignmentCheckerTests.java" "platform-tests/src/test/java/org/junit/platform/launcher/core/ClasspathAlignmentCheckerTests.java"

# Run the specific test classes for this PR
./gradlew :junit-vintage-engine:test --tests org.junit.vintage.engine.VintageTestEngineExecutionTests \
  :jupiter-tests:test --tests org.junit.jupiter.engine.discovery.DiscoveryTests \
  --tests org.junit.jupiter.engine.extension.TimeoutInvocationFactoryTests \
  :platform-tests:test --tests org.junit.platform.commons.support.scanning.DefaultClasspathScannerTests \
  --tests org.junit.platform.launcher.core.ClasspathAlignmentCheckerTests \
  --no-daemon --no-configuration-cache
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
