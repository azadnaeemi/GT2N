# GT2N BSPDN Proxy Helper Scripts

These scripts are not fixed-name ORFS platform entry points. They are invoked
explicitly by the BSPDN proxy run scripts or by run-level hooks.

- `add_bspdn_signoff_grid.rb`: KLayout postprocess that reads the routed
  OpenROAD GDS and writes a physical/signoff BSPDN GDS with deterministic
  `BPR`, `BM1`-`BM4`, `BRDL`, and `BV0`-`BV4` geometry.
- `power_activity_vectorless.tcl`: OpenSTA/OpenROAD hook that applies default
  vectorless switching activity before `report_power`.
- `preprocess_lvs_cdl.py`: CDL normalization helper for KLayout abstract LVS.
  It handles library-wide split-VSS abstract-pin cases and filler removal on
  the schematic side.
