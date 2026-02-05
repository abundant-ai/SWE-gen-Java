#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "subprojects/inlineTest/src/test/java/org/mockitoinline"
cp "/tests/subprojects/inlineTest/src/test/java/org/mockitoinline/ConstructionMockRuleTest.java" "subprojects/inlineTest/src/test/java/org/mockitoinline/ConstructionMockRuleTest.java"
mkdir -p "subprojects/inlineTest/src/test/java/org/mockitoinline"
cp "/tests/subprojects/inlineTest/src/test/java/org/mockitoinline/ConstructionMockTest.java" "subprojects/inlineTest/src/test/java/org/mockitoinline/ConstructionMockTest.java"
mkdir -p "subprojects/inlineTest/src/test/java/org/mockitoinline"
cp "/tests/subprojects/inlineTest/src/test/java/org/mockitoinline/EnumMockingTest.java" "subprojects/inlineTest/src/test/java/org/mockitoinline/EnumMockingTest.java"
mkdir -p "subprojects/inlineTest/src/test/java/org/mockitoinline"
cp "/tests/subprojects/inlineTest/src/test/java/org/mockitoinline/FinalClassMockingTest.java" "subprojects/inlineTest/src/test/java/org/mockitoinline/FinalClassMockingTest.java"
mkdir -p "subprojects/inlineTest/src/test/java/org/mockitoinline"
cp "/tests/subprojects/inlineTest/src/test/java/org/mockitoinline/HierarchyPreInitializationTest.java" "subprojects/inlineTest/src/test/java/org/mockitoinline/HierarchyPreInitializationTest.java"
mkdir -p "subprojects/inlineTest/src/test/java/org/mockitoinline"
cp "/tests/subprojects/inlineTest/src/test/java/org/mockitoinline/InOrderVerificationTest.java" "subprojects/inlineTest/src/test/java/org/mockitoinline/InOrderVerificationTest.java"
mkdir -p "subprojects/inlineTest/src/test/java/org/mockitoinline"
cp "/tests/subprojects/inlineTest/src/test/java/org/mockitoinline/InitializationTest.java" "subprojects/inlineTest/src/test/java/org/mockitoinline/InitializationTest.java"
mkdir -p "subprojects/inlineTest/src/test/java/org/mockitoinline"
cp "/tests/subprojects/inlineTest/src/test/java/org/mockitoinline/OneLinerStubStressTest.java" "subprojects/inlineTest/src/test/java/org/mockitoinline/OneLinerStubStressTest.java"
mkdir -p "subprojects/inlineTest/src/test/java/org/mockitoinline"
cp "/tests/subprojects/inlineTest/src/test/java/org/mockitoinline/PluginTest.java" "subprojects/inlineTest/src/test/java/org/mockitoinline/PluginTest.java"
mkdir -p "subprojects/inlineTest/src/test/java/org/mockitoinline"
cp "/tests/subprojects/inlineTest/src/test/java/org/mockitoinline/RecursionTest.java" "subprojects/inlineTest/src/test/java/org/mockitoinline/RecursionTest.java"
mkdir -p "subprojects/inlineTest/src/test/java/org/mockitoinline"
cp "/tests/subprojects/inlineTest/src/test/java/org/mockitoinline/SpyWithConstructorTest.java" "subprojects/inlineTest/src/test/java/org/mockitoinline/SpyWithConstructorTest.java"
mkdir -p "subprojects/inlineTest/src/test/java/org/mockitoinline"
cp "/tests/subprojects/inlineTest/src/test/java/org/mockitoinline/StaticMockRuleTest.java" "subprojects/inlineTest/src/test/java/org/mockitoinline/StaticMockRuleTest.java"
mkdir -p "subprojects/inlineTest/src/test/java/org/mockitoinline"
cp "/tests/subprojects/inlineTest/src/test/java/org/mockitoinline/StaticMockTest.java" "subprojects/inlineTest/src/test/java/org/mockitoinline/StaticMockTest.java"
mkdir -p "subprojects/inlineTest/src/test/java/org/mockitoinline"
cp "/tests/subprojects/inlineTest/src/test/java/org/mockitoinline/StaticRuleTest.java" "subprojects/inlineTest/src/test/java/org/mockitoinline/StaticRuleTest.java"
mkdir -p "subprojects/inlineTest/src/test/java/org/mockitoinline"
cp "/tests/subprojects/inlineTest/src/test/java/org/mockitoinline/StaticRunnerTest.java" "subprojects/inlineTest/src/test/java/org/mockitoinline/StaticRunnerTest.java"
mkdir -p "subprojects/inlineTest/src/test/java/org/mockitoinline"
cp "/tests/subprojects/inlineTest/src/test/java/org/mockitoinline/StressTest.java" "subprojects/inlineTest/src/test/java/org/mockitoinline/StressTest.java"
mkdir -p "subprojects/inlineTest/src/test/java/org/mockitoinline"
cp "/tests/subprojects/inlineTest/src/test/java/org/mockitoinline/StubbingLocationTest.java" "subprojects/inlineTest/src/test/java/org/mockitoinline/StubbingLocationTest.java"
mkdir -p "subprojects/inlineTest/src/test/java/org/mockitoinline"
cp "/tests/subprojects/inlineTest/src/test/java/org/mockitoinline/SubconstructorMockTest.java" "subprojects/inlineTest/src/test/java/org/mockitoinline/SubconstructorMockTest.java"
mkdir -p "subprojects/inlineTest/src/test/java/org/mockitoinline"
cp "/tests/subprojects/inlineTest/src/test/java/org/mockitoinline/SuperCallTest.java" "subprojects/inlineTest/src/test/java/org/mockitoinline/SuperCallTest.java"
mkdir -p "subprojects/inlineTest/src/test/java/org/mockitoinline/bugs"
cp "/tests/subprojects/inlineTest/src/test/java/org/mockitoinline/bugs/CyclicMockMethodArgumentMemoryLeakTest.java" "subprojects/inlineTest/src/test/java/org/mockitoinline/bugs/CyclicMockMethodArgumentMemoryLeakTest.java"
mkdir -p "subprojects/inlineTest/src/test/java/org/mockitoinline/bugs"
cp "/tests/subprojects/inlineTest/src/test/java/org/mockitoinline/bugs/OngoingStubShiftTest.java" "subprojects/inlineTest/src/test/java/org/mockitoinline/bugs/OngoingStubShiftTest.java"
mkdir -p "subprojects/inlineTest/src/test/java/org/mockitoinline/bugs"
cp "/tests/subprojects/inlineTest/src/test/java/org/mockitoinline/bugs/SelfSpyReferenceMemoryLeakTest.java" "subprojects/inlineTest/src/test/java/org/mockitoinline/bugs/SelfSpyReferenceMemoryLeakTest.java"

