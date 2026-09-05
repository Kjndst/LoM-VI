# LoM-VI — Handoff 2026-09-05 — Bulk Translation Coverage

**Timestamp:** 2026-09-05 08:23 ICT (+07:00)  
**Repository:** `Kjndst/LoM-VI`  
**Primary branch:** `main`  
**Main HEAD before this handoff:** `f78a7a2e20a4974ae9ba2f535e8bb938c5c8356e`  
**Current task:** **BULK COVERAGE — increase the number of Chinese strings that already have usable Vietnamese translations. Do NOT spend the current phase on QC/polish.**

---

## 1. READ THIS FIRST — what we are doing right now

The owner explicitly changed the immediate goal from QC to **bulking**:

> Continue checking which text is untranslated, partially translated, or absent from the database. No QC needed yet. Increase Vietnamese coverage. Follow the translation rules already established.

Therefore the next chat must **not restart UI QC, terminology review, font work, patcher work, or runtime architecture work** unless a blocker is found.

### Immediate objective

Find Chinese strings that are:

1. absent from `Translation_DB` **and** `Runtime_Literals`;
2. present but `vi_full` / `vi_short` / `vi_title` still contain Chinese/CJK;
3. only partially translated / mixed Chinese + Vietnamese;
4. present in the current official game data but missing from the current DB snapshot;
5. surfaced by the latest English patch/runtime diff as a discovery clue but not yet represented in LoM-VI.

Translate them **in bulk**, persist them to Drive immediately, and continue.

### Current bulk priority order

1. **UI coverage first** — visible menu/button/system/settings/navigation/runtime strings.
2. **Items** — item sets, item names, item types/rarity, item stats, `+stat`/affix lines, set bonuses, item effects, acquisition/use notes.
3. **Skill tooltips** — descriptions, damage, range/radius/area, cooldown, stacks, proc/trigger, buff/debuff, special mechanics.
4. Remaining system/general text.
5. Dialogue/lore later.

This ordering is for **coverage**, not QC. Do not spend time polishing already-translated rows just because wording is imperfect.

---

## 2. Stable product state — DO NOT REOPEN

LoM-VI patcher/runtime/font work has already passed live acceptance and was promoted to **Stable v0.3.0**.

Current stable `channel/manifest.json`:

- schema: `lomvi.thin.v3`
- patcher minimum: `0.3.0`
- Core: `0.2.0.4`
- Translation: `2026.09.03.4`
- Font: `2026.09.05.1`
- target game build for Font: `2018737`

Stable manifest translation is **still `2026.09.03.4`**. The Drive translation work performed after stable release has **NOT yet been repackaged/published to stable GitHub**.

Do not alter the stable package while doing the current bulk pass unless the owner explicitly asks to publish a new translation build.

Font is live-passed and locked:

- Body/UI: IBM Plex Sans Condensed Medium
- Title: Spectral SemiBold

Do not reopen font topology/Oodle/native bootstrap work during translation bulking.

---

## 3. Live translation authority / data surfaces

### Google Sheet — current working translation ledger

**Spreadsheet:** `LoM-VI Translation DB`  
**Spreadsheet ID:** `1CjpAVB3BYgNTRt-XmZ4rm9jD_fHHVeQeAeAC5dBHeWA`

Important sheets:

- `Translation_DB`
- `Runtime_Literals`
- `Term_Decisions`
- `QA_Log`

### `Translation_DB` columns

`A:T`:

1. `qa_tag`
2. `id`
3. `module`
4. `path`
5. `category`
6. `priority`
7. `zh`
8. `vi_full`
9. `vi_short`
10. `vi_title`
11. `translation_status`
12. `qa_state`
13. `policy`
14. `source_record_sha256`
15. `batch`
16. `draft_note`
17. `in_game_note`
18. `owner_note`
19. `last_updated`
20. `rule_version`

When a source has reliable canonical module/path/id identity, prefer adding/updating the canonical `Translation_DB` row.

### `Runtime_Literals` columns

