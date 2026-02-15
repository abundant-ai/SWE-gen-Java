#!/bin/bash

set -euo pipefail
cd /app/src

patch -p1 < /solution/fix.patch

# Rebuild after applying fix (TypeScript requires recompilation)
# Use increased heap size to avoid OOM errors
export NODE_OPTIONS="--max-old-space-size=4096"
npm run build

# Link the generator globally so tests can find it
npm link
