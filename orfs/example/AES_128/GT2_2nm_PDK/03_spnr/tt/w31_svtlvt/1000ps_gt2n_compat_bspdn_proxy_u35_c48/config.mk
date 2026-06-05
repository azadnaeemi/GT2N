# AES GT2N BSPDN-proxy compatibility-flow run.
#
# This run intentionally separates the OpenROAD router view from the final
# physical/signoff view. OpenROAD uses the known-good frontside routing proxy;
# scripts/make_bspdn_physical_gds.sh then materializes real backside PG geometry
# on BPR/BM*/BRDL layers in a separate GDS.

export RUN_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
export CONTAINER_PROJ ?= /work
export DESIGN_NAME = aes
export DESIGN_NICKNAME = aes_128
export VERILOG_FILES = $(sort $(wildcard $(CONTAINER_PROJ)/AES_128/GT2_2nm_PDK/01_rtl/top/*.v))
export SDC_FILE = $(RUN_DIR)/constraint.sdc
export CORE_UTILIZATION ?= 35
export NUM_CORES ?= 48

# Common GT2N BSPDN-proxy OpenROAD compatibility configuration.
#
# Methodology:
#   - OpenROAD/TritonRoute sees a stable frontside signal-routing view.  It does
#     not see true BPR/BM routing layers and it does not build a frontside PG
#     mesh for this flow.
#   - Tap insertion uses gt2_6t_tapbspdn_* cells: BPR-only well taps, not the
#     FSPDN bridge taps and not the tap-to-M3 frontside repair path.
#   - After GDS stream-out, a deterministic KLayout postprocess adds the real
#     GT2N BSPDN physical/signoff view on BPR/BM*/BRDL/BV* layers.
#
# This is the GT2N analogue of the compatibility-layer idea from the ISPD 2026
# OpenROAD 3D paper: keep router-visible abstractions simple and materialize the
# true physical backside PG connectivity in a signoff/postprocess view.

export PLATFORM = gt2n_compat_bspdn_proxy
export PLATFORM_DIR = $(CONTAINER_PROJ)/OpenROAD-flow-scripts/flow/platforms/$(PLATFORM)
export SCRIPTS_DIR = /OpenROAD-flow-scripts/flow/scripts

export CORE_ASPECT_RATIO ?= 1
export CORE_MARGIN ?= 5.04
export PROCESS ?= 2

# Router view: BPR is masterslice, backside BM* layers are not routed by DRT.
export TECH_LEF = $(PLATFORM_DIR)/techlib/gt2_fspdn_tech.lef
export SC_LEF = $(PLATFORM_DIR)/lef/gt2_6t_w31_svt.lef
export ADDITIONAL_LEFS = $(PLATFORM_DIR)/lef/gt2_6t_w31_lvt.lef

# Use the official GT2N Liberty collateral.  GT2N_LIB_DIR remains overridable
# for A/B testing alternate Liberty views without editing this run setup.
export GT2N_LIB_DIR ?= $(PLATFORM_DIR)/lib
export LIB_FILES = $(GT2N_LIB_DIR)/gt2_6t_w31_svt_tt_0p7v25c.lib \
                   $(GT2N_LIB_DIR)/gt2_6t_w31_lvt_tt_0p7v25c.lib
export GDS_FILES = $(wildcard $(PLATFORM_DIR)/gds/*.gds)
export DONT_USE_CELLS +=
export FILL_CELLS ?= gt2_6t_filler_w31_lvt

export TIEHI_CELL_AND_PORT = gt2_6t_tiehigh_w31_lvt Y
export TIELO_CELL_AND_PORT = gt2_6t_tielow_w31_lvt Y
export MIN_BUF_CELL_AND_PORTS = gt2_6t_buf_x1_w31_lvt A Y
export ABC_DRIVER_CELL = gt2_6t_buf_x1_w31_svt
export ABC_LOAD_IN_FF = 5
export LATCH_MAP_FILE :=
export CLKGATE_MAP_FILE :=
export ADDER_MAP_FILE :=
export MATCH_CELL_FOOTPRINT = 1

export PLACE_SITE = gt2_6t
export IO_PLACER_H ?= M2
export IO_PLACER_V ?= M3
export PDN_TCL ?= $(RUN_DIR)/pdn_bspdn_proxy_router_view.tcl
export POST_PDN_TCL ?=
export TAP_CELL_NAME = gt2_6t_tapbspdn_w31_lvt
export TAPCELL_DISTANCE ?= 28
export TAPCELL_TCL ?= $(PLATFORM_DIR)/tapcell.tcl
export MACRO_PLACE_HALO ?= 40 40

export PLACE_DENSITY ?= 0.58
export CELL_PAD_IN_SITES_GLOBAL_PLACEMENT ?= 1
export CELL_PAD_IN_SITES_DETAIL_PLACEMENT ?= 0
export ENABLE_DPO ?= 0
export DETAIL_PLACEMENT_ARGS ?= -max_displacement {50 10}

export ROUTING_LAYER_ADJUSTMENT ?= 0.25
export DETAILED_ROUTE_END_ITERATION ?= 20
export MIN_ROUTING_LAYER ?= M1
export MIN_CLK_ROUTING_LAYER ?= M3
export MAX_ROUTING_LAYER ?= M9
export FASTROUTE_TCL ?= $(PLATFORM_DIR)/fastroute.tcl

export KLAYOUT_TECH_FILE = $(PLATFORM_DIR)/$(PLATFORM).lyt
export GDS_LAYER_MAP = $(PLATFORM_DIR)/techlib/gt2_techfile.layermap
export FILL_CONFIG = $(PLATFORM_DIR)/fill.json
export RCX_RULES = $(PLATFORM_DIR)/rcx_patterns.rules
export LAYER_PARASITICS_FILE ?= $(PLATFORM_DIR)/setRC_fspdn.tcl
export MAKE_TRACKS ?= $(PLATFORM_DIR)/make_tracks_fspdn.tcl

# Use vectorless default switching activity for report_power, matching the
# evaluation style described by the ISPD 2026 Pin-3D OpenROAD flow.  Replace
# this hook with SAIF/VCD annotation for workload-specific power.
export POWER_ACTIVITY_TCL ?= $(PLATFORM_DIR)/scripts/power_activity_vectorless.tcl

# The OpenROAD router-view ODB intentionally has no real BSPDN physical PG grid.
# Running PDNSim/analyze_power_grid in final_report on this view can crash or
# report meaningless connectivity.  IR analysis belongs on the postprocessed
# physical/signoff view after BSPDN BPR/BM/BRDL geometry has been materialized.
export PWR_NETS_VOLTAGES ?=
export GND_NETS_VOLTAGES ?=
export IR_DROP_LAYER ?= BPR
export PDNSIM_DONT_REQUIRE_TERMINALS ?= 0
export PDNSIM_SOURCE_TYPE ?= STRAPS

export KLAYOUT_DRC_FILE = $(PLATFORM_DIR)/$(PLATFORM).lydrc
export KLAYOUT_LVS_FILE = $(PLATFORM_DIR)/$(PLATFORM).lylvs
export KLAYOUT_LVS_MODE ?= abstract
export CDL_FILE = $(PLATFORM_DIR)/cdl/gt2_6t_w31_svt.cdl \
                  $(PLATFORM_DIR)/cdl/gt2_6t_w31_lvt.cdl
export PRE_FINAL_REPORT_TCL ?= $(RUN_DIR)/pre_final_report_clear_psm.tcl
export SAVE_FINAL_IMAGES ?= 0

# Post-GDS physical/signoff materialization.
export BSPDN_PHYSICAL_GDS_SCRIPT ?= $(PLATFORM_DIR)/scripts/add_bspdn_signoff_grid.rb
export BSPDN_PHYSICAL_GDS_SUFFIX ?= _bspdn_physical
