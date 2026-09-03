# LoM-VI — Current State / Continuity Authority

**Status:** ACTIVE LIVING AUTHORITY  
**Last reconciled:** 2026-09-04 (+07)  
**Repository:** `Kjndst/LoM-VI`  

> Read this file before continuing development. It exists to prevent context drift.
>
> When a clean live result conflicts with an older handoff, stale marker, or speculative conclusion, the newer verified result wins and this file must be updated before the next major gate.

---

## 1. Product goal

LoM-VI is a Vietnamese localization for **Lord of Mysteries** with three separately updateable components:

- **Translation** — Vietnamese wording/data.
- **Core** — loader/runtime/hook/coverage.
- **Font** — game font payload and integration.

End-user goal: a lightweight patcher/updater. Normal Translation/Core/Font updates should come from GitHub without requiring a new launcher EXE unless launcher behavior itself changes.

Translation quality goals:

- terminology familiar to Vietnamese readers of *Quỷ Bí Chi Chủ*;
- avoid machine-like wording;
- prefer short UI-safe wording where long translations break layout;
- skill/item descriptions must remain precise enough for competitive build decisions;
- Font must not be coupled to Translation/Core release cadence.

Current stable channel (`channel/manifest.json`):

- Core `0.2.0.4`
- Translation `2026.09.03.4`
- Font `2026.09.03.2`

**Do not treat the current stable Font component as proof that final Font takeover is solved. Do not silently replace a published payload under the same version.**

---

## 2. Current blocker

**Reliable Font takeover on the current game build.**

The next live gate is intentionally end-to-end and visual:

> **FULL-BOLD VISUAL TAKEOVER CONTROL**

Vietnamese translation is enabled and all seven relevant Aleo Font assets are replaced by one deliberately heavy Bold face. Success must be obvious by eye across many UI surfaces, not inferred from “small text present/missing”.

---

## 3. Current live game state

Latest clean sequence:

1. old experimental clone was quarantined;
2. official GMZZLauncher **Verify/Repair** was run;
3. stock game launched and **small/legal/version text rendered correctly**;
4. exact-stock direct `_P.pak` was tested: text still rendered, no visible change;
5. MVH direct `_P.pak` was tested from the same B/C-neutral baseline: text still rendered and visible Chinese/font remained stock-looking;
6. `LoM-VI-BC-Recipe-Capture.exe` was then run successfully;
7. the capture tool ran exact dev.24-r4 temporarily and restored the pre-run state byte-for-byte.

Therefore the current state after the capture is the **pre-capture state**, including the direct MVH `_P.pak` that was present before the capture. The machine is **not** left in dev.24-r4 state.

Do not infer that direct `_P.pak` alone wins Font resolution. Clean retesting produced **no positive visual Font takeover marker**.

---

## 4. Historical route labels and corrected authority

Route labels:

- **A** = `C7/Saved/kscache/local.cache`
- **B** = `C7/Content/inner.cache`
- **C** = active `C7/Saved/kscache/package_*.manifest`

Historical isolation matrix:

| Route | Result |
|---|---|
| no A / no B / no C | stock font |
| A only | stock font |
| B only | stock font after asset update |
| C only | stock font after asset update |
| A+B | stock font |
| **B+C** | **takeover occurs; bad payload can cause missing text** |
| A+B+C | same takeover behavior |

Historical conclusion remains useful:

> **A/local.cache is not required. The successful route depends on the B/C authority state, not a loose PAK alone.**

### Important refinement from the 2026-09-04 recipe capture

The clean before→dev.24-r4 capture showed:

- `local.cache`: **unchanged**
- `signature.txt`: **unchanged**
- `package_2018737.manifest`: **unchanged byte-for-byte**
- `inner.cache`: **changed**
- dev.24 clone PAK: installed

So on the current clean game build, dev.24-r4 did **not** dynamically rewrite C. The active official C manifest was already the required state.

Thus the operational recipe captured now is more precisely:

> **current official C + dev.24-patched B + exact clone PAK**

Do **not** keep saying “regenerate B+C from every new PAK” as if both files necessarily mutate. The current unknown is the dynamic route/index data inside **B/`inner.cache`**.

---

## 5. Exact B+C Recipe Capture — PASS

Artifact run by owner:

`LoM-VI-BC-Recipe-Capture.exe`

SHA-256:

`318a79c21d1ac30757b87d6dd4e00bf10979b655effe16ea6e4a19b6e8a00626`

Returned ZIP:

`LoM-VI-BC-Recipe-Capture.zip`

Result:

`PASS_CAPTURED_AND_RESTORED`

Created local: `2026-09-04T06:30:38+07:00`.

### Before / restored authority

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

`local.cache`
- **unchanged**

`package_2018737.manifest`
- **unchanged**, still SHA `60c21eaf...`

`signature.txt`
- **unchanged**

clone PAK:

`Content/Paks/pakchunk99998-Windows_LVI_STOCK_CLONE_P.pak`
- size `25,867,666`

### Inner-cache structural finding

