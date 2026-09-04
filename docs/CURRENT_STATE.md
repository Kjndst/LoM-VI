# LoM-VI — Current State / Continuity Authority

**Status:** ACTIVE LIVING AUTHORITY  
**Last reconciled:** 2026-09-04 (+07), after FULL-BOLD r10 live result  
**Repository:** `Kjndst/LoM-VI`

> Read this file before continuing development. New clean live evidence overrides older handoffs/speculation. After every decisive live result, update this file before starting the next major Font gate.

---

## 1. Product goal

LoM-VI is a Vietnamese localization for **Lord of Mysteries** with separately updateable Translation / Core / Font components.

Translation goals remain:

- terminology familiar to Vietnamese readers of *Quỷ Bí Chi Chủ*;
- avoid machine-like wording;
- prefer short UI-safe wording where long strings break layout;
- skill/item descriptions must remain precise enough for competitive build decisions.

Font must remain independent from Translation/Core release cadence.

Current stable channel is still unchanged:

- Core `0.2.0.4`
- Translation `2026.09.03.4`
- Font `2026.09.03.2`

**Do not silently replace a published stable payload under the same version. Font experiments remain outside stable.**

---

## 2. Production Font direction — provisional but now strongly supported

Owner design target:

- **one Title face** for headings / large labels / class or character-name style surfaces;
- **one UI/Body face** for small text / skill / item / tooltip / dialogue / buttons;
- all seven Aleo assets may remain separate Unreal assets/wrappers, but should collapse visually to these two actual typefaces;
- both faces should contain **native full Vietnamese** so `ấ / ế / ạ / ộ / ữ ...` do not fall back to a different typeface;
- CJK coverage only needs to cover still-untranslated / required game surfaces rather than the entire Unicode CJK universe if glyph budget is constrained.

Current evidence suggests production should preserve the glyph structure/glyph-ID envelope already accepted by the game and **reuse/replace existing glyph slots**, rather than append large numbers of new physical glyph IDs.

This architecture is not yet production-PASS; r11 is the direct mechanical proof gate for it.

---

## 3. LOCKED runtime Font route

Historical labels:

- **A** = `C7/Saved/kscache/local.cache`
- **B** = `C7/Content/inner.cache`
- **C** = active `C7/Saved/kscache/package_*.manifest`

Exact clean recipe capture proved the current working route:

> **current official C + exact dev.24-patched B + custom dev.24 clone PAK**

In that captured recipe:

- A/local.cache stays unchanged;
- official C manifest stays byte-identical;
- signature stays unchanged;
- B/inner.cache changes by the exact captured dev.24 transformation;
- custom dev.24 clone PAK is installed.

Do not reopen A+B+C, PAK-only, random Oodle codec/level testing, or hand-appending a clone path to clean `inner.cache` unless a premise materially changes.

### Exact recipe authority

Returned artifact: `LoM-VI-BC-Recipe-Capture.zip`  
Capture result: `PASS_CAPTURED_AND_RESTORED`

Before/restored:

- `inner.cache`: size `17,256,852`, SHA-256 `164d16c4835e4536dbdac9ace67bfafd3378f5c872ee7e58451e1f6acab5193e`
- `local.cache`: size `3,019,363`, SHA-256 `3435ba0f98e6423e579238f4da73a0d990877444a8fb28ee8034c7f946f67603`
- `package_2018737.manifest`: size `35,217,770`, SHA-256 `60c21eaf5f65cfed3ed2a93f4c07a9a1f572e551c19509bca84c3ea1631779ba`
- `signature.txt`: SHA-256 `08fd107316378648ef015573500433869260404297f58be2bc84510becb28cbf`

After exact dev.24 route:

- `inner.cache`: size `17,256,905`, SHA-256 `e5c702c11ec55aeebe2d4f1a69dc9eb48b129863eef39af14ccf88ae88c1cdc1`
- A/local.cache, official manifest and signature unchanged.

Clone PAK:

`Content/Paks/pakchunk99998-Windows_LVI_STOCK_CLONE_P.pak`

The `inner.cache` delta is not merely a +53-byte path append; a larger aligned route/index region changes. Always reuse the captured transformation.

---

## 4. Seven captured Aleo assets

1. `C7/Content/Arts/UI_2/Resource/Font/Aleo_Regular.ufont`
2. `C7/Content/Arts/UI_2/Resource/Font/Aleo_Regular_SDF.ufont`
3. `C7/Content/Arts/UI_2/Resource/Font/Aleo_Title.ufont`
4. `C7/Content/Arts/UI_2/Resource/Font/Aleo_Title_SDF.ufont`
5. `C7/Content/Arts/UI_2/Resource/Font/Aleo_Title_SDF_HeadName.ufont`
6. `C7/Content/Arts/UI_Update/Resource/Font/Aleo_Regular_Update.ufont`
7. `C7/Content/Arts/UI_Update/Resource/Font/Aleo_Title_Update.ufont`

