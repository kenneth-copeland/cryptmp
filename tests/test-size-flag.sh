#!/bin/sh
# -s flag should be accepted and create a working mount
result=$("$CRYPTMP" -s 256M sh -c 'echo "$TMPDIR"' 2>/dev/null)
case "$result" in
    /Volumes/cryptmp-*|/tmp/cryptmp-*) ;;
    *) echo "TMPDIR='$result' — -s flag may have failed"; exit 1 ;;
esac
