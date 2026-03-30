#!/bin/sh
# TMPDIR should point to the encrypted mount
result=$("$CRYPTMP" sh -c 'echo "$TMPDIR"' 2>/dev/null)
case "$result" in
    /Volumes/cryptmp-*|/tmp/cryptmp-*) ;;
    *) echo "TMPDIR='$result' does not match expected pattern"; exit 1 ;;
esac
