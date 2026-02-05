#!/bin/bash

cd /app/src

# Set environment variables for test execution
export LANG=en_US.UTF-8

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "extensions/smallrye-graphql-client/deployment/src/test/java/io/quarkus/smallrye/graphql/client/deployment"
cp "/tests/extensions/smallrye-graphql-client/deployment/src/test/java/io/quarkus/smallrye/graphql/client/deployment/TypesafeGraphQLClientProgrammaticUsageWithClientModelTest.java" "extensions/smallrye-graphql-client/deployment/src/test/java/io/quarkus/smallrye/graphql/client/deployment/TypesafeGraphQLClientProgrammaticUsageWithClientModelTest.java"

# Rebuild the affected modules after solve.sh applies fix.patch
# This is necessary because fix.patch modifies source files
mvn -e -B --settings .github/mvn-settings.xml -DskipTests -DskipITs -DskipDocs \
  -Dinvoker.skip -Dskip.gradle.tests -Djbang.skip -Dtruststore.skip -Dno-format \
  -DskipExtensionValidation -Dtcks -Prelocations \
  -pl bom/application,extensions/smallrye-graphql-client/deployment,extensions/smallrye-graphql-client/runtime -am \
  clean install
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
