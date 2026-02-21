#!/bin/bash

set -euo pipefail
cd /app/src

# Apply text changes from fix.patch (the binary file addition is handled separately)
patch -p1 < /solution/fix.patch || true

# Restore the binary .class file that fix.patch adds (binary patches can't be applied with patch -p1)
mkdir -p spotbugsTestCases/src/classSamples/compiledWithCorretto11.0.4_10
cp /solution/Issue1147.class spotbugsTestCases/src/classSamples/compiledWithCorretto11.0.4_10/Issue1147.class
