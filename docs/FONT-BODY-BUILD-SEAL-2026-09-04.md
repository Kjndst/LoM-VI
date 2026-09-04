# LoM-VI — Body Font Production Build Seal — 2026-09-04

**Status:** `SEALED_MAINTAINER_PASS` — **NOT YET LIVE-ACCEPTED**  
**Target game build:** `2018737`  
**Development Font version:** `2026.09.04.1-dev`  
**Package:** `font-2026.09.04.1-build2018737.zip`

This record freezes the exact construction and validation identity of the first production Body-only IBM Plex candidate. It is a build/validation record, not a claim that this exact package has already rendered successfully inside C7.

---

## 1. Proof boundary — do not blur these levels

### Already live-proven before this build

1. **Runtime route:** current official C + exact dev.24-patched B + custom clone PAK can take over the Font assets.
2. **PAK/container:** the custom V12 clone topology is accepted when carrying stock-valid Oodle Font payloads.
3. **Glyph mechanic:** rewriting outlines in already accepted original TrueType GIDs can render replacement glyph shapes in C7. r11-r14 established the existing-GID principle; appended-GID dependence is not required and is avoided in production.

### Proven for this exact package off-machine

1. Exact stock-clone topology is preserved.
2. Only the three Body UFonts are semantically modified.
3. Four Title UFonts remain byte-identical to stock raw data.
4. Same-Unicode IBM Plex replacement preserves stock cmap/glyph-count/GID order and unsupported stock coverage.
5. Changed Oodle blocks fit their existing physical slots.
6. Full padded-slot Oodle decode passes with CRC checking.
7. All seven physical entries round-trip to their intended raw UFonts.
8. Encoded index/footer remain byte-identical.
9. Package layout matches the dev.10 thin-client Font contract.
10. Package SHA-256 is sealed.

### Still requires live acceptance

This exact IBM Plex package has **not yet been rendered by C7**. Development live acceptance must still verify:

- Body/small UI text renders rather than disappearing;
- Vietnamese diacritics render as intended;
- Chinese/CJK and unsupported stock glyphs remain available;
- widths/overflow are acceptable;
- the two changed Leviathan blocks are accepted by the game runtime in this PAK context.

Do not call this package stable or production-live PASS before that test.

---

## 2. Sealed package identity

### ZIP

`font-2026.09.04.1-build2018737.zip`

- size: `47,643,492` bytes
- SHA-256: `4e363da26fc09eb59e41e92abb5ee3f2e05aa9fdc96922fb993025a1d381a4a2`

### Candidate clone PAK

`Content/Paks/pakchunk99998-Windows_LVI_STOCK_CLONE_P.pak`

- size: `25,867,666` bytes
- SHA-256: `ef86be95b380eaeb4cf021ea6145ef024f2f671d7c34f90877b7103340499633`

### Exact captured stock-clone source

- SHA-256: `2495363dc7e9330ad7fa1f468f4dadeb9a6964611307bfcbd14eb4f2f8fab974`
- candidate size equals stock-clone size: **PASS**
- strict physical-diff allowlist: **PASS**

The source clone comes from the already captured `LoM-VI-BC-Recipe-Capture.zip`; no new owner-side clone capture is required.

---

## 3. Runtime route packaged for dev.10

The runtime route remains the previously proven recipe:

> **current official C + exact dev.24-patched B + custom clone PAK**

A/local.cache remains outside this package. Official C manifest/signature remain untouched.

Hashes used by the package contract:

- clean `Content/inner.cache`: `164d16c4835e4536dbdac9ace67bfafd3378f5c872ee7e58451e1f6acab5193e`
- dev.24 patched `Content/inner.cache`: `e5c702c11ec55aeebe2d4f1a69dc9eb48b129863eef39af14ccf88ae88c1cdc1`

ZIP layout:

```text
game/
  Content/
    inner.cache
    Paks/
      pakchunk99998-Windows_LVI_STOCK_CLONE_P.pak
clean/
  Content/
    inner.cache
validation/
  BODY_PAK_VALIDATION.json
  FONT_BUILD_REPORT.json
```

`game/` is the installation payload. `clean/` contains the deterministic clean B state used by Font uninstall when safe. `validation/` is evidence only and must not be copied into C7.

A dev.10 contract simulation was performed on this layout: install produced the intended patched B + candidate clone PAK; uninstall removed the clone and restored the known clean B state.

---

## 4. Body-only mapping

Donor face:

> **IBM Plex Sans Condensed Medium**

Modified UFonts only:

1. `C7/Content/Arts/UI_2/Resource/Font/Aleo_Regular.ufont`
2. `C7/Content/Arts/UI_2/Resource/Font/Aleo_Regular_SDF.ufont`
3. `C7/Content/Arts/UI_Update/Resource/Font/Aleo_Regular_Update.ufont`

All four Title UFonts remain stock raw bytes during this gate.

Selected existing GIDs:

- `Aleo_Regular` → `277`
- `Aleo_Regular_SDF` → `277`
- `Aleo_Regular_Update` → `109`

Production mapping rule:

> `Unicode(stock) ∩ Unicode(IBM Plex)` → keep the stock Unicode mapping and original accepted GID identity, but replace that GID's glyph representation with the IBM Plex glyph for the same Unicode.

If IBM Plex does not contain the Unicode, keep the stock glyph untouched.

No CJK→Latin marker remap is used. No large append-GID bank is used.

---

## 5. Table-preserving SFNT method

The production candidate is **not** a normal FontTools re-save of the entire font.

Naive full serialization was rejected because it moved/rebuilt `glyf/loca`, causing roughly 138/139 Oodle blocks to change and making multiple fresh blocks overflow fixed physical slots.

The sealed method is:

1. Start from the exact embedded stock SFNT bytes inside each stock UFont wrapper.
2. Keep stock `cmap`, physical glyph count, glyph order/GID identity and unsupported stock glyph coverage.
3. Determine the same-Unicode stock↔IBM intersection.
4. Compile IBM Plex glyphs into the already existing selected stock GIDs.
5. Use representation strategies that preserve the IBM glyph shape while reducing raw/entropy cost where useful:
   - `simple`;
   - `composite-remap`;
   - `decomposed`;
   - `equiv-composite`.
6. Repack only the necessary early `glyf` region inside the original stock `glyf` table budget; retain the original table envelope rather than shifting later SFNT tables.
7. Update `loca` to the new in-table glyph positions.
8. Update `hmtx` for the intentionally adopted IBM metrics.
9. Preserve unrelated tables byte-for-byte where expected.
10. Recompute table checksums and `head.checkSumAdjustment`; final whole-SFNT checksum is `0xB1B0AFBA`.
11. Inject the modified SFNT back into the original UFont wrapper without changing the surrounding UFont size/topology.
12. Recompress only physical PAK blocks whose raw 64 KiB chunks changed.

The layout includes deliberate zero-padding/slack placement inside the existing `glyf` table budget. This padding changes representation/layout only; semantic validation checks that intended glyph outlines/metrics remain correct.

### Final SFNT validation summary

`Aleo_Regular`:

- selected GIDs: `277`
- GID range touched: `1..1229`
- physical glyphs: `29,034`
- cmap mappings: `29,000`
- changed raw bytes: `115,388`
- final raw SHA-256: `7fdbbe5cd341b82166f67cbc3c73e9e05a6740ed4cf20e741e3c9ab65bc0a6f4`

`Aleo_Regular_SDF`:

- selected GIDs: `277`
- GID range touched: `1..1229`
- physical glyphs: `29,034`
- cmap mappings: `29,000`
- final raw SHA-256: `1352c070e8d8aa14514aa40c96587c52787a952ce358727c837d38b74159cb40`

`Aleo_Regular_Update`:

- selected GIDs: `109`
- GID range touched: `1..135`
- physical glyphs: `7,144`
- cmap mappings: `7,143`
- changed raw bytes: `8,946`
- final raw SHA-256: `141aedcc0e5a14312c4d1d180e202b23d358088109018967fece10dbe7561084`

For the two large Regular assets, tables including `GDEF`, `GPOS`, `GSUB`, `OS/2`, `cmap`, `gasp`, `hhea`, `maxp`, `name`, `post`, `prep`, `vhea`, and `vmtx` remained exact where reported by the build validator. `DSIG` was also exact on those assets.

---

## 6. Fixed PAK topology

Seven physical entry offsets remain:

`0, 5632000, 11268096, 14585856, 17928192, 21241856, 22546432`

Known encoded-entry offsets remain:

`0, 572, 1144, 1512, 1880, 2248, 2388`

Validated invariants:

- physical offsets unchanged;
- compressed block ranges unchanged;
- total compressed physical slot sizes unchanged;
- encoded index/footer byte-identical;
- Title entries `2/3/4/6` raw byte-identical to stock;
- physical SHA1 recomputed over each full compressed-slot payload;
- all seven entries round-trip to their intended raw bytes.

Only changed compressed Body blocks and the corresponding three physical-entry SHA1 fields are inside the strict diff allowlist.

---

## 7. Oodle block-fit seal

