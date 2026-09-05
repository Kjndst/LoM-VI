#!/usr/bin/env python3
"""Extract string constants and numeric ID->text pairs from LoM custom LuaJIT 0x82 bytecode.

This is an audit/extraction utility for translation coverage. It does not modify game
files. The current LoM translation modules use a 48-byte XOR stream that resets for
each prototype payload; after decoding, the payload follows LuaJIT 2.1 bytecode
serialization closely enough to parse constant tables deterministically.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import re
import struct
import zipfile
from collections import defaultdict
from pathlib import Path
from typing import Any, Iterator

XOR_KEY = b"c7fjs-432890fadnsyu9reqwj;lerwqio;jf;ldsanmdgmzz"
CJK = re.compile(r"[\u3400-\u9fff\uf900-\ufaff]")
MODULE_ROOTS = ("Data/", "Framework/", "Gameplay/", "Launch/", "Shared/")

# LuaJIT dump constants.
BCDUMP_F_STRIP = 0x02
KTAB_NIL, KTAB_FALSE, KTAB_TRUE, KTAB_INT, KTAB_NUM, KTAB_STR = range(6)
KGC_CHILD, KGC_TAB, KGC_I64, KGC_U64, KGC_COMPLEX, KGC_STR = range(6)


class Reader:
    def __init__(self, data: bytes):
        self.data = data
        self.pos = 0

    def byte(self) -> int:
        if self.pos >= len(self.data):
            raise ValueError("unexpected EOF")
        value = self.data[self.pos]
        self.pos += 1
        return value

    def read(self, count: int) -> bytes:
        end = self.pos + count
        if end > len(self.data):
            raise ValueError("unexpected EOF")
        value = self.data[self.pos:end]
        self.pos = end
        return value

    def uleb128(self) -> int:
        value = 0
        shift = 0
        while True:
            byte = self.byte()
            value |= (byte & 0x7F) << shift
            if byte < 0x80:
                return value
            shift += 7
            if shift > 63:
                raise ValueError("ULEB128 too long")

    def uleb128_33(self) -> int:
        # LuaJIT bcread_uleb128_33: bit 0 of the first byte is the int/num marker.
        byte = self.byte()
        value = byte >> 1
        if value >= 0x40:
            shift = -1
            value &= 0x3F
            while True:
                byte = self.byte()
                shift += 7
                value |= (byte & 0x7F) << shift
                if byte < 0x80:
                    break
        return value & 0xFFFFFFFF


def decode_double(low: int, high: int) -> float:
    return struct.unpack("<d", struct.pack("<II", low & 0xFFFFFFFF, high & 0xFFFFFFFF))[0]


def decode_proto_stream(data: bytes) -> tuple[list[bytes], int, int, str | None]:
    reader = Reader(data)
    if reader.read(3) != b"\x1bLJ":
        raise ValueError("not a LuaJIT bytecode dump")
    version = reader.byte()
    if version != 0x82:
        raise ValueError(f"unsupported LoM LuaJIT bytecode version 0x{version:02x}")
    flags = reader.uleb128()
    chunk_name: str | None = None
    if not (flags & BCDUMP_F_STRIP):
        name_len = reader.uleb128()
        chunk_name = reader.read(name_len).decode("utf-8", "replace")

    protos: list[bytes] = []
    while True:
        proto_len = reader.uleb128()
        if proto_len == 0:
            break
        encrypted = reader.read(proto_len)
        decoded = bytes(value ^ XOR_KEY[index % len(XOR_KEY)] for index, value in enumerate(encrypted))
        protos.append(decoded)

    if reader.pos != len(data):
        raise ValueError(f"trailing bytes after prototype stream: {len(data) - reader.pos}")
    return protos, version, flags, chunk_name


def parse_ktab_constant(reader: Reader) -> Any:
    kind = reader.uleb128()
    if kind >= KTAB_STR:
        return reader.read(kind - KTAB_STR).decode("utf-8", "replace")
    if kind == KTAB_NIL:
        return None
    if kind == KTAB_FALSE:
        return False
    if kind == KTAB_TRUE:
        return True
    if kind == KTAB_INT:
        value = reader.uleb128() & 0xFFFFFFFF
        return value - 2**32 if value >= 2**31 else value
    if kind == KTAB_NUM:
        return decode_double(reader.uleb128(), reader.uleb128())
    raise ValueError(f"unsupported KTAB constant type {kind}")


def parse_ktab(reader: Reader) -> dict[str, Any]:
    array_count = reader.uleb128()
    hash_count = reader.uleb128()
    array = [parse_ktab_constant(reader) for _ in range(array_count)]
    pairs = [(parse_ktab_constant(reader), parse_ktab_constant(reader)) for _ in range(hash_count)]
    return {"__array__": array, "__hash__": pairs}


def parse_kgc(reader: Reader) -> Any:
    kind = reader.uleb128()
    if kind >= KGC_STR:
        return reader.read(kind - KGC_STR).decode("utf-8", "replace")
    if kind == KGC_CHILD:
        return {"__child__": True}
    if kind == KGC_TAB:
        return parse_ktab(reader)
    if kind in (KGC_I64, KGC_U64):
        low = reader.uleb128() & 0xFFFFFFFF
        high = reader.uleb128() & 0xFFFFFFFF
        value = (high << 32) | low
        if kind == KGC_I64 and value >= 2**63:
            value -= 2**64
        return value
    if kind == KGC_COMPLEX:
        real = decode_double(reader.uleb128(), reader.uleb128())
        imag = decode_double(reader.uleb128(), reader.uleb128())
        return complex(real, imag)
    raise ValueError(f"unsupported KGC constant type {kind}")


def parse_proto(proto: bytes, *, stripped: bool) -> list[Any]:
    reader = Reader(proto)
    _proto_flags = reader.byte()
    _num_params = reader.byte()
    _frame_size = reader.byte()
    num_uv = reader.byte()
    num_kgc = reader.uleb128()
    num_kn = reader.uleb128()
    num_bc = reader.uleb128()

    debug_len = 0
    if not stripped:
        debug_len = reader.uleb128()
        if debug_len:
            reader.uleb128()  # first line
            reader.uleb128()  # line count

    reader.read(num_bc * 4)
    reader.read(num_uv * 2)
    values = [parse_kgc(reader) for _ in range(num_kgc)]

    for _ in range(num_kn):
        is_number = bool(reader.data[reader.pos] & 1)
        reader.uleb128_33()
        if is_number:
            reader.uleb128()

    if not stripped and debug_len:
        reader.read(debug_len)
    if reader.pos != len(proto):
        raise ValueError(f"prototype parse mismatch: parsed={reader.pos} size={len(proto)}")
    return values


def walk_strings(value: Any) -> Iterator[str]:
    if isinstance(value, str):
        yield value
    elif isinstance(value, dict) and "__array__" in value:
        for item in value["__array__"]:
            yield from walk_strings(item)
        for key, item in value["__hash__"]:
            if isinstance(key, str):
                yield key
            yield from walk_strings(item)
    elif isinstance(value, (list, tuple)):
        for item in value:
            yield from walk_strings(item)


def walk_numeric_pairs(value: Any) -> Iterator[tuple[int | float, str]]:
    if isinstance(value, dict) and "__hash__" in value:
        for key, item in value["__hash__"]:
            if isinstance(key, (int, float)) and not isinstance(key, bool) and isinstance(item, str):
                yield key, item
            yield from walk_numeric_pairs(item)
        for item in value["__array__"]:
            yield from walk_numeric_pairs(item)


def normalize_module(path: str) -> str:
    normalized = path.replace("\\", "/")
    for root in MODULE_ROOTS:
        marker = "/" + root
        if marker in normalized:
            normalized = root + normalized.split(marker, 1)[1]
            break
        if normalized.startswith(root):
            break
    if normalized.endswith(".lua"):
        normalized = normalized[:-4]
    return normalized.replace("/", ".")


def normalize_id(value: int | float) -> int | float:
    if isinstance(value, float) and value.is_integer():
        return int(value)
    return value


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("archive", type=Path, help="ZIP containing LoM LuaJIT 0x82 modules")
    parser.add_argument("--output-dir", type=Path, required=True)
    args = parser.parse_args()

    archive_bytes = args.archive.read_bytes()
    archive_sha256 = hashlib.sha256(archive_bytes).hexdigest()
    args.output_dir.mkdir(parents=True, exist_ok=True)

    module_summaries: list[dict[str, Any]] = []
    pairs: list[dict[str, Any]] = []
    string_modules: dict[str, set[str]] = defaultdict(set)
    failures: list[dict[str, str]] = []

    with zipfile.ZipFile(args.archive) as archive:
        members = sorted(name for name in archive.namelist() if name.lower().endswith(".lua"))
        for member in members:
            module = normalize_module(member)
            try:
                protos, version, flags, chunk_name = decode_proto_stream(archive.read(member))
                strings: list[str] = []
                module_pairs: list[tuple[int | float, str]] = []
                for proto in protos:
                    values = parse_proto(proto, stripped=bool(flags & BCDUMP_F_STRIP))
                    for value in values:
                        strings.extend(walk_strings(value))
                        module_pairs.extend(walk_numeric_pairs(value))
                for text in strings:
                    string_modules[text].add(module)
                for key, text in module_pairs:
                    pairs.append({"module": module, "path": f"n:{normalize_id(key)}", "id": normalize_id(key), "text": text})
                module_summaries.append({
                    "archive_path": member,
                    "module": module,
                    "bytecode_version": version,
                    "flags": flags,
                    "chunk_name": chunk_name,
                    "prototypes": len(protos),
                    "string_constant_occurrences": len(strings),
                    "cjk_string_occurrences": sum(bool(CJK.search(text)) for text in strings),
                    "numeric_id_text_pairs": len(module_pairs),
                })
            except Exception as exc:  # report every failed module, do not silently skip
                failures.append({"archive_path": member, "module": module, "error": repr(exc)})

    cjk_rows = [
        {"source": text, "modules": sorted(modules)}
        for text, modules in string_modules.items()
        if CJK.search(text)
    ]
    cjk_rows.sort(key=lambda row: row["source"])
    pairs.sort(key=lambda row: (row["module"].casefold(), str(row["id"]), row["text"]))
    module_summaries.sort(key=lambda row: row["module"].casefold())

    summary = {
        "format_version": 1,
        "archive": args.archive.name,
        "archive_sha256": archive_sha256,
        "xor_period": len(XOR_KEY),
        "module_count": len(module_summaries),
        "failed_module_count": len(failures),
        "unique_string_constants": len(string_modules),
        "unique_cjk_string_constants": len(cjk_rows),
        "numeric_id_text_pair_count": len(pairs),
        "modules": module_summaries,
        "failures": failures,
    }

    (args.output_dir / "summary.json").write_text(json.dumps(summary, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    (args.output_dir / "cjk_literals.json").write_text(json.dumps(cjk_rows, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    with (args.output_dir / "id_text_pairs.jsonl").open("w", encoding="utf-8", newline="\n") as stream:
        for row in pairs:
            stream.write(json.dumps(row, ensure_ascii=False) + "\n")

    print(json.dumps({key: summary[key] for key in (
        "archive_sha256", "module_count", "failed_module_count",
        "unique_string_constants", "unique_cjk_string_constants", "numeric_id_text_pair_count"
    )}, ensure_ascii=False))
    if failures:
        raise SystemExit(2)


if __name__ == "__main__":
    main()
