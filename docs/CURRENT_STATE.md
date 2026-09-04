# LoM-VI — Current State / Continuity Authority

**Status:** ACTIVE LIVING AUTHORITY  
**Last reconciled:** 2026-09-04 (+07), after FULL-BOLD r9 live result and post-test Việt hóa installer interaction  
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

### 2.3 Alternate Font rendering is positively proven

The old statement “LoM-VI has never positively rendered an alternate font” is retracted by live evidence.

- **r2** rendered loading version digits in an unmistakably heavy replacement face.
- **r8** rendered deliberate diagnostic `W` glyphs at multiple CJK/text positions, including immediately beside the version digits.

Therefore:

> **Alternate Font takeover/rendering is positively proven on the current game build.**

This proves route + wrapper/container + TrueType rasterization can work. It does **not** mean production-ready Vietnamese/CJK coverage is solved.

### 2.4 MVH remains structural reference only

Mê Việt Hóa remains useful for structure, packaging, compression and historical installer behavior, but it is not a current runtime oracle. Direct `_P.pak` tests on the current build did not provide positive MVH takeover proof.

---

## 3. Current blocker

The blocker is no longer route, Oodle, or “can another Font render?”. Those questions are closed unless new evidence materially changes a premise.

Current blocker:

> **Newly added real TrueType glyphs do not rasterize even though the same CJK codepoints render when mapped to an existing proven glyph.**

The smallest next question is whether the failure belongs to the converted Noto CJK outlines/metrics specifically, or to adding new glyph IDs/table integration generally.

The next live gate is:

> **r10 — SIMPLE-CJK-GLYPHS CONTROL**

---

## 4. Exact B/C recipe capture authority

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

Preserve clone filename, seven asset paths, fixed physical slots, encoded-entry slots, path-hash/full-directory topology, official C and A/local.cache. Only Font payload/header and required encoded-entry fields may change.

---

## 6. FULL-BOLD live sequence — decisive results

### r1 — full Noto CJK Bold

Installer failed closed before runtime mutation because `Aleo_Regular_Update` compressed data did not fit its fixed physical slot.

### r2 — compact Black TrueType positive control

- TrueType `glyf` payload;
- all seven Aleo assets replaced by the same diagnostic face;
- exact dev.24 route/template retained.

Live result: most text disappeared, but loading version `1.2018737.2097705` visibly rendered in a dramatically heavier replacement face.

**First positive alternate-font render proof.**

### r3 — CJK+VI CFF/OTF

Live result: all text disappeared, including version digits.

Interpretation: CFF/OTF is not the viable direction.

### r4 — TTF/glyf CJK+VI canary

Live result: version digits returned; a few special/replacement characters appeared.

Interpretation: TTF/glyf is the viable direction.

### r5 — very large CJK cmap, many codepoints → one `W`

Live result: visible glyphs disappeared, but layout/line height remained.

### r6 — reduced GB2312 cmap, many codepoints → one `W`

Live result: same invisible-glyph/layout state.

Interpretation: failure is not explained solely by r5's huge cmap.

### r7 — unique physical glyph IDs at high complexity

Live result: no meaningful change from r6; still invisible-glyph/layout state.

Interpretation: many-codepoints→one-glyph aliasing is not the primary blocker.

### r8 — CMAP4095 threshold control — **POSITIVE PASS**

Construction:

- same r2 TrueType/glyf base;
- `3316` physical glyphs;
- exactly `4095` Unicode cmap mappings;
- original r2 `2840` mappings unchanged;
- exact `1255` extra CJK codepoints mapped to existing proven `W` glyph.

Live result:

- version digits rendered;
- deliberate `W` glyphs rendered at many CJK/text positions.

This proves:

1. dev.24 route/template works for alternate Font rendering;
2. TTF/glyf rasterization works;
3. CJK-range codepoints flow through the runtime cmap path;
4. `4095` is a live-proven safe control point under this construction;
5. `~10k` mappings failed in tested constructions.

