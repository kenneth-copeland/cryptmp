#!/bin/sh
# -h should print usage and exit 0
output=$("$CRYPTMP" -h 2>&1)
rc=$?
[ $rc -eq 0 ] || { echo "Exit code $rc, expected 0"; exit 1; }
echo "$output" | grep -q "Usage:" || { echo "No usage text in output"; exit 1; }
