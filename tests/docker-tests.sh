#!/bin/sh
# Run the test suite inside each Linux variant.
# Usage: ./tests/docker-tests.sh [distro...]
# If no distros specified, runs all Dockerfiles in tests/docker/

set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
DOCKER_DIR="$SCRIPT_DIR/docker"

# Collect distros to test
distros=""
if [ $# -gt 0 ]; then
    distros="$*"
else
    for df in "$DOCKER_DIR"/Dockerfile.*; do
        [ -f "$df" ] || continue
        distros="$distros ${df##*.}"
    done
fi

passed=0
failed=0

for distro in $distros; do
    dockerfile="$DOCKER_DIR/Dockerfile.$distro"
    if [ ! -f "$dockerfile" ]; then
        echo "No Dockerfile for '$distro' at $dockerfile"
        failed=$((failed + 1))
        continue
    fi

    tag="cryptmp-test-$distro"
    printf "\n=== %s ===\n" "$distro"

    build_output=$(docker build -t "$tag" -f "$dockerfile" "$PROJECT_DIR" 2>&1)
    if [ $? -ne 0 ]; then
        echo "BUILD FAILED for $distro"
        echo "$build_output" | tail -3 | sed 's/^/  /'
        failed=$((failed + 1))
        continue
    fi

    if docker run --rm --cap-add SYS_ADMIN "$tag" 2>&1; then
        passed=$((passed + 1))
    else
        failed=$((failed + 1))
    fi
done

echo ""
echo "Docker tests: $passed distros passed, $failed distros failed"
[ "$failed" -eq 0 ]
