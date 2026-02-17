#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "ktor-server/ktor-server-core/common/test/io/ktor/server/routing"
cp "/tests/ktor-server/ktor-server-core/common/test/io/ktor/server/routing/RouteTest.kt" "ktor-server/ktor-server-core/common/test/io/ktor/server/routing/RouteTest.kt"
mkdir -p "ktor-server/ktor-server-plugins/ktor-server-metrics-micrometer/jvm/test/io/ktor/server/metrics/micrometer"
cp "/tests/ktor-server/ktor-server-plugins/ktor-server-metrics-micrometer/jvm/test/io/ktor/server/metrics/micrometer/MicrometerMetricsTests.kt" "ktor-server/ktor-server-plugins/ktor-server-metrics-micrometer/jvm/test/io/ktor/server/metrics/micrometer/MicrometerMetricsTests.kt"

ROUTING_NODE="ktor-server/ktor-server-core/common/src/io/ktor/server/routing/RoutingNode.kt"
MICROMETER="ktor-server/ktor-server-plugins/ktor-server-metrics-micrometer/jvm/src/io/ktor/server/metrics/micrometer/MicrometerMetrics.kt"
ROUTE_TEST="ktor-server/ktor-server-core/common/test/io/ktor/server/routing/RouteTest.kt"
MICROMETER_TEST="ktor-server/ktor-server-plugins/ktor-server-metrics-micrometer/jvm/test/io/ktor/server/metrics/micrometer/MicrometerMetricsTests.kt"
test_status=0

# Verify the path extension property is added to RoutingNode
if ! grep -q "public val RoutingNode.path: String" "$ROUTING_NODE"; then
    echo "FAIL: RoutingNode.path extension property not found in RoutingNode.kt (should be added by fix)"
    test_status=1
fi

# Verify the path() private function is present
if ! grep -q "private fun RoutingNode.path()" "$ROUTING_NODE"; then
    echo "FAIL: private path() function not found in RoutingNode.kt (should be added by fix)"
    test_status=1
fi

# Verify RouteSelector.toPathElement() function is present
if ! grep -q "private fun RouteSelector.toPathElement" "$ROUTING_NODE"; then
    echo "FAIL: toPathElement() function not found in RoutingNode.kt (should be added by fix)"
    test_status=1
fi

# Verify transformRoute function is added to MicrometerMetricsConfig
if ! grep -q "public fun transformRoute" "$MICROMETER"; then
    echo "FAIL: transformRoute() function not found in MicrometerMetrics.kt (should be added by fix)"
    test_status=1
fi

# Verify MicrometerMetrics uses pluginConfig.transformRoute (not the buggy call.route.parent.toString())
if grep -q "call.route.parent.toString()" "$MICROMETER"; then
    echo "FAIL: MicrometerMetrics should use pluginConfig.transformRoute(), not call.route.parent.toString() (this is the bug)"
    test_status=1
fi

if ! grep -q "pluginConfig.transformRoute" "$MICROMETER"; then
    echo "FAIL: pluginConfig.transformRoute() not found in MicrometerMetrics.kt (should be restored by fix)"
    test_status=1
fi

# Verify RouteTest includes the testPathProperty test
if ! grep -q "testPathProperty" "$ROUTE_TEST"; then
    echo "FAIL: testPathProperty test not found in RouteTest.kt (should be present after fix)"
    test_status=1
fi

# Verify MicrometerMetricsTests includes the transformRoute tests
if ! grep -q "route transformation can be configured" "$MICROMETER_TEST"; then
    echo "FAIL: 'route transformation can be configured' test not found in MicrometerMetricsTests.kt (should be present after fix)"
    test_status=1
fi

if ! grep -q "route with auth plugin should not include authentication provider" "$MICROMETER_TEST"; then
    echo "FAIL: 'route with auth plugin should not include authentication provider' test not found in MicrometerMetricsTests.kt (should be present after fix)"
    test_status=1
fi

if [ $test_status -eq 0 ]; then
    echo "PASS: All path extension property and transformRoute fixes verified"
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
