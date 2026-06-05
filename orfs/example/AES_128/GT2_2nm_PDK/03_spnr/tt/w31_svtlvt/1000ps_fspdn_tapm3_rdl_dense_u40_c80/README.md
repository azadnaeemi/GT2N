# AES FSPDN Run

This directory reproduces the GT2N AES frontside-PDN example. The flow uses
the GT2N FSPDN router view, a frontside M2/M3 plus upper-metal/RDL PDN, and a
tap-cell M1-to-M3 repair path for local power access.

Run everything from this directory with:

```bash
./run_all.sh
```

## Script Summary

- `source_orfs.sh`: loads the ORFS Docker environment for this handoff package,
  including the mount path, container project root, and supplemental groups.
- `run_all.sh`: top-level reproducer. It runs `clean_all`, `route`, `finish`,
  KLayout DRC, and signal-only LVS.
- `run_lvs_signal.sh`: runs the GT2N KLayout LVS deck in signal-only mode on
  the generated final layout. It passes `-rd signal_only_lvs=1` by default;
  set `SIGNAL_ONLY_LVS=0` to attempt full PG-included LVS.
- `pdn_no_bpr_m2m3_rdl_dense.tcl`: denser frontside/upper-metal/RDL PDN
  variant used by this run.
- `post_pdn_tap_to_m3.tcl`: inserts deterministic tap-cell VDD/VSS jogs from
  M1 through V1/M2/V2 to the M3 frontside PDN.
- `pre_final_report_clear_psm.tcl`: clears stale PDNSim markers and old VDD/VSS
  report files before final reporting.
- `config.mk`: selects the FSPDN tap cell and sets `TAPCELL_DISTANCE=28` for
  the platform `tapcell.tcl`.

## Notes

`finish` triggers the normal ORFS final reports, including OpenSTA timing and
OpenROAD/OpenSTA vectorless power reporting. This script does not run a
separate signoff-style IR-drop analysis step.
