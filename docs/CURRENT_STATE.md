# LoM-VI — Current State / Continuity Authority

**Status:** ACTIVE LIVING AUTHORITY  
**Last reconciled:** 2026-09-04 (+07), after FULL-BOLD r14 live proof  
**Repository:** `Kjndst/LoM-VI`

> Read this file before continuing development. New clean live evidence overrides older speculation. The diagnostic question “can LoM-VI take over and rasterize a replacement Font?” is now closed by live proof.

---

## 1. Product goal

LoM-VI is a Vietnamese localization for **Lord of Mysteries** with separately updateable Translation / Core / Font components.

Translation goals remain:

- terminology familiar to Vietnamese readers of *Quỷ Bí Chi Chủ*;
- avoid machine-like wording;
- prefer short UI-safe wording where long strings break layout;
- skill/item descriptions must remain precise enough for competitive build decisions.

Font is independent from Translation/Core release cadence.

Current stable channel remains unchanged:

- Core `0.2.0.4`
- Translation `2026.09.03.4`
- Font `2026.09.03.2`

**Do not silently replace a published stable payload under the same version. Font experiments remain outside stable until production acceptance.**

---

## 2. Production Font architecture — MECHANICALLY PROVEN

Owner design target:

- **one Title face** for headings / large labels / class or character-name style surfaces;
- **one UI/Body face** for small text / skill / item / tooltip / dialogue / buttons;
- all seven Aleo Unreal assets may remain separate wrappers, but should visually collapse to these two actual typefaces;
- both faces must contain **native full Vietnamese**, including precomposed tone forms such as `ấ / ế / ạ / ộ / ữ / ỹ`, so the engine does not mix in a fallback typeface;
- CJK only needs enough coverage for still-untranslated/required surfaces if glyph budget is constrained.

The mechanically proven architecture is:

> **Preserve the original accepted TrueType glyph-ID envelope/order and reuse existing glyph slots in-place. Rewrite their outlines with glyphs from the desired typeface. Do not depend on appending large numbers of new physical glyph IDs.**

This is no longer hypothetical. r11-r14 provide positive live proof.

Important nuance:

- Vietnamese glyphs already represented by accepted original slots/mappings can be replaced in-place with the desired face while preserving their Unicode meaning;
- additional required characters can be mapped to deliberately repurposed original slots;
- production must preserve ASCII/digits/punctuation needed by normal UI and must not repeat the destructive diagnostic slot selection used by r14.

---

## 3. LOCKED runtime Font route

Historical labels:

- **A** = `C7/Saved/kscache/local.cache`
- **B** = `C7/Content/inner.cache`
- **C** = active `C7/Saved/kscache/package_*.manifest`

Exact recipe capture proved the current working route:

> **current official C + exact dev.24-patched B + custom dev.24 clone PAK**

Captured behavior:

- A/local.cache unchanged;
- official C manifest byte-identical;
- signature unchanged;
- B/inner.cache changed by the exact captured dev.24 transformation;
- custom dev.24 clone PAK installed.

Do not reopen A+B+C, PAK-only, random Oodle codec/level testing, or hand-appending a clone path to clean `inner.cache` unless a premise materially changes.

### Exact recipe authority

Artifact: `LoM-VI-BC-Recipe-Capture.zip`  
Result: `PASS_CAPTURED_AND_RESTORED`

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

## 5. Decisive FULL-BOLD evidence

### r2 — first alternate-font raster proof

Compact Black TrueType `glyf`; all seven Aleo assets changed to the same heavy diagnostic face.

Live: loading version `1.2018737.2097705` rendered in the replacement face.

### r3 / r4 — format direction

- r3 CFF/OTF: all text including version disappeared.
- r4 TTF/glyf: version returned.

**TTF/glyf is the viable direction. CFF/OTF is not.**

### r8 — existing-GID mapping proof

- `3316` physical glyphs;
- `4095` mappings;
- `1255` extra CJK codepoints mapped to existing proven `W` GID.

Live: many deliberate `W` glyphs rendered at CJK/text positions.

This proves CJK-range codepoints can flow through cmap when targeting accepted original GIDs.

### r9 / r10 — appended-GID failure isolated

- r9: appended real CJK glyphs did not render.
- r10: even trivial newly appended rectangle glyphs did not render.

Version digits remained visible in both.

**Conclusion: appended physical glyph IDs/table integration are the blocker, not Noto outline complexity or route failure.**

### r11 — one original GID rewritten — POSITIVE PASS

Existing `W` GID rewritten in-place to a solid block; no new GID.

Live: block rendered at former CJK positions.

**In-place outline rewrite of an accepted original GID works.**

### r12 — multiple original GIDs rewritten — POSITIVE PASS

Eight accepted original GIDs (`W/M/N/H/X/Y/Z/Q`) rewritten to distinct markers; extra codepoints distributed across them.

Live: multiple distinct marker shapes rendered.

**Multiple original GIDs can be independently reused.**

### r13 — 5119 mapping expansion — POSITIVE PASS