- `source_zh`
- `vi`
- `scope`
- `authority`
- `note`
- `last_updated`

Use `Runtime_Literals` for exact literal coverage when canonical ID/module identity is not available or for runtime paths known to bypass ID mapping.

---

## 4. EXACT current bulk checkpoint — continue from here

`QA_Log` currently records:

### `BULK-20260905-V230-01`

- **407 unique Chinese literals** surfaced in English Patch v2.3 runtime context and were absent from the `Translation_DB` snapshot.
- **329 clear/runtime candidates were already translated and added to `Runtime_Literals`.**
- They use:
  - `scope = V230_RUNTIME_BULK`
  - `authority = AI_DRAFT`
  - note = `Bulk coverage; Chinese source authority; EN v2.3 context only; no QC.`
  - date = `2026-09-05`
- 5 multiline literals were included.
- **About 78 context literals remain from that v2.3 diff.**

### THIS IS THE FIRST NEXT ACTION

Finish the remaining ~78 v2.3-discovered literals:

1. compare each against current `Translation_DB.zh` and `Runtime_Literals.source_zh`;
2. skip duplicates;
3. bulk-translate clear strings;
4. preserve placeholders/tags/newlines exactly;
5. write clear candidates immediately as `AI_DRAFT` — **do not mark them `REVIEWED` merely because they were bulk-translated**;
6. if an Item/Skill name has 4+ Han characters and is genuinely ambiguous/lore-sensitive, collect it for an owner-question batch instead of guessing.

After the remaining v2.3 batch, move to the full official current corpus gap.

---

## 5. Current official source problem / corpus gap

The user uploaded current:

**`LoM-translation.zip`**  
Conversation file id: `file_00000000108482098eee6496be28eb7e`  
Size: `5,777,491` bytes

Audit result:

- contains **46/46 Lua files**;
- all are LuaJIT bytecode, not readable plain Lua source;
- includes main `StringDB_CN_Data` and dedicated tables for item/skill/buff/loading/guide/dialogue, etc.;
- file/module identity is useful for classification and mapping;
- bytecode cannot simply be treated as readable translation text without extraction/decode/decompile work.

Historical original Chinese extraction had:

- 38/38 modules at that older checkpoint;
- 104,895 source strings;
- 104,607 CJK-bearing strings.

The current Drive `Translation_DB` has only ~23k canonical records. Therefore there is a **large potential source-coverage gap**, even though the DB previously reported `0 UNTRANSLATED` *within its existing canonical rows*.

Important distinction:

> `0 UNTRANSLATED` in the DB does NOT mean the whole game is translated. It only means every row already present in that DB has some candidate.

### After v2.3 remaining literals

Get/build a **readable current official Chinese corpus** from the 46-module current source, or use another verified current official extraction. Then perform a true set diff:

`current official unique Chinese strings`  
minus  
`Translation_DB.zh`  
minus  
`Runtime_Literals.source_zh`

Bulk-translate the missing set by priority.

Do not substitute old 38-module corpus values for the current 46-module corpus if the current source can be recovered.

---

## 6. English Patch reference rule

Latest reference used in this session: **English Patch v2.3.0**.

Use English only to:

- discover new/changed runtime strings;
- understand item/skill/mechanic context;
- identify which Chinese source string a game surface refers to;
- disambiguate source topology.

**Never make English the semantic authority.**

Production direction remains:

`Chinese source -> Vietnamese`

not:

`Chinese -> English -> Vietnamese`

Do not copy English translation tables into LoM-VI.

---

## 7. Bulk translation rules — owner style

Current bulk goal is **quantity first, while respecting already-locked style**.

### General

