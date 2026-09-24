# Maintenance log

## 2026-09-24 — Add reproducible Godot validation

- **Rationale:** The repository includes headless milestone test suites and a verification script, but no hosted check ran them for pull requests or updates to the default branch. This allowed engine compatibility and gameplay regression failures to reach `main` unnoticed.
- **Files changed:** `.github/workflows/validate.yml` and `.github/maintenance-log.md`.
- **Validation performed:** Confirmed the project and development guide pin Godot 4.6.3; verified the official Linux x86_64 release asset and its published SHA-256 digest; reviewed the workflow for least-privilege permissions, bounded execution, exact action pinning, and use of the existing `scripts/verify_project.sh` entry point. The pull-request run is the authoritative clean-environment validation.
- **Risk level:** Low. This adds validation only and does not change game code, assets, exports, or runtime behavior.
- **Rollback:** Revert this change to remove the hosted check. The existing local verification script remains available.