Do not claim 4095 is a mathematically exact universal maximum.

### r9 — REAL-CJK SAFE SUBSET — **PARTIAL FAIL / IMPORTANT ISOLATION**

Construction:

- exact same `4095` mapping set as r8;
- original r2 `2840` mappings retained;
- exact same `1255` additional CJK codepoints retained;
- instead of mapping those codepoints to existing `W`, each codepoint received its own newly added real CJK glyph;
- source: Noto Sans CJK SC Bold CFF converted to quadratic TrueType `glyf` at 1000 UPEM;
- total glyph count `4571`;
- raw TTF `771,032` bytes;
- Font SHA-256 `624fa0c0e5c7728d4ad6c0691e749cdb868ad5b1b8c005ef2d4eb9c897c619a8`;
- EXE SHA-256 `f5763867b0ae6edf11e277c4018f6524589859e400de1bb3f8507c21b88ba1da`.

Live result from owner:

- loading version digits still rendered;
- real CJK glyphs did **not** visibly render;
- unlike r8, no diagnostic CJK `W` markers appeared.

Interpretation:

> **The 4095-mapping/codepoint route itself is still alive. The failure is narrowed to newly added glyph identities/outlines/metrics/table integration, not route or cmap budget.**

The strongest comparison is r8 vs r9: the same CJK codepoints render when they target an existing proven glyph, but fail when they target newly added converted real glyphs.

---

## 7. Post-r9 Việt hóa pack interaction — separate issue

After observing r9, the owner installed the current Việt hóa pack as an additional test.

Observed:

- pack uninstall/remove did not work;
- after that install, game text became full Chinese/stock-looking again.

This changes the effective runtime state, so the machine is **not a clean r9 checkpoint anymore**.

Do not infer without evidence that stable `channel/manifest.json` directly rewrites `inner.cache`: the stable manifest currently declares managed roots only under `Saved/Mods/...` for Core/Translation and the stable `pakchunk99999...VN_FONT_P.pak` for Font. The exact installer side effect that neutralized the experimental route has not yet been isolated.

Treat the uninstall failure as a **separate patcher/uninstaller bug**. Record it, but do not broaden the current Font gate into patcher repair unless the owner explicitly changes priority.

---

## 8. Current live machine state — IMPORTANT

Current state after the owner's post-r9 pack install is:

> **AMBIGUOUS / STOCK-LOOKING: full Chinese renders; stable pack removal failed.**

Therefore:

- do **not** assume r9 is still installed cleanly;
- do **not** use “run r9 a second time to rollback” as the default recovery;
- do **not** stack r10 on this ambiguous state.

Before the next Font gate, establish a clean baseline with official recovery.

Required pre-r10 recovery:

1. close the game;
2. do not manually delete arbitrary caches;
3. run official GMZZLauncher **Verify/Repair**;
4. launch once;
5. confirm stock/full Chinese plus normal small/legal/version text visibly renders;
6. close the game;
7. only then run r10 once.

The immediate r10 gate is intentionally **Font-mechanics-only**. Do not reinstall the stable Việt hóa pack during this gate. Translation/Core will be re-integrated only after newly added glyph rendering is understood, so installer side effects do not contaminate the Font decision.

---

## 9. r10 — SIMPLE-CJK-GLYPHS CONTROL — built, not live-tested

Purpose: distinguish **bad converted Noto outlines/metrics** from **new-glyph/table integration failure**.

Construction:

- start from r9;
- preserve exactly `4095` cmap mappings;
- preserve r9's `4571` total physical glyph count;
- preserve the same 1255 new CJK glyph IDs/codepoint assignments;
- replace every new CJK glyph outline with an extremely simple TrueType rectangle;
- each new glyph has its own physical glyph identity;
- simple metrics: advance `1000`, left side bearing `120`;
- rectangle coordinates: `(120,80) → (880,80) → (880,820) → (120,820)`;
- route, dev.24 captured `inner.cache`, seven Aleo assets, Oodle path, fixed physical slots and container topology remain unchanged.

