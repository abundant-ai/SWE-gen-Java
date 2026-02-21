#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "subprojects/core/src/test/groovy/org/gradle/api/internal/project"
cp "/tests/subprojects/core/src/test/groovy/org/gradle/api/internal/project/DefaultProjectTest.groovy" "subprojects/core/src/test/groovy/org/gradle/api/internal/project/DefaultProjectTest.groovy"

DEFAULT_PROJECT_JAVA="subprojects/core/src/main/java/org/gradle/api/internal/project/DefaultProject.java"
DEFAULT_PROJECT_TEST="subprojects/core/src/test/groovy/org/gradle/api/internal/project/DefaultProjectTest.groovy"

test_status=0

# Check that DefaultProject.java has getDefaultGroup() method (fix applied)
if ! grep -q 'getDefaultGroup' "${DEFAULT_PROJECT_JAVA}"; then
    echo "ERROR: DefaultProject.java does not have getDefaultGroup() method (fix not applied)" >&2
    test_status=1
fi

# Check that DefaultProject.java uses Stream.concat for group computation (fix applied)
if ! grep -q 'Stream.concat' "${DEFAULT_PROJECT_JAVA}"; then
    echo "ERROR: DefaultProject.java does not use Stream.concat for group computation (fix not applied)" >&2
    test_status=1
fi

# Check that DefaultProject.java uses Collectors.joining (fix applied)
if ! grep -q 'Collectors.joining' "${DEFAULT_PROJECT_JAVA}"; then
    echo "ERROR: DefaultProject.java does not use Collectors.joining (fix not applied)" >&2
    test_status=1
fi

# Check that DefaultProject.java does NOT use the broken 'this == rootProject' comparison (fix applied)
if grep -q 'this == rootProject' "${DEFAULT_PROJECT_JAVA}"; then
    echo "ERROR: DefaultProject.java still uses broken 'this == rootProject' comparison (fix not applied)" >&2
    test_status=1
fi

# Check that DefaultProjectTest.groovy has the full defaultProject() helper with ProjectIdentity (fix applied)
if ! grep -q 'ProjectIdentity' "${DEFAULT_PROJECT_TEST}"; then
    echo "ERROR: DefaultProjectTest.groovy does not have full defaultProject() helper with ProjectIdentity (fix not applied)" >&2
    test_status=1
fi

# Check that DefaultProjectTest.groovy has getGroup test asserting childchild.group == 'root.child1' (fix applied)
if ! grep -q "childchild.group == 'root.child1'" "${DEFAULT_PROJECT_TEST}"; then
    echo "ERROR: DefaultProjectTest.groovy does not assert correct group for childchild (fix not applied)" >&2
    test_status=1
fi

if [ $test_status -eq 0 ]; then
    echo "All checks passed: DefaultProject.getGroup() uses proper getDefaultGroup() implementation without trailing dot bug."
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
