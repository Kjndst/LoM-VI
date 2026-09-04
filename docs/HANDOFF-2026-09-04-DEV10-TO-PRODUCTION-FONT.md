# LoM-VI — Handoff 2026-09-04 — Patcher dev.10 → Production Font Body

**Status:** READY FOR NEW CHAT CONTINUATION  
**Repository:** `Kjndst/LoM-VI`  
**Primary branch:** `main`  
**Main HEAD before this handoff commit:** `9c335857f9f44d7f2e098f486d9aaae8a7800ba3`  
**Temporary maintainer build branch:** `build/font-body-oodle` @ `7b99e188c993de9ceb3c32d8566633414f5f4ee6`

> New chat: read this file and `docs/CURRENT_STATE.md` first. Reconcile `main`, stable manifest, `channel/manifest-v3-dev.json`, and the temporary build branch before changing anything. Stable channel must remain unchanged until live acceptance.

---

## 1. Stable channel — DO NOT MODIFY YET

Current stable remains:

- Core `0.2.0.4`
- Translation `2026.09.03.4`
- Font `2026.09.03.2`

Production Font and thin patcher work are development-only.

---

## 2. Thin patcher architecture — LOCKED

Public `LoM-VI.exe` is a thin patcher/updater. Heavy/generated data is prebuilt by the maintainer and hosted remotely.

Public patcher must:

- stay small;
- not embed clone PAK / `inner.cache` / donor font banks;
- not build fonts or PAKs on the user machine;
- not download/load Oodle at runtime;
- read a GitHub manifest;
- download versioned prebuilt packages;
- verify SHA-256;
- install/update transactionally;
- expose only user-facing **Bản dịch tiếng Việt** and **Font Việt Hoá** versions.

Development manifest: `channel/manifest-v3-dev.json`.

At handoff:

- Core `0.2.0.4`: available
- Translation `2026.09.03.4`: available
- Font `2026.09.04.1-dev`: `available=false`
- game build: `2018737`
- planned package: `font-2026.09.04.1-build2018737.zip`
- clean `inner.cache` SHA-256: `164d16c4835e4536dbdac9ace67bfafd3378f5c872ee7e58451e1f6acab5193e`
- dev24 patched `inner.cache` SHA-256: `e5c702c11ec55aeebe2d4f1a69dc9eb48b129863eef39af14ccf88ae88c1cdc1`

Do not set Font `available=true` until the prebuilt package passes maintainer-side validation.

---

## 3. Uninstall semantics — LOCKED OWNER DECISION

> **Gỡ cài đặt is uninstall, not backup restore.**

Uninstall removes/disables effects created by LoM-VI. It does not promise byte-for-byte restoration of an arbitrary pre-install state and must not depend on a persistent personal backup.

Expected behavior:

- remove LoM-VI Translation/Core managed files;
- remove LoM-VI clone PAK;
- remove LoM-VI state/marker;
- remove/disable the LoM-VI route using a deterministic known clean state when safe;
- unknown `inner.cache` state fails closed and directs the user to official GMZZLauncher Verify/Repair.

Same-operation rollback during a failed install/update is still allowed and is distinct from Uninstall.

---

## 4. Patcher UX authority and current candidate

Visual authority remains `LoM-VI-v0.2.0-dev.18-B-only-probe`.

Required UX:

- dark/black + gold;
- rounded cards/buttons;
- compact layout;
- clear hierarchy;
- Translation and Font checkboxes;
- progress bar;
- inline status, no operational MessageBox popups;
- hover/press states;
- automatic C7 discovery;
- loose folder resolution from C7, parent, or child folders;
- `GỠ CÀI ĐẶT` disabled when no real LoM-VI effect exists.

### Current candidate: dev.10

Artifact delivered to owner:

`LoM-VI-v0.3.0-dev.10-Fixed-UAC-Icon.exe`

SHA-256:

`36892d35242922dae55b0735370507670257e3b82d28de6f661023c5f6193b44`

Source archive delivered:

`LoM-VI-v0.3.0-dev.10-Source.zip`

dev.10 keeps the thin backend, dev18-style UI lineage, rounded shell, checkboxes, progress bar, inline status, auto/loose C7 resolver, and the original gold mystical eye/compass app icon inspired by the LoM site navigation language.

### Latest UAC/focus decision — supersedes older docs

Older thin-client text said not to request Admin at startup. That is obsolete.

Owner later explicitly chose:

> Ask for Administrator once, before the UI opens, and never ask a second time during that process.

Intended launch:

1. double-click EXE;
2. exactly one UAC Yes/No;
3. Yes;
4. one elevated process opens;
5. patcher foregrounds/focuses itself;
6. no second `runas`/relaunch prompt.

