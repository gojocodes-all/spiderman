#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT_BIN="${GODOT_BIN:-godot}"
DEFAULT_OUTPUT="$PROJECT_ROOT/build/android/aerial-vanguard-m2-debug.apk"
OUTPUT_PATH="${1:-$DEFAULT_OUTPUT}"

if ! command -v "$GODOT_BIN" >/dev/null 2>&1; then
	printf 'Godot executable not found: %s\n' "$GODOT_BIN" >&2
	printf 'Set GODOT_BIN to the Godot 4.6.3 executable.\n' >&2
	exit 2
fi

if [[ "$OUTPUT_PATH" != /* ]]; then
	OUTPUT_PATH="$PROJECT_ROOT/$OUTPUT_PATH"
fi

mkdir -p "$(dirname "$OUTPUT_PATH")"

"$GODOT_BIN" --headless --editor --path "$PROJECT_ROOT" --quit
"$GODOT_BIN" --headless --path "$PROJECT_ROOT" \
	--export-debug 'Android Debug' "$OUTPUT_PATH"

printf '[BUILD] Created %s\n' "$OUTPUT_PATH"
