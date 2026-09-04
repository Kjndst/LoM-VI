# LoM-VI Handoff — 2026-09-04 — Full-Bold Visual Takeover

**Authority:** read `docs/CURRENT_STATE.md` first. This handoff is only the compact execution pointer for the next chat.

**Repo:** `Kjndst/LoM-VI`  
**Branch:** `main`  
**HEAD at handoff:** `f48a9971b92d7cfc275302640058a114ce4148ef`  
**Stable channel must remain untouched during this experiment.**

---

## 1. Locked history — do not reinterpret

1. **Vietnamese localization has visibly worked in-game before.** Some regions remained Chinese because of untranslated data / incomplete Core runtime coverage / source-display paths not yet reached.
2. **B+C is the only Font route that has ever produced visible interaction.** The visible interaction was missing text with bad payloads. This proves route influence, **not** successful alternate-font rendering.
3. **LoM-VI has never yet positively rendered a different replacement font in-game.** Stock-clone PASS is still stock font; missing text is not a Font PASS.
4. **MVH is not current working proof.** Mê Việt Hóa is historical/structural reference only; do not use it as a current known-good runtime oracle.

The first real Font PASS must show an unmistakably different face/weight in the live game.

---

## 2. Latest decisive evidence

### Official clean baseline

Official GMZZLauncher Verify/Repair was run and stock game was launched.

Result:

> **small/legal/version text visible**

### Clean direct `_P.pak` tests

From the repaired B/C-neutral baseline:

- exact-stock Aleo direct `_P.pak` → text remained visible, no visual change;
- MVH direct `_P.pak` → text remained visible, Chinese/font remained stock-looking.

Conclusion:

> **PAK-only is not a sufficient demonstrated Font replacement solution on this build.**

Do not repeat PAK-only testing without a materially new mount premise.

---

## 3. B+C recipe capture — PASS and restored

User successfully ran:

`LoM-VI-BC-Recipe-Capture.exe`

SHA-256:

`318a79c21d1ac30757b87d6dd4e00bf10979b655effe16ea6e4a19b6e8a00626`

Returned artifact:

`LoM-VI-BC-Recipe-Capture.zip`

**Next chat must retrieve/search this actual ZIP through Files before asking the owner to upload it again.**

Capture result:

`PASS_CAPTURED_AND_RESTORED`

Important exact findings:

- clean `inner.cache`: size `17,256,852`, SHA-256 `164d16c4835e4536dbdac9ace67bfafd3378f5c872ee7e58451e1f6acab5193e`
- dev24-r4 `inner.cache`: size `17,256,905`, SHA-256 `e5c702c11ec55aeebe2d4f1a69dc9eb48b129863eef39af14ccf88ae88c1cdc1`
- `local.cache`: unchanged, SHA-256 `3435ba0f98e6423e579238f4da73a0d990877444a8fb28ee8034c7f946f67603`
- `package_2018737.manifest`: unchanged byte-for-byte, SHA-256 `60c21eaf5f65cfed3ed2a93f4c07a9a1f572e551c19509bca84c3ea1631779ba`
- `signature.txt`: unchanged, SHA-256 `08fd107316378648ef015573500433869260404297f58be2bc84510becb28cbf`
- dev24 clone PAK installed during capture: `Content/Paks/pakchunk99998-Windows_LVI_STOCK_CLONE_P.pak`, size `25,867,666`

Operational refinement:

> On the current clean build, known-good dev24-r4 is **official C unchanged + patched B/inner.cache + clone PAK**.

The inner-cache mutation is **not** merely a `+53` byte path append. A substantial aligned route/index region changes too. Do not hand-append a PAK path.

The capture helper restored the exact pre-capture state after collecting evidence.

---

## 4. Current live machine state at handoff

Because the recipe-capture helper restored pre-state, the machine is **not left in dev24-r4**.

The pre-capture state included the direct MVH `_P.pak` from the clean PAK-only test. The next experimental installer must therefore be transactional and explicitly account for/quarantine conflicting direct diagnostic PAK state instead of assuming a pristine directory.

If state becomes ambiguous, use the established recovery authority:

> quarantine LoM-VI experimental PAKs → official Verify/Repair → launch once → confirm small/legal/version text visible.

Do not delete arbitrary cache files by guesswork.

---

## 5. Exact next gate — build it, do not add another diagnostic

### FULL-BOLD VISUAL TAKEOVER CONTROL

Owner-approved purpose:

> **Produce the first positive visual proof that a different font can render in-game.**

Design:

