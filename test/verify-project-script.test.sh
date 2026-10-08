#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERIFY_SCRIPT="$PROJECT_ROOT/scripts/verify_project.sh"
MOCK_GODOT="$PROJECT_ROOT/test/fixtures/mock-godot.sh"
TEST_TMP="$(mktemp -d)"
MOCK_GODOT_LOG="$TEST_TMP/godot-calls.log"
trap 'rm -rf -- "$TEST_TMP"' EXIT

fail() {
	printf '[TEST] FAIL %s\n' "$1" >&2
	exit 1
}

assert_contains() {
	local value="$1"
	local expected="$2"
	local context="$3"
	grep -Fq -- "$expected" <<<"$value" || fail "$context: missing '$expected'"
}

assert_not_contains() {
	local value="$1"
	local unexpected="$2"
	local context="$3"
	if grep -Fq -- "$unexpected" <<<"$value"; then
		fail "$context: unexpectedly found '$unexpected'"
	fi
}

run_verifier() {
	GODOT_BIN="$MOCK_GODOT" \
		MOCK_GODOT_LOG="$MOCK_GODOT_LOG" \
		"$VERIFY_SCRIPT"
}

test_clean_clone_sequence() {
	: >"$MOCK_GODOT_LOG"
	local output
	output="$(run_verifier 2>&1)" || fail "clean-clone verification should pass"

	assert_contains "$output" "[VERIFY] Importing project metadata with Godot 4.6.3" "clean-clone output"
	assert_contains "$output" "Milestone 1 regression and Milestone 2 parkour suites passed" "clean-clone output"

	mapfile -t calls <"$MOCK_GODOT_LOG"
	[[ ${#calls[@]} -eq 4 ]] || fail "expected four Godot calls, found ${#calls[@]}"
	[[ "${calls[0]}" == "none|--version" ]] || fail "version check must run first"
	[[ "${calls[1]}" == "none|--headless --editor --quit --path $PROJECT_ROOT" ]] || fail "project import must run second"
	[[ "${calls[2]}" == "m1|--headless --path $PROJECT_ROOT" ]] || fail "Milestone 1 must run after import"
	[[ "${calls[3]}" == "m2|--headless --path $PROJECT_ROOT" ]] || fail "Milestone 2 must run last"
}

test_rejects_wrong_version() {
	: >"$MOCK_GODOT_LOG"
	local output status
	set +e
	output="$(MOCK_GODOT_VERSION="4.5.1.stable" run_verifier 2>&1)"
	status=$?
	set -e

	[[ $status -eq 2 ]] || fail "wrong Godot version should exit 2, got $status"
	assert_contains "$output" "Unsupported Godot version: 4.5.1.stable" "version rejection"
	assert_not_contains "$(<"$MOCK_GODOT_LOG")" "--headless" "version rejection calls"
}

test_import_failure_stops_suites() {
	: >"$MOCK_GODOT_LOG"
	local output status calls
	set +e
	output="$(MOCK_GODOT_IMPORT_STATUS="17" run_verifier 2>&1)"
	status=$?
	set -e

	[[ $status -eq 17 ]] || fail "import failure should preserve status 17, got $status"
	assert_contains "$output" "project import exited with status 17" "import failure"
	calls="$(<"$MOCK_GODOT_LOG")"
	assert_not_contains "$calls" "m1|" "import failure calls"
	assert_not_contains "$calls" "m2|" "import failure calls"
}

test_missing_marker_fails() {
	: >"$MOCK_GODOT_LOG"
	local output status calls
	set +e
	output="$(MOCK_GODOT_M1_MARKER="0" run_verifier 2>&1)"
	status=$?
	set -e

	[[ $status -eq 1 ]] || fail "missing marker should exit 1, got $status"
	assert_contains "$output" "Missing m1 PASS marker" "missing marker"
	calls="$(<"$MOCK_GODOT_LOG")"
	assert_contains "$calls" "m1|--headless --path $PROJECT_ROOT" "missing marker calls"
	assert_not_contains "$calls" "m2|" "missing marker calls"
}

test_clean_clone_sequence
test_rejects_wrong_version
test_import_failure_stops_suites
test_missing_marker_fails

printf '[TEST] PASS verify-project wrapper (4 cases)\n'