Before `inner.cache` contains 56 paths; after dev.24 contains 57.
The newly added path is exactly:

`Paks/pakchunk99998-Windows_LVI_STOCK_CLONE_P.pak`

Its encoded path entry accounts for the exact `+53` byte file-size increase.

However, **this is not merely a path append**. After aligning the path-list boundary, a large route/index region in the remainder also changes. Therefore:

> **Do not implement the next gate by simply appending the clone path to clean `inner.cache`.**

Dev.24’s dynamic route/index transformation remains part of the known-good recipe.

---

## 6. Known-good controls

### Official clean recovery

Preferred when state is ambiguous:

1. quarantine/remove LoM-VI experimental custom PAKs;
2. official GMZZLauncher Verify/Repair;
3. launch once;
4. confirm small/legal/version text visible.

Reconfirmed live 2026-09-04.

### dev.23 — Compressed Stock Clone

- custom LoM V12 PAK;
- seven stock `.ufont` entries;
- exact stock Oodle-compressed bytes;
- route authority active.

Result: **PASS — stock text renders normally.**

### dev.24-r4 — Exact dev.23 Restore

Repeated the same stock-clone result successfully.

Artifact SHA-256:

`2172575f1a410b43d17253490fea1ff0112c62546ad52b1bc886b794f797e146`

Result repeatedly reconfirmed: **PASS — small/body text renders.**

### dev.30-r2 — regenerated PakEntry + exact stock Oodle

Exact stock raw and exact stock compressed payload with regenerated PakEntry metadata rendered small text.

Interpretation: the custom PakEntry writer is not inherently rejected when carrying exact accepted payload bytes.

---

## 7. Compression investigation — resolved lessons

Observed:

- stock Font + `None` → missing text
- stock Font + `Zlib` → missing text
- exact stock Oodle → text returns
- dev.29-r2 stock raw + fresh OSS Kraken → missing small text
- h2r3 only block001 fresh OSS Kraken → missing small text
- h2o1 only block001 official Oodle 2.9.10 → missing small text

But later MVH analysis proved that its custom `Aleo_Regular` stream can be recompressed **525/525 blocks byte-for-byte** using official Oodle 2.9.10 / Kraken / Normal.

Therefore:

> **RETRACTED: “fresh official Oodle is inherently incompatible with C7.”**

Compression alone does not explain dev.29/h2 failures. Route/container metadata consistency is a first-class variable.

Do not return to random Kraken/Mermaid/Leviathan/level roulette.

---

## 8. Direct `_P.pak` experiments — corrected conclusion

Early direct-Pak disappearance tests were contaminated by stale dev.24 route state and are invalid as direct-route evidence.

Clean official-repair retest:

- exact-stock Aleo direct `_P.pak` → no visible change;
- MVH direct `_P.pak` → no visible change.

MVH’s Aleo contains the relevant CJK codepoints and deliberate glyph remaps, so unchanged `混沌海`-style text is strong evidence that the MVH Font asset did not become active.

Current conclusion:

> **PAK-only is not a sufficient Font takeover solution on this game build.**

Do not repeat PAK-only testing unless the mount premise materially changes.

---

## 9. MVH reference — what it is and is not

Uploaded files named `pakchunk0-Windows_P*.pak` are **MVH addon/mod PAKs**, not stock game PAKs.

Real stock authority:

`C7/Content/Paks/pakchunk0-Windows.pak`

MVH is not a current known-good render oracle; it can itself exhibit missing-text behavior on the current game.

It remains structurally valuable because:

- it is a LoM V12/encrypted-index PAK;
- it contains large custom Font assets;
- current CUE4Parse has LoM-specific support;
- MVH compression is reproducible with official Oodle;
- its installer historically works with route/cache layers beyond a loose PAK.

Never use MVH bytes as stock bytes.

---

## 10. Captured clone PAK template authority

Exact dev.24 clone PAK contains seven Font entries and is a valid LoM V12/encrypted-index template.

Seven paths:

1. `C7/Content/Arts/UI_2/Resource/Font/Aleo_Regular.ufont`
2. `C7/Content/Arts/UI_2/Resource/Font/Aleo_Regular_SDF.ufont`
3. `C7/Content/Arts/UI_2/Resource/Font/Aleo_Title.ufont`
4. `C7/Content/Arts/UI_2/Resource/Font/Aleo_Title_SDF.ufont`
5. `C7/Content/Arts/UI_2/Resource/Font/Aleo_Title_SDF_HeadName.ufont`
6. `C7/Content/Arts/UI_Update/Resource/Font/Aleo_Regular_Update.ufont`
7. `C7/Content/Arts/UI_Update/Resource/Font/Aleo_Title_Update.ufont`

Known entry offsets:

- Regular `0`
- Regular_SDF `5,632,000`
- Title `11,268,096`
- Title_SDF `14,585,856`
- Title_SDF_HeadName `17,928,192`
- Regular_Update `21,241,856`
- Title_Update `22,546,432`

Known encoded-entry offsets:

`0, 572, 1144, 1512, 1880, 2248, 2388`

The next diagnostic should preserve:

