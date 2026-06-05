# GT2N OpenROAD AES Reproduction Package

This package contains a compact OpenROAD-flow-scripts overlay for reproducing two GT2N AES runs:

- `1000ps_fspdn_tapm3_rdl_dense_u40_c80`: frontside PDN implementation.
- `1000ps_gt2n_compat_bspdn_proxy_u35_c48`: BSPDN compatibility implementation with deterministic post-GDS backside grid generation.

The package intentionally contains only the files needed to review/rerun the examples plus selected tool-generated logs/reports from the reference run.  It does not include final ODB/GDS/SPEF databases; rerun `run_all.sh` to regenerate them.

## Layout

- `OpenROAD-flow-scripts/flow/platforms/gt2n`: minimal GT2N platform collateral for the selected w31 SVT/LVT examples.
- `OpenROAD-flow-scripts/flow/platforms/gt2n_compat_bspdn_proxy`: BSPDN compatibility platform view.
- `AES_128/GT2_2nm_PDK/01_rtl/top`: AES RTL.
- `AES_128/GT2_2nm_PDK/03_spnr/tt/w31_svtlvt/<run>`: example run directories.

## How to Run

Place this package at the root of an ORFS workspace, or merge the included
`OpenROAD-flow-scripts/flow/platforms/*` directories into an existing ORFS
checkout.  This package's `OpenROAD-flow-scripts` directory is an overlay, not
a complete ORFS checkout. If ORFS is somewhere else, set:

```sh
export ORFS=/path/to/OpenROAD-flow-scripts
export PROJ=/path/to/project/root
export OR_IMAGE=docker.io/openroad/orfs:26Q2
```

`source_orfs.sh` assumes Docker can mount `PROJ` at `/work`. If your site only
allows Docker to mount a parent directory, set both variables before sourcing:

```sh
export ORFS_WORKSPACE_HOST=/path/to/mountable/parent
export CONTAINER_PROJ_IN_CONTAINER=/work/relative/path/to/gt2n_openroad_run
```

Then run one of the examples:

```sh
cd AES_128/GT2_2nm_PDK/03_spnr/tt/w31_svtlvt/1000ps_fspdn_tapm3_rdl_dense_u40_c80
./run_all.sh
```

or:

```sh
cd AES_128/GT2_2nm_PDK/03_spnr/tt/w31_svtlvt/1000ps_gt2n_compat_bspdn_proxy_u35_c48
./run_all.sh
```

## Reference Results Included

FSPDN reference logs are in:

```sh
AES_128/GT2_2nm_PDK/03_spnr/tt/w31_svtlvt/1000ps_fspdn_tapm3_rdl_dense_u40_c80/logs
```

BSPDN proxy reference logs are in:

```sh
AES_128/GT2_2nm_PDK/03_spnr/tt/w31_svtlvt/1000ps_gt2n_compat_bspdn_proxy_u35_c48/logs
```

Reference summary:

| Flow | DRC count | Signal LVS | Vectorless power |
|---|---:|---|---:|
| AES FSPDN | 97 | pass | 44.904 mW |
| AES BSPDN proxy physical GDS | 16 | pass | 41.865 mW |

Power is OpenSTA/OpenROAD vectorless `report_power` using Liberty + SPEF + explicit activity annotation.  It is intended for relative PPA comparison, not workload-specific signoff power.

Timing and vectorless power reports are produced by the normal ORFS `finish`
stage. The package does not claim a validated full-grid IR-drop result. In
particular, the BSPDN proxy flow materializes the physical backside PG geometry
after OpenROAD routing, so native PDNSim/IR-drop analysis over that complete
physical BSPDN grid remains an open item for further methodology work.
