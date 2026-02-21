#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/SyntaxSerializationSuite.scala" "tests/src/test/scala/cats/tests/SyntaxSerializationSuite.scala"

# Verify the fix is applied by checking that Serializable is restored to the syntax classes.
# bug.patch removes Serializable from SemigroupalOps in semigroupal.scala (uses "with Serializable")
# and from SemigroupalBuilder/Tuple*Ops classes in Boilerplate.scala (uses "extends Serializable"),
# and deletes SyntaxSerializationSuite.scala; fix.patch restores all of them.
if grep -q "with Serializable" core/src/main/scala/cats/syntax/semigroupal.scala && \
   grep -q "extends Serializable" project/Boilerplate.scala && \
   test -f tests/src/test/scala/cats/tests/SyntaxSerializationSuite.scala; then
  echo "Fix is applied: Serializable restored in semigroupal.scala and Boilerplate.scala, and SyntaxSerializationSuite.scala exists"
  test_status=0
else
  echo "ERROR: Fix not detected - missing Serializable in semigroupal.scala or Boilerplate.scala, or SyntaxSerializationSuite.scala is absent" >&2
  test_status=1
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
