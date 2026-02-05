#!/bin/bash

cd /app/src

# Set environment variables for test execution
export LANG=en_US.UTF-8

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "extensions/hibernate-orm/deployment/src/test/java/io/quarkus/hibernate/orm/functioncontributors"
cp "/tests/extensions/hibernate-orm/deployment/src/test/java/io/quarkus/hibernate/orm/functioncontributors/CustomFunctionContributor.java" "extensions/hibernate-orm/deployment/src/test/java/io/quarkus/hibernate/orm/functioncontributors/CustomFunctionContributor.java"
mkdir -p "extensions/hibernate-orm/deployment/src/test/java/io/quarkus/hibernate/orm/functioncontributors"
cp "/tests/extensions/hibernate-orm/deployment/src/test/java/io/quarkus/hibernate/orm/functioncontributors/FunctionContributorTest.java" "extensions/hibernate-orm/deployment/src/test/java/io/quarkus/hibernate/orm/functioncontributors/FunctionContributorTest.java"
mkdir -p "extensions/hibernate-orm/deployment/src/test/java/io/quarkus/hibernate/orm/functioncontributors"
cp "/tests/extensions/hibernate-orm/deployment/src/test/java/io/quarkus/hibernate/orm/functioncontributors/MyEntity.java" "extensions/hibernate-orm/deployment/src/test/java/io/quarkus/hibernate/orm/functioncontributors/MyEntity.java"
mkdir -p "extensions/hibernate-orm/deployment/src/test/java/io/quarkus/hibernate/orm/typecontributors"
cp "/tests/extensions/hibernate-orm/deployment/src/test/java/io/quarkus/hibernate/orm/typecontributors/BooleanYesNoType.java" "extensions/hibernate-orm/deployment/src/test/java/io/quarkus/hibernate/orm/typecontributors/BooleanYesNoType.java"
mkdir -p "extensions/hibernate-orm/deployment/src/test/java/io/quarkus/hibernate/orm/typecontributors"
cp "/tests/extensions/hibernate-orm/deployment/src/test/java/io/quarkus/hibernate/orm/typecontributors/CustomTypeContributor.java" "extensions/hibernate-orm/deployment/src/test/java/io/quarkus/hibernate/orm/typecontributors/CustomTypeContributor.java"
mkdir -p "extensions/hibernate-orm/deployment/src/test/java/io/quarkus/hibernate/orm/typecontributors"
cp "/tests/extensions/hibernate-orm/deployment/src/test/java/io/quarkus/hibernate/orm/typecontributors/MyEntity.java" "extensions/hibernate-orm/deployment/src/test/java/io/quarkus/hibernate/orm/typecontributors/MyEntity.java"
mkdir -p "extensions/hibernate-orm/deployment/src/test/java/io/quarkus/hibernate/orm/typecontributors"
cp "/tests/extensions/hibernate-orm/deployment/src/test/java/io/quarkus/hibernate/orm/typecontributors/TypeContributorTest.java" "extensions/hibernate-orm/deployment/src/test/java/io/quarkus/hibernate/orm/typecontributors/TypeContributorTest.java"

# Run the specific test classes from this PR
mvn -e -B --settings .github/mvn-settings.xml \
  -pl extensions/hibernate-orm/deployment \
  -Dtest=FunctionContributorTest,TypeContributorTest \
  test
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