Known physical entry offsets:

`0, 5,632,000, 11,268,096, 14,585,856, 17,928,192, 21,241,856, 22,546,432`

Known encoded-entry offsets:

`0, 572, 1144, 1512, 1880, 2248, 2388`

Preserve clone filename, seven asset paths, fixed physical slots, encoded-entry slots, path-hash/full-directory topology, official C and A/local.cache.

---

## 5. FULL-BOLD live sequence — decisive evidence

### r1 — full Noto CJK Bold

Installer failed closed before runtime mutation because `Aleo_Regular_Update` compressed data exceeded its fixed physical slot.

Build constraint only; no runtime conclusion.

### r2 — compact Black TrueType positive control

TrueType `glyf`; all seven Aleo assets changed to the same heavy diagnostic face.

Live:

- most text disappeared;
- loading version `1.2018737.2097705` rendered in an unmistakably heavy replacement face.

**First positive alternate-font raster proof.**

### r3 — CJK+VI CFF/OTF

All text disappeared, including version digits.

**CFF/OTF is not the current viable direction.**

### r4 — TTF/glyf CJK+VI canary

Version digits returned and some replacement/special characters appeared.

**TTF/glyf is the viable direction.**

### r5 / r6 / r7 — large/alias/unique-glyph probes

- r5: very large CJK cmap mapped to one `W` → visible glyphs disappeared, layout remained.
- r6: reduced GB2312 cmap still mapped to one `W` → same invisible-layout state.
- r7: unique physical glyph IDs at high complexity → still invisible-layout state.

These eliminated simple “one glyph aliasing” as the main cause and showed the failure is not explained solely by r5's huge cmap.

### r8 — CMAP4095 — **BROAD POSITIVE PASS**

Construction:

- r2 TrueType/glyf base;
- `3316` physical glyphs;
- exactly `4095` Unicode mappings;
- original r2 `2840` mappings unchanged;
- exact `1255` extra codepoints mapped to the existing proven `W` glyph.

Live:

- version digits rendered;
- many deliberate `W` glyphs visibly rendered at CJK/text positions, including next to version digits.

r8 proves:

1. route/container/TrueType raster path works;
2. CJK-range codepoints flow through cmap;
3. mapping a new codepoint to an **existing accepted glyph ID** works;
4. `4095` is a live-proven safe control point under this construction.

Do not claim 4095 is a universal mathematical maximum.

### r9 — real CJK glyph append — **PARTIAL FAIL / IMPORTANT ISOLATION**

Same exact `4095` mapping set as r8, but the `1255` CJK codepoints received newly appended real Noto CJK glyphs.

- total glyphs `4571`;
- Font SHA-256 `624fa0c0e5c7728d4ad6c0691e749cdb868ad5b1b8c005ef2d4eb9c897c619a8`;
- EXE SHA-256 `f5763867b0ae6edf11e277c4018f6524589859e400de1bb3f8507c21b88ba1da`.

Live:

- version digits still rendered;
- new real CJK glyphs did not render.

Therefore route and mapping budget remained alive; failure moved to new physical glyph construction/identity/table integration.

### r10 — simple newly appended rectangle glyphs — **FAIL / DECISIVE ISOLATION**

Construction:

- same `4095` mappings as r9;
- same `4571` physical glyph count;
- same `1255` newly appended glyph IDs;
- every added CJK glyph replaced by an extremely simple TrueType rectangle;
- no Noto outline complexity remained.

Candidate:

`LoM-VI-Full-Bold-Visual-Takeover-Control-r10-SIMPLE-CJK-GLYPHS.exe`

- Font SHA-256 `34265a6b0b27982d947f79bff845b3ecd1691b98779e3902ed248815996681d3`
- EXE SHA-256 `bac01e0286aece48bb8ecfce28739e2969150cb9a1ba559fd5b1095d97f895ce`

Owner live result:

- installer completed;
- loading version digits rendered normally/heavily;
- **no new rectangle glyphs rendered**;
- main/title UI still lacked those text glyphs.

Interpretation:

> **Outline complexity is eliminated as the cause. Newly appended physical glyph IDs/table integration are the current blocker.**

Strongest comparison:

- r8: same CJK codepoints → existing GID `W` → render;
- r9/r10: same codepoints → newly appended GIDs → invisible;
- even trivial rectangle outlines do not rescue appended GIDs.

Do not spend the next gate debugging Noto conversion or route/Oodle.

---

## 6. Current live machine state

At this update, owner has just live-tested **r10** successfully enough to observe its result.

Treat:

> **r10 as currently installed unless owner reports a rollback/recovery after this point.**

Before r11:

1. close game;
2. run r10 a second time and require exact rollback success;
3. if rollback refuses/hash-mismatches, stop and use official GMZZLauncher Verify/Repair instead;
4. confirm clean stock/full-Chinese small/legal/version text once;
5. only then install r11 once.

Do not reinstall the stable Việt hóa pack during this mechanical gate.

