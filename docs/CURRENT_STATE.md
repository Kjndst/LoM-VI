# LoM-VI — Current State / Continuity Authority

**Status:** ACTIVE LIVING AUTHORITY  
**Last reconciled:** 2026-09-04 (+07)  
**Repository:** `Kjndst/LoM-VI`  
**Reconciled base before this document:** `main@d6445c0e0f7c533cc306d945e9286c9ba4ec0a5b`

> This file exists to prevent context drift. Read it before continuing development, especially Font/container work.
>
> When a live result conflicts with an older handoff, speculative explanation, or old assistant conclusion, update this file and treat the newer verified result as authority.

---

## 1. Product goal

LoM-VI is a Vietnamese localization for **Lord of Mysteries** with three independent update components:

- **Translation** — Vietnamese wording/data.
- **Core** — runtime/loader/hook coverage.
- **Font** — game font payload/integration.

The desired end-user product is a lightweight patcher/updater. Ordinary Translation/Core/Font changes should be delivered from GitHub without requiring a new launcher EXE unless launcher behavior itself changes.

Translation goals are not merely “Chinese → Vietnamese”:

- terminology should feel familiar to readers of *Quỷ Bí Chi Chủ*;
- avoid mechanical/machine-like wording;
- prefer short UI-safe wording where long translations break layout;
- skill/item descriptions must remain precise enough for competitive play/build decisions;
- Translation, Core and Font must remain separately updateable.

Current stable channel authority (`channel/manifest.json` at the reconciled base):

- Core: `0.2.0.4`
- Translation: `2026.09.03.4`
- Font: `2026.09.03.2`

**Important:** the stable manifest containing a Font component is not proof that final Font integration is solved. Do not promote an experimental font payload under an unchanged version.

---

## 2. Current development focus

**Current blocker: reliable Font takeover.**

Translation/runtime work is not the current experimental variable. The Font lane must first answer:

> Can LoM-VI route a newly built font payload into all relevant game font assets reliably, with the current game build, without missing text?

The current visual validation strategy is no longer “did one small text region disappear?”. The next decisive live gate will deliberately make **all relevant font families visibly Bold**, while Vietnamese translation is enabled, so takeover is obvious by eye.

---

## 3. Current live game state — latest reported result

Latest clean sequence:

1. experimental clone was quarantined;
2. official GMZZLauncher **Verify/Repair** was run;
3. game launched stock;
4. **small/legal/version text rendered correctly**;
5. direct exact-stock Aleo `_P.pak` was then tested from this clean baseline;
6. small text still rendered and UI looked stock;
7. direct MVH `_P.pak` was then tested from the same clean B+C-neutral baseline;
8. small text still rendered and the visible font/Chinese text remained stock-looking.

Latest reported screen therefore has:

- stock-looking Chinese UI;
- small text present;
- direct MVH `_P.pak` placed by the diagnostic gate;
- no evidence that direct PAK-only routing wins Font asset resolution.

Do **not** infer from “small text still present” alone whether the direct PAK container was mounted internally. The useful conclusion is narrower:

> **Direct `_P.pak` alone did not produce visible Font takeover.**

The uploaded MVH `Aleo_Regular` is known to contain the relevant CJK codepoints and remapped glyphs; if that font had become active, strings such as `混沌海` would visibly differ. They did not.

---

## 4. Font route terminology

Historical route labels:

- **A** = `C7/Saved/kscache/local.cache`
- **B** = `C7/Content/inner.cache`
- **C** = active `C7/Saved/kscache/package_*.manifest`

Proven historical route matrix:

| Route | Result |
|---|---|
| no A / no B / no C | stock font |
| A only | stock font |
| B only | stock font after asset update |
| C only | stock font after asset update |
| A+B | stock font |
| **B+C** | **Font route takeover occurs** |
| A+B+C | same takeover behavior as B+C |

Therefore:

> **B+C is the proven minimum route pair. A is not required for Font takeover.**

Do not re-run A/B/C isolation unless the current game build changes in a way that invalidates this evidence.

---

## 5. Known-good controls

### 5.1 Official recovery baseline

The strongest clean recovery baseline is:

