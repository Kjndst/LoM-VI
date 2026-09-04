# LoM-VI — Current State / Continuity Authority

**Status:** ACTIVE LIVING AUTHORITY  
**Last reconciled:** 2026-09-04 (+07), after FULL-BOLD r8 live proof  
**Repository:** `Kjndst/LoM-VI`

> Read this file before continuing development. New clean live evidence overrides older handoffs/speculation. After every decisive live result, update this file before starting the next major Font gate.

---

## 1. Product goal

LoM-VI is a Vietnamese localization for **Lord of Mysteries** with three separately updateable components:

- **Translation** — Vietnamese wording/data.
- **Core** — loader/runtime/hook/coverage.
- **Font** — game font payload and integration.

End-user goal: a lightweight patcher/updater. Normal Translation/Core/Font updates should come from GitHub without requiring a new launcher EXE unless launcher behavior itself changes.

Translation quality goals remain:

- terminology familiar to Vietnamese readers of *Quỷ Bí Chi Chủ*;
- avoid machine-like wording;
- prefer short UI-safe wording where long translations break layout;
- skill/item descriptions must remain precise enough for competitive build decisions;
- Font must not be coupled to Translation/Core release cadence.

Current stable channel (`channel/manifest.json`) remains unchanged:

- Core `0.2.0.4`
- Translation `2026.09.03.4`
- Font `2026.09.03.2`

**Do not silently replace a published stable payload under the same version. Font experiments remain outside stable.**

---

## 2. LOCKED HISTORY — current authority

### 2.1 Translation/Core lane is historically proven

LoM-VI has previously applied Vietnamese translation visibly in-game. Some regions can remain Chinese because of untranslated data, incomplete runtime coverage, or a source/display path not reached by the current Translation/Core implementation.

> **Do not confuse Font work with “Vietnamese localization has never worked”.**

### 2.2 Proven runtime Font route

Historical labels:

- **A** = `C7/Saved/kscache/local.cache`
- **B** = `C7/Content/inner.cache`
- **C** = active `C7/Saved/kscache/package_*.manifest`

The exact clean recipe capture proved that on the current build:

- A/local.cache stays unchanged;
- official C manifest stays byte-identical;
- signature stays unchanged;
- B/inner.cache changes using the exact dev.24 transformation;
- the custom dev.24 clone PAK is installed.

Operationally the proven route is:

> **current official C + exact dev.24-patched B + custom clone PAK**

Do not return to A+B+C, direct-PAK-only testing, or hand-appending a path to clean `inner.cache` unless a premise materially changes.

### 2.3 Alternate Font rendering is now positively proven

The previous statement “LoM-VI has never positively rendered an alternate font” is **RETRACTED by newer live evidence**.

Live FULL-BOLD controls produced unmistakable non-stock pixels:

- **r2** — version digits on the loading screen rendered in an unmistakably heavy replacement face while most other text disappeared;
- **r8** — multiple CJK/text positions visibly rendered deliberate diagnostic `W` glyphs, including prefixes adjacent to the version digits.

Therefore:

> **Alternate Font takeover/rendering is positively proven on the current game build.**

This proves route + wrapper/container + TrueType rasterization can work. It does **not** yet mean production-ready full Vietnamese/CJK coverage is solved.

### 2.4 MVH remains structural reference only

Mê Việt Hóa is useful for structure, packaging, compression and historical installer behavior, but it is not a current runtime oracle. Direct `_P.pak` tests on the current build did not provide positive MVH takeover proof.

---

## 3. Current blocker

The blocker is no longer “can a different Font render?”. That is solved.

Current blocker:

> **Build a real-glyph Vietnamese + CJK TrueType subset that stays inside the accepted cmap/glyph/runtime envelope demonstrated by r8.**

The next live gate is **r9 — REAL-CJK SAFE SUBSET**.

---

## 4. Exact recipe capture authority

Artifact:

`LoM-VI-BC-Recipe-Capture.exe`

SHA-256:

`318a79c21d1ac30757b87d6dd4e00bf10979b655effe16ea6e4a19b6e8a00626`

Returned ZIP:

`LoM-VI-BC-Recipe-Capture.zip`

Result:

`PASS_CAPTURED_AND_RESTORED`

### Before / restored state

`inner.cache`
- size `17,256,852`
- SHA-256 `164d16c4835e4536dbdac9ace67bfafd3378f5c872ee7e58451e1f6acab5193e`

`local.cache`
- size `3,019,363`
- SHA-256 `3435ba0f98e6423e579238f4da73a0d990877444a8fb28ee8034c7f946f67603`

`package_2018737.manifest`
- size `35,217,770`
- SHA-256 `60c21eaf5f65cfed3ed2a93f4c07a9a1f572e551c19509bca84c3ea1631779ba`

