# LoM-VI Error Codes

Stable user-facing error codes for the LoM-VI patcher.

## Format

`LVI-<AREA>-<NNN>`

Areas:
- `NET` — network/update channel
- `INT` — payload integrity/signature/hash
- `GAME` — game discovery/runtime state
- `CORE` — Việt hoá runtime/loader
- `DATA` — translation package
- `FONT` — Font Việt Hoá
- `APPLY` — elevated apply/rollback
- `STATE` — local patcher state/cache

## Initial catalog

- `LVI-INT-001` — downloaded payload SHA-256 does not match the channel manifest. Installation is blocked before game files are modified.
- `LVI-INT-002` — downloaded payload size does not match the channel manifest.
- `LVI-NET-001` — update manifest cannot be reached and no usable cache exists.
- `LVI-NET-002` — component download returned an unexpected HTTP status.
- `LVI-GAME-001` — C7 game root could not be located or validated.
- `LVI-GAME-002` — game is running; patching requires the game to be closed.
- `LVI-CORE-001` — current loader/runtime shape cannot be safely repaired automatically.
- `LVI-DATA-001` — translation package requires a component/version not present in the channel.
- `LVI-FONT-001` — local VN Font source candidate is missing or its verified hash does not match.
- `LVI-APPLY-001` — elevated apply failed; rollback should be attempted/preserved.
- `LVI-STATE-001` — patcher local state or plan is invalid/corrupt.

## UI rule

The dialog should show a short Vietnamese explanation and the stable code, for example:

`Không thể xác minh gói cập nhật. Vui lòng thử lại sau. (LVI-INT-001)`

Detailed hashes, paths, HTTP diagnostics and stack/context belong in the local diagnostic log, not in the main user-facing dialog.
