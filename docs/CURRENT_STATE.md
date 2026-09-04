# LoM-VI — Current State / Continuity Authority

**Status:** ACTIVE LIVING AUTHORITY  
**Last reconciled:** 2026-09-04 21:58 (+07)  
**Repository:** `Kjndst/LoM-VI`

> Read this file first, then `docs/HANDOFF-2026-09-04-DEV10-TO-PRODUCTION-FONT.md`. New clean live evidence overrides older speculation. Stable channel remains unchanged until production acceptance.

---

## 1. Current stable channel — unchanged

- Core `0.2.0.4`
- Translation `2026.09.03.4`
- Font `2026.09.03.2`

Do not silently replace published stable payloads under the same version.

Development manifest: `channel/manifest-v3-dev.json`.

At this reconciliation:

- Core `0.2.0.4`: available
- Translation `2026.09.03.4`: available
- Font `2026.09.04.1-dev`: `available=false`
- game build target: `2018737`
- planned Font package: `font-2026.09.04.1-build2018737.zip`

Do not set Font available until the prebuilt package passes maintainer-side validation.

---

## 2. Public patcher architecture — LOCKED

Public `LoM-VI.exe` is a **thin patcher/updater**, not a font builder or PAK builder.

Heavy/generated data is prebuilt by the maintainer and published remotely. The public patcher must not:

- embed clone PAK / `inner.cache` / donor font banks;
- build fonts or PAKs on the user machine;
- download/load Oodle or other executable DLL dependencies at runtime.

The patcher does:

- read a small GitHub manifest;
- download versioned packages;
- verify SHA-256;
- extract/apply transactionally;
- expose only user-facing Translation and Font versions.

Core/runtime/font-family/route/Oodle/PAK details stay backend-only.

### Uninstall semantics — LOCKED

> **Gỡ cài đặt is uninstall, not backup restore.**

Uninstall removes/disables effects caused by LoM-VI. It does not promise restoration of an arbitrary pre-install byte state and must not depend on a persistent personal backup.

Unknown route state fails closed and directs the user to official GMZZLauncher Verify/Repair. Same-operation rollback during a failed install/update is still allowed.

---

## 3. Patcher UX authority and current candidate

Visual/interaction authority remains `LoM-VI-v0.2.0-dev.18-B-only-probe`.

Required UX:

- dark/black + gold;
- rounded cards/buttons;
- compact layout and clear hierarchy;
- Translation and Font checkboxes;
- progress bar;
- inline status, no operational MessageBox popups;
- hover/press states;
- automatic game discovery;
- loose manual folder resolution from C7, a parent, or a child folder;
- `GỠ CÀI ĐẶT` disabled when no real LoM-VI effect is detected.

Current candidate:

`LoM-VI-v0.3.0-dev.10-Fixed-UAC-Icon.exe`

SHA-256:

`36892d35242922dae55b0735370507670257e3b82d28de6f661023c5f6193b44`

Latest launch behavior supersedes the older “no Admin at startup” text:

1. double-click;
2. exactly one Windows UAC Yes/No before UI;
3. one elevated patcher process opens;
4. patcher foregrounds/focuses itself;
5. no second `runas`/relaunch prompt.

dev.9 introduced manifest-based elevation/focus but had a Windows side-by-side resource failure. dev.10 rebuilt PE resources, preserved the single-UAC/focus design, and integrated the original gold mystical eye/compass icon.

Owner moved on to Font work after dev.10; no later UX complaint is recorded in this session. dev.10 is current development candidate, not stable.

Earlier heavy UX2 was rejected after Windows reported `virus detected`. Do not ask users to whitelist LoM-VI or disable Defender. The thin-client generations no longer use the embedded-payload/runtime-Oodle architecture.

---

## 4. Font visual design — LOCKED

### UI / Body

**IBM Plex Sans Condensed Medium**

Mapped to:

- `Aleo_Regular.ufont`
- `Aleo_Regular_SDF.ufont`
- `Aleo_Regular_Update.ufont`

### Title

**Spectral SemiBold**

Mapped to:

- `Aleo_Title.ufont`
- `Aleo_Title_SDF.ufont`
- `Aleo_Title_SDF_HeadName.ufont`
- `Aleo_Title_Update.ufont`

Next gate is Body/Regular first. Title follows only after Body live-passes.

---

## 5. Mechanically proven Font method — DO NOT REOPEN

r11-r14 closed the diagnostic question.