Raw PAK compression chunks remain 64 KiB where applicable. Each fresh stream must be no larger than the already allocated stock physical slot; unused slot bytes are padded, and the decoder is validated against the **full padded slot** with CRC checking enabled.

### Entry 0 — Aleo_Regular

| Block | Codec | Level | Slot | Fresh | Padding | Full-slot CRC round-trip |
|---:|---|---:|---:|---:|---:|---|
| 0 | Kraken | 7 | 14,448 | 14,158 | 290 | PASS |
| 2 | Kraken | 9 | 22,562 | 20,986 | 1,576 | PASS |
| 3 | **Leviathan** | 7 | 22,682 | 20,929 | 1,753 | PASS |
| 4 | Kraken | 7 | 34,594 | 33,606 | 988 | PASS |
| 5 | Kraken | 7 | 37,084 | 37,084 | 0 | PASS |

Physical-entry SHA1: `9817875e8d7f7932bf51ae5e20cfcd977af8e171`

### Entry 1 — Aleo_Regular_SDF

| Block | Codec | Level | Slot | Fresh | Padding | Full-slot CRC round-trip |
|---:|---|---:|---:|---:|---:|---|
| 0 | Kraken | 9 | 14,718 | 14,447 | 271 | PASS |
| 2 | Kraken | 9 | 22,562 | 20,986 | 1,576 | PASS |
| 3 | **Leviathan** | 7 | 22,682 | 20,929 | 1,753 | PASS |
| 4 | Kraken | 7 | 34,594 | 33,606 | 988 | PASS |
| 5 | Kraken | 7 | 37,072 | 37,045 | 27 | PASS |

Physical-entry SHA1: `d2063f19f1d21f20571541e85ca93fae0612ca45`

The final SDF block-5 fit was achieved by moving `38` bytes of existing zero slack between adjacent selected GID regions; semantic glyph/metric validation remained unchanged.

### Entry 5 — Aleo_Regular_Update

| Block | Codec | Level | Slot | Fresh | Padding | Full-slot CRC round-trip |
|---:|---|---:|---:|---:|---:|---|
| 0 | Kraken | 8 | 39,279 | 37,916 | 1,363 | PASS |
| 28 | Kraken | 7 | 41,527 | 41,275 | 252 | PASS |
| 29 | Kraken | 7 | 30,135 | 25,182 | 4,953 | PASS |

Physical-entry SHA1: `7909246c167375b9a4f4b0c4bc2780ed856c9f4b`

### Residual runtime uncertainty

The two block-3 streams above use official Oodle **Leviathan** and pass official Oodle full-slot CRC decode off-machine. They are nevertheless part of the live acceptance boundary: C7 has not yet loaded this exact candidate, so runtime acceptance must be observed rather than inferred.

---

## 8. Seven-entry final round-trip

Expected raw identity after candidate decompression:

- entry 0: modified Body — PASS
- entry 1: modified Body — PASS
- entry 2: byte-exact stock Title — PASS
- entry 3: byte-exact stock Title — PASS
- entry 4: byte-exact stock Title — PASS
- entry 5: modified Body — PASS
- entry 6: byte-exact stock Title — PASS

Maintainer result string:

`PASS_BODY_PAK_MAINTAINER_VALIDATION`

The validation JSON files embedded in the sealed ZIP are the detailed machine-readable evidence for this build.

---

## 9. Development-channel state at seal time

`channel/manifest-v3-dev.json` has staged metadata for this exact ZIP:

- version: `2026.09.04.1-dev`
- game build: `2018737`
- package name: `font-2026.09.04.1-build2018737.zip`
- SHA-256: `4e363da26fc09eb59e41e92abb5ee3f2e05aa9fdc96922fb993025a1d381a4a2`
- `available=false`

`available` must remain false until the binary exists at the manifest URL.

Stable channel remains unchanged.

---

## 10. Exact next gate

1. Publish the sealed ZIP bytes at `channel/font-2026.09.04.1-build2018737.zip` without changing them.
2. Verify the remotely published bytes have the exact sealed SHA-256.
3. Only then set Font `available=true` in `channel/manifest-v3-dev.json`.
4. Start from a known clean build `2018737` / expected clean B state.
5. Install Font through patcher dev.10.
6. Launch C7 and visually validate Body text, Vietnamese diacritics, CJK preservation, width/overflow, and absence of missing text.
7. If Body passes, record live acceptance before beginning the Spectral Title gate.

### Known dev.10 follow-up, not part of this Body live gate

dev.10 currently carries `font.game_build` in the manifest contract but does not yet enforce that field during Font apply. Do not treat the current thin client as fully production-safe across unknown future game builds until that guard is implemented. This does not require redesigning the UX for the current controlled development test on build `2018737`.
