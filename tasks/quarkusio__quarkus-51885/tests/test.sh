#!/bin/bash

cd /app/src

# Set environment variables for test execution
export LANG=en_US.UTF-8

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "independent-projects/tools/devtools-testing/src/test/resources/__snapshots__/QuarkusCodestartGenerationTest/generateDefault"
cp "/tests/independent-projects/tools/devtools-testing/src/test/resources/__snapshots__/QuarkusCodestartGenerationTest/generateDefault/pom.xml" "independent-projects/tools/devtools-testing/src/test/resources/__snapshots__/QuarkusCodestartGenerationTest/generateDefault/pom.xml"
mkdir -p "independent-projects/tools/devtools-testing/src/test/resources/__snapshots__/QuarkusCodestartGenerationTest/generateMavenWithCustomDep"
cp "/tests/independent-projects/tools/devtools-testing/src/test/resources/__snapshots__/QuarkusCodestartGenerationTest/generateMavenWithCustomDep/pom.xml" "independent-projects/tools/devtools-testing/src/test/resources/__snapshots__/QuarkusCodestartGenerationTest/generateMavenWithCustomDep/pom.xml"
mkdir -p "integration-tests/devtools/src/test/resources/__snapshots__/KotlinSerializationCodestartTest/testMavenContent"
cp "/tests/integration-tests/devtools/src/test/resources/__snapshots__/KotlinSerializationCodestartTest/testMavenContent/pom.xml" "integration-tests/devtools/src/test/resources/__snapshots__/KotlinSerializationCodestartTest/testMavenContent/pom.xml"
mkdir -p "integration-tests/maven/src/test/resources/__snapshots__/CreateExtensionMojoIT/testCreateStandaloneExtension"
cp "/tests/integration-tests/maven/src/test/resources/__snapshots__/CreateExtensionMojoIT/testCreateStandaloneExtension/my-org-my-own-ext_pom.xml" "integration-tests/maven/src/test/resources/__snapshots__/CreateExtensionMojoIT/testCreateStandaloneExtension/my-org-my-own-ext_pom.xml"

# Rebuild the affected modules after solve.sh applies fix.patch
# This is necessary because fix.patch modifies source files
mvn -e -B --settings .github/mvn-settings.xml -DskipTests -DskipITs -DskipDocs \
  -Dinvoker.skip -Dskip.gradle.tests -Djbang.skip -Dtruststore.skip -Dno-format \
  -DskipExtensionValidation -Dtcks -Prelocations \
  -pl independent-projects/tools/devtools-testing,integration-tests/devtools,integration-tests/maven -am \
  clean install

# Run the specific test classes from this PR
# QuarkusCodestartGenerationTest, KotlinSerializationCodestartTest, and CreateExtensionMojoIT
mvn -e -B --settings .github/mvn-settings.xml \
  -pl independent-projects/tools/devtools-testing \
  -Dtest=QuarkusCodestartGenerationTest#generateDefault,QuarkusCodestartGenerationTest#generateMavenWithCustomDep \
  test

test_status_1=$?

mvn -e -B --settings .github/mvn-settings.xml \
  -pl integration-tests/devtools \
  -Dtest=KotlinSerializationCodestartTest#testMavenContent \
  test

test_status_2=$?

mvn -e -B --settings .github/mvn-settings.xml \
  -pl integration-tests/maven \
  -Dtest=CreateExtensionMojoIT#testCreateStandaloneExtension \
  test

test_status_3=$?

# Check if all tests passed
if [ $test_status_1 -eq 0 ] && [ $test_status_2 -eq 0 ] && [ $test_status_3 -eq 0 ]; then
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
