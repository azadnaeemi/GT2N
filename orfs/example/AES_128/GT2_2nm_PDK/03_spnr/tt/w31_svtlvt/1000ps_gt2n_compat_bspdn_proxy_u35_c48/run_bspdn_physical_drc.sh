#!/usr/bin/env bash
set -euo pipefail

# Run the GT2N KLayout DRC deck on the postprocessed physical BSPDN GDS.
# Requires `./make_bspdn_physical_gds.sh` to have generated 6_final_bspdn_physical.gds.

# shellcheck disable=SC1091
source ./source_orfs.sh >/dev/null
RESULTS_DIR_IN_CONTAINER="$WORK_HOME_IN_CONTAINER/results/gt2n_compat_bspdn_proxy/aes_128/base"
REPORTS_DIR_IN_CONTAINER="$WORK_HOME_IN_CONTAINER/reports/gt2n_compat_bspdn_proxy/aes_128/base"
PHYS_GDS="$RESULTS_DIR_IN_CONTAINER/6_final_bspdn_physical.gds"
REPORT="$REPORTS_DIR_IN_CONTAINER/6_drc_bspdn_physical.lyrdb"
COUNT="$REPORTS_DIR_IN_CONTAINER/6_drc_bspdn_physical_count.rpt"
DECK="$CONTAINER_PROJ_IN_CONTAINER/OpenROAD-flow-scripts/flow/platforms/gt2n_compat_bspdn_proxy/gt2n_compat_bspdn_proxy.lydrc"

orfs "test -f $PHYS_GDS && /OpenROAD-flow-scripts/flow/scripts/klayout.sh -zz -rd in_gds=$PHYS_GDS -rd drc_mode=route -rd drc_threads=${KLAYOUT_DRC_THREADS:-48} -rd drc_tile_um=${KLAYOUT_DRC_TILE_UM:-200} -rd report_file=$REPORT -r $DECK; grep -c '<value>' $REPORT > $COUNT || [[ \$? == 1 ]]"

echo "Wrote DRC report: $REPORT"
echo "Wrote DRC count: $COUNT"
