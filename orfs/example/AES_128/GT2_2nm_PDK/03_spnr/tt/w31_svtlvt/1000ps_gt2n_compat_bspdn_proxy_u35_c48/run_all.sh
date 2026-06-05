#!/usr/bin/env bash
set -euo pipefail
mkdir -p logs
export OR_IMAGE=${OR_IMAGE:-docker.io/openroad/orfs:26Q2}
# shellcheck disable=SC1091
source ./source_orfs.sh
orfs_make clean_all | tee logs/clean_all.log
orfs_make route NUM_CORES=${NUM_CORES:-48} DETAILED_ROUTE_END_ITERATION=${DETAILED_ROUTE_END_ITERATION:-20} | tee logs/route.log
orfs_make finish NUM_CORES=${NUM_CORES:-48} | tee logs/finish.log
./make_bspdn_physical_gds.sh | tee logs/make_physical_gds.log
./run_bspdn_physical_drc.sh | tee logs/drc.log
./run_bspdn_physical_lvs_signal.sh | tee logs/lvs_signal.log
