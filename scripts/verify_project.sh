#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT_BIN="${GODOT_BIN:-godot}"
PINNED_GODOT_VERSION="4.6.3"

if ! command -v "$GODOT_BIN" >/dev/null 2>&1; then
	printf 'Godot executable not found: %s\n' "$GODOT_BIN" >&2
	printf 'Set GODOT_BIN to the Godot 4.6.3 executable.\n' >&2
	exit 2
fi

if ! godot_version="$("$GODOT_BIN" --version 2>&1)"; then
	printf 'Unable to read the Godot version from: %s\n' "$GODOT_BIN" >&2
	exit 2
fi

case "$godot_version" in
	"$PINNED_GODOT_VERSION"|"$PINNED_GODOT_VERSION".*) ;;
	*)
		printf 'Unsupported Godot version: %s\n' "$godot_version" >&2
		printf 'Install Godot %s or set GODOT_BIN to that executable.\n' "$PINNED_GODOT_VERSION" >&2
		exit 2
		;;
esac

import_project() {
	printf '[VERIFY] Importing project metadata with Godot %s.\n' "$godot_version"
	if "$GODOT_BIN" --headless --editor --quit --path "$PROJECT_ROOT"; then
		return 0
	else
		local import_status=$?
		printf '[VERIFY] Godot project import exited with status %d.\n' "$import_status" >&2
		return "$import_status"
	fi
}

run_suite() {
	local suite_name="$1"
	local expected_marker="$2"
	local suite_output
	local suite_status
	set +e
	suite_output="$(AV_TEST_SUITE="$suite_name" "$GODOT_BIN" --headless --path "$PROJECT_ROOT" 2>&1)"
	suite_status=$?
	set -e
	printf '%s\n' "$suite_output"
	if [[ $suite_status -ne 0 ]]; then
		printf '[VERIFY] Godot %s suite exited with status %d\n' "$suite_name" "$suite_status" >&2
		exit "$suite_status"
	fi
	if ! grep -Fq "$expected_marker" <<<"$suite_output"; then
		printf '[VERIFY] Missing %s PASS marker.\n' "$suite_name" >&2
		exit 1
	fi
}

import_project
run_suite m1 '[SMOKE] PASS milestone=1'
run_suite m2 '[SMOKE] PASS milestone=2'
printf '[VERIFY] Milestone 1 regression and Milestone 2 parkour suites passed.\n'