- Vietnamese should sound natural and familiar to readers of *Quỷ Bí Chi Chủ*.
- Avoid stiff literal/machine wording when a compact natural Vietnamese equivalent is obvious.
- UI wording should be short enough not to break layout.
- Preserve mechanic meaning; do not remove numbers, percentages, conditions, targets, ranges, stacks, cooldowns, or timing.
- Preserve all formatting tokens exactly: `%s`, `%d`, `%.2f`, `<Highlight>...</>`, `<P_Yellow>...</>`, line breaks, brackets, etc.
- Do not overwrite `LOCKED`, `OWNER_APPROVED`, or clearly owner-finalized terms with a new draft.
- For bulk additions, use `AI_DRAFT` / `NOT_TESTED` unless the row already has stronger authority.
- No QC pass now. If a draft is understandable and structurally correct, add it and move on.

### Ambiguous Item/Skill names

If an Item or Skill name is **4+ Han characters** and meaning/lore/naming is genuinely ambiguous:

- do not stall the whole batch;
- skip it temporarily;
- collect several difficult names;
- ask the owner directly in one compact batch.

Clear names should be translated without asking.

### Context-sensitive short wording

Some terms intentionally differ between compact UI and prose:

- `封印物` -> **Phong Vật** in compact UI labels; **Vật Phong Ấn** may remain in prose/tooltips where clarity is useful.
- `段位天梯` -> **Bảng Xếp Hạng** full; **BXH** in very narrow UI.
- `秒` / `%s秒` -> use **s** for compact numeric suffixes such as `30s`; normal prose may use `giây`.

---

## 8. Recent owner-locked / accepted terminology — DO NOT REVERT

### UI / world / modes

- `神弃之地` -> **Thần Khí Chi Địa**
- `灰雾之上` -> **Trên Màn Sương Xám**
- `终末猎杀` -> **Săn Cùng Diệt Tận**
- `世界冒险` / `Mạo Hiểm Thế Giới` -> **Mạo Hiểm** in compact UI
- `下次更新前不再弹出` -> **Không Hiện Lại**
- `段位天梯` -> **Bảng Xếp Hạng** / **BXH**
- `高原战` / `高原竞逐` -> **Cao Nguyên Chiến**
- `命运时刻` -> **Thời Khắc Vận Mệnh**
- `四方联赛` -> **Giải Tứ Phương**
- `众神之巅` -> **Đỉnh Chư Thần**

### Skills

- `卡牌大师` -> **Thần Bài** — **NOT Dealer**
- `梦魇冲击` -> **Xung Kích**
- `戏法表演` -> **Ảo Thuật**
- `我只是一条狗` -> **Ta Là Chó**
- `裁决之剑` -> **Tài Quyết Kiếm**
- `精神穿刺` -> **Thần Xuyên**
- `疾行气刃` -> **Tật Hành**
- `星穹裁决` -> **Tinh Quyết**
- `圣光垂慕` -> **Thánh Quang**
- `道德刺剑` -> **Thí Kiếm**
- `余震冲击` -> **Dư Chấn**
- `勇气之歌` -> **Dũng Ca**
- `星沙突击` -> **Sa Kích**
- `禁锢秘偶` -> **Con Rối Ngục Tù**
- `真理裂隙` -> **Khe Nứt Chân Lý**
- `洞察之眼` -> **Động Sát Nhãn**
- `圣光共鸣` -> **Thánh Quang Cộng Minh** because plain `圣光` already maps to **Thánh Quang**
- `潜意识海洋` -> **Thức Hải**
- `梦境复苏` -> **Mộng Phục**
- `梦境重生` -> **Mộng Sinh**
- `知识漩涡` -> **Xoáy Tri Thức**
- `偷盗者变形术` -> **Biến Hình Kẻ Trộm**
- `病痛缠身` -> **Bệnh Tật Quấn Thân**

### Items / artifacts

- `深红月冕` -> **Thâm Hồng Nguyệt Miện**
- `奥尔尼娅的回眸` -> **Ánh Mắt của Auernia**
- `蠕动的饥饿` -> **Đói Khát**
- `无瞳的将军` -> **Vô Đồng Tướng**
- `概率之骰` -> **Xúc Xắc**
- `空想格罗塞尔游记` -> **Groselle Hư Tưởng Ký**
- `鱼人袖钉` -> **Khuy Người Cá**
- `剧毒之刃` -> **Dao Độc**
- `水晶之眼` -> **Pha Lê Nhãn**
- `厄运布偶` -> **Búp Bê Xui Xẻo**
- `苍白的死亡` -> **Cái Chết Trắng**
- `生命手杖` -> **Gậy Sinh Mệnh**
- `正义钱包` -> **Ví Chính Nghĩa**