dev.9 introduced manifest-based `requireAdministrator` + focus but had a Windows side-by-side resource/configuration failure. dev.10 rebuilt PE resources to fix SxS while preserving single-UAC + foreground behavior and adding the icon.

The owner moved on to Font work after dev.10; no later UX complaint is recorded in this session. Treat dev.10 as the current development candidate, not a public stable release.

---

## 5. Defender / AV conclusion

The old ~52 MB embedded-payload prototype was rejected after Windows reported `virus detected`. Do not ask users to whitelist LoM-VI or disable Defender.

Thin client removed the suspicious architecture: no embedded 40–50 MB game payload, no runtime Oodle DLL download/load, ordinary HTTPS manifest/package downloads, SHA-256 verification, ZIP extraction and file operations.

Owner reported that the thin-patcher generation stopped being blocked by Defender.

---

## 6. Font design — LOCKED

### UI / Body

**IBM Plex Sans Condensed Medium**

Mapped to:

1. `Aleo_Regular.ufont`
2. `Aleo_Regular_SDF.ufont`
3. `Aleo_Regular_Update.ufont`

### Title

**Spectral SemiBold**

Mapped to:

1. `Aleo_Title.ufont`
2. `Aleo_Title_SDF.ufont`
3. `Aleo_Title_SDF_HeadName.ufont`
4. `Aleo_Title_Update.ufont`

Next gate is Body/Regular first. Title follows only after Body live-passes.

---

## 7. Proven Font runtime route — DO NOT REOPEN

Historical labels:

- A = `C7/Saved/kscache/local.cache`
- B = `C7/Content/inner.cache`
- C = active `C7/Saved/kscache/package_*.manifest`

Exact proven recipe:

> **current official C + exact dev.24-patched B + custom dev.24 clone PAK**

A/local.cache stays unchanged. Official C manifest/signature stay unchanged. Reuse exact captured B transformation; do not hand-append a clone path.

Authority archive already exists:

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

The stock clone needed for production building is already inside the capture archive. Do not ask the owner to capture it again.

---

## 8. Proven Font mechanics — r14 is decisive

Do not return to marker diagnostics by default.

Proven:

- CFF/OTF direct embedding failed;
- TrueType `glyf` is viable;
- CJK codepoints can map to accepted existing GIDs;
- appended physical GIDs can remain invisible;
- accepted original GIDs can be rewritten in-place;
- multiple original GIDs can be reused;
- 5119 mappings were live-proven in the diagnostic construction;
- r14 rendered recognizable real Vietnamese glyph shapes from rewritten accepted original slots.

Production principle:

> Preserve the game-accepted font structure and original GID envelope/order. Rewrite existing glyphs in-place. Avoid append-GID dependency.

---

## 9. BODY v1/v2 failure — cause understood

Old BODY v1/v2 are discarded.

They used the diagnostic 3316-glyph base instead of the real stock game font. Live result: most text disappeared while digits remained.

Current production analysis found the real stock Regular font is much larger:

- `Aleo_Regular`: **29,034 physical glyphs / about 29,000 Unicode mappings**
- `Aleo_Regular_Update`: **7,144 physical glyphs / 7,143 mappings**

Do not use the r2/r14 3316-glyph diagnostic TTF as the production template.

---

## 10. Production transformation — LOCKED

For each original game font:

> `Unicode(original) ∩ Unicode(donor)` → rewrite the existing original GID outline with the donor glyph for the same Unicode.

If the donor lacks the Unicode, retain the stock game glyph unchanged.

Constraints:

- keep original cmap;
- keep original physical glyph count/order;
- no CJK→Latin marker remap;
- no append-GID dependency;
- preserve unsupported CJK/symbols;
- native Vietnamese comes from IBM Plex/Spectral at the same Unicode.

Current Body intersection results recorded from this session:

- `Aleo_Regular` → IBM Plex: **277 existing GIDs** selected;
- `Aleo_Regular_SDF` → IBM Plex: **277 existing GIDs** selected;
- `Aleo_Regular_Update` → IBM Plex: **109 existing GIDs** selected.

All four Title assets remain stock for the first Body-only gate.

---

## 11. Current blocker / exact next technical gate

A naive FontTools full save/re-serialize is not acceptable.

Observed during current production work:

- full serialization rebuilds/shifts `glyf/loca` even though only a few hundred glyphs change;
- roughly 138/139 Oodle blocks change in the large Regular entry;
- several recompressed blocks become larger than their fixed physical slots.

Current implementation direction:

> **table-preserving, in-place SFNT rewrite**

Required construction:

