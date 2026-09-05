#!/usr/bin/env python3
"""Build the true current-46 LoM-VI missing Chinese queue from a pristine audit.

Inputs are deliberately plain JSONL artifacts so this tool does not edit Google Drive:
  * pristine_entries.jsonl from join_current46_pristine.py
  * Translation_DB JSONL snapshot (one object per sheet row)
  * Runtime_Literals JSONL snapshot

The semantic coverage calculation is exactly:
  pristine current Chinese source
    - Translation_DB.zh
    - Runtime_Literals.source_zh

It emits both unique-source and module/path queues, sorted by the LoM-VI bulk priority:
UI -> item -> skill/mechanic -> general/system -> dialogue/lore -> debug/internal.
"""
from __future__ import annotations

import argparse
import json
import re
from collections import Counter, defaultdict
from pathlib import Path
from typing import Iterable

CJK = re.compile(r"[\u3400-\u9fff\uf900-\ufaff]")
HAN_ONLY = re.compile(r"^[\u3400-\u9fff\uf900-\ufaff]{4,12}$")

PRIORITY_RANK = {
    "ui": 0,
    "item": 1,
    "skill_mechanic": 2,
    "general_system": 3,
    "dialogue_lore": 4,
    "debug_internal": 5,
}


def load_jsonl(path: Path) -> list[dict]:
    rows: list[dict] = []
    with path.open(encoding="utf-8") as stream:
        for line_no, line in enumerate(stream, 1):
            if not line.strip():
                continue
            try:
                value = json.loads(line)
            except json.JSONDecodeError as exc:
                raise ValueError(f"{path}:{line_no}: {exc}") from exc
            if not isinstance(value, dict):
                raise ValueError(f"{path}:{line_no}: expected JSON object")
            rows.append(value)
    return rows


def classify(module: str) -> str:
    low = module.casefold()
    leaf = low.rsplit(".", 1)[-1]

    if "debug" in low:
        return "debug_internal"

    if (
        "stringconst.language_zhs" in low
        or low.endswith("shared.language_zhs")
        or low.endswith("launch.i18n.zh")
        or "rolecreateqandadata" in low
        or "createroleanswer_panel" in low
        or leaf.endswith("_guide")
        or leaf.endswith("_loading")
        or leaf.endswith("_main")
    ):
        return "ui"

    if any(token in leaf for token in ("itemgift", "itemlife", "itemnormal", "itemoutlook", "itemtask")):
        return "item"

    if any(token in leaf for token in ("skill", "buff", "aura", "spellfield", "trap")):
        return "skill_mechanic"

    if any(
        token in leaf
        for token in (
            "talk",
            "gossip",
            "tingen",
            "beckland",
            "lettertext",
            "newspaper",
            "maintask",
            "sidetask",
            "newbietask",
            "manor",
        )
    ):
        return "dialogue_lore"

    return "general_system"


