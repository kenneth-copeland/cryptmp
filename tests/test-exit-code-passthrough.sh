#!/bin/sh
# cryptmp should pass through the exit code of the command
"$CRYPTMP" sh -c 'exit 0' 2>/dev/null
[ $? -eq 0 ] || { echo "Expected exit 0"; exit 1; }

"$CRYPTMP" sh -c 'exit 42' 2>/dev/null
[ $? -eq 42 ] || { echo "Expected exit 42, got $?"; exit 1; }
