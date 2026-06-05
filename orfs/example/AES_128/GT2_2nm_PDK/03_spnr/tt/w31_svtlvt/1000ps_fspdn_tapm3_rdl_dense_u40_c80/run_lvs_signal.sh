#!/usr/bin/env bash
set -euo pipefail

# Default is signal-only LVS: remove vdd/vss from the comparison and verify the
# routed signal network.  Set SIGNAL_ONLY_LVS=0 to attempt full PG-included LVS.
SIGNAL_ONLY_LVS="${SIGNAL_ONLY_LVS:-1}"
if [[ "$SIGNAL_ONLY_LVS" == "1" ]]; then
  LVS_KIND="signalonly"
else
  LVS_KIND="full"
fi

# shellcheck disable=SC1091
source ./source_orfs.sh >/dev/null
RESULTS_DIR_IN_CONTAINER="$WORK_HOME_IN_CONTAINER/results/gt2n/aes_128/base"
OBJECTS_DIR_IN_CONTAINER="$WORK_HOME_IN_CONTAINER/objects/gt2n/aes_128/base"
GDS="$RESULTS_DIR_IN_CONTAINER/6_final.gds"
DEF="$RESULTS_DIR_IN_CONTAINER/6_final.def"
CDL="$OBJECTS_DIR_IN_CONTAINER/6_final_concat.cdl"
REPORT="$RESULTS_DIR_IN_CONTAINER/6_lvs_${LVS_KIND}.lvsdb"
DECK="$CONTAINER_PROJ_IN_CONTAINER/OpenROAD-flow-scripts/flow/platforms/gt2n/gt2n.lylvs"

orfs_make "$CDL"
orfs "test -f $GDS && test -f $DEF && test -f $CDL && /OpenROAD-flow-scripts/flow/scripts/klayout.sh -b -rd in_gds=$GDS -rd def_file=$DEF -rd cdl_file=$CDL -rd report_file=$REPORT -rd signal_only_lvs=$SIGNAL_ONLY_LVS -r $DECK"

echo "Wrote ${LVS_KIND} LVS database: $REPORT"
