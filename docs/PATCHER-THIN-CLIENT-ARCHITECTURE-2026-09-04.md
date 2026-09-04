# LoM-VI — Thin Patcher Architecture Authority (2026-09-04)

This document supersedes the old backup-dependent uninstall semantics in `docs/PATCHER-PRODUCTION-UX-2026-09-04.md` and records the owner-approved public distribution architecture.

**Latest UX/UAC decisions in `docs/CURRENT_STATE.md` and `docs/HANDOFF-2026-09-04-DEV10-TO-PRODUCTION-FONT.md` override earlier prototype notes in this document.**

## 1. Product boundary

The public `LoM-VI.exe` is a **thin patcher/updater**, not a font builder or PAK builder.

Heavy/generated data is prebuilt by the maintainer and published as versioned GitHub packages. The public patcher must not build Oodle PAK data, transform fonts, or download/load executable DLL dependencies at runtime.

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

A short-lived same-operation rollback is still allowed while an install/update is in progress. This transactional safety mechanism is distinct from the product's Uninstall feature.

## 5. AV-friendly public patcher requirements

Prototype UX2 (`f14f79cf66a8b81afd17c34ee11603ff03417fe510b895b0224da6dc82dc0c1b`) was rejected after Windows reported `virus detected`.

Do not ask users to whitelist the patcher or disable Defender.

The public patcher must:

- remain small; do not embed clone PAK, `inner.cache`, donor font banks or other heavy payloads;
- not download/load an Oodle or other executable DLL at runtime;
- use ordinary HTTPS downloads, JSON parsing, SHA-256 verification, ZIP extraction and file operations;
- keep source/build behavior transparent and deterministic.

### Administrator behavior — LATEST OWNER DECISION

The earlier prototype rule “do not request Administrator privileges at startup” is superseded.

The owner explicitly chose:

> request Administrator once before the patcher UI opens, then do not prompt again during that process.

Use a standard Windows application manifest (`requireAdministrator`) rather than self-relaunching with `runas`. Expected behavior is exactly one UAC prompt, then one elevated process that foregrounds/focuses the patcher window.

## 6. UX authority

Use `LoM-VI-v0.2.0-dev.18-B-only-probe` as the visual/interaction reference:

- dark/black + gold;
- compact layout;
- rounded cards/buttons;
- visible hover and press-down feedback;
- game discovery card + `ĐỔI` action;
- Translation card + checkbox;
- Font card + checkbox;
- primary install/update/repair action;
- `GỠ CÀI ĐẶT` action, disabled when no LoM-VI effect exists;
- visible progress bar;
- inline operational status inside the patcher, not MessageBox popups;
- launcher version may be shown subtly at bottom-right.

Do not expose backend implementation details.

Current candidate is dev.10: `LoM-VI-v0.3.0-dev.10-Fixed-UAC-Icon.exe`, SHA-256 `36892d35242922dae55b0735370507670257e3b82d28de6f661023c5f6193b44`.

## 7. Game discovery / loose selection

Try automatic discovery immediately on startup across normal drive letters and common launcher/game layouts.

Manual selection is deliberately loose. The user may point at:

- `C7` itself;
- a parent such as `GMZZLauncher` or `Game`;
- a child such as `C7/Content` or `C7/Content/Paks`.

The patcher resolves the actual C7 root by bounded upward/downward search and validates it using known game structure such as `Content/inner.cache` and the main game PAK.

Do not require a literal `C:\Program Files\GMZZLauncher\Game\C7` path.

## 8. Current next deliverable

Patcher UX is not the active gate unless new live evidence shows a regression.

The active gate is the prebuilt production Font package:

1. finish table-preserving Body-only IBM Plex transformation on the exact stock game fonts;
2. validate fixed-slot Oodle recompression and full round-trip in the maintainer environment;
3. package `font-2026.09.04.1-build2018737.zip`;
4. publish it to the development channel;
5. set Font `available=true` in `channel/manifest-v3-dev.json` only after validation;
6. live-test through patcher dev.10;
7. then repeat for Spectral Title and only later consider stable promotion.
