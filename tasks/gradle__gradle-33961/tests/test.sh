#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "platforms/core-configuration/base-diagnostics/src/test/groovy/org/gradle/api/reporting/model"
cp "/tests/platforms/core-configuration/base-diagnostics/src/test/groovy/org/gradle/api/reporting/model/ModelReportParserTest.groovy" "platforms/core-configuration/base-diagnostics/src/test/groovy/org/gradle/api/reporting/model/ModelReportParserTest.groovy"
mkdir -p "testing/internal-integ-testing/src/test/groovy/org/gradle/integtests/fixtures/logging"
cp "/tests/testing/internal-integ-testing/src/test/groovy/org/gradle/integtests/fixtures/logging/GroupedOutputFixtureTest.groovy" "testing/internal-integ-testing/src/test/groovy/org/gradle/integtests/fixtures/logging/GroupedOutputFixtureTest.groovy"

GROUPED_OUTPUT_FIXTURE="testing/internal-integ-testing/src/main/groovy/org/gradle/integtests/fixtures/logging/GroupedOutputFixture.java"
GROUPED_OUTPUT_FIXTURE_TEST="testing/internal-integ-testing/src/test/groovy/org/gradle/integtests/fixtures/logging/GroupedOutputFixtureTest.groovy"
MODEL_REPORT_PARSER="platforms/core-configuration/base-diagnostics/src/testFixtures/groovy/org/gradle/api/reporting/model/ModelReportParser.groovy"
MODEL_REPORT_PARSER_TEST="platforms/core-configuration/base-diagnostics/src/test/groovy/org/gradle/api/reporting/model/ModelReportParserTest.groovy"
CC_PROBLEMS_SUMMARY="platforms/core-configuration/configuration-cache/src/main/kotlin/org/gradle/internal/cc/impl/problems/ConfigurationCacheProblemsSummary.kt"

test_status=0

# The fix renames the constant to include OR_FEATURES in GroupedOutputFixture.java
if ! grep -q 'CONFIGURATION_CACHE_INCOMPATIBLE_TASKS_OR_FEATURES_FOOTER' "${GROUPED_OUTPUT_FIXTURE}"; then
    echo "ERROR: GroupedOutputFixture.java is missing CONFIGURATION_CACHE_INCOMPATIBLE_TASKS_OR_FEATURES_FOOTER constant (fix not applied)" >&2
    test_status=1
fi

# The fix updates the message in GroupedOutputFixture.java to include "or features"
if ! grep -q 'Some tasks or features in this build are not compatible with the configuration cache' "${GROUPED_OUTPUT_FIXTURE}"; then
    echo "ERROR: GroupedOutputFixture.java is missing 'Some tasks or features' message (fix not applied)" >&2
    test_status=1
fi

# The fix updates the ConfigurationCacheProblemsSummary.kt message to include "or features"
if ! grep -q 'Some tasks or features in this build are not compatible with the configuration cache' "${CC_PROBLEMS_SUMMARY}"; then
    echo "ERROR: ConfigurationCacheProblemsSummary.kt is missing 'Some tasks or features' message (fix not applied)" >&2
    test_status=1
fi

# The fix updates ModelReportParser.groovy pattern to include "or features"
if ! grep -q 'Some tasks or features in this build are not compatible with the configuration cache' "${MODEL_REPORT_PARSER}"; then
    echo "ERROR: ModelReportParser.groovy is missing 'Some tasks or features' pattern (fix not applied)" >&2
    test_status=1
fi

# The HEAD GroupedOutputFixtureTest.groovy has "cc-incompatible tasks/features summary" test case
if ! grep -q 'cc-incompatible tasks/features summary' "${GROUPED_OUTPUT_FIXTURE_TEST}"; then
    echo "ERROR: GroupedOutputFixtureTest.groovy is missing 'cc-incompatible tasks/features summary' test case (HEAD test not copied)" >&2
    test_status=1
fi

# The HEAD ModelReportParserTest.groovy has "Some tasks or features" in test data
if ! grep -q 'Some tasks or features in this build are not compatible with the configuration cache' "${MODEL_REPORT_PARSER_TEST}"; then
    echo "ERROR: ModelReportParserTest.groovy is missing 'Some tasks or features' test data (HEAD test not copied)" >&2
    test_status=1
fi

if [ $test_status -eq 0 ]; then
    echo "All checks passed: GroupedOutputFixture has INCOMPATIBLE_TASKS_OR_FEATURES_FOOTER, ConfigurationCacheProblemsSummary and ModelReportParser use 'Some tasks or features' message, and test files include correct test cases."
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
