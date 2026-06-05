#!/usr/bin/env bash
set -euo pipefail

# Generate the physical/signoff BSPDN GDS from the routed OpenROAD GDS.
# Run this after `orfs_make finish` has produced 6_final.gds.

if [[ ! -f ./source_orfs.sh ]]; then
  echo "Error: source_orfs.sh not found. Run from this BSPDN proxy run directory." >&2
  exit 1
fi

# shellcheck disable=SC1091
source ./source_orfs.sh >/dev/null

RESULTS_DIR_IN_CONTAINER="$WORK_HOME_IN_CONTAINER/results/gt2n_compat_bspdn_proxy/aes_128/base"
REPORTS_DIR_IN_CONTAINER="$WORK_HOME_IN_CONTAINER/reports/gt2n_compat_bspdn_proxy/aes_128/base"
SCRIPT_IN_CONTAINER="$CONTAINER_PROJ_IN_CONTAINER/OpenROAD-flow-scripts/flow/platforms/gt2n_compat_bspdn_proxy/scripts/add_bspdn_signoff_grid.rb"
IN_GDS="$RESULTS_DIR_IN_CONTAINER/6_final.gds"
OUT_GDS="$RESULTS_DIR_IN_CONTAINER/6_final_bspdn_physical.gds"
REPORT="$REPORTS_DIR_IN_CONTAINER/6_bspdn_physical_grid.rpt"

orfs "mkdir -p $REPORTS_DIR_IN_CONTAINER && test -f $IN_GDS && klayout -b -r $SCRIPT_IN_CONTAINER -rd in_gds=$IN_GDS -rd out_gds=$OUT_GDS -rd report=$REPORT -rd topcell=aes -rd core_margin_um=5.04"

echo "Wrote physical BSPDN GDS: $OUT_GDS"
echo "Wrote generation report: $REPORT"