def write_jsonl(path: Path, rows: Iterable[dict]) -> None:
    with path.open("w", encoding="utf-8", newline="\n") as stream:
        for row in rows:
            stream.write(json.dumps(row, ensure_ascii=False, sort_keys=False) + "\n")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("pristine_entries", type=Path)
    parser.add_argument("translation_db_rows", type=Path)
    parser.add_argument("runtime_literal_rows", type=Path)
    parser.add_argument("--output-dir", type=Path, required=True)
    args = parser.parse_args()

    pristine = load_jsonl(args.pristine_entries)
    db_rows = load_jsonl(args.translation_db_rows)
    runtime_rows = load_jsonl(args.runtime_literal_rows)

    db_zh = {
        str(row.get("zh", ""))
        for row in db_rows
        if str(row.get("zh", "")).strip() and str(row.get("zh", "")) != "zh"
    }
    runtime_zh = {
        str(row.get("source_zh", ""))
        for row in runtime_rows
        if str(row.get("source_zh", "")).strip() and str(row.get("source_zh", "")) != "source_zh"
    }
    covered = db_zh | runtime_zh

    clean_entries: list[dict] = []
    seen_entry: set[tuple[str, str, str]] = set()
    for row in pristine:
        source = str(row.get("source_zh", row.get("source", "")))
        module = str(row.get("module", ""))
        path = str(row.get("path", ""))
        if not source or not CJK.search(source):
            continue
        identity = (module, path, source)
        if identity in seen_entry:
            continue
        seen_entry.add(identity)
        category = classify(module)
        clean_entries.append(
            {
                "module": module,
                "path": path,
                "source_zh": source,
                "category": category,
                "priority_rank": PRIORITY_RANK[category],
                "covered_by_exact_source": source in covered,
            }
        )

    missing_entries = [row for row in clean_entries if not row["covered_by_exact_source"]]
    missing_entries.sort(
        key=lambda row: (
            row["priority_rank"],
            row["module"].casefold(),
            row["path"],
            row["source_zh"],
        )
    )

    by_source: dict[str, list[dict]] = defaultdict(list)
    for row in missing_entries:
        by_source[row["source_zh"]].append(row)

    missing_unique: list[dict] = []
    for source, contexts in by_source.items():
        categories = sorted({row["category"] for row in contexts}, key=PRIORITY_RANK.get)
        primary = categories[0]
        modules = sorted({row["module"] for row in contexts}, key=str.casefold)
        context_rows = [
            {"module": row["module"], "path": row["path"]}
            for row in sorted(contexts, key=lambda x: (x["module"].casefold(), x["path"]))
        ]
        han_count = len(CJK.findall(source))
        owner_review = (
            primary in {"item", "skill_mechanic"}
            and bool(HAN_ONLY.fullmatch(source))
        )
        missing_unique.append(
            {
                "source_zh": source,
                "category": primary,
                "priority_rank": PRIORITY_RANK[primary],
                "occurrences": len(contexts),
                "han_characters": han_count,
                "owner_review_name_candidate": owner_review,
                "modules": modules,
                "contexts": context_rows,
            }
        )

    missing_unique.sort(
        key=lambda row: (
            row["priority_rank"],
            row["owner_review_name_candidate"],
            -row["occurrences"],
            row["source_zh"],
        )
    )

    clear_unique = [row for row in missing_unique if not row["owner_review_name_candidate"]]
    owner_review = [row for row in missing_unique if row["owner_review_name_candidate"]]

    args.output_dir.mkdir(parents=True, exist_ok=True)
    write_jsonl(args.output_dir / "missing_entries.jsonl", missing_entries)
    write_jsonl(args.output_dir / "missing_unique.jsonl", missing_unique)
    write_jsonl(args.output_dir / "clear_unique.jsonl", clear_unique)
    write_jsonl(args.output_dir / "owner_review_name_candidates.jsonl", owner_review)

    pristine_sources = {row["source_zh"] for row in clean_entries}
    category_unique = Counter(row["category"] for row in missing_unique)
    category_entries = Counter(row["category"] for row in missing_entries)
    summary = {
        "format_version": 1,
        "formula": "current pristine Chinese sources - Translation_DB.zh - Runtime_Literals.source_zh",
        "pristine_entries": len(clean_entries),
        "pristine_unique_sources": len(pristine_sources),
        "translation_db_unique_zh": len(db_zh),
        "runtime_literals_unique_source_zh": len(runtime_zh),
        "covered_pristine_unique_sources": len(pristine_sources & covered),
        "missing_unique_sources": len(missing_unique),
        "missing_entries": len(missing_entries),
        "clear_unique_sources": len(clear_unique),
        "owner_review_name_candidates": len(owner_review),
        "missing_unique_by_category": dict(category_unique),
        "missing_entries_by_category": dict(category_entries),
    }
    (args.output_dir / "summary.json").write_text(
        json.dumps(summary, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    print(json.dumps(summary, ensure_ascii=False))


if __name__ == "__main__":
    main()
