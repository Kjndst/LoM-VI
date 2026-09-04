# LoM-VI — Current State / Continuity Authority

**Status:** ACTIVE LIVING AUTHORITY  
**Last reconciled:** 2026-09-04 (+07), after FULL-BOLD r13 live result  
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

Current stable channel remains unchanged:

- Core `0.2.0.4`
- Translation `2026.09.03.4`
- Font `2026.09.03.2`

**Do not silently replace a published stable payload under the same version. Font experiments remain outside stable.**

---

## 2. Production Font direction — now mechanically supported

Owner design target:

- **one Title face** for headings / large labels / class or character-name style surfaces;
- **one UI/Body face** for small text / skill / item / tooltip / dialogue / buttons;
- all seven Aleo assets may remain separate Unreal assets/wrappers, but should collapse visually to these two actual typefaces;
- both faces should contain **native full Vietnamese** so `ấ / ế / ạ / ộ / ữ ...` do not fall back to a different typeface;
- CJK coverage only needs to cover still-untranslated / required game surfaces rather than the entire Unicode CJK universe if glyph budget is constrained.

The current mechanically supported architecture is:

> **Preserve the original accepted TrueType glyph-ID envelope/order and reuse existing glyph slots in-place. Do not append large numbers of new physical glyph IDs.**

r11/r12/r13 provide positive live evidence for this direction.

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

Installer failed closed before runtime mutation because `Aleo_Regular_Update` compressed data exceeded its fixed physical slot. Build constraint only.

### r2 — compact Black TrueType positive control

TrueType `glyf`; all seven Aleo assets changed to the same heavy diagnostic face.

Live:

- most text disappeared;
- loading version `1.2018737.2097705` rendered in an unmistakably heavy replacement face.

**First positive alternate-font raster proof.**

### r3 — CJK+VI CFF/OTF

All text disappeared, including version digits. **CFF/OTF is not the viable direction.**

### r4 — TTF/glyf CJK+VI canary

Version digits returned and some replacement/special characters appeared. **TTF/glyf is viable.**

### r5 / r6 / r7 — large/alias/unique-glyph probes

- r5: very large CJK cmap mapped to one `W` → visible glyphs disappeared, layout remained.
- r6: reduced GB2312 cmap still mapped to one `W` → same invisible-layout state.
- r7: unique physical glyph IDs at high complexity → still invisible-layout state.

### r8 — CMAP4095 — **BROAD POSITIVE PASS**

Construction:

- r2 TrueType/glyf base;
- `3316` physical glyphs;
- exactly `4095` Unicode mappings;
- original r2 `2840` mappings unchanged;
- `1255` extra codepoints mapped to existing proven `W` glyph.

Live:

- version digits rendered;
- many deliberate `W` glyphs rendered at CJK/text positions.

r8 proves route/container/TrueType raster path works, CJK-range codepoints flow through cmap, and mapping new codepoints to an **existing accepted glyph ID** works.

### r9 — real CJK glyph append — **FAIL / ISOLATION**

Same 4095 mapping set as r8, but 1255 CJK codepoints received newly appended real Noto CJK glyphs.

Live:

- version digits rendered;
- new real CJK glyphs did not render.

### r10 — simple newly appended rectangle glyphs — **FAIL / DECISIVE**

Same appended glyph IDs as r9 but every new glyph was replaced by a trivial rectangle.

Live:

- version digits rendered;
- no appended rectangle glyphs rendered.

Therefore outline complexity is not the cause. Newly appended physical glyph IDs/table integration are the blocker.

### r11 — rewrite one original accepted glyph — **POSITIVE PASS**

Construction:

- exact r8-style accepted shape;
- `3316` physical glyphs;
- `4095` mappings;
- no new glyph IDs;
- existing `W` GID 58 rewritten in-place into a large solid block;
- CJK mappings still targeted that original GID.

Owner live result:

- version digits rendered;
- solid blocks rendered at multiple former CJK positions;
- not every text position was covered.

Interpretation:

> **In-place rewrite of an original accepted glyph ID works. The production architecture is mechanically valid; remaining absence is coverage, not route failure.**

### r12 — multi-original-glyph bank — **POSITIVE PASS**

Construction:

- no appended glyph IDs;
- `3316` physical glyphs;
- `4095` mappings;
- eight existing glyphs `W/M/N/H/X/Y/Z/Q` rewritten to visibly distinct marker shapes;
- 1255 extra codepoints distributed across those eight original GIDs.

Owner live result:

- loading rendered multiple distinct marker shapes/letters, not only one block;
- main/in-game still lacked most text.

Interpretation:

> **Multiple original accepted glyph IDs can be rewritten and independently reused.**

Main/in-game absence is still primarily a coverage problem under this diagnostic subset.

### r13 — multi-original-glyph bank, 5119 mappings — **POSITIVE PASS**

Construction:

- same original-GID reuse model as r12;
- no new glyph IDs;
- still `3316` physical glyphs;
- mapping coverage increased from `4095` to exactly **`5119`**;
- eight rewritten original marker GIDs retained.

Owner live result:

- loading still rendered multiple marker shapes plus normal version digits;
- marker pattern changed / coverage increased slightly;
- title/main text still mostly absent.

Interpretation:

> **5119 mappings is also live-proven viable under original-GID reuse.**

Do not claim 5119 is a universal maximum. The next useful gate is no longer “more marker coverage”; it is **real glyph replacement inside a larger original-slot bank**.

---

## 6. Current live machine state

