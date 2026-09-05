#!/usr/bin/env python3
"""Validate/join LoM-VI current-46 pristine runtime audit with decoded current ID tables."""
from __future__ import annotations

import argparse
import json
import re
from pathlib import Path

CJK = re.compile(r"[\u3400-\u9fff\uf900-\ufaff]")


def load_jsonl(path: Path):
    rows = []
    with path.open(encoding="utf-8") as stream:
        for line_number, line in enumerate(stream, 1):
            if not line.strip():
                continue
            try:
                rows.append(json.loads(line))
            except json.JSONDecodeError as exc:
                raise ValueError(f"{path}:{line_number}: {exc}") from exc
    return rows


def norm_path(path: str) -> str:
    if re.fullmatch(r"-?\d+", path or ""):
        return "n:" + path
    return path


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("report", type=Path)
    parser.add_argument(
        "--current-id-pairs",
        type=Path,
        help="id_text_pairs.jsonl from extract_luajit82_corpus.py",
    )
    parser.add_argument("--output-dir", type=Path, required=True)
    args = parser.parse_args()

    rows = load_jsonl(args.report)
    summaries = [row for row in rows if row.get("type") == "summary"]
    if len(summaries) != 1 or rows[-1] is not summaries[0]:
        raise ValueError("report must end with exactly one summary")
    summary = summaries[0]
    module_summaries = [row for row in rows if row.get("type") == "module-summary"]
    if int(summary.get("module_count", -1)) != 46 or len(module_summaries) != 46:
        raise ValueError(
            f"expected 46 modules, got summary={summary.get('module_count')} "
            f"rows={len(module_summaries)}"
        )

    missing_chunks = [row["module"] for row in module_summaries if not row.get("chunk_found")]
    failed_exec = [row for row in module_summaries if not row.get("execute_ok")]

    entries = []
    seen = set()
    for row in rows:
        if row.get("type") != "entry":
            continue
        source = str(row.get("source", ""))
        if not CJK.search(source):
            continue
        item = {
            "module": str(row.get("module", "")),
            "path": norm_path(str(row.get("path", ""))),
            "source_zh": source,
        }
        identity = (item["module"], item["path"], item["source_zh"])
        if identity not in seen:
            seen.add(identity)
            entries.append(item)
    entries.sort(key=lambda row: (row["module"].casefold(), row["path"], row["source_zh"]))

    literals = sorted(
        {
            (str(row.get("module", "")), str(row.get("source", "")))
            for row in rows
            if row.get("type") == "literal" and CJK.search(str(row.get("source", "")))
        }
    )

    args.output_dir.mkdir(parents=True, exist_ok=True)
    with (args.output_dir / "pristine_entries.jsonl").open(
        "w", encoding="utf-8", newline="\n"
    ) as stream:
        for row in entries:
            stream.write(json.dumps(row, ensure_ascii=False) + "\n")
    (args.output_dir / "pristine_literals.json").write_text(
        json.dumps(
            [{"module": module, "source_zh": source} for module, source in literals],
            ensure_ascii=False,
            indent=2,
        )
        + "\n",
        encoding="utf-8",
    )

    result = {
        "audit_id": summary.get("audit_id"),
        "module_count": 46,
        "chunks_found": summary.get("chunks_found"),
        "execute_ok": summary.get("execute_ok"),
        "missing_chunks": missing_chunks,
        "failed_execute_modules": [row["module"] for row in failed_exec],
        "unique_pristine_entries": len(entries),
        "unique_pristine_literals": len(literals),
    }

    if args.current_id_pairs:
        current = load_jsonl(args.current_id_pairs)
        current_map = {
            (str(row.get("module", "")), norm_path(str(row.get("path", "")))): str(
                row.get("text", "")
            )
            for row in current
        }
        joined = []
        pristine_only = []
        for row in entries:
            identity = (row["module"], row["path"])
            if identity in current_map:
                joined.append({**row, "current_text": current_map[identity]})
            else:
                pristine_only.append(row)

        pristine_keys = {(row["module"], row["path"]) for row in entries}
        current_only = [
            {"module": module, "path": path, "current_text": text}
            for (module, path), text in current_map.items()
            if (module, path) not in pristine_keys
        ]
        joined.sort(key=lambda row: (row["module"].casefold(), row["path"]))
        current_only.sort(key=lambda row: (row["module"].casefold(), row["path"]))

        for filename, records in (
            ("joined_current46.jsonl", joined),
            ("current_only.jsonl", current_only),
            ("pristine_only.jsonl", pristine_only),
        ):
            with (args.output_dir / filename).open(
                "w", encoding="utf-8", newline="\n"
            ) as stream:
                for row in records:
                    stream.write(json.dumps(row, ensure_ascii=False) + "\n")

        result.update(
            {
                "joined_keys": len(joined),
                "current_only_keys": len(current_only),
                "pristine_only_keys": len(pristine_only),
            }
        )

    (args.output_dir / "summary.json").write_text(
        json.dumps(result, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    print(json.dumps(result, ensure_ascii=False))
    if missing_chunks:
        raise SystemExit(2)


if __name__ == "__main__":
    main()