- clone filename;
- all seven asset paths;
- physical entry offsets;
- encoded-entry slot offsets;
- path-hash/full-directory topology;

while rebuilding only the Font payload/header and encoded entry fields required by the new compressed sizes/block counts.

This minimizes variables and lets the known dev.24 inner route continue pointing at the same container identity/topology.

---

## 11. Community tooling — keep only the useful lessons

Useful:

- current CUE4Parse includes `GAME_LordOfMysteries` support;
- LoM packaging has game-specific behavior beyond generic UE assumptions;
- community `repak` demonstrates official-Oodle loading/compression cleanly;
- official Oodle 2.9.10 / Kraken / Normal is the intended compression path for the next build.

Do not repeat as new work:

- scanning installed games for Oodle DLLs;
- scanning local Unreal Engine installations solely for Oodle;
- generic old UnrealReZen IoStore probing;
- hardlink-based temporary IoStore view;
- random compression-level experiments.

---

## 12. Retracted/corrected conclusions

- **RETRACTED:** uploaded `_P.pak` is stock data. It is MVH addon data.
- **RETRACTED:** direct `_P.pak` was proven to break fonts. Early tests were contaminated.
- **RETRACTED:** official Oodle 2.9.10 is inherently incompatible. MVH disproves this.
- **RETRACTED:** MVH is a current known-good Font oracle. It is only a structural/historical reference.
- **RETRACTED:** missing text positively proves a replacement font loaded. Missing text may be an asset-load failure.
- **RETRACTED:** dev.24 clean recipe necessarily rewrites package manifest C. The capture proves C stayed byte-identical.
- **RETRACTED:** dev.24 `inner.cache` change is only “append a PAK path”. A large aligned route/index region also changes.

Correct diagnostic principle:

> Require a **positive visual marker**.

For the next gate, that marker is deliberately obvious **Bold weight across all translated/Latin UI surfaces**.

---

## 13. Exact next gate — FULL-BOLD VISUAL TAKEOVER CONTROL

Owner-approved design:

1. Enable stable LoM-VI Translation/Core so the live screen contains obvious Vietnamese/Latin text.
2. Replace **all seven Aleo Font assets**, not only `Aleo_Regular`.
3. Use the same deliberately heavy diagnostic font for all seven.
4. Preserve each stock `.ufont` wrapper/trailing asset bytes where applicable; replace only its embedded TTF payload.
5. Use official Oodle 2.9.10 / Kraken / Normal, 64 KiB blocks.
6. Use the captured exact dev.24 LoM V12 clone as the container template.
7. Keep clone filename, seven asset paths, physical entry offsets and index topology fixed.
8. Use the **exact dev.24 route transformation** for `inner.cache`; do not hand-append the path.
9. Keep the current official package manifest C unchanged unless runtime evidence proves otherwise.
10. Keep A/local.cache unchanged.
11. Installer must be transactional/fail-closed and retain rollback of the exact pre-test state.

### Diagnostic font

A small, very heavy Noto Sans ExtraBold-class TTF with verified Vietnamese diacritics is sufficient for this gate because Vietnamese translation is deliberately enabled. CJK coverage is desirable but not worth changing the fixed-slot/container strategy merely for the diagnostic.

Final release typography is a separate decision after takeover is proven.

### Visual result reporting

Do not report only “PASS/FAIL”. Record which surfaces become Bold:

- Vietnamese body text;
- small/legal/version text;
- menu/title text;
- character/name labels;
- any untranslated CJK surface separately.

Expected decisive result:

> If many Vietnamese/Latin surfaces become dramatically heavier, custom Font takeover is positively proven.

If text remains visually stock, takeover did not occur. If some surfaces change and some do not, record the exact split before changing another variable.

---

## 14. Experiment discipline

1. Read this file first.
2. Reconcile current GitHub `main`, stable manifest and latest live game state.
3. One gate must answer one explicit decision.
4. Do not rerun a resolved experiment unless a premise materially changed.
5. A popup saying PASS is not runtime proof.
6. Prefer latest clean live evidence over old markers/handoffs.
7. Keep recovery controls available.
8. **After every decisive live result, update this file before starting the next major gate.**
9. Do not modify the stable channel while Font work is experimental.

Evidence order:

1. latest clean live result with known preconditions;
2. exact captured bytes/hashes from the tested artifact;
3. current repository and stable manifest;
4. this document after reconciliation;
5. historical handoffs;
6. speculative interpretation.

---

## 15. Recovery

If Font state becomes ambiguous:

- quarantine known LoM-VI experimental custom PAKs;
- official GMZZLauncher Verify/Repair;
- launch once;
- confirm small/legal/version text visible;
- only then start the next clean gate.

Do not delete arbitrary caches by guesswork.

---

## 16. Next-session instruction

Begin with:

> Read `docs/CURRENT_STATE.md` as authority. Reconcile current GitHub `main` and the owner's latest live game state. Do not repeat resolved/retracted experiments. Continue only the smallest unfinished step toward the **FULL-BOLD VISUAL TAKEOVER CONTROL**.