1. remove/quarantine LoM-VI experimental custom PAKs;
2. run official GMZZLauncher **Verify/Repair**;
3. launch game;
4. confirm small/legal/version text renders.

This was reconfirmed live on 2026-09-04.

### 5.2 dev.23 — Compressed Stock Clone

Design:

- B+C route;
- custom LoM V12 PAK;
- exact stock `.ufont` payloads;
- exact stock Oodle-compressed bytes copied from the installed game.

Result:

> **PASS — text rendered normally.**

This proved that B+C, a custom V12 PAK, and the custom writer can work.

### 5.3 dev.24-r4 — Exact dev.23 Restore

Recreated the same exact-stock-Oodle control.

Result, repeatedly reconfirmed:

> **PASS — small/body text renders.**

Known artifact SHA-256:

`2172575f1a410b43d17253490fea1ff0112c62546ad52b1bc886b794f797e146`

This remains the historical experimental control, but official Verify/Repair is the preferred clean-stock recovery when contamination is uncertain.

### 5.4 dev.30-r2 — regenerated PakEntry with exact stock Oodle

Purpose:

- exact stock raw Aleo;
- exact stock Oodle payload bytes;
- PakEntry/encoded metadata regenerated through the custom writer path.

Immediate live result and screenshot showed small text present.

Interpretation:

> The custom PakEntry writer is not inherently rejected when it carries exact stock payload bytes.

Do not use dev.30-r2 as the only recovery baseline; use dev.24-r4 or official Verify/Repair.

---

## 6. Compression experiments — what happened

### dev.24-r2 — stock font, `None`

Result: **missing small/body text**.

### dev.24-r3 — stock font, `Zlib`

Result: **missing small/body text**.

### dev.24-r4 — exact stock Oodle again

Result: **text returned**.

### dev.29-r2 — exact stock Aleo raw, freshly Kraken-compressed by OSS encoder

Result: **missing small text**.

Exact tested EXE SHA-256:

`2580f53e535c245d775e16c2fb341d6401aa9277bffc24e2ed3ac37e8ea9078a`

Fresh payload details recovered from the exact tested EXE:

- 139 blocks;
- 64 KiB raw partitioning;
- total compressed size `5,734,782` bytes.

### h2r3 — only block001 fresh OSS Kraken

- block000 = exact stock;
- block001 = fresh OSS Kraken;
- block002..138 = exact stock.

Result: **missing small text**.

### h2o1 — only block001 official Oodle SDK 2.9.10

Same isolation, but block001 was recompressed with official Oodle SDK.

Result: **missing small text**.

### Community/Oodle comparison breakthrough

Later analysis of the actual MVH addon established:

- MVH contains a large custom `Aleo_Regular`;
- MVH uses Oodle-compressed 64 KiB blocks;
- recompressing that MVH raw font with official Oodle 2.9.10 / Kraken / Normal reproduced its 525 compressed blocks byte-for-byte.

Therefore the earlier broad conclusion:

> “fresh official Oodle is incompatible with C7”

is **RETRACTED**.

The current interpretation is:

> failures in dev.29/h2 cannot be blamed on the Oodle codec alone; route/container metadata consistency must be treated as a first-class variable.

Do not resume random Kraken/Mermaid/Leviathan/level experiments.

---

## 7. Direct `_P.pak` experiments — corrected authority

### Early direct-Pak tests were contaminated

Several early direct `_P.pak` tests appeared to make small text disappear. A later read-only audit found that an old dev.24 clone PAK plus modified B+C state were still active.

Therefore those early results are **INVALID as direct-Pak route evidence**.

### Clean A/B retest after Official Verify/Repair

From an officially repaired stock baseline where small text was visibly present:

#### Exact-stock Aleo direct `_P.pak`

- one `Aleo_Regular.ufont`;
- exact stock raw bytes;
- exact stock Oodle bytes;
- no B+C mutation.

Result:

> **small text remained present; no visible font change.**

This by itself was ambiguous because stock input can look identical whether the PAK wins or is ignored.

#### MVH direct `_P.pak`

Then the direct PAK was switched to the historical MVH addon without enabling B+C.

Result:

> **small text remained present and visible font/Chinese text remained unchanged.**

The MVH font includes the CJK codepoints visible on screen and intentionally remaps glyphs, so the unchanged visible text is strong evidence that the MVH Font asset did **not** become active.

