#!/bin/bash

cd /app/src

# Set environment variables for test execution
export LANG=en_US.UTF-8

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "extensions/kubernetes/vanilla/deployment/src/test/java/io/quarkus/kubernetes/deployment"
cp "/tests/extensions/kubernetes/vanilla/deployment/src/test/java/io/quarkus/kubernetes/deployment/EnvVarValidatorTest.java" "extensions/kubernetes/vanilla/deployment/src/test/java/io/quarkus/kubernetes/deployment/EnvVarValidatorTest.java"
mkdir -p "integration-tests/kubernetes/quarkus-standard-way/src/test/java/io/quarkus/it/kubernetes"
cp "/tests/integration-tests/kubernetes/quarkus-standard-way/src/test/java/io/quarkus/it/kubernetes/MinikubeWithApplicationPropertiesTest.java" "integration-tests/kubernetes/quarkus-standard-way/src/test/java/io/quarkus/it/kubernetes/MinikubeWithApplicationPropertiesTest.java"
mkdir -p "integration-tests/kubernetes/quarkus-standard-way/src/test/resources"
cp "/tests/integration-tests/kubernetes/quarkus-standard-way/src/test/resources/kubernetes-with-application.properties" "integration-tests/kubernetes/quarkus-standard-way/src/test/resources/kubernetes-with-application.properties"
mkdir -p "integration-tests/kubernetes/quarkus-standard-way/src/test/resources"
cp "/tests/integration-tests/kubernetes/quarkus-standard-way/src/test/resources/kubernetes-with-env-from-configmap.properties" "integration-tests/kubernetes/quarkus-standard-way/src/test/resources/kubernetes-with-env-from-configmap.properties"
mkdir -p "integration-tests/kubernetes/quarkus-standard-way/src/test/resources"
cp "/tests/integration-tests/kubernetes/quarkus-standard-way/src/test/resources/kubernetes-with-env-from-field.properties" "integration-tests/kubernetes/quarkus-standard-way/src/test/resources/kubernetes-with-env-from-field.properties"
mkdir -p "integration-tests/kubernetes/quarkus-standard-way/src/test/resources"
cp "/tests/integration-tests/kubernetes/quarkus-standard-way/src/test/resources/kubernetes-with-sidecar-and-jib.properties" "integration-tests/kubernetes/quarkus-standard-way/src/test/resources/kubernetes-with-sidecar-and-jib.properties"
mkdir -p "integration-tests/kubernetes/quarkus-standard-way/src/test/resources"
cp "/tests/integration-tests/kubernetes/quarkus-standard-way/src/test/resources/minikube-with-application.properties" "integration-tests/kubernetes/quarkus-standard-way/src/test/resources/minikube-with-application.properties"
mkdir -p "integration-tests/kubernetes/quarkus-standard-way/src/test/resources"
cp "/tests/integration-tests/kubernetes/quarkus-standard-way/src/test/resources/openshift-with-application.properties" "integration-tests/kubernetes/quarkus-standard-way/src/test/resources/openshift-with-application.properties"

# Run the specific test classes from this PR
# First test: EnvVarValidatorTest
mvn -e -B --settings .github/mvn-settings.xml \
  -pl extensions/kubernetes/vanilla/deployment \
  -Dtest=EnvVarValidatorTest \
  test
test_status_1=$?

# Second test: MinikubeWithApplicationPropertiesTest
mvn -e -B --settings .github/mvn-settings.xml \
  -pl integration-tests/kubernetes/quarkus-standard-way \
  -Dtest=MinikubeWithApplicationPropertiesTest \
  test
test_status_2=$?

# Combined status: both tests must pass
if [ $test_status_1 -eq 0 ] && [ $test_status_2 -eq 0 ]; then
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
