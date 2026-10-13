# CPCell GT2N logic library (31 nm sheets, LVT)

Combined 18-cell library for w31/LVT: 14 nm gates, three-sheet devices,
backside power, 144 nm standard-cell row. Topologies are authored in CPCell's
`cells.py`; no reference layout polygons or fixed transistor order are supplied.
One abstract solution per cell is exported at every width, so w13 and w31 share
footprints and pin positions.

| Cell | Function Y | Transistors | Width x height (nm) | Area (um^2) | SPICE vectors |
| --- | --- | ---: | --- | ---: | ---: |
| AND4 | `(A & B & C & D)` | 10 | 294 × 144 | 0.042336 | 16 |
| AND5 | `(A & B & C & D & E)` | 12 | 336 × 144 | 0.048384 | 32 |
| AO221 | `((A1 & A2) | (B1 & B2) | C)` | 12 | 336 × 144 | 0.048384 | 32 |
| AO222 | `((A1 & A2) | (B1 & B2) | (C1 & C2))` | 14 | 420 × 144 | 0.060480 | 64 |
| AOI221 | `!((A1 & A2) | (B1 & B2) | C)` | 10 | 294 × 144 | 0.042336 | 32 |
| AOI222 | `!((A1 & A2) | (B1 & B2) | (C1 & C2))` | 12 | 336 × 144 | 0.048384 | 64 |
| MAJ3 | `((A & B) | (A & C) | (B & C))` | 12 | 336 × 144 | 0.048384 | 8 |
| MAJI3 | `!((A & B) | (A & C) | (B & C))` | 10 | 294 × 144 | 0.042336 | 8 |
| NAND4 | `!(A & B & C & D)` | 8 | 252 × 144 | 0.036288 | 16 |
| NAND5 | `!(A & B & C & D & E)` | 10 | 294 × 144 | 0.042336 | 32 |
| NOR4 | `!(A | B | C | D)` | 8 | 252 × 144 | 0.036288 | 16 |
| NOR5 | `!(A | B | C | D | E)` | 10 | 294 × 144 | 0.042336 | 32 |
| OA221 | `((A1 | A2) & (B1 | B2) & C)` | 12 | 336 × 144 | 0.048384 | 32 |
| OA222 | `((A1 | A2) & (B1 | B2) & (C1 | C2))` | 14 | 420 × 144 | 0.060480 | 64 |
| OAI221 | `!((A1 | A2) & (B1 | B2) & C)` | 10 | 294 × 144 | 0.042336 | 32 |
| OAI222 | `!((A1 | A2) & (B1 | B2) & (C1 | C2))` | 12 | 336 × 144 | 0.048384 | 64 |
| OR4 | `(A | B | C | D)` | 10 | 294 × 144 | 0.042336 | 16 |
| OR5 | `(A | B | C | D | E)` | 12 | 336 × 144 | 0.048384 | 32 |

All 18 passed transistor LVS individually and in mirrored 2 x 2 arrays, with
only the documented `GATE.2` DRC category. All 592 SPICE truth-table vectors
and 3132 propagation-delay measurements passed. OpenROAD loaded the LEF and
Liberty alongside the released GT2N views and evaluated timing arcs; Yosys
loaded the Liberty, linked an 18-cell smoke design, and checked the functional
Verilog. The Python regression suite passed with 135 tests and 66 subtests.

## Generate and verify

```bash
# Generate using this repository's dependencies only (default w31 library).
.venv/bin/python examples/gt2n_logic/reproduce.py

# Both width flavors in one run.
.venv/bin/python examples/gt2n_logic/reproduce.py --widths 31 13

# Full physical checks and nominal schematic characterization.
GT2N_ROOT=/home/jeff/iv4/repos/GT2N PYTHONDONTWRITEBYTECODE=1 ../chipforge_gt2n/.venv/bin/python examples/gt2n_logic/reproduce.py --widths 31 13 --output-dir /tmp/widths_fullcat --timeout 180 --spice --reference-repo /tmp/chipforge_ref
```

`--verify` runs DRC/LVS without SPICE. `--spice` implies `--verify` and generates
an experimental Liberty file. External verification reuses the sibling
project's full platform DRC deck, transistor LVS deck, and Xyce model-card
adapter; it requires KLayout, Xyce and the GT2N PDK. Xyce's MPI runtime needs
local socket access. The sibling repositories are read-only inputs.

Use `--cells NAND4 AOI221` for a subset, `--timeout 180` for the per-cell solve
limit, `--reference-repo PATH` to locate the verification helpers, and
`--output-dir PATH` to select another output directory (multi-width runs create
`w13/` and `w31/` beneath it). With a single `--widths` value and an explicit
`--output-dir`, views land directly in that directory.

Each per-width output directory holds:

- `solver.cdl`, `config/*.json`, `result/*.res`, and per-cell `solve.log` preserve
  the actual topology, constraints, placement and routing.
- Combined `.gds`, `.cdl`, `.lef`, and `.v` form the physical and functional
  views. Individual GDS/CDL files are also saved under each cell.
- The `_tt_0p7v25c.lib` Liberty is generated only by a successful `--spice` run.
- Each cell's `*.lyrdb`/`*.lvsdb` files contain the physical check results.
- Each cell's `truth.cir` and `timing_*.cir` reproduce the SPICE benches.
- `report.json` records dimensions, solver status, input/result/model hashes,
  DRC counts, LVS status, every truth-table result and timing sample.

Regeneration removes superseded combined GDS/LEF/Liberty views. A failed solve
cannot reuse an old `.res` file. Check the report status before using artifacts
from a failed or interrupted run.

## Placement, routing and pin access

The `gt2n_logic` profile retains CPCell's two abstract placement bands and
four-track device dimensions, while supplying **five physical routing rows**:
M0/M2 at y=`[16, 42, 72, 102, 128]` nm. `TRACK=4` in `.res` describes the abstract
placement model; `LAYOUT_PROFILE=gt2n_logic` selects the physical grid.

Complementary devices driven by the same input are constrained to align, so
that they share a continuous gate with access in the central gap at y=72 nm.
CPCell chooses their order, source/drain orientations, diffusion breaks, cell
width, contacts and wires. There are no fixed placement coordinates.

Diffusion access uses the outer tracks and the tracks through each active band.
M1 access is prohibited at y=16/128 nm: its end extensions there would violate
the 20 nm end spacing across mirrored rows. M1 pins and routing use the inner
tracks, and the LEF exposes actual solved M1 metal. M0 and internal M1/M2 shapes
are obstructions.

The search canvas permits one extra diffusion-break slot for NAND/NOR/AND/OR
cells and four for AO/OA/MAJ cells. `OPTIMAL` means optimal for this constrained
model and its weighted objective; it does not establish a globally minimum-area
GT2N implementation or optimized electrical sizing.

## Verification scope

Before placement, an independent switch-network connectivity check exhausts all
**592 Boolean input vectors**, rejecting both floating outputs and supply
shorts. The generated cells are checked against their physical-size CDL.
Each is also placed in a **2 x 2 mirrored abutment fixture** with independent
signal nets and shared supply rails, and the complete fixture receives DRC/LVS.
Top-level signal labels establish the fixture's external connections without
adding metal that could conceal an internal routing problem.

The flow fails on any LVS mismatch or DRC category other than the reference
project's documented `GATE.2` finding: the platform deck reads the spacing past
the outermost gates of a cell or array as a gate space, so it marks those two
edges though no gate faces them. Each cell and each 2 x 2 array reports two.
Counts are reported explicitly; acceptance is not a claim of zero DRC findings
or proprietary signoff. No `SDCON.ACT.1` markers were observed in this run.

The archived `*.lyrdb`, the DRC counts in `report.json` and
`verification/decks/gt2n.lydrc` come from the run itself against the corrected
platform deck (5 nm `SDCON.ACT.1`, matching `icv_runset/Include/gt2.sdcon.drc.rs`).

## Experimental Liberty characterization

`--spice` runs **TT, 0.7 V, 25 C** using the reference project's GT2N-to-Xyce
BSIM-CMG conversion. Sheet dimensions and the three-sheet count come from the
w31 model card. CDL-only `W`/`M` instance parameters are removed for Xyce,
as in the SRAM characterization flow.

- All 592 static vectors must settle below 10% VDD or above 90% VDD.
- Timing tables use 20-80% input slews of **10, 30, 80 ps** and explicit output
  loads of **0.2, 1, 3 fF**.
- Every input arc is checked under **every sensitizing assignment** of the other
  inputs: 4-5 per NAND/NOR/AND/OR cell, 21 per 221 compound cell, 54 per 222
  compound cell, and 6 per majority cell.
- Each table entry is the worst measured value across those assignments, for
  both output polarities. Delays use 50% crossings; output slews use 20-80%.
  A negative propagation delay at light load is retained when the output's
  50% crossing precedes the slowly changing input's 50% crossing.
- Input capacitance is the largest measured rising-transition charge divided
  by VDD across the sweeps, including intrinsic Miller coupling.

This Liberty is for **initial mapping and timing experiments**. It has no
extracted wiring RC, no internal/leakage power tables, and no additional PVT or
variation corners. Timing and capacitance therefore do not yet represent a
post-layout characterized library. The supplied load/slew grid bounds its
measured range; further sweeps and extraction are needed before broader use.

Load `cells.lef` alongside the GT2N technology and released standard-cell LEFs;
it references their `gt2_6t` site. Load `cells_tt.lib` alongside a compatible TT
library, and supply `cells.v` for functional simulation.