Same original-GID reuse model; mapping coverage increased to exactly `5119` while physical glyph count remained `3316`.

Live: multiple markers + version remained visible.

**5119 mappings is live-proven viable under this construction. Do not treat it as a universal maximum.**

### r14 — REAL VIETNAMESE ORIGINAL-SLOT BANK — POSITIVE PRODUCTION-MECHANICS PROOF

Construction:

- `3316` physical glyphs;
- `5119` mappings;
- no new physical glyph IDs;
- 64 existing original slots rewritten with real Latin/Vietnamese outlines;
- source bank included native shapes such as `Ă Â Đ Ê Ô Ơ Ư`, `ấ ế ạ ộ ữ ỹ`, etc.;
- version digits/period kept as stable control.

Live owner result:

- version digits remained visible;
- recognizable real Vietnamese/Latin glyphs rendered at remapped former-CJK positions, including visible forms such as `ỗ`, `è`, `ầ`, `ự`, `ỹ`, `ư`;
- this was not fallback text: these shapes came from the deliberately rewritten original glyph slots.

**Conclusion:**

> **The production theory is proven: LoM-VI can preserve the game-accepted font structure/GID envelope and replace original glyph outlines with real glyphs from the desired typeface. Native Vietnamese can therefore be supplied in the primary font instead of relying on fallback.**

Do not spend more live cycles on `W`, block, or generic marker diagnostics unless a new production-specific failure requires one.

---

## 6. Current live machine state

At this update:

> **r14 is installed unless the owner reports a later rollback/recovery.**

Before any next candidate:

1. close game;
2. run r14 a second time and require exact transactional rollback success;
3. if rollback refuses/hash-mismatches, use official GMZZLauncher Verify/Repair;
4. confirm clean stock rendering once;
5. then install the next candidate.

Do not stack production candidates on top of r14.

---

## 7. Next phase — production font design, not another marker gate

The next deliverable should be a **production prototype**, not r15 diagnostic blocks.

Required design:

### UI/Body face

- compact and highly legible at small sizes;
- native complete Vietnamese;
- good numeral/punctuation clarity;
- conservative metrics to reduce UI overflow;
- used by `Aleo_Regular*` and `Aleo_Regular_Update` class assets.

### Title face

- visually stronger / more characterful;
- native complete Vietnamese;
- used by `Aleo_Title*`, title SDF/head-name and title-update class assets unless live surface testing later shows a wrapper-specific exception.

Implementation contract:

- preserve accepted `3316` GID envelope/order for each generated face unless a smaller verified original template is selected deliberately;
- rewrite glyph outlines in-place by Unicode correspondence where the original template already has the codepoint;
- preserve required ASCII/digits/punctuation;
- allocate a production-safe original-slot bank only for missing Vietnamese/CJK/symbol coverage;
- no append-GID dependency;
- keep stable channel unchanged until visual acceptance + Translation ON integration pass.

Before final font selection, owner should choose/approve the visual direction for **Title** and **UI/Body**. Do not lock an arbitrary final typeface merely because it is convenient for diagnostics.

---

## 8. Separate stable Việt hóa installer issue

After r9, installing the current Việt hóa pack produced stock-looking/full Chinese and its remove/uninstall action did not work.

This remains a separate patcher/uninstaller bug. Do not infer that stable manifest directly manages `inner.cache`; current stable manifest declares managed roots under `Saved/Mods/...` and the stable VN Font PAK only.

Do not broaden Font production work into patcher repair unless owner changes priority.

---

## 9. Resolved conclusions / do not repeat

- PAK-only is not a demonstrated current Font takeover solution.
- A/local.cache is not required by the captured working recipe.
- Do not hand-append only the clone path to `inner.cache`.
- Do not randomize Oodle codec/levels.
- Official Oodle 2.9.10 is not inherently incompatible.
- **Alternate-font render proof exists.**
- TTF/glyf is viable; CFF/OTF is not.
- CJK codepoint/cmap flow to accepted original GIDs is proven.
- Appended GIDs can remain invisible even with trivial outlines.
- In-place rewrite/reuse of original accepted GIDs works.
- Multiple original GIDs can be reused.
- `5119` mappings is live-proven viable under the tested original-GID construction.
- Real Vietnamese glyph shapes render from rewritten original slots.
- Production direction is **two visual faces + original-slot reuse + native Vietnamese**, not further generic diagnostics.
- Stable channel must remain unchanged until production acceptance.

---

## 10. Next-session instruction

Begin with:

> Read `docs/CURRENT_STATE.md` as authority. Reconcile `main` and stable manifest. Treat r14 as decisive production-mechanics proof: real Vietnamese glyph outlines render when written into existing accepted GIDs while preserving the original glyph envelope. Do not reopen route/Oodle/appended-GID diagnostics and do not build more marker controls by default. Current live state is r14 installed unless newer owner evidence says otherwise. The next task is production Font design: owner approves one Title face and one UI/Body face, then build the first native-Vietnamese two-face prototype using original-slot reuse. Stable channel remains unchanged.
