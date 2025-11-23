#!/bin/bash

#
# bitz test suite runner
#
# This script runs all bitz tests and reports results.
# Each test file is a standalone script that can also be run individually.
#
# Usage:
#   ./run_tests.sh           # Run all tests
#   ./run_tests.sh -v        # Verbose mode (show all output)
#   ./run_tests.sh -q        # Quiet mode (only show failures)
#   ./run_tests.sh <test>    # Run specific test file
#
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed
#

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BITZ="$SCRIPT_DIR/../bitz.py"
VERBOSE=0
QUIET=0
SPECIFIC_TEST=""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -v|--verbose)
            VERBOSE=1
            shift
            ;;
        -q|--quiet)
            QUIET=1
            shift
            ;;
        *)
            SPECIFIC_TEST="$1"
            shift
            ;;
    esac
done

# Counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test result tracking
declare -a FAILED_TESTS

#
# run_test: Execute a single test and check result
#
# Arguments:
#   $1 - Test name/description
#   $2 - Command to run
#   $3 - Expected output (substring match)
#   $4 - (optional) "exact" for exact match, "regex" for regex match
#
run_test() {
    local name="$1"
    local cmd="$2"
    local expected="$3"
    local match_type="${4:-substring}"

    TESTS_RUN=$((TESTS_RUN + 1))

    # Run the command and capture output
    local output
    local exit_code=0
    output=$(eval "$cmd" 2>&1) || exit_code=$?

    # Check the result
    local passed=0
    case "$match_type" in
        exact)
            if [[ "$output" == "$expected" ]]; then
                passed=1
            fi
            ;;
        regex)
            if [[ "$output" =~ $expected ]]; then
                passed=1
            fi
            ;;
        substring|*)
            if [[ "$output" == *"$expected"* ]]; then
                passed=1
            fi
            ;;
    esac

    if [[ $passed -eq 1 ]]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        if [[ $QUIET -eq 0 ]]; then
            echo -e "${GREEN}PASS${NC}: $name"
        fi
        if [[ $VERBOSE -eq 1 ]]; then
            echo "  Command: $cmd"
            echo "  Output: ${output:0:100}..."
        fi
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        FAILED_TESTS+=("$name")
        echo -e "${RED}FAIL${NC}: $name"
        echo "  Command: $cmd"
        echo "  Expected: $expected"
        echo "  Got: ${output:0:200}"
    fi
}

#
# run_test_exit_code: Check that a command exits with expected code
#
run_test_exit_code() {
    local name="$1"
    local cmd="$2"
    local expected_code="$3"

    TESTS_RUN=$((TESTS_RUN + 1))

    local exit_code=0
    eval "$cmd" >/dev/null 2>&1 || exit_code=$?

    if [[ $exit_code -eq $expected_code ]]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        if [[ $QUIET -eq 0 ]]; then
            echo -e "${GREEN}PASS${NC}: $name"
        fi
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        FAILED_TESTS+=("$name")
        echo -e "${RED}FAIL${NC}: $name"
        echo "  Command: $cmd"
        echo "  Expected exit code: $expected_code"
        echo "  Got exit code: $exit_code"
    fi
}

#
# section: Print a section header
#
section() {
    if [[ $QUIET -eq 0 ]]; then
        echo ""
        echo -e "${CYAN}=== $1 ===${NC}"
        echo ""
    fi
}

# Export for use in test scripts
export BITZ
export -f run_test
export -f run_test_exit_code
export -f section
export VERBOSE
export QUIET
export RED GREEN YELLOW CYAN NC

# Run tests
echo -e "${YELLOW}bitz test suite${NC}"
echo "==============="

if [[ -n "$SPECIFIC_TEST" ]]; then
    # Run specific test
    if [[ -f "$SCRIPT_DIR/$SPECIFIC_TEST" ]]; then
        source "$SCRIPT_DIR/$SPECIFIC_TEST"
    elif [[ -f "$SCRIPT_DIR/test_${SPECIFIC_TEST}.sh" ]]; then
        source "$SCRIPT_DIR/test_${SPECIFIC_TEST}.sh"
    else
        echo "Test not found: $SPECIFIC_TEST"
        exit 1
    fi
else
    # Run all test files in order
    for test_file in "$SCRIPT_DIR"/test_*.sh; do
        if [[ -f "$test_file" ]]; then
            source "$test_file"
        fi
    done
fi

# Print summary
echo ""
echo "==============="
echo -e "Tests run: ${CYAN}$TESTS_RUN${NC}"
echo -e "Passed:    ${GREEN}$TESTS_PASSED${NC}"
echo -e "Failed:    ${RED}$TESTS_FAILED${NC}"

if [[ $TESTS_FAILED -gt 0 ]]; then
    echo ""
    echo -e "${RED}Failed tests:${NC}"
    for test in "${FAILED_TESTS[@]}"; do
        echo "  - $test"
    done
    exit 1
else
    echo ""
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
fi
