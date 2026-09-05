#!/usr/bin/env python3
"""Validate/join LoM-VI current-46 pristine runtime audit with decoded current ID tables."""
from __future__ import annotations
import argparse, json, re
from pathlib import Path

CJK = re.compile(r"[\u3400-\u9fff\uf900-\ufaff]")

def load_jsonl(path: Path):
    rows=[]
    with path.open(encoding="utf-8") as f:
        for n,line in enumerate(f,1):
            if line.strip():
                try: rows.append(json.loads(line))
                except json.JSONDecodeError as e: raise ValueError(f"{path}:{n}: {e}") from e
    return rows

def norm_path(path: str) -> str:
    if re.fullmatch(r"-?\d+", path or ""):
        return "n:" + path
    return path

def main():
    p=argparse.ArgumentParser()
    p.add_argument("report", type=Path)
    p.add_argument("--current-id-pairs", type=Path,
                   help="id_text_pairs.jsonl from extract_luajit82_corpus.py")
    p.add_argument("--output-dir", type=Path, required=True)
    a=p.parse_args()
    rows=load_jsonl(a.report)
    summaries=[r for r in rows if r.get("type")=="summary"]
    if len(summaries)!=1 or rows[-1] is not summaries[0]:
        raise ValueError("report must end with exactly one summary")
    summary=summaries[0]
    module_summaries=[r for r in rows if r.get("type")=="module-summary"]
    if int(summary.get("module_count",-1))!=46 or len(module_summaries)!=46:
        raise ValueError(f"expected 46 modules, got summary={summary.get('module_count')} rows={len(module_summaries)}")
    missing_chunks=[r["module"] for r in module_summaries if not r.get("chunk_found")]
    failed_exec=[r for r in module_summaries if not r.get("execute_ok")]
    entries=[]
    seen=set()
    for r in rows:
        if r.get("type")!="entry": continue
        source=str(r.get("source",""))
        if not CJK.search(source): continue
        item={"module":str(r.get("module","")), "path":norm_path(str(r.get("path",""))), "source_zh":source}
        k=(item["module"],item["path"],item["source_zh"])
        if k not in seen: seen.add(k); entries.append(item)
    entries.sort(key=lambda r:(r["module"].casefold(),r["path"],r["source_zh"]))
    literals=sorted({(str(r.get("module","")),str(r.get("source","")))
                     for r in rows if r.get("type")=="literal" and CJK.search(str(r.get("source","")))})
    a.output_dir.mkdir(parents=True,exist_ok=True)
    with (a.output_dir/"pristine_entries.jsonl").open("w",encoding="utf-8",newline="\n") as f:
        for r in entries: f.write(json.dumps(r,ensure_ascii=False)+"\n")
    (a.output_dir/"pristine_literals.json").write_text(
        json.dumps([{"module":m,"source_zh":s} for m,s in literals],ensure_ascii=False,indent=2)+"\n",
        encoding="utf-8")
    result={"audit_id":summary.get("audit_id"),"module_count":46,
            "chunks_found":summary.get("chunks_found"),
            "execute_ok":summary.get("execute_ok"),
            "missing_chunks":missing_chunks,
            "failed_execute_modules":[r["module"] for r in failed_exec],
            "unique_pristine_entries":len(entries),"unique_pristine_literals":len(literals)}
    if a.current_id_pairs:
        current=load_jsonl(a.current_id_pairs)
        cmap={(str(r.get("module","")),norm_path(str(r.get("path",""))):):str(r.get("text","")) for r in current}
        joined=[]; pristine_only=[]
        for r in entries:
            k=(r["module"],r["path"])
            if k in cmap:
                joined.append({**r,"current_text":cmap[k]})
            else:
                pristine_only.append(r)
        pkeys={(r["module"],r["path"]) for r in entries}
        current_only=[{"module":m,"path":p,"current_text":t} for (m,p),t in cmap.items() if (m,p) not in pkeys]
        joined.sort(key=lambda r:(r["module"].casefold(),r["path"]))
        current_only.sort(key=lambda r:(r["module"].casefold(),r["path"]))
        with (a.output_dir/"joined_current46.jsonl").open("w",encoding="utf-8",newline="\n") as f:
            for r in joined: f.write(json.dumps(r,ensure_ascii=False)+"\n")
        with (a.output_dir/"current_only.jsonl").open("w",encoding="utf-8",newline="\n") as f:
            for r in current_only: f.write(json.dumps(r,ensure_ascii=False)+"\n")
        with (a.output_dir/"pristine_only.jsonl").open("w",encoding="utf-8",newline="\n") as f:
            for r in pristine_only: f.write(json.dumps(r,ensure_ascii=False)+"\n")
        result.update({"joined_keys":len(joined),"current_only_keys":len(current_only),
                       "pristine_only_keys":len(pristine_only)})
    (a.output_dir/"summary.json").write_text(json.dumps(result,ensure_ascii=False,indent=2)+"\n",encoding="utf-8")
    print(json.dumps(result,ensure_ascii=False))
    if missing_chunks:
        raise SystemExit(2)

if __name__=="__main__":
    main()
