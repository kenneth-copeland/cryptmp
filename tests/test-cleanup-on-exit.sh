#!/bin/sh
# After cryptmp exits, the volume/mount should be gone or empty.
# macOS: the volume is fully detached (directory gone)
# Linux: the tmpfs is unmounted; the empty mountpoint dir may remain in /tmp
vol_path=$("$CRYPTMP" sh -c 'echo "$TMPDIR"' 2>/dev/null)
[ -n "$vol_path" ] || { echo "No TMPDIR returned"; exit 1; }

if [ -d "$vol_path" ]; then
    contents=$(ls -A "$vol_path" 2>/dev/null)
    if [ -n "$contents" ]; then
        echo "Volume $vol_path still has contents after exit: $contents"
        exit 1
    fi
    rmdir "$vol_path" 2>/dev/null || true
fi
