#!/bin/sh
# Files written to TMPDIR should be readable within the session
result=$("$CRYPTMP" sh -c '
    echo "secret data" > "$TMPDIR/test.txt"
    cat "$TMPDIR/test.txt"
' 2>/dev/null)
[ "$result" = "secret data" ] || {
    echo "Expected 'secret data', got '$result'"
    exit 1
}
