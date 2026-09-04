# LoM-VI — Production Patcher UX Authority (2026-09-04)

Owner changed priority from Font-only production work to the integrated production patcher.

## UI reference

Use `LoM-VI-v0.2.0-dev.18-B-only-probe` as the visual/interaction reference, not the light `0.3.0 Production Prototype` UI.

Required direction:

- dark / black UI with gold accents, visually close to dev.18;
- clear hover and press-down feedback on buttons;
- compact UI, no backend implementation detail exposed;
- show only the user-facing **Translation version** and **Font version**;
- do **not** show Core version, donor font names, Font architecture, route details, Oodle details, or other backend implementation information.

## Game discovery / selection

The patcher must try automatic discovery on startup.

- search common layouts on normal game drives (C:, D:, E:, etc.);
- recognize GMZZLauncher / Game / C7 common layouts;
- manual folder selection must be loose: user may select C7 itself, a parent such as GMZZLauncher/Game, or a child folder inside the game;
- patcher resolves the actual C7 root by validating `Content/inner.cache` and `Content/Paks/pakchunk0-Windows_P.pak`;
- do not require the literal path `C:\Program Files\GMZZLauncher\Game\C7`.

## Install / repair / remove behavior

- keep install transactional;
- preserve exact pre-install backup;
- post-apply hash verification remains mandatory;
- Remove stays available when the installation reports `Cần sửa chữa`;
- if installed files drifted, Remove may proceed only when the saved backup is verified clean and current `inner.cache` is a known LoM-VI dev24 or official clean state;
- unknown `inner.cache` state must fail closed and instruct official Verify/Repair instead of deleting blindly.

## Font production architecture

Unchanged from `docs/CURRENT_STATE.md`:

- Regular family -> IBM Plex Sans Condensed Medium;
- Title family -> Spectral SemiBold;
- preserve original game cmap / GID envelope;
- replace outlines only for same-Unicode intersection where donor has the codepoint;
- donor-missing codepoints keep original game glyph;
- no append-GID dependency;
- use exact captured dev24 `inner.cache` route and seven-Aleo clone PAK topology.

## Prototype UX2

Built locally as `LoM-VI-v0.3.0-Production-Prototype-UX2.exe`.

SHA-256:

`f14f79cf66a8b81afd17c34ee11603ff03417fe510b895b0224da6dc82dc0c1b`

Stable channel remains unchanged pending live acceptance.
