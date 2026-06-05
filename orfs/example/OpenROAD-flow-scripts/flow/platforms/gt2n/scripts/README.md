# GT2N Helper Scripts

Scripts here are helpers, not ORFS fixed-name platform hooks.

- `power_activity_vectorless.tcl`: applies deterministic vectorless switching
  activity before OpenSTA/OpenROAD power reporting when no SAIF/VCD is
  available.
- `preprocess_lvs_cdl.py`: normalizes CDL input before KLayout LVS preprocessing.

Variant-specific helpers, such as BSPDN physical-GDS materialization, live in
the corresponding compatibility platform `scripts/` directory.
