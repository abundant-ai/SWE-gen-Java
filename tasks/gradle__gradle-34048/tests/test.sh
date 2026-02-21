#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "platforms/core-runtime/logging/src/test/groovy/org/gradle/internal/logging/console"
cp "/tests/platforms/core-runtime/logging/src/test/groovy/org/gradle/internal/logging/console/ConsoleStub.java" "platforms/core-runtime/logging/src/test/groovy/org/gradle/internal/logging/console/ConsoleStub.java"
mkdir -p "platforms/core-runtime/logging/src/test/groovy/org/gradle/internal/logging/console"
cp "/tests/platforms/core-runtime/logging/src/test/groovy/org/gradle/internal/logging/console/WorkInProgressRendererTest.groovy" "platforms/core-runtime/logging/src/test/groovy/org/gradle/internal/logging/console/WorkInProgressRendererTest.groovy"

CONSOLE_STUB="platforms/core-runtime/logging/src/test/groovy/org/gradle/internal/logging/console/ConsoleStub.java"
RENDERER_TEST="platforms/core-runtime/logging/src/test/groovy/org/gradle/internal/logging/console/WorkInProgressRendererTest.groovy"
BUILD_PROGRESS_AREA="platforms/core-runtime/logging/src/main/java/org/gradle/internal/logging/console/BuildProgressArea.java"
WORK_IN_PROGRESS_RENDERER="platforms/core-runtime/logging/src/main/java/org/gradle/internal/logging/console/WorkInProgressRenderer.java"

test_status=0

# The fix adds getCursorParkLine() to BuildProgressArea interface
if ! grep -q 'getCursorParkLine' "${BUILD_PROGRESS_AREA}"; then
    echo "ERROR: BuildProgressArea.java is missing getCursorParkLine() method (fix not applied)" >&2
    test_status=1
fi

# The fix adds reportLinesNotShown() to WorkInProgressRenderer
if ! grep -q 'reportLinesNotShown' "${WORK_IN_PROGRESS_RENDERER}"; then
    echo "ERROR: WorkInProgressRenderer.java is missing reportLinesNotShown() method (fix not applied)" >&2
    test_status=1
fi

# The HEAD ConsoleStub.java has getCursorParkLine() in TestableBuildProgressTextArea
if ! grep -q 'getCursorParkLine' "${CONSOLE_STUB}"; then
    echo "ERROR: ConsoleStub.java is missing getCursorParkLine() method (HEAD test not copied)" >&2
    test_status=1
fi

# The HEAD ConsoleStub.java has both statusBar and progressBar fields
if ! grep -q 'statusBar' "${CONSOLE_STUB}"; then
    echo "ERROR: ConsoleStub.java is missing statusBar field (HEAD test not copied)" >&2
    test_status=1
fi

# The HEAD WorkInProgressRendererTest.groovy has cursorParkText getter
if ! grep -q 'cursorParkText' "${RENDERER_TEST}"; then
    echo "ERROR: WorkInProgressRendererTest.groovy is missing cursorParkText getter (HEAD test not copied)" >&2
    test_status=1
fi

# The HEAD WorkInProgressRendererTest.groovy has "multiple offscreen operations" test
if ! grep -q 'multiple offscreen operations' "${RENDERER_TEST}"; then
    echo "ERROR: WorkInProgressRendererTest.groovy is missing 'multiple offscreen operations' test (HEAD test not copied)" >&2
    test_status=1
fi

if [ $test_status -eq 0 ]; then
    echo "All checks passed: BuildProgressArea has getCursorParkLine(), WorkInProgressRenderer has reportLinesNotShown(), and test files include cursorParkText checks."
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
