# Milestone 2 APK

`aerial-vanguard-relay-m2-debug.apk` is the superhero parkour and wall-traversal checkpoint for Aerial Vanguard: Relay.

- Debug build; sideload testing only
- Package `com.gojocodes.aerialvanguard`
- Version `0.2.0-m2` / code 3
- Size 27,880,145 bytes
- SHA-256 `e10051e2992009b867ba5a49a8410861c5de4c734f38a5c85f91ba377013bd7d`
- Target/compile API 36; minimum API 24
- `arm64-v8a` only; landscape
- APK Signature Scheme v2 and v3
- 16 KB ZIP alignment and `0x4000` native LOAD alignment verified for both shared libraries
- No Android permissions reported by `aapt2 dump permissions`
- Automated M1 regression and M2 traversal suites passed
- Physical-device validation pending user feedback

[Download the APK](aerial-vanguard-relay-m2-debug.apk) or verify it against [`SHA256SUMS.txt`](SHA256SUMS.txt).

See [`docs/M2_ACCEPTANCE.md`](../../docs/M2_ACCEPTANCE.md) for traversal controls, tuning, full evidence, known limits, and the short Android test checklist.
