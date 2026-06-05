# GT2N BSPDN Proxy Compatibility Platform

This platform is intentionally separate from `platforms/gt2n` and from the
FSPDN compatibility platform.

The `lef/` and `techlib/` entries are symlinks back to the canonical GT2N
platform directories. That keeps the BSPDN proxy view path-compatible without
duplicating the shared LEF/LIB collateral.

## Goal

Demonstrate a practical two-view GT2N/OpenROAD BSPDN methodology:

- `routing view`: OpenROAD/TritonRoute uses the stable frontside router view
  (`gt2_fspdn_tech.lef` from the shared GT2N techlib), with BPR as
  `MASTERSLICE` and no BM*/BRDL routing. Tap insertion uses the BPR-only
  `gt2_6t_tapbspdn_*` well-tap cells, not the FSPDN bridge taps and not the
  tap-to-M3 repair network.
- `physical/signoff view`: after normal GDS stream-out, KLayout adds real GT2N
  backside PG geometry on `BPR`, `BM1`-`BM4`, `BRDL`, and `BV0`-`BV4`.

This avoids direct TritonRoute BPR/backside routing while preserving a physical
view that KLayout DRC/LVS decks can inspect with the real GT2N layer names and
connectivity chain.

## Script Summary

- `pdn_bspdn_proxy_router_view.tcl`: router-visible PDN stub that preserves PG
  net annotations but suppresses native BPR/BM pdngen.
- `power_activity_vectorless.tcl`: vectorless switching-activity hook for
  report_power.
- `pre_final_report_clear_psm.tcl`: clears stale PSM markers before final IR
  checks.
- `setRC.tcl`: compatibility wrapper. The BSPDN proxy router view uses
  `gt2_fspdn_tech.lef`, so this wrapper dispatches to `setRC_fspdn.tcl` during
  OpenROAD routing and leaves `setRC_full.tcl` available for full-stack
  experiments.
- `tapcell.tcl`: platform tap insertion script. Example runs set
  `TAPCELL_DISTANCE=28`; the script defaults to 14 if unset.
- `fill.json`: explicit ORFS/KLayout fill configuration. It is currently `{}`,
  meaning no special density-fill rules are required for this example.

## Important Files

- `gt2n_compat_bspdn_proxy.lydrc`: DRC deck with real GT2N layer names.
- `gt2n_compat_bspdn_proxy.lylvs`: LVS deck with BM*/BV*/BPR connectivity.
- `scripts/add_bspdn_signoff_grid.rb`: post-GDS physical BSPDN grid generator.
- `lib/`: official GT2N Liberty collateral, symlinked from `../gt2n/lib`.

## Limitations

This is not native OpenROAD lower/backside pin-access support. It is a
GT2N-specific compatibility abstraction: route first with a safe router view,
then materialize backside PG deterministically for signoff-oriented inspection.

The LEF, Liberty, and GDS payloads now distinguish `tapfspdn` and `tapbspdn`.
The BSPDN proxy flow is intended to stream out the physical
`gt2_6t_tapbspdn_*` cells directly, with no alias back to the old FSPDN tap.

The official PrimeLib-generated Liberty files in `lib/` are the canonical GT2N
characterization for this platform.  If `lib_opensta_power/` is used for any
experiment, regenerate or resynchronize it after refreshing `lib/`.
