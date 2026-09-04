# LoM-VI dev.11 — Native integration / stable gate

Date: 2026-09-05 (+07)
Status: DEV.11 BUILT LOCALLY; LIVE ACCEPTANCE PENDING

## Decisive live evidence before dev.11

- Native bootstrap proof patched exact build-2018737 `pakchunk0-Windows.pak` region at offset `427225161`, length `4660`.
- Clean whole PAK SHA-256: `abbadeeaec029807c6547d7faa9788f38da0099e8ea05ee20ff0167c0f5686d8`.
- Native-patched whole PAK SHA-256: `1712e55db2b9b4b6c8ff86e5a11b7ac56b9602951a08cbdb8c5face2687c6bd1`.
- Native region SHA-256: `c031726986e09358bb18ff8a2b8ee5f0b4e65ce8ae8331eed2d7575c80b7efa9`.
- After the native proof, LoM-VI Translation became active in game. This confirms the missing layer in dev.10 was the native bootstrap route.
- Font `2026.09.05.1-dev` then live-passed: IBM Plex Sans Condensed Medium Body, Spectral SemiBold Title, Vietnamese diacritics, CJK preservation, and representative UI coverage. Owner result: `Tất cả font đã đúng.`

## Required fallback contract

- VI only: `Vietnamese -> original Chinese`.
- VI + English Patch: `Vietnamese -> English -> original Chinese`.

The current LoM-VI `BootstrapFactory` explicitly applies exact Vietnamese IDs on top of the existing module value and avoids competing for `Loader.Overlays`. Therefore an existing English LOMModLoader can remain the underlay while LoM-VI registers later/higher-priority hooks.

## English Patch 2.2.9 interoperability evidence

Pinned upstream data package:
- size `16,783,086`
- SHA-256 `28705ea108d2d46094ad7e7b991e3b4dd0b8db884087e33a09e24741a5004389`

Exact shared native region:
- `payload/bridge/LaunchInstance.native-bridge.padded.oodle`
- 4660 bytes
- SHA-256 `c031726986e09358bb18ff8a2b8ee5f0b4e65ce8ae8331eed2d7575c80b7efa9`

English bridge:
- `Binaries/Win64/lua/Launch/Base/CPDDTranslation.lua`
- SHA-256 `d224604d10be733ac8750b84eaafee20c52027d2d9e48892eb5b0e492156bac4`

English bootstrap v0.4.5 exposes `LOMModLoader.AfterLoad` and loads `Saved/Mods/manifest.lua`. dev.11 must preserve that bootstrap and add only `mods.lom_vi.Init` to the Load list.

## dev.11 implementation target

The dev.11 source is derived from the exact dev.10 source and preserves the dev.10 UI/UAC/icon behavior. Runtime changes:

1. Enforce build 2018737 by exact clean/native pakchunk0 identity.
2. Enforce Font `game_build` before Font apply.
3. On Translation install, establish the exact shared native route transactionally when starting from clean PAK.
4. Do not embed the compatibility asset. When needed, download the pinned upstream English 2.2.9 data archive and verify exact SHA before extracting the shared native region/bridge.
5. Preserve a compatible existing English LOMModLoader bootstrap byte-for-byte.
6. In English-underlay mode, merge `mods.lom_vi.Init` into the existing manifest instead of replacing English modules.
7. Without English underlay, install the existing LoM-VI standalone bootstrap from Core 0.2.0.4 and a standalone LoM-VI manifest.
8. Final Translation success requires: patched native route + compatible CPDD bridge + compatible loader + manifest entry + `lom_vi/Init.lua`.
9. Existing English underlay is preserved during uninstall.
10. No donor font, clone PAK, inner.cache, Oodle runtime, or 4660-byte native compatibility payload is embedded in the EXE.

## Stable gate

Before stable promotion:

- upgrade-in-place live test of dev.11 on the currently known-good integrated state;
- clean/Verify baseline;
- fresh VI-only install through dev.11 -> launch -> Translation + full Font visual PASS;
- uninstall -> LoM-VI effects disabled and Font route clean; Verify/Repair remains the byte-stock route for shared native bootstrap if required;
- English Patch coexistence test -> missing VI text must remain English while VI-covered text stays Vietnamese;
- only then promote stable.

After stable, return to translation coverage/terminology/QC as explicitly requested by the owner.