At this update, owner has just live-tested **r13**.

Treat:

> **r13 as currently installed unless owner reports rollback/recovery after this point.**

Before r14:

1. close game;
2. run r13 a second time and require exact rollback success;
3. if rollback refuses/hash-mismatches, use official GMZZLauncher Verify/Repair instead;
4. confirm clean stock/full-Chinese small/legal/version text once;
5. only then install r14 once.

Do not install the stable Việt hóa pack during this mechanical gate.

---

## 7. r14 — REAL-VIETNAMESE ORIGINAL-SLOT BANK — built, not live-tested

Purpose:

> Prove that a **large bank of existing accepted glyph IDs** can be rewritten with **real Latin/Vietnamese outlines**, not only simple marker blocks, while preserving the accepted glyph count/order.

Construction:

- base route/container = r13;
- physical glyph count remains exactly **3316**;
- Unicode mapping count remains exactly **5119**;
- no new physical glyph IDs appended;
- 64 existing original glyph slots are reused: `A-Z`, `a-z`, plus 12 punctuation slots (`[]{}<>@#$%&*`);
- those 64 slots are rewritten with 64 real Latin/Vietnamese glyph outlines taken from the already-proven TTF base;
- source outline bank includes native Vietnamese shapes such as `Ă Â Đ Ê Ô Ơ Ư`, `á à ả ã ạ`, `ấ ầ ẩ ẫ ậ`, `ế ề ể ễ ệ`, `ố ồ ổ ỗ ộ`, `ớ ờ ở ỡ ợ`, `ứ ừ ử ữ ự`, `ý ỳ ỷ ỹ ỵ`;
- composite source glyphs are decomposed/flattened into simple TrueType outlines before insertion;
- the same r13 2279 extra codepoints are distributed across the 64 reused original GIDs;
- version digits and period are not used as rewrite slots, so loading version remains a stable control.

Static validation:

- `numGlyphs = 3316`;
- best Unicode cmap = `5119` unique mappings;
- raw TTF size `535,168` bytes;
- raw TTF SHA-256 `a52191ed53d791b175aff32fe8014c9836b5af9781e752b9e310f97299ab9cd8`;
- padded embedded-slot SHA-256 `de13891f82c2db13f9c7609510bbc543478287c882012f15767dd1e64c806d4c`;
- `欢迎回来`, `切换账号`, `游戏`, `设置`, `版本`, `服务器`, `登录`, `进入`, `开始`, `战斗`, `技能`, `装备`, `地图` all map into the 64 reused original slots.

Candidate EXE:

`LoM-VI-Full-Bold-Visual-Takeover-Control-r14-REAL-VIETNAMESE-ORIGINAL-SLOTS.exe`

EXE SHA-256:

`1da79f57858384a11ffff01054120bac67ba6ec6aa7e155ca2fdfee7dadda812`

### r14 decision table

- **Version digits render + former CJK positions now show recognizable Latin/Vietnamese letters/diacritics** → mass rewrite of original accepted slots with real glyph outlines is proven. Font mechanics are sufficiently solved to begin the production split into Title + UI/Body and native full-Vietnamese mapping.
- **Version digits render but only some rewritten slots show / many remain invisible** → identify which original GIDs are accepted across surfaces; build a production-safe slot whitelist rather than reopening route/Oodle.
- **Version digits disappear** → stronger structural rejection from the 64-slot rewrite; compare r13↔r14 font table deltas only.

---

## 8. Separate stable Việt hóa installer issue

After r9, installing the current Việt hóa pack produced stock-looking/full Chinese and its remove/uninstall action did not work.

This remains a separate patcher/uninstaller bug. Do not infer that stable manifest directly manages `inner.cache`; current stable manifest declares managed roots under `Saved/Mods/...` and the stable VN Font PAK only.

Do not broaden Font mechanics into patcher repair unless owner changes priority.

---

## 9. Resolved conclusions / do not repeat

- PAK-only is not a demonstrated current Font takeover solution.
- A/local.cache is not required by the captured working recipe.
- Do not hand-append only the clone path to `inner.cache`.
- Do not randomize Oodle codec/levels.
- Official Oodle 2.9.10 is not inherently incompatible.
- Missing text alone is not positive proof.
- **Alternate-font proof exists via r2 and especially r8.**
- TTF/glyf is viable; CFF/OTF is not.
- CJK codepoint/cmap flow is positively proven by r8.
- r9/r10 prove newly appended physical glyph IDs can remain invisible even with trivial outlines.
- r11 proves modifying an existing accepted GID outline in-place works.
- r12 proves multiple existing original GIDs can be independently reused.
- r13 proves `5119` mappings remains viable under original-GID reuse.
- Current production direction is **original-slot reuse + native Vietnamese**, not append-GID expansion.
- Stable channel must remain unchanged during experiments.

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

> Read `docs/CURRENT_STATE.md` as authority. Reconcile `main` and stable manifest. Treat r11/r12 as positive proof that original accepted glyph IDs can be rewritten/reused, and r13 as proof that 5119 mappings still render under that model. Do not reopen route/Oodle, CFF, or append-GID diagnostics. Current live state is r13 installed unless newer owner evidence says otherwise. The smallest unfinished gate is r14 REAL-VIETNAMESE ORIGINAL-SLOT BANK: rollback r13 cleanly, install r14 once, and report whether recognizable Vietnamese/Latin glyph shapes render at former CJK positions while version digits remain visible. Stable channel must remain unchanged.
