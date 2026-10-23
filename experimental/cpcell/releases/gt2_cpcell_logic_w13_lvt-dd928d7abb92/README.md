# gt2_cpcell_logic_w13_lvt

Experimental 18-cell W13/LVT logic extension. Revision: `dd928d7abb92`.

The views are copied byte-for-byte from a validated snapshot; packaging does
not rerun the solver, DRC, LVS or SPICE. Characterization is schematic-only TT 0.7 V 25 C; no extracted RC or power tables.
Recorded DRC acceptance and limits remain in `source/verification/report.json` and the
original `source/manifest.json`. All manifest-listed evidence and exact solver
solutions are retained in `source/`, including the original source provenance.

## Load alongside the GT2N base library

Set `pdk` to the GT2N checkout and `extension` to this extracted directory:

```tcl
read_lef $pdk/techlib/gt2_tech.lef
read_lef $pdk/lef/tt/gt2_6t_w13_lvt.lef
read_lef $extension/gt2_cpcell_logic_w13_lvt.lef
read_liberty $pdk/lib/tt/gt2_6t_w13_lvt_tt_0p7v25c.lib
read_liberty $extension/gt2_cpcell_logic_w13_lvt_tt_0p7v25c.lib
```

Include `gt2_cpcell_logic_w13_lvt.gds` alongside the base GDS during stream-out.
`gt2_cpcell_logic_w13_lvt.cdl` supplies LVS subcircuits and `gt2_cpcell_logic_w13_lvt.v`
supplies functional models with implicit power pins. Physical views and Liberty
include `vdd`/`vss`. Load a single revision of each flavor in a design.

`manifest.json` hashes all package payloads except itself. The adjacent
`.tar.gz.sha256` verifies the archive, whose top directory is `gt2_cpcell_logic_w13_lvt-dd928d7abb92`.
Files inside the package are uncompressed. Generation and packaging are owned
by `chipforge_gt2n`; the preserved snapshot may predate that migration.
