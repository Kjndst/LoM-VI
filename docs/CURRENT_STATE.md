# LoM-VI — Current State / Continuity Authority

**Status:** ACTIVE LIVING AUTHORITY  
**Last reconciled:** 2026-09-05 00:26 (+07)  
**Repository:** `Kjndst/LoM-VI`

> Read this file first, then `docs/FONT-BODY-BUILD-SEAL-2026-09-04.md` and `docs/HANDOFF-2026-09-04-DEV10-TO-PRODUCTION-FONT.md`. New clean live evidence overrides older speculation. Stable channel remains unchanged until production acceptance.

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
- Font `2026.09.04.1-dev`: `available=true`
- game build target: `2018737`
- published Font package: `channel/font-2026.09.04.1-build2018737.zip`
- package size: `47,643,492` bytes
- package SHA-256: `4e363da26fc09eb59e41e92abb5ee3f2e05aa9fdc96922fb993025a1d381a4a2`
- binary publication commit: `6bdcb1f50c2dd433e6d77c15413cf3af72741827`
- dev availability commit: `cce80971be571b3b4e4c9fac5e66e6fbed241a43`

The publication workflow downloaded the temporary source, required the exact size and SHA-256 above, required `unzip -t` to pass, reconciled current `main`, rechecked the staged manifest contract, and only then committed the binary. Git tree metadata confirms the published path and exact size. The development manifest now points to the GitHub copy and is enabled for the controlled live test.

Stable remains untouched.

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

Owner moved on to Font work after dev.10; no later UX complaint is recorded. dev.10 remains the current development candidate, not stable.

Known follow-up discovered during Body package contract review: dev.10 reads the Font `game_build` manifest field but does not yet enforce that field during Font apply. Do not redesign UX for the current controlled build-2018737 test, but do not call dev.10 fully production-safe across unknown future game builds until that guard exists.

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

Current gate is Body live acceptance. Title follows only after Body live-passes.

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

Do not reopen A+B+C, PAK-only, random Oodle codec testing, or hand-appending only a clone path to clean `inner.cache`.

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

Production analysis found the actual stock Regular font is much larger:

- `Aleo_Regular`: **29,034 physical glyphs / 29,000 Unicode mappings**
- `Aleo_Regular_Update`: **7,144 physical glyphs / 7,143 mappings**

Do not use the r2/r14 diagnostic TTF as the production template.

---

## 9. Production transformation — LOCKED AND NOW IMPLEMENTED FOR BODY

For each original font:

> `Unicode(original) ∩ Unicode(donor)` → rewrite the existing original GID representation with the donor glyph for that same Unicode.

If donor lacks the Unicode, keep the original game glyph unchanged.

Constraints:

- keep original cmap;
- keep original physical glyph count/order;
- no CJK→Latin marker remap;
- no append-GID dependency;
- retain unsupported CJK/symbols from stock;
- native Vietnamese comes from IBM Plex/Spectral at the same Unicode.

Sealed Body intersection:

- `Aleo_Regular` → IBM Plex: **277 existing GIDs**
- `Aleo_Regular_SDF` → IBM Plex: **277 existing GIDs**
- `Aleo_Regular_Update` → IBM Plex: **109 existing GIDs**

All four Title assets remain stock for this Body-only candidate.

The implemented serializer is table-preserving/in-place rather than a naive whole-font re-save. It preserves the stock SFNT envelope, cmap, glyph count/order and unrelated tables while rebuilding only the required `glyf/loca/hmtx` representation inside the original table budget and recomputing required checksums.

Detailed immutable build record:

`docs/FONT-BODY-BUILD-SEAL-2026-09-04.md`

---

## 10. Body production maintainer gate — PASS; live gate still open

The previous blocker was physical Oodle slot fit after table-preserving SFNT construction. That blocker is now closed for the sealed candidate.

### Sealed ZIP

`font-2026.09.04.1-build2018737.zip`

- size: `47,643,492` bytes
- SHA-256: `4e363da26fc09eb59e41e92abb5ee3f2e05aa9fdc96922fb993025a1d381a4a2`
- published path: `channel/font-2026.09.04.1-build2018737.zip`
- Git blob: `d09a7915136c26efbf07702e20300224d61edb84`
- publication workflow: PASS
- development availability: ENABLED