# Run the specific tests for this PR (on inlineTest subproject)
./gradlew :inlineTest:test \
  --tests org.mockitoinline.ConstructionMockRuleTest \
  --tests org.mockitoinline.ConstructionMockTest \
  --tests org.mockitoinline.EnumMockingTest \
  --tests org.mockitoinline.FinalClassMockingTest \
  --tests org.mockitoinline.HierarchyPreInitializationTest \
  --tests org.mockitoinline.InOrderVerificationTest \
  --tests org.mockitoinline.InitializationTest \
  --tests org.mockitoinline.OneLinerStubStressTest \
  --tests org.mockitoinline.PluginTest \
  --tests org.mockitoinline.RecursionTest \
  --tests org.mockitoinline.SpyWithConstructorTest \
  --tests org.mockitoinline.StaticMockRuleTest \
  --tests org.mockitoinline.StaticMockTest \
  --tests org.mockitoinline.StaticRuleTest \
  --tests org.mockitoinline.StaticRunnerTest \
  --tests org.mockitoinline.StressTest \
  --tests org.mockitoinline.StubbingLocationTest \
  --tests org.mockitoinline.SubconstructorMockTest \
  --tests org.mockitoinline.SuperCallTest \
  --tests org.mockitoinline.bugs.CyclicMockMethodArgumentMemoryLeakTest \
  --tests org.mockitoinline.bugs.OngoingStubShiftTest \
  --tests org.mockitoinline.bugs.SelfSpyReferenceMemoryLeakTest \
  --no-daemon --rerun-tasks
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