`signature.txt`
- SHA-256 `08fd107316378648ef015573500433869260404297f58be2bc84510becb28cbf`

### After exact dev.24-r4

`inner.cache`
- size `17,256,905`
- SHA-256 `e5c702c11ec55aeebe2d4f1a69dc9eb48b129863eef39af14ccf88ae88c1cdc1`

`local.cache`, package manifest and signature are unchanged.

Clone PAK:

`Content/Paks/pakchunk99998-Windows_LVI_STOCK_CLONE_P.pak`

- size `25,867,666`

Important structural finding: the `inner.cache` change is **not** merely the +53-byte clone path append. A larger aligned route/index region also changes. Reuse the exact captured dev.24 transformation.

---

## 5. Captured clone PAK template authority

Exact dev.24 clone contains seven Font entries:

1. `C7/Content/Arts/UI_2/Resource/Font/Aleo_Regular.ufont`
2. `C7/Content/Arts/UI_2/Resource/Font/Aleo_Regular_SDF.ufont`
3. `C7/Content/Arts/UI_2/Resource/Font/Aleo_Title.ufont`
4. `C7/Content/Arts/UI_2/Resource/Font/Aleo_Title_SDF.ufont`
5. `C7/Content/Arts/UI_2/Resource/Font/Aleo_Title_SDF_HeadName.ufont`
6. `C7/Content/Arts/UI_Update/Resource/Font/Aleo_Regular_Update.ufont`
7. `C7/Content/Arts/UI_Update/Resource/Font/Aleo_Title_Update.ufont`

Known physical entry offsets:

- Regular `0`
- Regular_SDF `5,632,000`
- Title `11,268,096`
- Title_SDF `14,585,856`
- Title_SDF_HeadName `17,928,192`
- Regular_Update `21,241,856`
- Title_Update `22,546,432`

Known encoded-entry offsets:

`0, 572, 1144, 1512, 1880, 2248, 2388`

Current experimental discipline is to preserve clone filename, all seven asset paths, fixed physical slots, encoded-entry slots, path-hash/full-directory topology, official C and A/local.cache. Only the Font payload/header and required encoded entry fields may change.

---

## 6. FULL-BOLD live sequence — decisive results

### r1 — full Noto CJK Bold

Installer failed closed before runtime mutation because `Aleo_Regular_Update` compressed data did not fit the fixed physical slot.

Interpretation: build constraint only; no runtime conclusion.

### r2 — compact Black TrueType positive control

- TrueType `glyf` payload;
- all seven Aleo assets replaced with the same diagnostic face;
- exact dev.24 route/template retained.

Live result:

- most title/loading text disappeared;
- loading version `1.2018737.2097705` visibly rendered in a dramatically heavier replacement face.

**First positive alternate-font render proof.**

### r3 — CJK+VI CFF/OTF attempt

Live result: all text disappeared, including version digits.

Interpretation: CFF/OTF path was rejected or otherwise failed; do not use it as the production direction.

### r4 — TTF/glyf CJK+VI canary

Live result:

- version digits returned;
- a few special/replacement characters appeared.

Interpretation: return to TTF/glyf was decisive. TTF/glyf is the supported direction.

### r5 — all-CJK many-codepoints → one `W` glyph

Live result: visible text disappeared, but text layout/line height remained — an invisible glyph/layout state rather than the earlier fully absent layout.

### r6 — reduced GB2312 cmap, still many-codepoints → one `W`

Live result: same invisible glyph/layout state.

Interpretation: failure is not explained solely by the huge ~31k r5 cmap.

### r7 — unique physical glyph IDs

Live result: no meaningful change from r6; still invisible glyph/layout state.

Interpretation: one-glyph aliasing is not the primary blocker.

### r8 — CMAP4095 threshold control — **POSITIVE PASS**

Construction:

- same r2 TrueType/glyf base;
- `3316` physical glyphs;
- exactly `4095` Unicode cmap mappings;
- r2's original `2840` mappings unchanged;
- `1255` additional codepoints deliberately mapped to `W`.

Live result:

- version digits rendered again;
- many deliberate `W` glyphs visibly appeared at CJK/text positions, including strings immediately adjacent to the version number.

This is broad positive proof that:

1. the dev.24 route/template is valid for alternate Font rendering;
2. TTF/glyf rasterization is valid;
3. CJK-range codepoints can flow through the runtime cmap path;
4. the r5/r6/r7 failures are strongly associated with Font/cmap/glyph complexity above the r8-safe shape, not with route failure.

Do **not** claim `4095` is a mathematically exact hard maximum yet. It is the current proven-safe control point; `~10k` mappings is a proven failure point under the tested constructions.

---

## 7. Current live machine state

At the time of this authority update:

