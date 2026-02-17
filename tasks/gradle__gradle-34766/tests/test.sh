#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p ".teamcity/src/main/kotlin/configurations"
cp "/tests/.teamcity/src/main/kotlin/configurations/BuildLogicTest.kt" ".teamcity/src/main/kotlin/configurations/BuildLogicTest.kt"
mkdir -p ".teamcity/src/main/kotlin/configurations"
cp "/tests/.teamcity/src/main/kotlin/configurations/TestPerformanceTest.kt" ".teamcity/src/main/kotlin/configurations/TestPerformanceTest.kt"
mkdir -p ".teamcity/src/test/kotlin"
cp "/tests/.teamcity/src/test/kotlin/ApplyDefaultConfigurationTest.kt" ".teamcity/src/test/kotlin/ApplyDefaultConfigurationTest.kt"
mkdir -p ".teamcity/src/test/kotlin"
cp "/tests/.teamcity/src/test/kotlin/BuildTypeTest.kt" ".teamcity/src/test/kotlin/BuildTypeTest.kt"
mkdir -p ".teamcity/src/test/kotlin"
cp "/tests/.teamcity/src/test/kotlin/PerformanceTestBuildTypeTest.kt" ".teamcity/src/test/kotlin/PerformanceTestBuildTypeTest.kt"

# Recompile after copying HEAD test files
cd /app/src/.teamcity
./mvnw test-compile

# Run specific test classes using Maven
./mvnw test -Dtest=BuildTypeTest,ApplyDefaultConfigurationTest,PerformanceTestBuildTypeTest
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
