#!/bin/bash

cd /app/src

# Set environment variables for test execution
export LANG=en_US.UTF-8

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "extensions/quartz/deployment/src/test/java/io/quarkus/quartz/test/security"
cp "/tests/extensions/quartz/deployment/src/test/java/io/quarkus/quartz/test/security/QuartzSchedulerRunAsUserTest.java" "extensions/quartz/deployment/src/test/java/io/quarkus/quartz/test/security/QuartzSchedulerRunAsUserTest.java"
mkdir -p "extensions/scheduler/deployment/src/test/java/io/quarkus/scheduler/test/security"
cp "/tests/extensions/scheduler/deployment/src/test/java/io/quarkus/scheduler/test/security/SimpleSchedulerRunAsUserTest.java" "extensions/scheduler/deployment/src/test/java/io/quarkus/scheduler/test/security/SimpleSchedulerRunAsUserTest.java"
mkdir -p "extensions/security/deployment/src/test/java/io/quarkus/security/test/runasuser"
cp "/tests/extensions/security/deployment/src/test/java/io/quarkus/security/test/runasuser/RunAsUserMissingAnnotationValidationFailureTest.java" "extensions/security/deployment/src/test/java/io/quarkus/security/test/runasuser/RunAsUserMissingAnnotationValidationFailureTest.java"
mkdir -p "extensions/security/deployment/src/test/java/io/quarkus/security/test/runasuser"
cp "/tests/extensions/security/deployment/src/test/java/io/quarkus/security/test/runasuser/RunAsUserSecurityAnnotationsTest.java" "extensions/security/deployment/src/test/java/io/quarkus/security/test/runasuser/RunAsUserSecurityAnnotationsTest.java"
mkdir -p "extensions/security/deployment/src/test/java/io/quarkus/security/test/runasuser"
cp "/tests/extensions/security/deployment/src/test/java/io/quarkus/security/test/runasuser/RunAsUserSecurityBeansTest.java" "extensions/security/deployment/src/test/java/io/quarkus/security/test/runasuser/RunAsUserSecurityBeansTest.java"

# Rebuild the affected modules after solve.sh applies fix.patch
# This is necessary because fix.patch modifies source files
mvn -e -B --settings .github/mvn-settings.xml -DskipTests -DskipITs -DskipDocs \
  -Dinvoker.skip -Dskip.gradle.tests -Djbang.skip -Dtruststore.skip -Dno-format \
  -DskipExtensionValidation -Dtcks -Prelocations \
  -pl extensions/quartz/deployment,extensions/scheduler/deployment,extensions/security/deployment -am \
  clean install

# Run the specific test classes
mvn -e -B --settings .github/mvn-settings.xml \
  -Dtest=QuartzSchedulerRunAsUserTest,SimpleSchedulerRunAsUserTest,RunAsUserMissingAnnotationValidationFailureTest,RunAsUserSecurityAnnotationsTest,RunAsUserSecurityBeansTest \
  -pl extensions/quartz/deployment,extensions/scheduler/deployment,extensions/security/deployment \
  test
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
