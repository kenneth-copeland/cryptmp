#!/bin/sh
# Run all test scripts in this directory.
# Each test exits 0 on success, non-zero on failure.

set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CRYPTMP="${CRYPTMP:-${SCRIPT_DIR}/../cryptmp}"
export CRYPTMP

passed=0
failed=0
skipped=0

for test_script in "$SCRIPT_DIR"/test-*.sh; do
    [ -f "$test_script" ] || continue
    name=$(basename "$test_script" .sh)
    printf "%-45s " "$name"

    output=$("$test_script" 2>&1)
    rc=$?

    if [ $rc -eq 0 ]; then
        echo "PASS"
        passed=$((passed + 1))
    elif [ $rc -eq 77 ]; then
        echo "SKIP"
        skipped=$((skipped + 1))
    else
        echo "FAIL"
        echo "$output" | sed 's/^/  /'
        failed=$((failed + 1))
    fi
done

echo ""
echo "Results: $passed passed, $failed failed, $skipped skipped"
[ "$failed" -eq 0 ]
