#!/bin/bash

cd /app/src

# Copy HEAD source files from /tests (overwrites BASE state)
mkdir -p ".teamcity/src/main/kotlin/configurations"
cp "/tests/.teamcity/src/main/kotlin/configurations/FunctionalTest.kt" ".teamcity/src/main/kotlin/configurations/FunctionalTest.kt"
mkdir -p ".teamcity/src/main/kotlin/configurations"
cp "/tests/.teamcity/src/main/kotlin/configurations/SmokeIdeTests.kt" ".teamcity/src/main/kotlin/configurations/SmokeIdeTests.kt"
mkdir -p ".teamcity/src/main/kotlin/configurations"
cp "/tests/.teamcity/src/main/kotlin/configurations/SmokeTests.kt" ".teamcity/src/main/kotlin/configurations/SmokeTests.kt"

# Compile the TeamCity configuration to verify the Kotlin files compile correctly
cd .teamcity && mvn compile
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
