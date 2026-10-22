#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT_BIN="${GODOT_BIN:-godot}"
DEFAULT_OUTPUT="$PROJECT_ROOT/build/android/aerial-vanguard-m2-debug.apk"
OUTPUT_PATH="${1:-$DEFAULT_OUTPUT}"
source "$PROJECT_ROOT/scripts/lib/godot-toolchain.sh"

require_pinned_godot "$GODOT_BIN"

if [[ "$OUTPUT_PATH" != /* ]]; then
	OUTPUT_PATH="$PROJECT_ROOT/$OUTPUT_PATH"
fi

mkdir -p "$(dirname "$OUTPUT_PATH")"

printf '[BUILD] Using Godot %s.\n' "$GODOT_VERSION_OUTPUT"
"$GODOT_BIN" --headless --editor --path "$PROJECT_ROOT" --quit
"$GODOT_BIN" --headless --path "$PROJECT_ROOT" \
	--export-debug 'Android Debug' "$OUTPUT_PATH"

printf '[BUILD] Created %s\n' "$OUTPUT_PATH"
