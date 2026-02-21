#!/bin/bash

set -euo pipefail
cd /app/src

# Use --force to skip binary file diffs (patch cannot handle git binary diffs;
# the binary .class files are already present in the environment at the correct state)
patch -p1 --force < /solution/fix.patch
