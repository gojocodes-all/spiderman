#!/usr/bin/env bash
set -euo pipefail

: "${MOCK_GODOT_LOG:?MOCK_GODOT_LOG must identify the call log}"

printf '%s|%s\n' "${AV_TEST_SUITE:-none}" "$*" >>"$MOCK_GODOT_LOG"

if [[ "${1:-}" == "--version" ]]; then
	printf '%s\n' "${MOCK_GODOT_VERSION:-4.6.3.stable.official.test}"
	exit "${MOCK_GODOT_VERSION_STATUS:-0}"
fi

if [[ " $* " == *" --editor "* ]]; then
	printf '[MOCK] project import\n'
	exit "${MOCK_GODOT_IMPORT_STATUS:-0}"
fi

case "${AV_TEST_SUITE:-}" in
	m1)
		if [[ "${MOCK_GODOT_M1_MARKER:-1}" == "1" ]]; then
			printf '[SMOKE] PASS milestone=1\n'
		else
			printf '[MOCK] milestone 1 completed without a marker\n'
		fi
		exit "${MOCK_GODOT_M1_STATUS:-0}"
		;;
	m2)
		printf '[SMOKE] PASS milestone=2\n'
		exit "${MOCK_GODOT_M2_STATUS:-0}"
		;;
	*)
		printf '[MOCK] unexpected invocation: %s\n' "$*" >&2
		exit 64
		;;
esac
