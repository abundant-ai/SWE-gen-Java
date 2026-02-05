#!/bin/bash

cd /app/src

# Set environment variables for test execution
export LANG=en_US.UTF-8

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "extensions/redis-client/deployment/src/test/java/io/quarkus/redis/deployment/client"
cp "/tests/extensions/redis-client/deployment/src/test/java/io/quarkus/redis/deployment/client/RedisActiveClientsMissingConfigTest.java" "extensions/redis-client/deployment/src/test/java/io/quarkus/redis/deployment/client/RedisActiveClientsMissingConfigTest.java"
mkdir -p "extensions/redis-client/deployment/src/test/java/io/quarkus/redis/deployment/client"
cp "/tests/extensions/redis-client/deployment/src/test/java/io/quarkus/redis/deployment/client/RedisActiveClientsTest.java" "extensions/redis-client/deployment/src/test/java/io/quarkus/redis/deployment/client/RedisActiveClientsTest.java"
mkdir -p "extensions/redis-client/deployment/src/test/java/io/quarkus/redis/deployment/client"
cp "/tests/extensions/redis-client/deployment/src/test/java/io/quarkus/redis/deployment/client/RedisConfigClientNamesTest.java" "extensions/redis-client/deployment/src/test/java/io/quarkus/redis/deployment/client/RedisConfigClientNamesTest.java"
mkdir -p "extensions/redis-client/deployment/src/test/java/io/quarkus/redis/deployment/client"
cp "/tests/extensions/redis-client/deployment/src/test/java/io/quarkus/redis/deployment/client/RedisInactiveClientsByConfigExceptionTest.java" "extensions/redis-client/deployment/src/test/java/io/quarkus/redis/deployment/client/RedisInactiveClientsByConfigExceptionTest.java"
mkdir -p "extensions/redis-client/deployment/src/test/java/io/quarkus/redis/deployment/client"
cp "/tests/extensions/redis-client/deployment/src/test/java/io/quarkus/redis/deployment/client/RedisInactiveClientsByConfigTest.java" "extensions/redis-client/deployment/src/test/java/io/quarkus/redis/deployment/client/RedisInactiveClientsByConfigTest.java"
mkdir -p "extensions/redis-client/deployment/src/test/java/io/quarkus/redis/deployment/client"
cp "/tests/extensions/redis-client/deployment/src/test/java/io/quarkus/redis/deployment/client/RedisInactiveClientsTest.java" "extensions/redis-client/deployment/src/test/java/io/quarkus/redis/deployment/client/RedisInactiveClientsTest.java"

# Rebuild runtime module to pick up any source changes from fix.patch
mvn -e -B --settings .github/mvn-settings.xml -DskipTests -DskipITs -DskipDocs \
    -Dinvoker.skip -Dskip.gradle.tests -Djbang.skip -Dtruststore.skip -Dno-format \
    -DskipExtensionValidation \
    -pl extensions/redis-client/runtime \
    clean install

# Run the specific test classes from this PR
mvn -e -B --settings .github/mvn-settings.xml \
  -pl extensions/redis-client/deployment \
  -Dtest=RedisActiveClientsMissingConfigTest,RedisActiveClientsTest,RedisConfigClientNamesTest,RedisInactiveClientsByConfigExceptionTest,RedisInactiveClientsByConfigTest,RedisInactiveClientsTest \
  -DskipExtensionValidation \
  test
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