Current conclusion:

> **PAK-only is not a sufficient Font takeover route on the current game.**

Do not repeat PAK-only tests unless a new mount mechanism or game update materially changes the premise.

---

## 8. MVH reference — what it is and is not

Uploaded files named like:

`pakchunk0-Windows_P.pak`

are **MVH addon/mod PAKs**, not the original stock game PAK.

The real stock game PAK authority is the installed file:

`C7/Content/Paks/pakchunk0-Windows.pak`

Never use an uploaded MVH `_P.pak` as a stock-byte oracle.

MVH is also a **historical/launch-era reference**, not a current known-good patch. It has previously shown missing-text behavior on the current game.

However, MVH remains valuable structurally because its builder was statically observed to work with more than a loose PAK, including:

- `inner.cache`;
- `local.cache`;
- active `package_*.manifest`;
- container/route preparation logic;
- `.ucas/.utoc` related layers.

This aligns with the proven B+C requirement.

---

## 9. Community tooling research — useful findings

Community tooling was investigated to avoid reinventing Unreal packaging.

Useful findings:

- current CUE4Parse has a **Lord of Mysteries-specific game mode/parser**;
- the game uses custom LoM PAK/container behavior beyond generic UE assumptions;
- generic old UnrealReZen/UE5.7 probing was the wrong abstraction for this game;
- `repak`/community Oodle loader demonstrated a clean way to use official Oodle compression instead of hunting local DLLs.

Failed/inconclusive probes that must **not** be repeated as if they were new evidence:

- scanning installed games for `oo2core_*_win64.dll` — none found;
- scanning local Unreal Engine SDK installs — none found;
- generic UnrealReZen IoStore preflight — failed before a meaningful LoM-specific conclusion;
- hardlink-based temporary IoStore view — Windows access denied; wrapper failure only.

The correct lesson is not “community tooling failed”. It is:

> use LoM-specific parsing/packaging knowledge, not generic UE5 assumptions.

---

## 10. Retracted or corrected conclusions

These are explicit anti-context-drift rules.

### RETRACTED: uploaded `_P.pak` is stock game data

False. It is the MVH addon.

### RETRACTED: direct `_P.pak` was proven to break fonts

False. The initial disappearance tests were contaminated by active B+C/dev.24 clone state.

Clean official-repair retest showed direct PAK-only produced no visible Font takeover.

### RETRACTED: official Oodle 2.9.10 is inherently incompatible

False. Official Oodle reproduced MVH's valid compressed Font stream byte-for-byte.

### RETRACTED: MVH is a known-good current Font oracle

False. MVH is historical and itself can exhibit missing text on the current game.

### RETRACTED: missing Chinese after a custom font proves that custom font loaded

Not necessarily. Missing text can also mean the asset failed to load. Require a positive visual takeover marker.

### CORRECTED experimental principle

A successful gate must establish a **positive marker**, not merely absence/presence of text.

For the next Font gate, the positive marker is deliberately obvious **Bold weight across all Font families**.

---

## 11. Current next gate — FULL-BOLD VISUAL TAKEOVER CONTROL

Owner-approved diagnostic design:

1. **Enable LoM-VI Vietnamese translation** so the screen contains obvious Latin/Vietnamese diacritics as well as CJK where still present.
2. Replace **all seven relevant Aleo Font assets**, not just `Aleo_Regular`.
3. Use the **same deliberately heavy/Bold font** for every family.
4. The diagnostic font must cover both **Vietnamese and Chinese/CJK** so fallback ambiguity is removed.
5. Preserve each original `.ufont` wrapper/topology as required; change the embedded font payload, not unrelated asset structure.
6. Compress with the proven official-Oodle path.
7. Build the LoM-compatible V12 custom PAK.
8. **Regenerate B+C metadata from that exact newly built PAK/state. Do not reuse stock-clone B+C metadata blindly.**
9. Do not change A/local.cache unless new evidence proves it is required; historical route isolation says A is unnecessary.

### Visual PASS criterion

A successful takeover should be obvious without pixel comparison:

