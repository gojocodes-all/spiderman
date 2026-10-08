#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APK_PATH="${1:-$PROJECT_ROOT/build/android/aerial-vanguard-m2-debug.apk}"

if [[ "$APK_PATH" != /* ]]; then
	APK_PATH="$PROJECT_ROOT/$APK_PATH"
fi

if [[ ! -f "$APK_PATH" ]]; then
	printf 'APK not found: %s\n' "$APK_PATH" >&2
	exit 2
fi

if [[ -z "${ANDROID_SDK_ROOT:-}" ]]; then
	printf 'ANDROID_SDK_ROOT must point to an Android SDK.\n' >&2
	exit 2
fi

BUILD_TOOLS="$(find "$ANDROID_SDK_ROOT/build-tools" -mindepth 1 -maxdepth 1 -type d -print | sort -V | tail -n 1)"
if [[ -z "$BUILD_TOOLS" ]]; then
	printf 'No Android Build Tools installation found.\n' >&2
	exit 2
fi

APKSIGNER="$BUILD_TOOLS/apksigner"
AAPT2="$BUILD_TOOLS/aapt2"
ZIPALIGN="$BUILD_TOOLS/zipalign"
for TOOL in "$APKSIGNER" "$AAPT2" "$ZIPALIGN"; do
	if [[ ! -x "$TOOL" ]]; then
		printf 'Required Android tool is missing: %s\n' "$TOOL" >&2
		exit 2
	fi
done

if ! command -v readelf >/dev/null 2>&1; then
	printf 'Required ELF inspection tool is missing: readelf\n' >&2
	exit 2
fi

"$APKSIGNER" verify --verbose "$APK_PATH"
"$ZIPALIGN" -c -P 16 -v 4 "$APK_PATH"

BADGING="$($AAPT2 dump badging "$APK_PATH" 2>/dev/null)"
printf '%s\n' "$BADGING" | grep -F "package: name='com.gojocodes.aerialvanguard' versionCode='3' versionName='0.2.0-m2'"
printf '%s\n' "$BADGING" | grep -F "minSdkVersion:'24'"
printf '%s\n' "$BADGING" | grep -F "targetSdkVersion:'36'"
printf '%s\n' "$BADGING" | grep -F "native-code: 'arm64-v8a'"

PERMISSIONS="$($AAPT2 dump permissions "$APK_PATH" 2>/dev/null)"
if grep -q '^uses-permission:' <<<"$PERMISSIONS"; then
	printf '[VERIFY] Unexpected Android permission found:\n%s\n' "$PERMISSIONS" >&2
	exit 1
fi

unzip -tq "$APK_PATH"

ELF_TMP_DIR="$(mktemp -d)"
trap 'rm -rf -- "$ELF_TMP_DIR"' EXIT
unzip -q "$APK_PATH" 'lib/arm64-v8a/*.so' -d "$ELF_TMP_DIR"
for ELF_PATH in "$ELF_TMP_DIR"/lib/arm64-v8a/*.so; do
	if ! readelf -lW "$ELF_PATH" | awk -v file="$(basename "$ELF_PATH")" '
		$1 == "LOAD" {
			found = 1
			if ($NF != "0x4000") {
				printf "[VERIFY] %s has LOAD alignment %s, expected 0x4000\n", file, $NF > "/dev/stderr"
				bad = 1
			}
		}
		END { exit (!found || bad) }
	'; then
		exit 1
	fi
	printf '[VERIFY] %s LOAD segments are 0x4000 aligned.\n' "$(basename "$ELF_PATH")"
done

sha256sum "$APK_PATH"
printf '[VERIFY] APK static checks passed.\n'
