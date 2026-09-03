# LoM-VI Error Codes

Canonical error-code catalog for the LoM-VI launcher/patcher.

The launcher shows a short Vietnamese explanation plus a stable code. Technical details are written locally to:

`%LOCALAPPDATA%\LoM-VI\logs\LoM-VI.log`

The local log is JSON Lines, rotates at 2 MiB, and keeps one previous file as `LoM-VI.log.1`.

## Format

`LVI-<AREA>-<NNN>`

Areas:
- `NET` — network/update channel
- `INT` — payload integrity/hash/size/archive
- `GAME` — game discovery/runtime state/build
- `CORE` — Việt hoá runtime/loader
- `DATA` — translation package/dependencies
- `FONT` — Font Việt Hoá
- `APPLY` — elevated apply/rollback
- `STATE` — local patcher state/cache/plan
- `SYS` — unexpected internal failure

## Catalog

- `LVI-NET-001` — update manifest unavailable and no usable cache exists.
- `LVI-NET-002` — manifest/component server returned an unexpected HTTP status.
- `LVI-NET-003` — component transfer failed or could not be started.
- `LVI-INT-001` — downloaded or planned payload SHA-256 does not match the manifest.
- `LVI-INT-002` — payload size does not match the manifest/HTTP metadata.
- `LVI-INT-003` — payload is structurally invalid, corrupt, or outside accepted safety bounds.
- `LVI-GAME-001` — C7 game root cannot be located or validated.
- `LVI-GAME-002` — game is running while a mutation was requested.
- `LVI-GAME-003` — current game build is not approved for a build-bound component.
- `LVI-CORE-001` — current loader/runtime shape cannot be repaired safely/automatically.
- `LVI-DATA-001` — translation package requires a missing component/version.
- `LVI-FONT-001` — Font Việt Hoá payload is unavailable, invalid, or fails verification/integration.
- `LVI-APPLY-001` — elevated apply/rollback/integration failed.
- `LVI-STATE-001` — local state, install plan, or cache metadata is invalid/corrupt.
- `LVI-SYS-001` — unexpected internal error not yet assigned a more specific code.

## UI rule

User-facing dialogs must not expose full SHA-256 hashes, filesystem internals, HTTP traces, or stack/context. Example:

`Không thể xác minh gói cập nhật. Vui lòng thử lại sau. (LVI-INT-001)`

The corresponding technical details belong in the local diagnostic log.
