#!/bin/sh
# -n flag should create a working unencrypted RAM disk
result=$("$CRYPTMP" -n sh -c 'echo "$TMPDIR"' 2>/dev/null)
case "$result" in
    /Volumes/cryptmp-*|/tmp/cryptmp-*) ;;
    *) echo "TMPDIR='$result' — -n flag may have failed"; exit 1 ;;
esac

# Verify files work on it
data=$("$CRYPTMP" -n sh -c '
    echo "test data" > "$TMPDIR/test.txt"
    cat "$TMPDIR/test.txt"
' 2>/dev/null)
[ "$data" = "test data" ] || {
    echo "File read/write failed with -n flag"
    exit 1
}