1. Enable stable LoM-VI Translation/Core so live UI contains obvious Vietnamese/Latin text.
2. Replace **all seven relevant Aleo Font assets**, not only `Aleo_Regular`.
3. Use the **same deliberately very heavy Bold/ExtraBold diagnostic face** across all seven.
4. Prefer full Vietnamese + CJK coverage if it fits cleanly; at minimum Vietnamese/Latin must be covered because Translation is deliberately ON.
5. Preserve each original `.ufont` wrapper/trailing asset bytes where required; replace only embedded font payload.
6. Use **official Oodle 2.9.10 / Kraken / Normal**, 64 KiB blocks. Do not resume codec/level roulette.
7. Use the **captured exact dev24 V12 clone PAK as the container template**.
8. Preserve clone filename, seven asset paths, physical entry offsets, encoded-entry offsets, path-hash index and directory-index topology as far as possible.
9. Use the **exact captured dev24 `inner.cache` route transformation**, not a guessed B mutation.
10. Keep current official C manifest unchanged unless direct evidence requires otherwise.
11. Keep A/local.cache unchanged.
12. Installer must be fail-closed, transactional, verify hashes, back up exact pre-state, and rollback on failure.
13. Do **not** modify stable channel versions/payloads for this experimental gate.

Seven Font paths in captured clone:

1. `C7/Content/Arts/UI_2/Resource/Font/Aleo_Regular.ufont`
2. `C7/Content/Arts/UI_2/Resource/Font/Aleo_Regular_SDF.ufont`
3. `C7/Content/Arts/UI_2/Resource/Font/Aleo_Title.ufont`
4. `C7/Content/Arts/UI_2/Resource/Font/Aleo_Title_SDF.ufont`
5. `C7/Content/Arts/UI_2/Resource/Font/Aleo_Title_SDF_HeadName.ufont`
6. `C7/Content/Arts/UI_Update/Resource/Font/Aleo_Regular_Update.ufont`
7. `C7/Content/Arts/UI_Update/Resource/Font/Aleo_Title_Update.ufont`

Captured physical entry offsets:

- Regular `0`
- Regular_SDF `5,632,000`
- Title `11,268,096`
- Title_SDF `14,585,856`
- Title_SDF_HeadName `17,928,192`
- Regular_Update `21,241,856`
- Title_Update `22,546,432`

Captured encoded-entry offsets:

`0, 572, 1144, 1512, 1880, 2248, 2388`

Known special case: `Aleo_Title_SDF` has trailing asset metadata beyond the embedded font payload. Preserve the original wrapper/tail; do not blindly replace the entire `.ufont` with a bare TTF.

---

## 6. Live PASS criterion

Do not call installer popup success a runtime PASS.

After install, open the game and record surfaces separately:

- Vietnamese body text
- small/legal/version text
- menu/title text
- character/name labels
- untranslated CJK regions

**True Font PASS:** multiple translated/Latin surfaces visibly become dramatically heavier/different. This must be obvious by eye.

If some surfaces change and others remain stock, record the split; that is useful partial coverage evidence.

If text merely disappears, Font replacement is **not** proven.

---

## 7. Do not repeat

Unless a material premise changes, do not spend another gate on:

- A-only/B-only/C-only isolation;
- PAK-only as the Font solution;
- random Oodle codec/level changes;
- searching local Oodle DLLs / Unreal installs;
- generic UnrealReZen hardlink workarounds;
- MVH as current runtime proof;
- interpreting missing text as positive Font takeover;
- final IBM/Spectral typography before positive alternate-font rendering is achieved.

---

## 8. Translation/Core context for the visual gate

Translation has historically worked visibly in-game. Stable Translation currently contains the Vietnamese data lane; historical package reports include tens of thousands of exact-ID/safe-literal entries. Some UI remains Chinese because Core/runtime coverage is incomplete; that is a later lane.

For this gate, the purpose of Translation ON is simply to provide obvious Vietnamese/Latin surfaces where a Bold replacement is unmistakable.

Do not broaden into Translation QC/Core coverage during the Font gate.

---

## 9. Start-of-next-chat instruction

Paste/use this instruction:

> **Continue LoM-VI from `docs/CURRENT_STATE.md` and `docs/HANDOFF-2026-09-04-FULL-BOLD.md` as authority. Reconcile `main` first. Retrieve `LoM-VI-BC-Recipe-Capture.zip` through Files before asking me to reupload it. Do not repeat resolved Font diagnostics. Build the smallest unfinished deliverable: the transactional FULL-BOLD VISUAL TAKEOVER CONTROL using the captured dev24 clone/inner-cache recipe, with Translation ON and all seven Aleo assets changed to one unmistakably heavy diagnostic font. Do not modify stable channel.**
