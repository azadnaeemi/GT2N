#!/usr/bin/env bash
set -euo pipefail

# Default is signal-only LVS on the postprocessed physical BSPDN GDS: remove
# vdd/vss from the comparison and verify the routed signal network.  Set
# SIGNAL_ONLY_LVS=0 to attempt full PG-included LVS.
SIGNAL_ONLY_LVS="${SIGNAL_ONLY_LVS:-1}"
if [[ "$SIGNAL_ONLY_LVS" == "1" ]]; then
  LVS_KIND="signalonly"
else
  LVS_KIND="full"
fi

# shellcheck disable=SC1091
source ./source_orfs.sh >/dev/null
RESULTS_DIR_IN_CONTAINER="$WORK_HOME_IN_CONTAINER/results/gt2n_compat_bspdn_proxy/aes_128/base"
OBJECTS_DIR_IN_CONTAINER="$WORK_HOME_IN_CONTAINER/objects/gt2n_compat_bspdn_proxy/aes_128/base"
REPORTS_DIR_IN_CONTAINER="$WORK_HOME_IN_CONTAINER/reports/gt2n_compat_bspdn_proxy/aes_128/base"
LOGS_DIR_IN_CONTAINER="$WORK_HOME_IN_CONTAINER/logs/gt2n_compat_bspdn_proxy/aes_128/base"
PLATFORM_DIR_IN_CONTAINER="$CONTAINER_PROJ_IN_CONTAINER/OpenROAD-flow-scripts/flow/platforms/gt2n_compat_bspdn_proxy"
PHYS_GDS="$RESULTS_DIR_IN_CONTAINER/6_final_bspdn_physical.gds"
ROUTED_DEF="$RESULTS_DIR_IN_CONTAINER/6_final.def"
CDL="$OBJECTS_DIR_IN_CONTAINER/6_final_concat.cdl"
REPORT="$RESULTS_DIR_IN_CONTAINER/6_lvs_bspdn_physical_${LVS_KIND}.lvsdb"
DECK="$PLATFORM_DIR_IN_CONTAINER/gt2n_compat_bspdn_proxy.lylvs"

# Use the existing concatenated CDL when available.  If it is missing, generate
# it directly from the existing final ODB; do not ask ORFS Make to build the CDL
# target, because stale timestamps can pull route/finish back into this
# post-GDS LVS wrapper.
if ! orfs "test -f $CDL"; then
  echo "Generating concatenated CDL from existing final ODB: $CDL"
  orfs "test -f $RESULTS_DIR_IN_CONTAINER/6_final.odb && test -f $RESULTS_DIR_IN_CONTAINER/6_final.sdc && \
    export FLOW_HOME=/OpenROAD-flow-scripts/flow; \
    export SCRIPTS_DIR=/OpenROAD-flow-scripts/flow/scripts; \
    export KEEP_VARS=1; \
    export OPENROAD_HIERARCHICAL=0; \
    export DESIGN_NAME=aes; \
    export DESIGN_NICKNAME=aes_128; \
    export PLATFORM=gt2n_compat_bspdn_proxy; \
    export RESULTS_DIR=$RESULTS_DIR_IN_CONTAINER; \
    export OBJECTS_DIR=$OBJECTS_DIR_IN_CONTAINER; \
    export REPORTS_DIR=$REPORTS_DIR_IN_CONTAINER; \
    export LOG_DIR=$LOGS_DIR_IN_CONTAINER; \
    export PLATFORM_DIR=$PLATFORM_DIR_IN_CONTAINER; \
    export LIB_FILES='$PLATFORM_DIR_IN_CONTAINER/lib/gt2_6t_w31_svt_tt_0p7v25c.lib $PLATFORM_DIR_IN_CONTAINER/lib/gt2_6t_w31_lvt_tt_0p7v25c.lib'; \
    export CDL_FILE='$PLATFORM_DIR_IN_CONTAINER/cdl/gt2_6t_w31_svt.cdl $PLATFORM_DIR_IN_CONTAINER/cdl/gt2_6t_w31_lvt.cdl'; \
    export LAYER_PARASITICS_FILE=$PLATFORM_DIR_IN_CONTAINER/setRC_fspdn.tcl; \
    export PROCESS=2; \
    mkdir -p $OBJECTS_DIR_IN_CONTAINER $REPORTS_DIR_IN_CONTAINER $LOGS_DIR_IN_CONTAINER; \
    /OpenROAD-flow-scripts/tools/install/OpenROAD/bin/openroad -exit -no_init -threads ${NUM_CORES:-48} /OpenROAD-flow-scripts/flow/scripts/cdl.tcl; \
    cat $RESULTS_DIR_IN_CONTAINER/6_final.cdl $PLATFORM_DIR_IN_CONTAINER/cdl/gt2_6t_w31_svt.cdl $PLATFORM_DIR_IN_CONTAINER/cdl/gt2_6t_w31_lvt.cdl > $CDL"
fi

orfs "test -f $PHYS_GDS && test -f $ROUTED_DEF && test -f $CDL && /OpenROAD-flow-scripts/flow/scripts/klayout.sh -b -rd in_gds=$PHYS_GDS -rd def_file=$ROUTED_DEF -rd cdl_file=$CDL -rd report_file=$REPORT -rd signal_only_lvs=$SIGNAL_ONLY_LVS -r $DECK"

echo "Wrote ${LVS_KIND} LVS database: $REPORT"
