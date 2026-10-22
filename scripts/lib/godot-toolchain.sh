#!/usr/bin/env bash

readonly PINNED_GODOT_VERSION="4.6.3"
GODOT_VERSION_OUTPUT=""

require_pinned_godot() {
	local godot_bin="$1"
	local detected_version

	if ! command -v "$godot_bin" >/dev/null 2>&1; then
		printf 'Godot executable not found: %s\n' "$godot_bin" >&2
		printf 'Set GODOT_BIN to the Godot %s executable.\n' "$PINNED_GODOT_VERSION" >&2
		return 2
	fi

	if ! detected_version="$("$godot_bin" --version 2>&1)"; then
		printf 'Unable to read the Godot version from: %s\n' "$godot_bin" >&2
		return 2
	fi

	case "$detected_version" in
		"$PINNED_GODOT_VERSION"|"$PINNED_GODOT_VERSION".*) ;;
		*)
			printf 'Unsupported Godot version: %s\n' "$detected_version" >&2
			printf 'Install Godot %s or set GODOT_BIN to that executable.\n' "$PINNED_GODOT_VERSION" >&2
			return 2
			;;
	esac

	GODOT_VERSION_OUTPUT="$detected_version"
}
