# LoM-VI — Thin Patcher Architecture Authority (2026-09-04)

This document supersedes the old backup-dependent uninstall semantics in `docs/PATCHER-PRODUCTION-UX-2026-09-04.md` and records the owner-approved public distribution architecture.

## 1. Product boundary

The public `LoM-VI.exe` is a **thin patcher/updater**, not a font builder or PAK builder.

Heavy/generated data is prebuilt by the maintainer and published as versioned GitHub Release packages. The public patcher must not build Oodle PAK data, transform fonts, or download/load executable DLL dependencies at runtime.

Stable channel remains unchanged until live acceptance.

## 2. Remote data model

The patcher reads a small channel manifest from GitHub. The manifest identifies user-facing versions and build-compatible packages.

User-facing UI exposes only:

- **Bản dịch tiếng Việt** version;
- **Font Việt Hoá** version.

Core/runtime version, donor font names, Oodle details, route details, PAK topology and other implementation details stay backend-only.

Production packages are expected to be prebuilt, for example:

- `translation-<version>.zip`;
- backend Core data as needed;
- `font-<version>-build<game-build>.zip` containing the proven clone PAK and route data for that supported game build.

Every remote package must have an expected SHA-256 in the manifest. Download -> hash verify -> extract/apply. Unsupported or changed game builds fail closed instead of guessing.

## 3. Font package contract

Font data is prebuilt off the user's machine using the mechanically proven production method:

- Regular family -> IBM Plex Sans Condensed Medium;
- Title family -> Spectral SemiBold;
- use each original game font as template;
- preserve its accepted cmap/GID envelope/order;
- for each Unicode codepoint present in both original font and donor, rewrite the original GID outline with the donor outline;
- donor-missing codepoints retain the original game glyph;
- do not append physical GIDs as a production dependency;
- use the exact captured dev24 `inner.cache` route and seven-Aleo clone topology.

The user machine only installs the resulting prebuilt files.

## 4. Uninstall semantics — LOCKED OWNER DECISION

**Uninstall is uninstall, not backup restore.**

`GỠ CÀI ĐẶT` removes or disables effects created by LoM-VI. It does not promise byte-for-byte restoration of the user's arbitrary pre-install state and does not depend on a persistent personal backup.

Expected behavior:

- remove LoM-VI managed Translation/Core files;
- remove the LoM-VI clone PAK;
- remove LoM-VI marker/state;
- remove/disable the LoM-VI route influence using a deterministic supported-build clean state when safe;
- never overwrite an unknown `inner.cache` state blindly;
- if exact official bytes are desired or the current state is unknown, direct the user to the official launcher Verify/Repair.

A short-lived same-operation rollback is still allowed while an install/update is in progress: if an apply step fails, files modified by that *same operation* may be reverted. This transactional safety mechanism is distinct from the product's Uninstall feature.

## 5. AV-friendly public patcher requirements

Prototype UX2 (`f14f79cf66a8b81afd17c34ee11603ff03417fe510b895b0224da6dc82dc0c1b`) was rejected after Windows reported `virus detected`.

Do not ask users to whitelist the patcher or disable Defender.

The next public patcher must:

- remain small; do not embed clone PAK, `inner.cache`, donor font banks or other heavy payloads;
- not download/load an Oodle or other executable DLL at runtime;
- not graft PE resources after build;
- not request Administrator privileges at startup;
- request elevation only if a real write operation requires it;
- use ordinary HTTPS downloads, JSON parsing, SHA-256 verification, ZIP extraction and file operations;
- keep source/build behavior transparent and deterministic.

## 6. UX authority

Use `LoM-VI-v0.2.0-dev.18-B-only-probe` as the visual/interaction reference:

- dark/black + gold;
- compact layout;
- visible hover and press-down feedback;
- game discovery card + `ĐỔI` action;
- Translation card;
- Font card;
- primary install/update/repair action;
- `GỠ CÀI ĐẶT` action;
- launcher version may be shown subtly at bottom-right.

Do not expose backend implementation details.

## 7. Game discovery / loose selection

Try automatic discovery immediately on startup across normal drive letters and common launcher/game layouts.

Manual selection is deliberately loose. The user may point at:

- `C7` itself;
- a parent such as `GMZZLauncher` or `Game`;
- a child such as `C7/Content` or `C7/Content/Paks`.

The patcher resolves the actual C7 root by bounded upward/downward search and validates it using known game structure such as `Content/inner.cache` and the main game PAK.

Do not require a literal `C:\Program Files\GMZZLauncher\Game\C7` path.

## 8. Next deliverable

Build a small Windows GUI thin-client prototype that exercises:

1. dev18-style dark/gold UI;
2. hover/press states;
3. automatic and loose manual C7 discovery;
4. remote development manifest retrieval;
5. SHA-256 package verification/extraction path;
6. LoM-VI effect-removal semantics for uninstall;
7. no embedded heavy production payload and no runtime Oodle dependency.

The production font Release asset may remain unpublished until its prebuilt package passes maintainer-side validation; the thin patcher must represent that as unavailable rather than fabricating a successful install.