Proven conclusions:

- CFF/OTF direct embedding is nonviable;
- TrueType `glyf` is viable;
- CJK codepoints can flow through cmap to accepted original GIDs;
- appended physical GIDs can remain invisible;
- rewriting accepted original GIDs in-place works;
- multiple original GIDs can be reused;
- r14 rendered recognizable real Vietnamese glyph shapes from rewritten accepted original slots.

Production principle:

> **Preserve the game-accepted font structure and original GID envelope/order. Rewrite existing glyphs in-place. Avoid append-GID dependency.**

Do not return to `W`, block, marker, generic appended-GID, or CFF diagnostics unless a new production-specific failure requires it.

---

## 6. LOCKED runtime Font route

Historical labels:

- A = `C7/Saved/kscache/local.cache`
- B = `C7/Content/inner.cache`
- C = active `C7/Saved/kscache/package_*.manifest`

Exact proven recipe:

> **current official C + exact dev.24-patched B + custom dev.24 clone PAK**

A/local.cache stays unchanged. Official C manifest/signature stay unchanged.

Authority archive:

`LoM-VI-BC-Recipe-Capture.zip`

Result: `PASS_CAPTURED_AND_RESTORED`.

Important hashes:

- clean `inner.cache`: `164d16c4835e4536dbdac9ace67bfafd3378f5c872ee7e58451e1f6acab5193e`
- dev24 patched `inner.cache`: `e5c702c11ec55aeebe2d4f1a69dc9eb48b129863eef39af14ccf88ae88c1cdc1`
- `local.cache`: `3435ba0f98e6423e579238f4da73a0d990877444a8fb28ee8034c7f946f67603`
- `package_2018737.manifest`: `60c21eaf5f65cfed3ed2a93f4c07a9a1f572e551c19509bca84c3ea1631779ba`
- signature: `08fd107316378648ef015573500433869260404297f58be2bc84510becb28cbf`

Clone PAK:

`Content/Paks/pakchunk99998-Windows_LVI_STOCK_CLONE_P.pak`

The exact stock clone is already in the capture archive. Do not ask the owner to capture it again.

Do not reopen A+B+C, PAK-only, random Oodle codec/level testing, or hand-appending only a clone path to clean `inner.cache`.

---

## 7. Seven Aleo assets and fixed topology

Assets:

1. `C7/Content/Arts/UI_2/Resource/Font/Aleo_Regular.ufont`
2. `C7/Content/Arts/UI_2/Resource/Font/Aleo_Regular_SDF.ufont`
3. `C7/Content/Arts/UI_2/Resource/Font/Aleo_Title.ufont`
4. `C7/Content/Arts/UI_2/Resource/Font/Aleo_Title_SDF.ufont`
5. `C7/Content/Arts/UI_2/Resource/Font/Aleo_Title_SDF_HeadName.ufont`
6. `C7/Content/Arts/UI_Update/Resource/Font/Aleo_Regular_Update.ufont`
7. `C7/Content/Arts/UI_Update/Resource/Font/Aleo_Title_Update.ufont`

Physical entry offsets:

`0, 5632000, 11268096, 14585856, 17928192, 21241856, 22546432`

Encoded-entry offsets:

`0, 572, 1144, 1512, 1880, 2248, 2388`

Preserve clone filename, seven asset paths, fixed physical/encoded slots, path-hash/full-directory topology, official C and A/local.cache.

---

## 8. BODY v1/v2 failure — cause now understood

Old BODY v1/v2 are discarded.

They used the 3316-glyph diagnostic base instead of the real stock font, which caused most text to disappear while digits remained.

Current production analysis found the actual stock Regular font is much larger:

- `Aleo_Regular`: **29,034 physical glyphs / about 29,000 Unicode mappings**
- `Aleo_Regular_Update`: **7,144 physical glyphs / 7,143 mappings**

Do not use the r2/r14 diagnostic TTF as the production template.

---

## 9. Production transformation — LOCKED

For each original font:

> `Unicode(original) ∩ Unicode(donor)` → rewrite the existing original GID outline with the donor glyph for that same Unicode.

If donor lacks the Unicode, keep the original game glyph unchanged.

Constraints:

- keep original cmap;
- keep original physical glyph count/order;
- no CJK→Latin marker remap;
- no append-GID dependency;
- retain unsupported CJK/symbols from stock;
- native Vietnamese comes from IBM Plex/Spectral at the same Unicode.