> **r8 is installed and is the current positive live checkpoint.**

Do not stack r9 on top of r8.

Before r9 live test:

1. close the game;
2. run the r8 EXE a second time;
3. require exact rollback success to the pre-r8 state;
4. only then run r9 once;
5. launch the game and capture loading + main/login UI.

If rollback refuses or reports a hash/precondition mismatch, stop and preserve evidence; do not manually delete caches.

---

## 8. r9 — REAL-CJK SAFE SUBSET candidate

r9 is built but **not live-tested yet**.

Goal: keep r8's known-good mapping budget and replace the deliberate `W` aliases with real heavy CJK outlines, changing the smallest possible variable.

Construction:

- base: exact r2 diagnostic TrueType/glyf font;
- r8 cmap codepoint set retained **exactly**: `4095` mappings;
- original r2 `2840` mappings retained unchanged;
- the exact `1255` codepoints added by r8 are retained;
- instead of mapping those 1255 codepoints to `W`, each receives its own real glyph outline;
- source outlines: **Noto Sans CJK SC Bold**;
- source CFF outlines are converted to quadratic TrueType `glyf` outlines at `1000 UPEM`;
- total glyph count: `4571`;
- raw TTF size: `771,032` bytes;
- all tested glyphs such as `诡秘之主`, `欢迎回来`, `切换账号`, `游戏`, `设置`, `版本` have non-empty real outlines;
- exact r8 installer/route/inner.cache/Oodle/7-Aleo/fixed-slot logic retained.

Font SHA-256:

`624fa0c0e5c7728d4ad6c0691e749cdb868ad5b1b8c005ef2d4eb9c897c619a8`

Fixed embedded Font slot:

- offset `5,630,592`
- length `1,591,424`
- padded-slot SHA-256 `15e580ab0099d1dd6933b69a5c179bb61e0a47e4ac25b96f3c6d59e0389b5e3b`

Candidate EXE:

`LoM-VI-Full-Bold-Visual-Takeover-Control-r9-REAL-CJK-SAFE.exe`

EXE SHA-256:

`f5763867b0ae6edf11e277c4018f6524589859e400de1bb3f8507c21b88ba1da`

Binary diff against r8 is restricted to:

- the 64-byte fixed-slot SHA self-check;
- the same-length diagnostic label;
- the fixed embedded Font slot.

No stable-channel file is modified.

### r9 decision table

- **Real Chinese glyphs + version digits render** → real CJK path is proven within r8-safe cmap shape; proceed to production subset planning and Vietnamese visual validation.
- **Version renders but some CJK is missing** → inspect only the missing codepoint set/coverage; route remains closed as solved.
- **All text returns to invisible-layout state** → r8-safe mapping count alone is insufficient; binary-search glyph-count/outline complexity while preserving the exact 4095 mapping set.
- **Asset disappears without retained layout** → treat as a stronger Font rejection and compare r8↔r9 Font tables; do not reopen route/Oodle diagnostics.

---

## 9. Resolved conclusions / do not repeat

- PAK-only is not a demonstrated current Font takeover solution.
- A/local.cache is not required by the captured working recipe.
- Do not hand-append only the clone path to `inner.cache`.
- Do not randomize Kraken/Mermaid/Leviathan/compression levels.
- Official Oodle 2.9.10 is not inherently incompatible.
- Missing text alone is not positive proof.
- Stock clone PASS is not alternate-font proof.
- **Alternate-font proof now exists via r2 and especially r8.**
- TTF/glyf is the current viable Font direction; CFF/OTF is not.
- Many-codepoints→one-glyph aliasing was tested and is not the main explanation.
- Unique physical glyph IDs alone did not cure the high-complexity failure.
- `4095` mappings is a live-proven safe control; `~10k` mappings failed in tested variants.
- Do not modify the stable channel while Font work remains experimental.

---

## 10. Recovery

If experimental state becomes ambiguous:

1. prefer the experiment EXE's exact transactional rollback when its own preconditions still match;
2. otherwise quarantine known LoM-VI experimental custom PAKs;
3. run official GMZZLauncher Verify/Repair;
4. launch once;
5. confirm stock small/legal/version text visibly renders;
6. only then begin another clean gate.

Do not delete arbitrary caches by guesswork.

---

## 11. Next-session instruction

Begin with:

> Read `docs/CURRENT_STATE.md` as authority. Reconcile current GitHub `main` and stable manifest. Treat r8 as the first broad positive Font takeover proof. Do not reopen route/Oodle diagnostics. Current live state is r8 installed unless newer owner evidence says otherwise. The smallest unfinished gate is r9 REAL-CJK SAFE SUBSET: rollback r8 exactly, install r9, and report real CJK / version / Vietnamese surfaces separately.