The separate stable pack uninstall/remove failure observed after r9 remains a patcher bug, not part of r11 Font mechanics.

---

## 7. r11 — REUSE / REWRITE ORIGINAL GLYPH — built, not live-tested

Purpose:

> Prove that the game accepts a **modified outline inside an already-existing, already-proven glyph ID**, without adding any new physical glyph IDs.

Construction is intentionally a direct r8 derivative:

- base = exact r8 known-good font shape;
- physical glyph count remains exactly **3316**;
- Unicode mapping count remains exactly **4095**;
- no new glyph IDs appended;
- existing glyph ID `W` remains GID **58**;
- all r8 CJK codepoints that targeted `W` still target that same existing GID;
- only the existing `W` outline is rewritten into one unmistakable large solid rectangle/block;
- W metrics remain `(advance 1015, LSB 22)`;
- rewritten W bbox `(90,60) → (925,780)`;
- route, captured dev.24 `inner.cache`, seven Aleo assets, Oodle path, fixed PAK topology remain unchanged.

r11 Font:

- raw size `530,464` bytes;
- SHA-256 `e4d49565b71ea1741457bf6ccde369d94b39f2b78b9596e78c0022c87e77d261`;
- padded embedded-slot SHA-256 `3e91d5b3b915acea60eb4c8f3f8313613197a442e088c4d98e8ab3247eb6bf99`.

Candidate EXE:

`LoM-VI-Full-Bold-Visual-Takeover-Control-r11-REUSE-ORIGINAL-GLYPH.exe`

EXE SHA-256:

`fd3233efc37d8dbb02a9a487b1d9c6135cb4acc288a2fcc388f41dcb3f0ef01e`

Static validation:

- `numGlyphs = 3316`;
- `cmap mappings = 4095`;
- `W GID = 58`;
- 789 CJK Unified Ideograph codepoints in the current r8 set still map to `W`;
- no new glyph identity exists;
- executable self-check contains the exact new padded-slot SHA once.

### r11 decision table

- **Version digits render + CJK positions become large solid blocks** → in-place rewrite of an original accepted glyph works. This is the required positive proof for the production strategy: preserve glyph-ID budget/order and repurpose existing slots for full Vietnamese + required CJK. Next gate should use multiple existing original glyph slots with distinct real Vietnamese/CJK outlines, then split Title vs UI/Body faces.
- **Version digits render but CJK positions are invisible** → even modifying an existing glyph outline is being rejected in this construction; compare r8↔r11 font-table changes around the rewritten original glyph while keeping route closed as solved.
- **Version digits disappear too** → stronger font rejection; inspect r8↔r11 structural delta only.

---

## 8. Separate stable Việt hóa installer issue

After r9, installing the current Việt hóa pack produced stock-looking/full Chinese and its remove/uninstall action did not work.

This remains recorded separately. Do not infer that stable manifest directly manages `inner.cache`; current stable manifest declares managed roots under `Saved/Mods/...` and the stable VN Font PAK only.

Do not broaden Font mechanics into patcher repair unless owner explicitly changes priority.

---

## 9. Resolved conclusions / do not repeat

- PAK-only is not a demonstrated current Font takeover solution.
- A/local.cache is not required by the captured working recipe.
- Do not hand-append only the clone path to `inner.cache`.
- Do not randomize Oodle codec/levels.
- Official Oodle 2.9.10 is not inherently incompatible.
- Missing text alone is not positive proof.
- **Alternate-font proof exists via r2 and especially r8.**
- TTF/glyf is the viable direction; CFF/OTF is not.
- CJK codepoint/cmap flow is positively proven by r8.
- Many-codepoints→one-glyph aliasing is not the primary blocker.
- r9 shows newly appended real glyphs fail while the same mappings to existing GID work.
- r10 shows even trivial newly appended rectangle glyphs fail; Noto outline complexity is not the cause.
- The smallest current hypothesis is **append-GID/table integration failure**.
- Do not modify stable channel while Font work remains experimental.

---

## 10. Recovery

If experiment rollback preconditions unquestionably match, use its transactional rollback. Otherwise:

1. official GMZZLauncher Verify/Repair;
2. launch once;
3. confirm stock Chinese + small/legal/version text;
4. close game;
5. begin the next clean gate.

Do not delete arbitrary caches by guesswork.

---

## 11. Next-session instruction

Begin with:

> Read `docs/CURRENT_STATE.md` as authority. Reconcile `main` and stable manifest. Treat r8 as broad positive alternate-font/cmap proof and r10 as decisive evidence that newly appended physical glyph IDs remain invisible even with trivial outlines. Do not reopen route/Oodle or Noto-outline diagnostics. Current live state is r10 installed unless newer owner evidence says otherwise. The smallest unfinished gate is r11 REUSE/REWRITE ORIGINAL GLYPH: rollback r10 cleanly, install r11 once, and report whether former CJK positions become solid blocks while version digits remain visible. Stable channel must remain unchanged.
