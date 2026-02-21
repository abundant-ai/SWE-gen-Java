#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "platforms/core-configuration/base-diagnostics/src/test/groovy/org/gradle/api/tasks/diagnostics"
cp "/tests/platforms/core-configuration/base-diagnostics/src/test/groovy/org/gradle/api/tasks/diagnostics/ProjectReportTaskTest.groovy" "platforms/core-configuration/base-diagnostics/src/test/groovy/org/gradle/api/tasks/diagnostics/ProjectReportTaskTest.groovy"
mkdir -p "platforms/core-configuration/base-diagnostics/src/test/groovy/org/gradle/api/tasks/diagnostics/internal"
cp "/tests/platforms/core-configuration/base-diagnostics/src/test/groovy/org/gradle/api/tasks/diagnostics/internal/TextReportRendererSpec.groovy" "platforms/core-configuration/base-diagnostics/src/test/groovy/org/gradle/api/tasks/diagnostics/internal/TextReportRendererSpec.groovy"
mkdir -p "platforms/documentation/docs/src/snippets/bestPractices/avoidEmptyProjects-avoid/tests"
cp "/tests/platforms/documentation/docs/src/snippets/bestPractices/avoidEmptyProjects-avoid/tests/avoidEmptyProjects-avoid.out" "platforms/documentation/docs/src/snippets/bestPractices/avoidEmptyProjects-avoid/tests/avoidEmptyProjects-avoid.out"
mkdir -p "platforms/documentation/docs/src/snippets/bestPractices/avoidEmptyProjects-do/tests"
cp "/tests/platforms/documentation/docs/src/snippets/bestPractices/avoidEmptyProjects-do/tests/avoidEmptyProjects-do.out" "platforms/documentation/docs/src/snippets/bestPractices/avoidEmptyProjects-do/tests/avoidEmptyProjects-do.out"
mkdir -p "platforms/documentation/docs/src/snippets/bestPractices/avoidInternal-do/tests"
cp "/tests/platforms/documentation/docs/src/snippets/bestPractices/avoidInternal-do/tests/avoidInternal.out" "platforms/documentation/docs/src/snippets/bestPractices/avoidInternal-do/tests/avoidInternal.out"
mkdir -p "platforms/documentation/docs/src/snippets/java/multiproject/tests"
cp "/tests/platforms/documentation/docs/src/snippets/java/multiproject/tests/listProjects.out" "platforms/documentation/docs/src/snippets/java/multiproject/tests/listProjects.out"
mkdir -p "platforms/documentation/docs/src/snippets/mavenMigration/multiModule/tests"
cp "/tests/platforms/documentation/docs/src/snippets/mavenMigration/multiModule/tests/projects.out" "platforms/documentation/docs/src/snippets/mavenMigration/multiModule/tests/projects.out"
mkdir -p "platforms/documentation/docs/src/snippets/multiproject/basic-multiproject/tests"
cp "/tests/platforms/documentation/docs/src/snippets/multiproject/basic-multiproject/tests/projects.out" "platforms/documentation/docs/src/snippets/multiproject/basic-multiproject/tests/projects.out"
mkdir -p "platforms/documentation/docs/src/snippets/tutorial/projectReports/tests"
cp "/tests/platforms/documentation/docs/src/snippets/tutorial/projectReports/tests/propertyListReport.out" "platforms/documentation/docs/src/snippets/tutorial/projectReports/tests/propertyListReport.out"
mkdir -p "platforms/documentation/docs/src/snippets/tutorial/projectReports/tests"
cp "/tests/platforms/documentation/docs/src/snippets/tutorial/projectReports/tests/propertyReport.out" "platforms/documentation/docs/src/snippets/tutorial/projectReports/tests/propertyReport.out"

PROJECT_REPORT_TASK="platforms/core-configuration/base-diagnostics/src/main/java/org/gradle/api/tasks/diagnostics/ProjectReportTask.java"
TEXT_REPORT_RENDERER="platforms/core-configuration/base-diagnostics/src/main/java/org/gradle/api/tasks/diagnostics/internal/TextReportRenderer.java"
PROJECT_REPORT_TEST="platforms/core-configuration/base-diagnostics/src/test/groovy/org/gradle/api/tasks/diagnostics/ProjectReportTaskTest.groovy"

test_status=0

# The fix adds renderRootProjectLocation to show the project directory path
if ! grep -q 'renderRootProjectLocation' "${PROJECT_REPORT_TASK}"; then
    echo "ERROR: ProjectReportTask.java is missing renderRootProjectLocation (fix not applied)" >&2
    test_status=1
fi

# The fix adds renderRootProjectDescription to show project description separately
if ! grep -q 'renderRootProjectDescription' "${PROJECT_REPORT_TASK}"; then
    echo "ERROR: ProjectReportTask.java is missing renderRootProjectDescription (fix not applied)" >&2
    test_status=1
fi

# The fix adds renderProjectsLocations to show project locations section
if ! grep -q 'renderProjectsLocations\|renderProjectHierarchy' "${PROJECT_REPORT_TASK}"; then
    echo "ERROR: ProjectReportTask.java is missing renderProjectsLocations or renderProjectHierarchy (fix not applied)" >&2
    test_status=1
fi

# The fix removes GUtil import from TextReportRenderer and removes description from header
if grep -q 'import org.gradle.util.internal.GUtil' "${TEXT_REPORT_RENDERER}"; then
    echo "ERROR: TextReportRenderer.java still imports GUtil (fix not applied - description still in header)" >&2
    test_status=1
fi

# The fix removes 'GUtil.isTrue(description)' from createHeader (description moved to separate section)
if grep -q 'GUtil.isTrue' "${TEXT_REPORT_RENDERER}"; then
    echo "ERROR: TextReportRenderer.java still uses GUtil.isTrue for description in header (fix not applied)" >&2
    test_status=1
fi

# The HEAD test file expects 'Location:' in the output, which is added by the fix
if ! grep -q 'Location:' "${PROJECT_REPORT_TEST}"; then
    echo "ERROR: ProjectReportTaskTest.groovy is missing 'Location:' assertion (HEAD test not copied)" >&2
    test_status=1
fi

# The HEAD test file expects 'Project locations:' section, which is added by the fix
if ! grep -q 'Project locations:' "${PROJECT_REPORT_TEST}"; then
    echo "ERROR: ProjectReportTaskTest.groovy is missing 'Project locations:' assertion (HEAD test not copied or fix not applied)" >&2
    test_status=1
fi

if [ $test_status -eq 0 ]; then
    echo "All checks passed: ProjectReportTask has renderRootProjectLocation/Description, TextReportRenderer no longer includes description in header, and test files match expected HEAD state."
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