r10 Font:

- raw TTF size `583,820` bytes;
- SHA-256 `34265a6b0b27982d947f79bff845b3ecd1691b98779e3902ed248815996681d3`;
- padded fixed-slot SHA-256 `5c68a4f03499b1f499bd846a61f8c9d8afe41a7640060b12a66ed8e69d0623af`.

Candidate EXE:

`LoM-VI-Full-Bold-Visual-Takeover-Control-r10-SIMPLE-CJK-GLYPHS.exe`

EXE SHA-256:

`bac01e0286aece48bb8ecfce28739e2969150cb9a1ba559fd5b1095d97f895ce`

Binary diff versus r9 is restricted to:

- fixed embedded Font slot;
- fixed-slot SHA self-check;
- same-length diagnostic label.

### r10 decision table

- **Version digits render + many solid blocks appear at former CJK positions** → new glyph IDs/table integration is viable; r9's converted Noto glyph construction/outlines/metrics are the culprit. Next gate should rebuild real CJK glyphs using a safer TrueType-native construction.
- **Version digits render but all new block glyphs remain invisible** → outline complexity is not the cause; investigate newly appended glyph/table integration (glyph order, loca/glyf/maxp/hmtx/cmap table relationships) while preserving exact route and mapping set.
- **Version digits also disappear** → stronger font rejection; compare r9/r10 table structure, but still do not reopen route/Oodle diagnostics unless clean control evidence demands it.

---

## 10. Resolved conclusions / do not repeat

- PAK-only is not a demonstrated current Font takeover solution.
- A/local.cache is not required by the captured working recipe.
- Do not hand-append only the clone path to `inner.cache`.
- Do not randomize Kraken/Mermaid/Leviathan/compression levels.
- Official Oodle 2.9.10 is not inherently incompatible.
- Missing text alone is not positive proof.
- Stock clone PASS is not alternate-font proof.
- **Alternate-font proof exists via r2 and especially r8.**
- TTF/glyf is the current viable Font direction; CFF/OTF is not.
- CJK codepoint/cmap flow is positively proven by r8.
- Many-codepoints→one-glyph aliasing is not the main explanation.
- Unique physical glyph IDs alone did not cure high-complexity r7.
- `4095` mappings is a live-proven safe control under r8; `~10k` failed in tested variants.
- r9 proves mapping count alone is insufficient: newly added real glyphs can fail while existing proven glyphs still render.
- Do not modify stable channel while Font work remains experimental.
- Do not use the stable Việt hóa pack as part of the immediate r10 mechanical gate; its post-r9 install changed effective runtime state and its uninstall failed.

---

## 11. Recovery

If experimental state is ambiguous:

1. if an experiment's own exact rollback preconditions still unquestionably match, transactional rollback is preferred;
2. otherwise use official GMZZLauncher Verify/Repair;
3. launch once and confirm stock small/legal/version text plus normal Chinese rendering;
4. only then begin another clean gate.

Do not delete arbitrary caches by guesswork.

---

## 12. Next-session instruction

Begin with:

> Read `docs/CURRENT_STATE.md` as authority. Reconcile GitHub `main` and stable manifest. Treat r8 as broad positive Font takeover proof and r9 as proof that the remaining blocker lies in newly added glyph construction/table integration, not route/cmap budget. Current live machine state is ambiguous/stock-looking after a Việt hóa pack install whose uninstall failed. Do not run r9 rollback by default. First official Verify/Repair to a clean stock baseline, then run the smallest unfinished gate: r10 SIMPLE-CJK-GLYPHS. Do not reopen route/Oodle diagnostics and do not reinstall the stable Việt hóa pack during r10.
