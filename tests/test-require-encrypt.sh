#!/bin/sh
# --require-encrypt / -e should work when encryption is available.
# On macOS, encryption is always available (APFS).
# On Linux without gocryptfs, it should fail.
case "$(uname -s)" in
    Darwin)
        # macOS always has encryption — should succeed
        result=$("$CRYPTMP" -e sh -c 'echo "$TMPDIR"' 2>/dev/null)
        case "$result" in
            /Volumes/cryptmp-*) ;;
            *) echo "-e failed on macOS: TMPDIR='$result'"; exit 1 ;;
        esac
        ;;
    Linux)
        if command -v gocryptfs >/dev/null 2>&1; then
            # gocryptfs available — should succeed
            result=$("$CRYPTMP" -e sh -c 'echo "$TMPDIR"' 2>/dev/null)
            case "$result" in
                /tmp/cryptmp-*) ;;
                *) echo "-e failed with gocryptfs: TMPDIR='$result'"; exit 1 ;;
            esac
        else
            # no gocryptfs — should fail
            output=$("$CRYPTMP" -e sh -c 'echo hello' 2>&1)
            rc=$?
            [ $rc -ne 0 ] || {
                echo "-e should have failed without gocryptfs but exited 0"
                exit 1
            }
            echo "$output" | grep -q "gocryptfs" || {
                echo "Error message should mention gocryptfs"
                exit 1
            }
        fi
        ;;
esac
