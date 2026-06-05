#!/usr/bin/env python3
"""Normalize GT2N full-chip CDL for KLayout abstract LVS.

This preprocessor makes the schematic-side CDL consistent with the abstract
layout extraction used by gt2n.lylvs:

1. Split VSS rail pins:
   Some two-row GT2N cells have two separate BPR shapes labeled "vss" in the
   abstract GDS/LEF view. Commercial LVS decks treat same-name PG fragments in a
   cell as one logical pin. KLayout's abstract extraction exposes the two label
   fragments as two pins, so the reference CDL must expose a duplicate vss pin
   for the affected library masters and their instances.

2. Physical-only fillers:
   gt2n.lylvs excludes filler masters on the layout side in abstract LVS because
   they do not affect signal connectivity. The reference CDL must remove the
   corresponding top-level filler instances as well; otherwise LVS fails on
   schematic-only filler subcircuits.

The transformations are library-wide, not AES-specific.
"""

from __future__ import print_function
import argparse
import re
from pathlib import Path


SPLIT_VSS_CELLS = {
    "gt2_6t_dffasync_x{}_w{}_{}".format(drive, width, vt)
    for drive in ("1", "2", "4")
    for width in ("13", "31")
    for vt in ("elvt", "hvt", "lvt", "svt", "ulvt")
} | {
    "gt2_6t_mux2_x1_w{}_{}".format(width, vt)
    for width in ("13", "31")
    for vt in ("elvt", "hvt", "lvt", "svt", "ulvt")
}

FILLER_CELL_RE = re.compile(r"^gt2_6t_filler", re.IGNORECASE)


def record_tokens(lines):
    tokens = []
    for idx, line in enumerate(lines):
        stripped = line.strip()
        if not stripped or stripped.startswith("*"):
            continue
        if idx > 0 and stripped.startswith("+"):
            stripped = stripped[1:].strip()
        tokens.extend(stripped.split())
    return tokens


def append_to_last_line(lines, text):
    patched = list(lines)
    eol = "\n" if patched[-1].endswith("\n") else ""
    patched[-1] = patched[-1].rstrip("\n") + text + eol
    return patched


def insert_before_last_token(lines, token):
    patched = list(lines)
    last = patched[-1]
    eol = "\n" if last.endswith("\n") else ""
    body = last.rstrip("\n")
    if not body.strip():
        return patched
    parts = body.rsplit(None, 1)
    if len(parts) != 2:
        return patched
    patched[-1] = "{} {} {}{}".format(parts[0], token, parts[1], eol)
    return patched


def patch_record(lines, drop_fillers):
    tokens = record_tokens(lines)
    if not tokens:
        return lines, None

    lower = [t.lower() for t in tokens]

    if lower[0] == ".subckt" and len(tokens) >= 4:
        cell = lower[1]
        if cell in SPLIT_VSS_CELLS:
            pins = lower[2:]
            if pins.count("vss") == 1:
                return append_to_last_line(lines, " vss"), "split_subckt"
        return lines, None

    if lower[0].startswith("x") and len(tokens) >= 3:
        cell = lower[-1]
        if drop_fillers and FILLER_CELL_RE.match(cell):
            return [], "drop_filler_instance"
        if cell in SPLIT_VSS_CELLS:
            if lower[-2] == "vss" and (len(lower) < 4 or lower[-3] != "vss"):
                return insert_before_last_token(lines, tokens[-2]), "split_instance"

    return lines, None


def iter_records(path):
    current = []
    with path.open() as src:
        for line in src:
            stripped = line.lstrip()
            if current and stripped.startswith("+"):
                current.append(line)
            else:
                if current:
                    yield current
                current = [line]
        if current:
            yield current


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("input")
    parser.add_argument("output")
    parser.add_argument("--keep-fillers", action="store_true",
                        help="do not remove gt2_6t_filler* instances")
    args = parser.parse_args()

    in_path = Path(args.input)
    out_path = Path(args.output)

    counts = {
        "split_subckts": 0,
        "split_instances": 0,
        "dropped_filler_instances": 0,
    }

    with out_path.open("w") as dst:
        for record in iter_records(in_path):
            patched, kind = patch_record(record, drop_fillers=not args.keep_fillers)
            if kind == "split_subckt":
                counts["split_subckts"] += 1
            elif kind == "split_instance":
                counts["split_instances"] += 1
            elif kind == "drop_filler_instance":
                counts["dropped_filler_instances"] += 1
            dst.writelines(patched)

    print("split_subckts={split_subckts} split_instances={split_instances} "
          "dropped_filler_instances={dropped_filler_instances} output={}".format(out_path, **counts))


if __name__ == "__main__":
    main()
