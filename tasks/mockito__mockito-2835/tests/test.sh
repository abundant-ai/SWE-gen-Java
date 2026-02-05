#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "src/test/java/org/mockito/internal/invocation"
cp "/tests/java/org/mockito/internal/invocation/InvocationMatcherTest.java" "src/test/java/org/mockito/internal/invocation/InvocationMatcherTest.java"
mkdir -p "src/test/java/org/mockito/internal/invocation"
cp "/tests/java/org/mockito/internal/invocation/MatcherApplicationStrategyTest.java" "src/test/java/org/mockito/internal/invocation/MatcherApplicationStrategyTest.java"
mkdir -p "src/test/java/org/mockito/internal/matchers"
cp "/tests/java/org/mockito/internal/matchers/InstanceOfTest.java" "src/test/java/org/mockito/internal/matchers/InstanceOfTest.java"
mkdir -p "src/test/java/org/mockito/internal/util/reflection"
cp "/tests/java/org/mockito/internal/util/reflection/ParameterizedConstructorInstantiatorTest.java" "src/test/java/org/mockito/internal/util/reflection/ParameterizedConstructorInstantiatorTest.java"
mkdir -p "src/test/java/org/mockitousage/basicapi"
cp "/tests/java/org/mockitousage/basicapi/UsingVarargsTest.java" "src/test/java/org/mockitousage/basicapi/UsingVarargsTest.java"
mkdir -p "src/test/java/org/mockitousage/bugs/varargs"
cp "/tests/java/org/mockitousage/bugs/varargs/VarargsAndAnyPicksUpExtraInvocationsTest.java" "src/test/java/org/mockitousage/bugs/varargs/VarargsAndAnyPicksUpExtraInvocationsTest.java"
mkdir -p "src/test/java/org/mockitousage/matchers"
cp "/tests/java/org/mockitousage/matchers/CapturingArgumentsTest.java" "src/test/java/org/mockitousage/matchers/CapturingArgumentsTest.java"
mkdir -p "src/test/java/org/mockitousage/matchers"
cp "/tests/java/org/mockitousage/matchers/HamcrestMatchersTest.java" "src/test/java/org/mockitousage/matchers/HamcrestMatchersTest.java"
mkdir -p "src/test/java/org/mockitousage/matchers"
cp "/tests/java/org/mockitousage/matchers/VarargsTest.java" "src/test/java/org/mockitousage/matchers/VarargsTest.java"
mkdir -p "src/test/java/org/mockitousage/stubbing"
cp "/tests/java/org/mockitousage/stubbing/StubbingWithAdditionalAnswersTest.java" "src/test/java/org/mockitousage/stubbing/StubbingWithAdditionalAnswersTest.java"

# Run the specific tests for this PR (on main project)
./gradlew :test \
  --tests org.mockito.internal.invocation.InvocationMatcherTest \
  --tests org.mockito.internal.invocation.MatcherApplicationStrategyTest \
  --tests org.mockito.internal.matchers.InstanceOfTest \
  --tests org.mockito.internal.util.reflection.ParameterizedConstructorInstantiatorTest \
  --tests org.mockitousage.basicapi.UsingVarargsTest \
  --tests org.mockitousage.bugs.varargs.VarargsAndAnyPicksUpExtraInvocationsTest \
  --tests org.mockitousage.matchers.CapturingArgumentsTest \
  --tests org.mockitousage.matchers.HamcrestMatchersTest \
  --tests org.mockitousage.matchers.VarargsTest \
  --tests org.mockitousage.stubbing.StubbingWithAdditionalAnswersTest \
  --no-daemon --rerun-tasks
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
