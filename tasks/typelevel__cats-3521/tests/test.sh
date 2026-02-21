#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "alleycats-tests/shared/src/test/scala/alleycats/tests"
cp "/tests/alleycats-tests/shared/src/test/scala/alleycats/tests/MapSuite.scala" "alleycats-tests/shared/src/test/scala/alleycats/tests/MapSuite.scala"
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/ChainSuite.scala" "tests/src/test/scala/cats/tests/ChainSuite.scala"
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/ListSuite.scala" "tests/src/test/scala/cats/tests/ListSuite.scala"
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/QueueSuite.scala" "tests/src/test/scala/cats/tests/QueueSuite.scala"
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/SortedMapSuite.scala" "tests/src/test/scala/cats/tests/SortedMapSuite.scala"
mkdir -p "tests/src/test/scala/cats/tests"
cp "/tests/src/test/scala/cats/tests/VectorSuite.scala" "tests/src/test/scala/cats/tests/VectorSuite.scala"

# Verify the fix is applied by checking that traverseViaChain and traverseFilterViaChain
# are defined in Chain.scala. bug.patch removes these methods; fix.patch restores them.
# Also verify list.scala uses traverseViaChain (bug.patch changes it to use inline recursion).

if grep -q "def traverseViaChain" core/src/main/scala/cats/data/Chain.scala && \
   grep -q "def traverseFilterViaChain" core/src/main/scala/cats/data/Chain.scala && \
   grep -q "traverseViaChain" core/src/main/scala/cats/instances/list.scala; then
  echo "Fix is applied: traverseViaChain and traverseFilterViaChain are present in Chain.scala"
  test_status=0
else
  echo "ERROR: Fix not detected - traverseViaChain/traverseFilterViaChain missing from Chain.scala" >&2
  test_status=1
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
