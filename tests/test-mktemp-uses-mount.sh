#!/bin/sh
# mktemp -p $TMPDIR should create files on the encrypted mount.
# Note: bare `mktemp` on macOS ignores TMPDIR (BSD behavior).
# Scripts should use `mktemp -p "$TMPDIR"` for cross-platform correctness.
result=$("$CRYPTMP" sh -c '
    f=$(mktemp -p "$TMPDIR")
    echo "$f"
' 2>/dev/null)
case "$result" in
    /Volumes/cryptmp-*|/tmp/cryptmp-*) ;;
    *) echo "mktemp -p created '$result' — not on encrypted mount"; exit 1 ;;
esac
