#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT_BIN="${GODOT_BIN:-godot}"

if ! command -v "$GODOT_BIN" >/dev/null 2>&1; then
	printf 'Godot executable not found: %s\n' "$GODOT_BIN" >&2
	printf 'Set GODOT_BIN to the Godot 4.6.3 executable.\n' >&2
	exit 2
fi

set +e
SMOKE_OUTPUT="$(AV_RUN_SMOKE_TESTS=1 "$GODOT_BIN" --headless --path "$PROJECT_ROOT" 2>&1)"
SMOKE_STATUS=$?
set -e

printf '%s\n' "$SMOKE_OUTPUT"

if [[ $SMOKE_STATUS -ne 0 ]]; then
	printf '[VERIFY] Godot exited with status %d\n' "$SMOKE_STATUS" >&2
	exit "$SMOKE_STATUS"
fi

if ! grep -Fq '[SMOKE] PASS' <<<"$SMOKE_OUTPUT"; then
	printf '[VERIFY] Missing smoke-test PASS marker.\n' >&2
	exit 1
fi

printf '[VERIFY] Project smoke test passed.\n'
