#!/bin/sh
# The mount point should be mode 0700 (owner only)
result=$("$CRYPTMP" sh -c '
    case "$(uname -s)" in
        Darwin) stat -f "%Lp" "$TMPDIR" ;;
        *)      stat -c "%a" "$TMPDIR" ;;
    esac
' 2>/dev/null)
result=$(echo "$result" | tr -d '[:space:]')
[ "$result" = "700" ] || {
    echo "Expected permissions 700, got '$result'"
    exit 1
}
