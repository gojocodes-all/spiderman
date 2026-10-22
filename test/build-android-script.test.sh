#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_SCRIPT="$PROJECT_ROOT/scripts/build_android_debug.sh"
MOCK_GODOT="$PROJECT_ROOT/test/fixtures/mock-godot.sh"
TEST_TMP="$(mktemp -d)"
MOCK_GODOT_LOG="$TEST_TMP/godot-calls.log"
OUTPUT_PATH="$TEST_TMP/build/aerial-vanguard-test.apk"
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

run_builder() {
	GODOT_BIN="$MOCK_GODOT" \
		MOCK_GODOT_LOG="$MOCK_GODOT_LOG" \
		"$BUILD_SCRIPT" "$OUTPUT_PATH"
}

test_build_sequence() {
	: >"$MOCK_GODOT_LOG"
	local output
	output="$(run_builder 2>&1)" || fail "supported Godot build should pass"

	assert_contains "$output" "[BUILD] Using Godot 4.6.3" "build output"
	assert_contains "$output" "[BUILD] Created $OUTPUT_PATH" "build output"

	mapfile -t calls <"$MOCK_GODOT_LOG"
	[[ ${#calls[@]} -eq 3 ]] || fail "expected three Godot calls, found ${#calls[@]}"
	[[ "${calls[0]}" == "none|--version" ]] || fail "version check must run first"
	[[ "${calls[1]}" == "none|--headless --editor --path $PROJECT_ROOT --quit" ]] || fail "project import must run second"
	[[ "${calls[2]}" == "none|--headless --path $PROJECT_ROOT --export-debug Android Debug $OUTPUT_PATH" ]] || fail "Android export must run last"
}

test_rejects_wrong_version_before_writing() {
	: >"$MOCK_GODOT_LOG"
	local output status calls
	rm -rf -- "$(dirname "$OUTPUT_PATH")"
	set +e
	output="$(MOCK_GODOT_VERSION="4.5.1.stable" run_builder 2>&1)"
	status=$?
	set -e

	[[ $status -eq 2 ]] || fail "wrong Godot version should exit 2, got $status"
	assert_contains "$output" "Unsupported Godot version: 4.5.1.stable" "version rejection"
	calls="$(<"$MOCK_GODOT_LOG")"
	assert_not_contains "$calls" "--editor" "version rejection calls"
	assert_not_contains "$calls" "--export-debug" "version rejection calls"
	[[ ! -e "$(dirname "$OUTPUT_PATH")" ]] || fail "wrong version must not create the output directory"
}

test_import_failure_stops_export() {
	: >"$MOCK_GODOT_LOG"
	local output status calls
	set +e
	output="$(MOCK_GODOT_IMPORT_STATUS="17" run_builder 2>&1)"
	status=$?
	set -e

	[[ $status -eq 17 ]] || fail "import failure should preserve status 17, got $status"
	calls="$(<"$MOCK_GODOT_LOG")"
	assert_contains "$calls" "--editor" "import failure calls"
	assert_not_contains "$calls" "--export-debug" "import failure calls"
	assert_not_contains "$output" "[BUILD] Created" "import failure output"
}

test_export_failure_does_not_report_success() {
	: >"$MOCK_GODOT_LOG"
	local output status
	set +e
	output="$(MOCK_GODOT_EXPORT_STATUS="23" run_builder 2>&1)"
	status=$?
	set -e

	[[ $status -eq 23 ]] || fail "export failure should preserve status 23, got $status"
	assert_not_contains "$output" "[BUILD] Created" "export failure output"
}

test_build_sequence
test_rejects_wrong_version_before_writing
test_import_failure_stops_export
test_export_failure_does_not_report_success

printf '[TEST] PASS Android build wrapper (4 cases)\n'