### Sealed candidate PAK

`pakchunk99998-Windows_LVI_STOCK_CLONE_P.pak`

- size: `25,867,666` bytes — identical to stock-clone size
- SHA-256: `ef86be95b380eaeb4cf021ea6145ef024f2f671d7c34f90877b7103340499633`
- strict physical diff allowlist: PASS

### Maintainer validation

Result:

`PASS_BODY_PAK_MAINTAINER_VALIDATION`

Validated:

- only Body entries 0/1/5 semantically change;
- Title entries 2/3/4/6 round-trip byte-exact stock;
- physical entry offsets unchanged;
- compressed block ranges/total slot sizes unchanged;
- encoded index/footer byte-identical;
- fresh changed blocks all fit existing slots;
- full padded-slot Oodle decode with CRC checking PASS;
- physical entry SHA1 recomputed over full compressed-slot payload;
- all seven entries round-trip to intended raw UFonts;
- dev.10 package install/uninstall contract simulation PASS.

Final changed Body blocks:

- Regular: blocks `0,2,3,4,5`
- Regular_SDF: blocks `0,2,3,4,5`
- Regular_Update: blocks `0,28,29`

Most changed blocks use Kraken. Regular block 3 and Regular_SDF block 3 use official Oodle Leviathan and pass full-slot CRC round-trip off-machine. Their acceptance by C7 is therefore explicitly part of the upcoming live test rather than assumed.

**Do not translate this maintainer PASS into “this exact IBM candidate already renders in game.”** Route/container and existing-GID mechanics are live-proven; this exact package still needs C7 live acceptance.

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

The branch/workflow is maintainer-only and must not be merged into stable/public runtime architecture. Retire it after the build dependency is no longer needed.

---

## 12. Live machine state

Do not assume any old r14/dev30 experimental state is still active.

Before the first sealed Body package test:

1. close game;
2. if state is uncertain, use official GMZZLauncher Verify/Repair;
3. launch once and confirm stock text;
4. close game;
5. confirm game build is `2018737` and clean `inner.cache` is `164d16c4835e4536dbdac9ace67bfafd3378f5c872ee7e58451e1f6acab5193e`;
6. then install through dev.10 development channel.

Do not stack the sealed candidate on an unknown experimental state.

---

## 13. Exact next deliverable

Do not redesign patcher UX and do not reopen marker/font-topology experiments.

Publication and dev-channel enablement are complete. Smallest unfinished gate is now:

> **Perform controlled live C7 acceptance of the sealed Body package through patcher dev.10 on exact game build 2018737.**

Exact order:

1. establish a known-clean build-2018737 local baseline;
2. confirm stock text renders before applying LoM-VI;
3. install Font via dev.10 development channel;
4. confirm the patcher downloads/applies `font-2026.09.04.1-build2018737.zip` without error;
5. launch C7;
6. visually validate small/body text, Vietnamese diacritics, CJK preservation, punctuation/symbol preservation, width/overflow and absence of missing/invisible text;
7. specifically watch for any failure suggesting C7 rejection of the two Leviathan-compressed changed blocks;
8. test `GỠ CÀI ĐẶT` and confirm clone removal + clean `inner.cache` restoration;
9. record Body live PASS or exact failure evidence;
10. only after Body live PASS begin the four Title assets using Spectral SemiBold.

Do not promote to stable yet.

---

## 14. Next-session instruction

> **Read `docs/CURRENT_STATE.md`, `docs/FONT-BODY-BUILD-SEAL-2026-09-04.md`, and `docs/HANDOFF-2026-09-04-DEV10-TO-PRODUCTION-FONT.md` as authority. Reconcile current GitHub state first. Patcher dev.10 remains the thin-client candidate; stable remains unchanged. The exact Body-only IBM Plex package is sealed, maintainer-validated, published on `main`, and enabled only in `manifest-v3-dev.json`. Continue the smallest gate: establish a clean build-2018737 baseline and perform live Body acceptance through dev.10. Do not recapture the clone, search C7 for Oodle, redesign UX, begin Spectral Title, or promote stable before Body live PASS.**
