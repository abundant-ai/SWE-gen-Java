#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "subprojects/core/src/test/groovy/org/gradle/internal/graph"
cp "/tests/subprojects/core/src/test/groovy/org/gradle/internal/graph/DirectedGraphRendererTest.groovy" "subprojects/core/src/test/groovy/org/gradle/internal/graph/DirectedGraphRendererTest.groovy"

GRAPH_NODE_RENDERER="subprojects/core/src/main/java/org/gradle/internal/graph/GraphNodeRenderer.java"
DIRECTED_GRAPH_RENDERER_TEST="subprojects/core/src/test/groovy/org/gradle/internal/graph/DirectedGraphRendererTest.groovy"

test_status=0

# Check that GraphNodeRenderer has 3-arg renderTo with alreadySeen (fix applied)
if ! grep -q 'boolean alreadySeen' "${GRAPH_NODE_RENDERER}"; then
    echo "ERROR: GraphNodeRenderer.java does not have 'boolean alreadySeen' parameter (fix not applied)" >&2
    test_status=1
fi

# Check that the buggy 2-arg renderTo is NOT the only signature (should have alreadySeen)
if grep -q 'void renderTo(N node, StyledTextOutput output);' "${GRAPH_NODE_RENDERER}"; then
    echo "ERROR: GraphNodeRenderer.java still has the 2-arg renderTo without alreadySeen (fix not applied)" >&2
    test_status=1
fi

# Check that the test file uses the 3-arg stub (fix applied)
if ! grep -q 'renderTo(_, _, _)' "${DIRECTED_GRAPH_RENDERER_TEST}"; then
    echo "ERROR: DirectedGraphRendererTest.groovy does not use 3-arg renderTo(_, _, _) stub (fix not applied)" >&2
    test_status=1
fi

# Check that the test expects '[2](seen) (*)' output (alreadySeen behavior)
if ! grep -q '\[2\](seen)' "${DIRECTED_GRAPH_RENDERER_TEST}"; then
    echo "ERROR: DirectedGraphRendererTest.groovy does not expect '[2](seen) (*)' output (fix not applied)" >&2
    test_status=1
fi

if [ $test_status -eq 0 ]; then
    echo "All checks passed: GraphNodeRenderer uses 3-arg renderTo API with alreadySeen parameter."
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
