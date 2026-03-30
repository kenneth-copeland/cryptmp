#!/bin/sh
# Two concurrent cryptmp sessions should not interfere
vol1=$("$CRYPTMP" sh -c 'echo "$TMPDIR"' 2>/dev/null)
vol2=$("$CRYPTMP" sh -c 'echo "$TMPDIR"' 2>/dev/null)
[ -n "$vol1" ] && [ -n "$vol2" ] || { echo "One or both sessions failed"; exit 1; }
[ "$vol1" != "$vol2" ] || {
    echo "Both sessions got the same TMPDIR: $vol1"
    exit 1
}
