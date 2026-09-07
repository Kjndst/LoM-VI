# LoM-VI - Project Closed Handoff - 2026-09-07

**Status:** CLOSED / MAINTENANCE-ONLY  
**Authority date:** 2026-09-07 (+07)  
**Repository:** `Kjndst/LoM-VI`

This document is the latest continuity authority for the completed LoM-VI development cycle. Older `docs/CURRENT_STATE.md` material remains useful as technical history, but any older statement that Stable was unchanged or that an earlier dev gate was still open is superseded by this handoff.

## 1. Final Stable state

- Patcher: `0.3.0`
- Core: `0.2.0.4`
- Translation: `2026.09.07.1`
- Font: `2026.09.05.1`
- Font game-build target: `2018737`

Stable Translation publication commit:

`44ca233a0124da45e9846e9972ff5d6267f9ade4`

Translation package:

`channel/translation-2026.09.07.1.zip`

Exact package size:

`4,939,684 bytes`

SHA-256:

`bf55ec014a4df2e81940a7bf239930be1193dbd1baa751f4f77d9ac6c55cda42`

Remote verification was performed after publication against raw GitHub content. Manifest version/hash/URL, downloaded binary size/hash and ZIP topology all passed.

Expected Translation ZIP topology is exactly:

1. `game/Saved/Mods/lua/mods/lom_vi/IdOverrides.lua`
2. `game/Saved/Mods/lua/mods/lom_vi/SafeLiterals.lua`
3. `game/Saved/Mods/lua/mods/lom_vi/UiLiterals.lua`

There is no `Init.lua` in the Translation payload. Runtime belongs to Core.

## 2. Final translation architecture

Current design is intentionally hybrid:

- `SafeLiterals.lua` handles globally safe, unambiguous exact Chinese-source fallback.
- `IdOverrides.lua` handles contextual source collisions by aggregate/split StringDB identity.
- `UiLiterals.lua` handles exact runtime/UI atoms, including known NPC-name routes.
- Core `0.2.0.4` remains unchanged and supports arbitrary dynamic split tags.

Do not replace this with blind global source substitution. A Chinese source atom may require different Vietnamese wording in different contexts.

Comparison with Lani / CPDD English Patch supports the same general runtime model: StringDB/runtime hooks plus additional fallback handling. Lani also uses baked/container text for surfaces that runtime replacement cannot persistently cover. LoM-VI deliberately did not add baked PAK/container text in this release because the project does not yet have a complete current-build block inventory and hash-guarded editing contract for that path.

If a future game update exposes persistent untranslated/reverting surfaces, treat baked/container text as a new isolated gate rather than rebuilding the translation system from scratch.

## 3. Final data/QC state

Current46 source topology at closure:

- 46 modules
- 105,018 numeric module+ID to text pairs
- 104,730 CJK numeric pairs
- 98,772 unique CJK-bearing string constants
- approximately 5,535 numeric IDs reused across modules

Final deterministic routing proof:

- `104,730 / 104,730` CJK numeric pairs covered
- `414 / 414` non-ID Current46 CJK literals covered by an intended route
- 0 unresolved Current46 CJK numeric pairs
- 0 real placeholder/brace parity failures in final QC
- 0 newly introduced invalid rich-text pseudo-tags in final QC

Final payload architecture at build time:

- 148 contextual ID overrides for 78 contextual source strings
- 98,694 globally safe literals
- 630 UI/runtime literals

Remaining CJK seen in final static scans was limited to intentional technical identifiers/file names rather than untranslated player-facing content.

Translation coverage is described publicly as approximately 99% because static data coverage does not prove that every possible runtime surface in every game state has been exercised live.

## 4. Translation authority rules

Chinese source is semantic authority.

Owner-approved canon overrides prior machine/bulk/Hachi wording.

Primary translation goals:

- terminology familiar to Vietnamese readers of Quỷ Bí Chi Chủ;
- lore-consistent style;
- short skill/item/UI names where necessary to avoid clipping and broken layout;
- exact enough skill/item/mechanic descriptions for competitive gameplay and build decisions;
- natural Vietnamese rather than literal word-for-word machine output.

Do not globally flatten repeated numeric IDs. Numeric IDs repeat across modules and must retain module context.

Do not globally substring-replace proper names or generic source atoms across prose.

Preserve placeholders, tags, line breaks and control tokens.

## 5. Font state

Vietnamese Font is optional and independent from Translation.

Its purpose is to provide stable Vietnamese glyph coverage where the stock game font cannot reliably display all Vietnamese diacritics or falls back to visually inconsistent fonts.

Current Stable Font is `2026.09.05.1`, targeted to game build `2018737`.

Historical font experiments and route diagnostics in `docs/CURRENT_STATE.md` are retained for provenance. Do not reopen discarded marker/CFF/append-GID experiments unless new evidence specifically requires them.

## 6. English Patch compatibility

LoM-VI does not depend on English Patch.

Simultaneous installation with Lani English Patch has not been officially tested, so compatibility must be treated as unknown. Do not claim coexistence is supported until a clean controlled live test proves it.

Lani English Patch was used only as a technical/runtime reference, not as translation data.

## 7. Live acceptance boundary

Technical publication gates are closed:

- authority/QC: PASS
- structural build: PASS
- GitHub publication: PASS
- raw remote manifest verification: PASS
- raw remote binary size/hash verification: PASS
- ZIP topology verification: PASS

Do not convert those results into a claim that every runtime screen has been live-tested.

If the project is reopened, first establish whether the new evidence is one of:

- new game version/data;
- Chinese leakage on a specific runtime surface;
- translated text reverting to Chinese after panel reopen/scene transition;
- NPC-name route failure;
- font breakage after a game build change;
- incorrect translation/mechanic/lore wording;
- UI clipping or overflow.

Use screenshots, exact source text and location when possible. Fix the smallest proven layer rather than reopening already-closed architecture.

## 8. Reopen protocol

When returning to the project:

1. Read this handoff first.
2. Read current `channel/manifest.json` and reconcile GitHub `main` before changing anything.
3. Check whether the game build or source data changed since this closure.
4. Use the Google Sheet `LoM-VI Translation DB` as translation authority.
5. Preserve the current Translation payload topology and Core ownership contract unless new evidence proves a required change.
6. Make a new versioned payload. Never silently replace an already published package under the same version.
7. Keep static/build verification separate from actual in-game acceptance.

## 9. Project closure

The current development cycle is complete. No unfinished implementation gate is intentionally carried forward.

Future work begins only when there is new game data, a confirmed bug, a translation correction, or a compatibility requirement.

**Đây là bản Việt Hoá miễn phí. From Linh Lan Bang with love.**
