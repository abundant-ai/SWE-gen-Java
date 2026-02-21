#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/tools/jackson/databind/jsonschema"
cp "/tests/java/tools/jackson/databind/jsonschema/FormatVisitor5393Test.java" "src/test/java/tools/jackson/databind/jsonschema/FormatVisitor5393Test.java"
mkdir -p "src/test/java/tools/jackson/databind/jsonschema"
cp "/tests/java/tools/jackson/databind/jsonschema/NewSchemaTest.java" "src/test/java/tools/jackson/databind/jsonschema/NewSchemaTest.java"
mkdir -p "src/test/java/tools/jackson/databind/views"
cp "/tests/java/tools/jackson/databind/views/ViewsWithSchemaTest.java" "src/test/java/tools/jackson/databind/views/ViewsWithSchemaTest.java"

# Recompile all sources to pick up any changes from solve.sh
mvn compile test-compile -q 2>&1

# API contract check: PR #5599 removed the no-arg constructors from JsonObjectFormatVisitor.Base,
# JsonArrayFormatVisitor.Base, and JsonMapFormatVisitor.Base to reduce mutability.
# Write a small Java snippet that tries to use the no-arg constructor.
# This should compile on BUGGY (pre-fix) code but FAIL on FIXED (post-fix) code.
# We invert the logic: if it compiles, we're on buggy code -> fail the test.
cat > /tmp/ApiContractCheck.java << 'JAVAEOF'
import tools.jackson.databind.jsonFormatVisitors.JsonObjectFormatVisitor;
public class ApiContractCheck {
    public static void main(String[] args) {
        // This constructor was removed in PR #5599 (reduce mutability)
        // If this compiles, the fix has NOT been applied yet
        JsonObjectFormatVisitor.Base v = new JsonObjectFormatVisitor.Base();
    }
}
JAVAEOF

mvn dependency:build-classpath -q -Dmdep.outputFile=/tmp/cp.txt 2>/dev/null
M2_CP=$(cat /tmp/cp.txt 2>/dev/null)
CP="target/classes:${M2_CP}"

if javac -cp "$CP" /tmp/ApiContractCheck.java 2>/dev/null; then
    # Compilation succeeded: no-arg constructor exists -> buggy code, fix NOT applied
    echo "ERROR: JsonObjectFormatVisitor.Base() no-arg constructor still exists - fix not applied" >&2
    echo 0 > /logs/verifier/reward.txt
    exit 1
fi

# Run only the specific test classes from the PR
mvn test -Dtest="FormatVisitor5393Test,NewSchemaTest,ViewsWithSchemaTest" 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
