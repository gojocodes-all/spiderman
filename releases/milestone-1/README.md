# Milestone 1 APK

`aerial-vanguard-relay-m1-debug.apk` is the preserved core third-person movement checkpoint for Aerial Vanguard: Relay.

- Debug build; sideload testing only
- Package `com.gojocodes.aerialvanguard`
- Version `0.1.0-m1` / code 2
- Size 27,808,805 bytes
- SHA-256 `73653e3e92ac759c019b2d8ab34643827e6881044b28a220af3d6a529bc1f58b`
- Target/compile API 36; minimum API 24
- `arm64-v8a` only; landscape
- APK Signature Scheme v2 and v3
- 16 KB ZIP alignment and `0x4000` native LOAD alignment verified
- Not run on a physical Android device in the build workspace

The user later reported that M1 loaded on a physical Android device, the implemented work was visibly present, and the milestone passed. This is limited user-reported physical validation; no detailed action matrix, phone/OS details, or performance data were supplied.

The [Milestone 1 GitHub release](https://github.com/gojocodes-all/spiderman/releases/tag/milestone-1) currently preserves the source checkpoint and release notes but has no attached APK. The binary is also not tracked in this directory; only its verification record and [`SHA256SUMS.txt`](SHA256SUMS.txt) remain here. To publish the verified local artifact, attach `aerial-vanguard-relay-m1-debug.apk` to that release with a file-capable client, then verify the uploaded file against the checksum.

See [`docs/M1_ACCEPTANCE.md`](../../docs/M1_ACCEPTANCE.md) for the full automated/package evidence and explicit limits.