1. start from exact stock embedded font bytes;
2. preserve original SFNT table offsets/sizes whenever possible;
3. rebuild only replacement `glyf` data inside the original `glyf` table budget;
4. update `loca`;
5. update `hmtx` where donor metrics are intentionally adopted;
6. update required checksums;
7. preserve `cmap`, glyph count/order, unrelated tables;
8. inject modified font into original UFont wrapper;
9. Oodle-recompress changed physical PAK blocks;
10. require every block to fit its existing slot;
11. update physical entry metadata/SHA1 correctly;
12. decompress final candidate and byte-validate intended UFont before live testing.

The stock `Aleo_Regular` `glyf` table has roughly **8.47 MB** of room, so repack donor outlines into that existing budget instead of moving later tables.

PAK fact confirmed in this work:

> the SHA1 in the physical PAK entry corresponds to the compressed block payload, not the raw UFont.

---

## 12. Oodle — corrected architecture and temporary branch

Critical correction:

> The user's C7 installation does **not** contain `oo2core_*_win64.dll`.

Discarded tool:

`LoM-VI-Original-Font-Source-Capture-v1.exe`

It failed because it incorrectly assumed C7 contained Oodle. Do not use/revive it.

Production rule:

- user machine: **no Oodle dependency**;
- maintainer build environment: Oodle may be used to prebuild the PAK/package.

Temporary build branch:

`build/font-body-oodle`

HEAD:

`7b99e188c993de9ceb3c32d8566633414f5f4ee6`

Temporary workflow:

`.github/workflows/tmp-fetch-oodle-linux.yml`

Successful run:

`33882824867`

Artifact:

`oodle-linux-9`, artifact ID `9940563552`.

**Do not merge the temporary Oodle-fetch workflow to main.** Retire/delete the branch/workflow after the maintainer build no longer needs it.

---

## 13. Fixed clone topology

Physical entry offsets:

`0, 5632000, 11268096, 14585856, 17928192, 21241856, 22546432`

Encoded-entry offsets:

`0, 572, 1144, 1512, 1880, 2248, 2388`

Preserve clone filename, seven asset paths, fixed physical slots, encoded slots, path-hash/full-directory topology, official C and A/local.cache.

---

## 14. Live machine state — do not assume old r14 state

Many patcher/install/remove experiments happened after the old r14 continuity note.

Before first production Body test:

1. close game;
2. if state is uncertain, use GMZZLauncher Verify/Repair;
3. launch once and confirm stock text;
4. close game;
5. confirm build `2018737` and expected clean `inner.cache`;
6. then test via dev thin patcher/package.

Do not stack a new Font candidate on an unknown experimental state.

---

## 15. Exact next deliverable

Do not redesign the patcher and do not build another marker font.

Smallest unfinished gate:

> **Finish a table-preserving Body-only production clone PAK/package.**

Modify only:

- `Aleo_Regular`
- `Aleo_Regular_SDF`
- `Aleo_Regular_Update`

Donor: IBM Plex Sans Condensed Medium.

Keep all four Title UFonts byte-identical to stock.

Then:

1. validate every Oodle block fits and round-trips;
2. package clone PAK + route data as `font-2026.09.04.1-build2018737.zip`;
3. calculate SHA-256;
4. publish the development package;
5. set Font `available=true` in `channel/manifest-v3-dev.json`;
6. test install through patcher dev.10;
7. visually validate Vietnamese, CJK preservation, width/overflow;
8. only after Body PASS, repeat for the four Title assets using Spectral SemiBold;
9. after dual-face PASS, consider stable promotion.

---

## 16. Do-not-repeat list

Do not:

- modify stable Font yet;
- use the 3316-glyph diagnostic font as stock template;
- append large new GID banks;
- remap CJK to markers for production;
- direct-embed CFF/OTF;
- ask owner to capture the stock clone again;
- assume game has Oodle DLL;
- put Oodle into the public patcher;
- merge the temporary Oodle-fetch workflow to main;
- restore backup-dependent Uninstall semantics;
- expose Core/font-family/Oodle internals in UI;
- reopen A/B/C route experiments;
- hand-append only a PAK path to clean `inner.cache`;
- randomize Oodle codec/levels;
- stack candidates on unknown live state.

---

## 17. New-chat instruction

> **Continue LoM-VI from this handoff. Reconcile current GitHub state first. Treat patcher dev.10 as the current thin-client candidate and do not redesign UX unless a new live issue appears. Stable channel remains unchanged. Continue the smallest unfinished gate: finish the table-preserving Body-only IBM Plex production font package from the exact stock clone, validate Oodle block fit + round-trip off-machine, then wire the prebuilt package into `manifest-v3-dev.json` for a live test. Do not ask me to recapture the clone or find Oodle in C7.**
