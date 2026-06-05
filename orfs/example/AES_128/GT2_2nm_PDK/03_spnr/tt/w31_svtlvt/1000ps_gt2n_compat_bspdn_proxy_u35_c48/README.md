# AES BSPDN Proxy Run

This directory reproduces the GT2N AES backside-PDN proxy example. OpenROAD
routes the signal design using a stable router view, then a deterministic
postprocess step materializes backside/BPR/BM/BRDL power geometry in the final
physical GDS.

Run everything from this directory with:

```bash
./run_all.sh
```

## Script Summary

- `source_orfs.sh`: loads the ORFS Docker environment for this handoff package,
  including the mount path, container project root, and supplemental groups.
- `run_all.sh`: top-level reproducer. It runs `clean_all`, `route`, `finish`,
  physical BSPDN GDS materialization, KLayout DRC, and signal-only LVS.
- `make_bspdn_physical_gds.sh`: postprocesses the routed GDS and adds the
  deterministic physical backside PG grid.
- `run_bspdn_physical_drc.sh`: runs KLayout DRC on the physical BSPDN GDS.
- `run_bspdn_physical_lvs_signal.sh`: runs signal-only KLayout LVS on the
  physical BSPDN GDS. It passes `-rd signal_only_lvs=1` by default; set
  `SIGNAL_ONLY_LVS=0` to attempt full PG-included LVS. If the concatenated CDL
  is missing, this script regenerates it directly from the existing final ODB
  and does not invoke the ORFS Make CDL target, avoiding accidental route reruns.
- `pdn_bspdn_proxy_router_view.tcl`: router-view PDN stub. It avoids asking
  OpenROAD/TritonRoute to route true BPR/BM backside layers directly.
- `pre_final_report_clear_psm.tcl`: clears stale PDNSim markers and old VDD/VSS
  report files before final reporting.
- `config.mk`: self-contained BSPDN run configuration. It selects the
  `gt2n_compat_bspdn_proxy` platform, uses the BSPDN tap cell, sets
  `TAPCELL_DISTANCE=28`, and documents the router-view versus physical/signoff
  split. There is no separate BSPDN common-config include.

## Notes

`finish` triggers the normal ORFS final reports, including OpenSTA timing and
OpenROAD/OpenSTA vectorless power reporting. The backside power grid in the
final GDS is generated after signal routing, so native IR-drop analysis over
the full physical BSPDN structure remains a limitation requiring further work.
