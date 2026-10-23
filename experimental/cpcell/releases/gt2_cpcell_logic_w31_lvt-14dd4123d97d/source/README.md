# Experimental CPCell GT2N logic library

Combined 18-cell views for w31/LVT, 14 nm gates, three-sheet devices
and a 144 nm standard-cell row. Devices are uniformly sized; the names
intentionally make no drive-strength claim. Both width flavors are exported
from one shared solver solution per cell, so w13 and w31 share footprints
and pin positions.

| Cell | Function Y | Width x height (nm) | Area (um^2) |
| --- | --- | --- | ---: |
| AND4 | `(A & B & C & D)` | 294 × 144 | 0.042336 |
| AND5 | `(A & B & C & D & E)` | 336 × 144 | 0.048384 |
| AO221 | `((A1 & A2) | (B1 & B2) | C)` | 336 × 144 | 0.048384 |
| AO222 | `((A1 & A2) | (B1 & B2) | (C1 & C2))` | 420 × 144 | 0.060480 |
| AOI221 | `!((A1 & A2) | (B1 & B2) | C)` | 294 × 144 | 0.042336 |
| AOI222 | `!((A1 & A2) | (B1 & B2) | (C1 & C2))` | 336 × 144 | 0.048384 |
| MAJ3 | `((A & B) | (A & C) | (B & C))` | 336 × 144 | 0.048384 |
| MAJI3 | `!((A & B) | (A & C) | (B & C))` | 294 × 144 | 0.042336 |
| NAND4 | `!(A & B & C & D)` | 252 × 144 | 0.036288 |
| NAND5 | `!(A & B & C & D & E)` | 294 × 144 | 0.042336 |
| NOR4 | `!(A | B | C | D)` | 252 × 144 | 0.036288 |
| NOR5 | `!(A | B | C | D | E)` | 294 × 144 | 0.042336 |
| OA221 | `((A1 | A2) & (B1 | B2) & C)` | 336 × 144 | 0.048384 |
| OA222 | `((A1 | A2) & (B1 | B2) & (C1 | C2))` | 420 × 144 | 0.060480 |
| OAI221 | `!((A1 | A2) & (B1 | B2) & C)` | 294 × 144 | 0.042336 |
| OAI222 | `!((A1 | A2) & (B1 | B2) & (C1 | C2))` | 336 × 144 | 0.048384 |
| OR4 | `(A | B | C | D)` | 294 × 144 | 0.042336 |
| OR5 | `(A | B | C | D | E)` | 336 × 144 | 0.048384 |

Load `cells.lef` alongside GT2N's technology LEF and released w31/LVT LEF
(which defines the `gt2_6t` site). Load `cells_tt.lib` alongside the compatible
released TT library. `cells.gds`, `cells.cdl` and `cells.v` provide the other
physical, transistor and functional views. This extension has distinct cell
names and does not replace the released libraries.

## Validation and limits

All 18 cells pass transistor LVS individually and in mirrored 2 x 2 arrays.
DRC reports only `GATE.2`, two markers per cell and per array: the deck reads
the spacing past the outermost gates as a gate space, though no gate faces them.
Counts and full databases are under `verification/`. These checks do not claim
zero DRC findings or signoff.
All 592 static SPICE vectors and 3132 propagation-delay measurements passed.
OpenROAD loaded the LEF/Liberty and evaluated timing; Yosys linked the cells
and checked the functional Verilog. The CPCell suite passed 135 tests and 66
subtests. Evidence is archived in `verification/`.

The Liberty is **experimental schematic-only TT, 0.7 V, 25 C**. It has no
extracted wiring RC, power tables, additional corners or variation models.
Input slew is 10/30/80 ps (20-80%); load is 0.2/1/3 fF. Each timing entry is
the worst measured sensitizing assignment. See
[generation notes](verification/generation-notes.md) for methodology.

## Provenance and regeneration

- CPCellUCSD: `1a179c9512171ff2da80e5caf509dd90b32d3609` (branch `cpcell/logic-batch1`, tree not clean
  at generation time; see manifest for the exact input hashes).
- GT2N base: `1d90098296b8792b2716c7aa1224e3f9192206c0`. The run consumed an equivalent workspace; device
  cards are byte-identical and the DRC deck is archived by content.
- Verification helpers: pinned chipforge_gt2n commit
  `2d94a9ca96a6186d922d2ccb411121d450284946`, extracted to a reference directory
  with a run-local 3-line tolerance fix in `gt2n_spice.py` (skip the `.LIB` /
  `.ENDL` wrappers current GT2N cards add around each model; the flat converted
  deck is otherwise unchanged). The manifest records the patched source hashes.
  That checkout has no configured remote.
- `manifest.json` records hashes for every snapshot payload file and source
  revisions. Original reports retain the generating machine's absolute paths.

From the pinned CPCellUCSD checkout, with the helper reference beside it:

```bash
GT2N_ROOT=/home/jeff/iv4/repos/GT2N PYTHONDONTWRITEBYTECODE=1 ../chipforge_gt2n/.venv/bin/python examples/gt2n_logic/reproduce.py --widths 31 13 --output-dir /tmp/widths_fullcat --timeout 180 --spice --reference-repo /tmp/chipforge_ref
```

Set `GT2N_ROOT` if the PDK is elsewhere. The helper flow expects the DRC deck
at `Openroad_example/gt2n_openroad_run/OpenROAD-flow-scripts/flow/platforms/gt2n/gt2n.lydrc`
within the PDK. This deck is untracked; the contents the archived results were
checked with are saved as `verification/decks/gt2n.lydrc`. In a fresh PDK
checkout, provision that file at the expected path before running the helper
flow. The exact LVS deck is also archived. Both decks can be run directly with
KLayout using `in_gds`, `topcell`, `report_file`, and (for LVS) `cdl_file`;
DRC uses `drc_mode=full`. Self-contained Xyce benches are saved under each
cell's verification folder.

The solver may choose a different equally optimal layout on regeneration.
`solver/config/` and `solver/result/` preserve the exact solutions exported
in this snapshot. `OPTIMAL` applies to the configured model and objective.
