#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "subprojects/core/src/test/groovy/org/gradle/execution/taskgraph"
cp "/tests/subprojects/core/src/test/groovy/org/gradle/execution/taskgraph/DefaultTaskExecutionGraphSpec.groovy" "subprojects/core/src/test/groovy/org/gradle/execution/taskgraph/DefaultTaskExecutionGraphSpec.groovy"

TASK_GRAPH_JAVA="subprojects/core/src/main/java/org/gradle/execution/taskgraph/DefaultTaskExecutionGraph.java"
TASK_GRAPH_INTERNAL="subprojects/core/src/main/java/org/gradle/execution/taskgraph/TaskExecutionGraphInternal.java"

test_status=0

# Check that DefaultTaskExecutionGraph.java references internalGraphListeners (fix adds it back)
if ! grep -q 'internalGraphListeners' "${TASK_GRAPH_JAVA}"; then
    echo "ERROR: DefaultTaskExecutionGraph.java is missing internalGraphListeners (fix not applied)" >&2
    test_status=1
fi

# Check that TaskExecutionGraphInternal.java declares addExecutionListener/removeExecutionListener (fix adds them back)
if ! grep -q 'addExecutionListener' "${TASK_GRAPH_INTERNAL}"; then
    echo "ERROR: TaskExecutionGraphInternal.java is missing addExecutionListener (fix not applied)" >&2
    test_status=1
fi

# Check that TaskExecutionGraphExecutionListener interface exists (fix restores the class)
if [ ! -f "subprojects/core/src/main/java/org/gradle/execution/taskgraph/TaskExecutionGraphExecutionListener.java" ]; then
    echo "ERROR: TaskExecutionGraphExecutionListener.java is missing (fix not applied)" >&2
    test_status=1
fi

if [ $test_status -eq 0 ]; then
    echo "All checks passed: internalGraphListeners present in DefaultTaskExecutionGraph, addExecutionListener in TaskExecutionGraphInternal, TaskExecutionGraphExecutionListener.java exists."
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
