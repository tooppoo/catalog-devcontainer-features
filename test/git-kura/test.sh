#!/bin/bash
set -e

FAILED=()

echo_stderr() {
    echo "$@" >&2
}

check() {
    local label="$1"
    shift

    echo
    echo "Testing ${label}"
    if "$@"; then
        echo "Passed"
        return 0
    fi

    echo_stderr "${label} check failed."
    FAILED+=("${label}")
    return 1
}

report_results() {
    if [ ${#FAILED[@]} -ne 0 ]; then
        echo_stderr
        echo_stderr "Failed tests: ${FAILED[*]}"
        exit 1
    fi

    echo
    echo "All passed"
}

check "git-kura is on PATH" command -v git-kura
check "git-kura help works" git-kura -h
check "git subcommand help works" git kura -h

report_results
