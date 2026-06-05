# GT2N ORFS Platform Collateral

This directory follows the OpenROAD-flow-scripts platform convention:

- Files at the platform root are ORFS entry points or active signoff decks that
  configs reference directly, such as `config.mk`, `make_tracks*.tcl`,
  `setRC*.tcl`, `fastroute.tcl`, `tapcell.tcl`, `fill.json`, `rcx_patterns.rules`,
  `gt2n.lydrc`, `gt2n.lylvs`, `gt2n.lyp`, and `gt2n.lyt`.
- `lib/`, `gds/`, and `cdl/` contain the active GT2N library collateral used by
  ORFS runs.
- `lef/` contains standard-cell LEFs and compatibility views only. The tech LEF
  is canonical in `techlib/`.
- `scripts/` contains helper scripts sourced or invoked by platform/run hooks,
  not fixed-name ORFS platform entry points.
- `techlib/` contains the canonical tech LEFs, layer maps, display-generation
  inputs, and extraction collateral.

Do not move the root hook files into `scripts/` unless every ORFS config that
references them is updated at the same time.

## Script Summary

- `make_tracks.tcl`: declares the canonical routing grid for the full GT2N
  tech LEF.
- `make_tracks_fspdn.tcl`: declares the alternate routing grid used with the
  FSPDN tech LEF.
- `setRC.tcl`: compatibility wrapper. Stock ORFS scripts may source this file
  directly, so it dispatches to `setRC_fspdn.tcl` for `gt2_fspdn_tech.lef`
  and to `setRC_full.tcl` otherwise.
- `setRC_fspdn.tcl`: assigns layer parasitics for the FSPDN/router-view stack.
- `setRC_full.tcl`: assigns layer parasitics for the full GT2N stack.
- `fastroute.tcl`: configures TritonRoute/FastRoute routing limits.
- `pre_io_avoid_pdn_stripes.tcl`: nudges I/O placement away from PDN stripes.
- `tapcell.tcl`: inserts GT2N taps at `TAPCELL_DISTANCE` sites, defaulting to
  14 if the run does not override it.
- `fill.json`: filler-cell configuration consumed by ORFS.
- `rcx_patterns.rules`: OpenRCX calibration rule deck.
- `gt2n.lydrc`: GT2N KLayout DRC deck.
- `gt2n.lylvs`: GT2N KLayout LVS deck.
- `gt2n.lyp` / `gt2n.lyt`: KLayout layer map and wrapper.
