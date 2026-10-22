# Maintenance log

## 2026-10-22 — Enforce the pinned engine for Android builds

- **Rationale:** Project verification rejected unsupported Godot versions, but
  the Android build wrapper only checked that an executable existed. A local
  build could therefore import and export the pinned project with a different
  engine despite the repository's documented toolchain contract.
- **Files changed:** `scripts/lib/godot-toolchain.sh` centralizes executable and
  version validation; both project verification and Android builds use it;
  `test/build-android-script.test.sh` and the mock fixture cover build ordering,
  wrong-version rejection, and failure propagation; hosted CI runs both wrapper
  suites; `README.md` and `DEVELOPMENT.md` document the shared gate.
- **Validation performed:** Ran shell syntax checks, the four project-verifier
  wrapper cases, the four Android-build wrapper cases, the complete Godot
  Milestone 1 and Milestone 2 suites, and reviewed the full diff for shell
  safety, CI permissions, Android build compatibility, and repository scope.
- **Risk level:** Low. Gameplay, tuning, scenes, assets, export settings, Android
  metadata, and the supported 4.6.3 build path are unchanged. Builds now stop
  before creating output when the engine is missing, unreadable, or unsupported.
- **Rollback:** Revert this pull request's squash commit to restore the separate
  verifier-only version check and the previous build-wrapper behavior.

## 2026-10-17 — Document the contributor workflow

- **Rationale:** The repository documented its engine, Android toolchain,
  architecture, validation, assets, original-IP boundary, and known issues, but
  contributors had no single workflow connecting those records to change
  preparation and pull-request review.
- **Files changed:** `CONTRIBUTING.md` documents the current milestone scope,
  setup, module boundaries, validation levels, asset and security rules, and
  pull-request checklist; `README.md` links the guide; and
  `.github/maintenance-log.md` records this work.
- **Validation performed:** Cross-checked the guide against `DEVELOPMENT.md`,
  `docs/ARCHITECTURE.md`, `docs/TEST_PLAN.md`, `KNOWN_ISSUES.md`,
  `ASSETS.md`, the three validation scripts, `project.godot`, and the hosted
  workflow; verified every new relative link and command path; reviewed the
  complete documentation diff for accuracy, original-IP guidance, security,
  compatibility, and repository conventions.
- **Risk level:** Low. Documentation only; game code, assets, tuning, tests,
  dependencies, Android configuration, build artifacts, and runtime behavior
  are unchanged.
- **Rollback:** Revert this pull request's squash commit to remove the guide,
  README link, and maintenance entry without affecting the project.

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
