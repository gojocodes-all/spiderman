# Maintenance log

## 2026-10-08 — Make project verification self-contained

- **Rationale:** The documented verification command could fail on a clean clone
  because Godot's generated class metadata did not exist until the editor import
  ran. Hosted CI compensated with a separate import step, so local and hosted
  validation had different entry-point contracts. The three documented shell
  commands also lacked executable file modes after cloning.
- **Files changed:** `scripts/verify_project.sh`, executable modes for
  `scripts/build_android_debug.sh` and `scripts/verify_apk.sh`,
  `test/verify-project-script.test.sh`, `test/fixtures/mock-godot.sh`,
  `.github/workflows/validate.yml`, `README.md`, `DEVELOPMENT.md`, and
  `.github/maintenance-log.md`.
- **Validation performed:** Added dependency-free shell regression coverage for
  the pinned-version gate, clean-clone import ordering, import failure handling,
  and missing suite markers. Ran shell syntax checks, the wrapper tests, the
  complete Milestone 1 and Milestone 2 Godot suites, and the hosted workflow.
- **Risk level:** Low. Runtime game code, assets, tuning, exports, and Android
  packaging are unchanged; only the developer verification path is affected.
- **Rollback:** Revert the pull request's squash commit to restore the separate
  CI import step and the previous local wrapper behavior.

## 2026-09-29 — Clear touch input when the app loses focus

- **Rationale:** Android interruptions can remove application focus without
  delivering the final touch or button-release events. Movement, camera touch
  IDs, sprint, or queued actions could consequently remain active when the
  player returned to the game.
- **Files changed:** `game/scripts/ui/touch_input_overlay.gd`,
  `game/scripts/tests/milestone_1_test_runner.gd`, and
  `.github/maintenance-log.md`.
- **Validation performed:** Extended the existing Milestone 1 headless suite to
  simulate active move/look touches, held sprint, queued jump and BURST input,
  followed by application focus loss. The test verifies that every touch state
  is released. Also ran the complete Milestone 1 and Milestone 2 verification
  suites and checked the final diff.
- **Risk level:** Low. The reset runs only when the application loses focus,
  pauses, or the overlay exits; ordinary touch handling and gameplay tuning are
  unchanged.
- **Rollback:** Revert the pull request's squash commit to restore the previous
  interruption behavior.

## 2026-09-24 — Add reproducible Godot validation

- **Rationale:** The repository includes headless milestone test suites and a verification script, but no hosted check ran them for pull requests or updates to the default branch. A clean clone also needs a headless editor import to generate Godot's global-class metadata before the suites can load.
- **Files changed:** `.github/workflows/validate.yml` and `.github/maintenance-log.md`.
- **Validation performed:** Confirmed the project and development guide pin Godot 4.6.3; verified the official Linux x86_64 release asset and its published SHA-256 digest; reproduced the clean-clone metadata failure; ran the headless import locally; passed both milestone suites locally; and passed the complete pull-request workflow on Ubuntu 24.04. The workflow was also reviewed for read-only permissions, bounded execution, exact action pinning, and use of the existing `scripts/verify_project.sh` entry point.
- **Risk level:** Low. This adds validation only and does not change game code, assets, exports, or runtime behavior.
- **Rollback:** Revert this change to remove the hosted check. The existing local verification script remains available.