### Other accepted names from the previous question batch

Unless later overridden, the owner said unmentioned entries were temporarily accepted:

- `英雄登场` -> **Anh Hùng Đăng Tràng**
- `许愿神灯` -> **Đèn Thần Ước Nguyện**
- `月亮纸人` -> **Người Giấy Mặt Trăng**
- `荣耀之证` -> **Chứng Nhận Vinh Quang**

---

## 9. What was already done immediately before the bulk switch

`QC-20260905-UI-PASS1`:

- 69 high-confidence UI corrections were persisted to `Translation_DB` and marked `REVIEWED`.
- Examples: `躺赢 -> Nằm Thắng` in tutorial copy, visible `竞技 -> Thi Đấu`, audio/graphics/control compact wording, `Ám Thành` normalization, date/hot-update formatting, `传送 -> Dịch Chuyển`.
- One real semantic mismatch was fixed: `玩家提升<Highlight>晋升条件</>的完成进度可获得奖励。` had an unrelated potion-recipe Vietnamese sentence and was corrected.

**Do not continue that QC pass now.** The owner explicitly asked to bulk coverage first.

---

## 10. Runtime issues that are known but NOT the current task

Do not get sidetracked by these during bulk translation:

- Some Chinese text already has a translation mapping but bypasses current runtime setters/cache path.
- Early/pre-bootstrap text such as `正在校验资源文件...` may require a separate pre-boot/native route.
- Some baked banner art contains Chinese pixels and cannot be fixed by StringDB mapping.
- These are runtime/asset coverage issues, not reasons to stop bulk translation.

Store useful translations now; runtime-path expansion can be handled later.

---

## 11. Next-chat execution checklist

On the next chat, do this without asking the owner to repeat context:

1. Read this handoff as continuity authority.
2. Reconcile live `channel/manifest.json` and Drive `QA_Log` before mutation.
3. Confirm `BULK-20260905-V230-01` exists and 329 drafts are already present.
4. Continue the **remaining ~78 v2.3-discovered missing literals**.
5. Add clear translations immediately to Drive as `AI_DRAFT`; no QC.
6. Do not overwrite owner-approved/locked rows.
7. Batch ambiguous 4+ Han-character Item/Skill names for owner review; do not block bulk work.
8. After v2.3 remainder, build/obtain a readable current 46-module official Chinese corpus from `LoM-translation.zip` or another verified current extraction.
9. Diff official source against both `Translation_DB.zh` and `Runtime_Literals.source_zh`.
10. Bulk in priority order: UI -> items/set/stats/tooltips -> skill tooltips/mechanics -> rest.
11. Log each substantial bulk batch in `QA_Log` with counts and source/discovery method.
12. Do **not** publish a new stable GitHub Translation package until the owner asks or the bulk batch is intentionally promoted.

### Definition of progress for this phase

Success is measured primarily by:

- more unique current Chinese source strings having Vietnamese candidates;
- fewer absent/Chinese/mixed strings;
- preserved formatting/mechanic data;
- no loss of owner-locked terminology.

It is **not** measured by `REVIEWED` count during this phase.

---

## 12. One-line continuation prompt

Use this in the new chat if needed:

> **Continue LoM-VI from `docs/HANDOFF-2026-09-05-BULK-COVERAGE.md` as authority. Reconcile Drive QA_Log and stable manifest first, then continue BULK translation coverage from `BULK-20260905-V230-01`: finish the ~78 remaining v2.3-discovered missing literals, write clear translations to Drive as AI_DRAFT without QC, then move toward a true current 46-module official-corpus diff. Do not reopen patcher/font/runtime work and do not publish stable Translation yet.**