- body text becomes substantially heavier;
- small/legal/version text becomes substantially heavier;
- title/menu text becomes substantially heavier;
- Vietnamese text uses the same Bold family;
- CJK text also uses the same Bold family or otherwise shows the expected custom glyph appearance.

If the UI remains stock-looking, Font takeover did not occur.

If some families change and others do not, record exactly which surfaces changed; do not collapse that into a generic PASS/FAIL.

### Diagnostic font choice

Use one OFL/free font with strong visual weight and full CJK + Vietnamese coverage (for example a Noto Sans CJK SC Bold/Black-class face). The exact aesthetic choice is diagnostic-only and is **not** the final release-font decision.

---

## 12. Immediate precondition before Full-Bold build

A pending helper was prepared to capture the exact known-good B+C recipe instead of guessing it:

`LoM-VI-BC-Recipe-Capture.exe`

SHA-256:

`318a79c21d1ac30757b87d6dd4e00bf10979b655effe16ea6e4a19b6e8a00626`

Intended behavior:

- snapshot current state;
- temporarily remove the direct MVH `_P.pak`;
- run exact dev.24-r4 known-good;
- capture B+C before/after plus clone PAK;
- restore the pre-run state byte-for-byte.

**As of this continuity update, the owner has not reported running this capture yet.**

Do not assume its output exists until a capture ZIP is actually returned and inspected.

If a cleaner source-level way to reproduce the exact B+C recipe is recovered from the repo/reference before running this helper, prefer that; do not add another diagnostic solely for convenience.

---

## 13. Experiment discipline from now on

To prevent another loop:

1. **Read this file first.**
2. Reconcile current GitHub `main`, stable manifest, and live game state.
3. Do not trust stale local marker files over current hashes/live result.
4. One gate must answer one explicit decision.
5. Do not change route + compression + font topology in the same diagnostic unless the gate is intentionally an end-to-end visual takeover test.
6. Do not rerun an experiment listed above unless a material premise changed.
7. Do not treat an operation/popup saying PASS as runtime proof; inspect the game result.
8. Keep recovery controls available.
9. After every decisive live result, **update this file before starting the next major gate**.
10. Stable channel components must not be silently replaced under the same version.

### Evidence ranking

When evidence conflicts, prefer in this order:

1. latest clean live game result with known preconditions;
2. exact file hashes / captured bytes from the tested artifact;
3. current repo source and current stable manifest;
4. this continuity document after it is updated with those facts;
5. historical handoffs;
6. old speculative assistant interpretation.

---

## 14. Do-not-repeat list

Unless a premise materially changes, do **not** spend more gates on:

- A-only/B-only/C-only route isolation;
- direct `_P.pak` alone as a Font solution;
- hunting installed games for Oodle DLLs;
- hunting a local Unreal Engine install solely for Oodle;
- random Oodle codec/level roulette;
- treating OSS encoder roundtrip as proof of C7 acceptance;
- generic UnrealReZen hardlink workarounds;
- using MVH addon bytes as stock bytes;
- IBM/Spectral/final typography selection before reliable takeover is proven;
- interpreting “missing text” as positive proof that a specific replacement font loaded.

---

## 15. Recovery / safety notes

If experimental Font state becomes ambiguous:

- quarantine known LoM-VI custom PAKs;
- official GMZZLauncher Verify/Repair;
- launch once;
- confirm small/legal/version text is visible;
- only then begin a new clean A/B gate.

Do not delete arbitrary game caches by guesswork.

The final patcher should remain fail-closed and transactional around invasive game-file changes, with exact rollback/verification.

---

## 16. Stable component contract reminder

`docs/UPDATE_CONTRACT.md` remains authority for component ownership:

- wording/data → Translation;
- runtime/hooks/coverage → Core;
- font payload/integration → Font;
- launcher EXE only changes when launcher/update behavior itself changes.

Font experimentation must not accidentally broaden into a launcher redesign.

---

## 17. Next-session instruction

A new session continuing LoM-VI should begin with:

> Read `docs/CURRENT_STATE.md` as authority. Reconcile current GitHub `main` and the user's latest live game state. Do not repeat experiments listed as resolved/retracted. Continue only the smallest unfinished step toward the **FULL-BOLD VISUAL TAKEOVER CONTROL**.

If the user reports a new decisive live result, update this document before broadening scope.
