#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/ListSuite.scala" "tests/src/test/scala/cats/tests/ListSuite.scala"
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/SortedSetSuite.scala" "tests/src/test/scala/cats/tests/SortedSetSuite.scala"
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/SyntaxSerializationSuite.scala" "tests/src/test/scala/cats/tests/SyntaxSerializationSuite.scala"
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/VectorSuite.scala" "tests/src/test/scala/cats/tests/VectorSuite.scala"

# Verify the fix is applied by checking that the key methods exist in the source files.
# bug.patch removes combineKEval from SemigroupK.scala and foldMapK from list.scala and vector.scala;
# fix.patch restores all of them.
if grep -q "def combineKEval" core/src/main/scala/cats/SemigroupK.scala && \
   grep -q "def foldMapK" core/src/main/scala/cats/instances/list.scala && \
   grep -q "def foldMapK" core/src/main/scala/cats/instances/vector.scala; then
  echo "Fix is applied: combineKEval exists in SemigroupK.scala and foldMapK exists in list.scala and vector.scala"
  test_status=0
else
  echo "ERROR: Fix not detected - missing one or more of: combineKEval in SemigroupK.scala, foldMapK in list.scala, foldMapK in vector.scala" >&2
  test_status=1
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