Current Body intersection results:

- `Aleo_Regular` → IBM Plex: **277 existing GIDs** selected;
- `Aleo_Regular_SDF` → IBM Plex: **277 existing GIDs** selected;
- `Aleo_Regular_Update` → IBM Plex: **109 existing GIDs** selected.

All four Title assets stay stock for the first Body-only gate.

---

## 10. Current technical blocker / next gate

Naive FontTools full serialization is rejected.

Observed:

- it rebuilds/shifts `glyf/loca` despite only a few hundred changed glyphs;
- roughly 138/139 Oodle blocks change in the large Regular entry;
- several recompressed blocks become larger than their fixed physical slots.

Current implementation direction:

> **table-preserving, in-place SFNT rewrite**

Required:

1. start from exact stock embedded font bytes;
2. preserve original table offsets/sizes whenever possible;
3. rebuild replacement `glyf` inside the original `glyf` table budget;
4. update `loca`;
5. update `hmtx` where intended;
6. update required checksums;
7. preserve `cmap`, glyph count/order and unrelated tables;
8. inject into original UFont wrapper;
9. Oodle-recompress changed PAK blocks;
10. require every block to fit its existing fixed slot;
11. update physical entry metadata/SHA1 correctly;
12. decompress final candidate and byte-validate the intended UFont before live testing.

The stock `Aleo_Regular` `glyf` table has roughly **8.47 MB** available.

PAK fact confirmed during production work:

> physical entry SHA1 corresponds to the compressed block payload, not the raw UFont.

---

## 11. Oodle — corrected architecture

The user's C7 installation does **not** contain `oo2core_*_win64.dll`.

Discarded utility:

`LoM-VI-Original-Font-Source-Capture-v1.exe`

Do not use/revive it.

Production rule:

- user machine: **no Oodle dependency**;
- maintainer environment: Oodle may be used to prebuild the PAK/package.

Temporary maintainer branch:

`build/font-body-oodle`

Current recorded HEAD:

`7b99e188c993de9ceb3c32d8566633414f5f4ee6`

Temporary workflow:

`.github/workflows/tmp-fetch-oodle-linux.yml`

Successful run: `33882824867`  
Artifact: `oodle-linux-9`  
Artifact ID: `9940563552`

**Do not merge this temporary Oodle-fetch workflow to main.** Retire it after the maintainer build no longer needs it.

---

## 12. Live machine state

Do not assume the old “r14 installed” note is still true. Many patcher/install/remove experiments happened later.

Before the first production Body package test:

1. close game;
2. if state is uncertain, use official GMZZLauncher Verify/Repair;
3. launch once and confirm stock text;
4. close game;
5. confirm build `2018737` and expected clean `inner.cache`;
6. then test through the dev thin patcher/package.

Do not stack a new production Font candidate on an unknown experimental state.

---

## 13. Exact next deliverable

Do not redesign patcher UX unless new live evidence requires it. Do not build another marker font.

Smallest unfinished gate:

> **Finish a table-preserving Body-only production clone PAK/package.**

Modify only:

- `Aleo_Regular`
- `Aleo_Regular_SDF`
- `Aleo_Regular_Update`

Donor: IBM Plex Sans Condensed Medium.

Keep all four Title UFonts byte-identical to stock.

Then:

1. validate Oodle block fit + full round-trip off-machine;
2. package clone PAK + route data as `font-2026.09.04.1-build2018737.zip`;
3. calculate SHA-256;
4. publish development package;
5. set Font `available=true` in `channel/manifest-v3-dev.json`;
6. test install through patcher dev.10;
7. visually validate Vietnamese, CJK preservation and UI width/overflow;
8. after Body PASS, repeat for the four Title assets using Spectral SemiBold;
9. after dual-face PASS, consider stable promotion.

---

## 14. Next-session instruction

> **Read `docs/CURRENT_STATE.md` and `docs/HANDOFF-2026-09-04-DEV10-TO-PRODUCTION-FONT.md` as authority. Reconcile current GitHub state first. Treat patcher dev.10 as the current thin-client candidate; stable remains unchanged. Continue the smallest unfinished gate: finish the table-preserving Body-only IBM Plex production font package from the exact stock clone, validate Oodle block fit + round-trip off-machine, then wire the prebuilt package into `manifest-v3-dev.json` for a live test. Do not ask the owner to recapture the clone or find Oodle in C7.**
