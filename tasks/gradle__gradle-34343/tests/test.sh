#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "platforms/jvm/ear/src/test/groovy/org/gradle/plugins/ear/descriptor/internal"
cp "/tests/platforms/jvm/ear/src/test/groovy/org/gradle/plugins/ear/descriptor/internal/DefaultDeploymentDescriptorTest.groovy" "platforms/jvm/ear/src/test/groovy/org/gradle/plugins/ear/descriptor/internal/DefaultDeploymentDescriptorTest.groovy"

DESCRIPTOR_SRC="platforms/jvm/ear/src/main/java/org/gradle/plugins/ear/descriptor/internal/DefaultDeploymentDescriptor.java"
TEST_FILE="platforms/jvm/ear/src/test/groovy/org/gradle/plugins/ear/descriptor/internal/DefaultDeploymentDescriptorTest.groovy"

test_status=0

# Check that DefaultDeploymentDescriptor.java handles version "11" in toXmlNode (schemaLocation)
if ! grep -q '"11".equals(version)' "${DESCRIPTOR_SRC}"; then
    echo "ERROR: DefaultDeploymentDescriptor.java does not handle version 11 in toXmlNode (schemaLocation check)" >&2
    test_status=1
fi

# Check that both occurrences handle version "11" (one for schemaLocation, one for QName namespace)
count=$(grep -c '"11".equals(version)' "${DESCRIPTOR_SRC}" 2>/dev/null || echo 0)
if [ "$count" -lt 2 ]; then
    echo "ERROR: DefaultDeploymentDescriptor.java should have version 11 check in both toXmlNode and nodeNameFor, found only $count" >&2
    test_status=1
fi

# Check that the HEAD test file includes the '11' version test cases
if ! grep -q "'11'" "${TEST_FILE}"; then
    echo "ERROR: DefaultDeploymentDescriptorTest.groovy does not include version 11 test cases (expected HEAD state)" >&2
    test_status=1
fi

if [ $test_status -eq 0 ]; then
    echo "All Jakarta EE 11 deployment descriptor checks passed."
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
