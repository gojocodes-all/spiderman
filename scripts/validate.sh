#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT_BIN="${GODOT_BIN:-godot}"

printf '[VALIDATE] Checking shell syntax.\n'
shell_count=0
while IFS= read -r -d '' shell_script; do
	bash -n "$shell_script"
	shell_count=$((shell_count + 1))
done < <(
	find "$PROJECT_ROOT/scripts" "$PROJECT_ROOT/test" \
		-type f -name '*.sh' -print0 | sort -z
)

if [[ $shell_count -eq 0 ]]; then
	printf '[VALIDATE] No shell scripts were found.\n' >&2
	exit 1
fi
printf '[VALIDATE] Shell syntax passed for %d scripts.\n' "$shell_count"

printf '[VALIDATE] Running project-verifier wrapper tests.\n'
"$PROJECT_ROOT/test/verify-project-script.test.sh"

printf '[VALIDATE] Running Android-build wrapper tests.\n'
"$PROJECT_ROOT/test/build-android-script.test.sh"

printf '[VALIDATE] Running real-engine milestone suites.\n'
GODOT_BIN="$GODOT_BIN" "$PROJECT_ROOT/scripts/verify_project.sh"

printf '[VALIDATE] Shell checks, wrapper regressions, and milestone suites passed.\n'
