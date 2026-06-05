# Run-specific design + platform configuration (TT / w31_svtlvt / tap-BPR LEF test)

# Must match the RTL top module name.
export DESIGN_NAME = aes
export DESIGN_NICKNAME = aes_128
# Default to 48 threads; override per command if needed.
export NUM_CORES ?= 80

export PLATFORM = gt2n
# Run-specific work/config directory (points to current directory).
export RUN_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
export CONTAINER_PROJ ?= /work
# PDK collateral.
export PLATFORM_DIR = $(CONTAINER_PROJ)/OpenROAD-flow-scripts/flow/platforms/$(PLATFORM)
# Use ORFS scripts from the container image; the handoff carries platform files.
export SCRIPTS_DIR = /OpenROAD-flow-scripts/flow/scripts

export VERILOG_FILES = $(sort $(wildcard $(CONTAINER_PROJ)/AES_128/GT2_2nm_PDK/01_rtl/top/*.v))
export SDC_FILE = $(RUN_DIR)/constraint.sdc

export CORE_UTILIZATION = 40
export CORE_ASPECT_RATIO = 1
export CORE_MARGIN = 5.04

# Process node
export PROCESS = 2

#-----------------------------------------------------
# Tech/Libs
#-----------------------------------------------------
export TECH_LEF = $(PLATFORM_DIR)/techlib/gt2_fspdn_tech.lef
export SC_LEF = $(PLATFORM_DIR)/lef/gt2_6t_w31_svt.lef
export ADDITIONAL_LEFS = $(PLATFORM_DIR)/lef/gt2_6t_w31_lvt.lef
export LIB_FILES = $(PLATFORM_DIR)/lib/gt2_6t_w31_svt_tt_0p7v25c.lib \
                   $(PLATFORM_DIR)/lib/gt2_6t_w31_lvt_tt_0p7v25c.lib
export GDS_FILES = $(wildcard $(PLATFORM_DIR)/gds/*.gds)

export DONT_USE_CELLS +=

export FILL_CELLS ?= gt2_6t_filler_w31_lvt

#-----------------------------------------------------
# Yosys
#-----------------------------------------------------
export TIEHI_CELL_AND_PORT = gt2_6t_tiehigh_w31_lvt Y
export TIELO_CELL_AND_PORT = gt2_6t_tielow_w31_lvt Y
export MIN_BUF_CELL_AND_PORTS = gt2_6t_buf_x1_w31_lvt A Y

export LATCH_MAP_FILE :=
export CLKGATE_MAP_FILE :=
export ADDER_MAP_FILE :=

export ABC_DRIVER_CELL = gt2_6t_buf_x1_w31_svt
export ABC_LOAD_IN_FF = 5

#-----------------------------------------------------
# Sizing
#-----------------------------------------------------
export MATCH_CELL_FOOTPRINT = 1

#-----------------------------------------------------
# Floorplan
#-----------------------------------------------------
export PLACE_SITE = gt2_6t
export IO_PLACER_H ?= M2
export IO_PLACER_V ?= M3
export PRE_IO_PLACEMENT_TCL ?= $(PLATFORM_DIR)/pre_io_avoid_pdn_stripes.tcl

# Run-specific PDN file.
export PDN_TCL ?= $(RUN_DIR)/pdn_no_bpr_m2m3_rdl_dense.tcl
export POST_PDN_TCL ?= $(RUN_DIR)/post_pdn_tap_to_m3.tcl

export TAP_CELL_NAME = gt2_6t_tapfspdn_w31_lvt
export TAPCELL_DISTANCE ?= 28
export TAPCELL_TCL ?= $(PLATFORM_DIR)/tapcell.tcl

export MACRO_PLACE_HALO ?= 40 40

#-----------------------------------------------------
# Place
#-----------------------------------------------------
export PLACE_DENSITY ?= 0.58
export CELL_PAD_IN_SITES_GLOBAL_PLACEMENT ?= 1
export CELL_PAD_IN_SITES_DETAIL_PLACEMENT ?= 0
export ENABLE_DPO ?= 0
export DETAIL_PLACEMENT_ARGS ?= -max_displacement {50 10}

#-----------------------------------------------------
# Route
#-----------------------------------------------------
export ROUTING_LAYER_ADJUSTMENT ?= 0.25
export DETAILED_ROUTE_END_ITERATION ?= 20
export MIN_ROUTING_LAYER ?= M1
export MIN_CLK_ROUTING_LAYER ?= M3
export MAX_ROUTING_LAYER ?= M9

export FASTROUTE_TCL ?= $(PLATFORM_DIR)/fastroute.tcl
# Disabled for this tap-to-M3 topology.  The old hotspot nudge was tuned for a
# different placement/PDN shape set and creates an illegal overlap here.
# export PRE_DETAIL_ROUTE_TCL ?= $(RUN_DIR)/pre_detail_route_drc_avoid.tcl

export KLAYOUT_TECH_FILE = $(PLATFORM_DIR)/$(PLATFORM).lyt
export GDS_LAYER_MAP = $(PLATFORM_DIR)/techlib/gt2_techfile.layermap
export FILL_CONFIG = $(PLATFORM_DIR)/fill.json
export TEMPLATE_PGA_CFG ?= $(PLATFORM_DIR)/template_pga.cfg

export RCX_RULES = $(PLATFORM_DIR)/rcx_patterns.rules
# Select RC model to match chosen tech LEF.
ifeq ($(notdir $(TECH_LEF)),gt2_fspdn_tech.lef)
export LAYER_PARASITICS_FILE ?= $(PLATFORM_DIR)/setRC_fspdn.tcl
export MAKE_TRACKS ?= $(PLATFORM_DIR)/make_tracks_fspdn.tcl
else
export LAYER_PARASITICS_FILE ?= $(PLATFORM_DIR)/setRC.tcl
export MAKE_TRACKS ?= $(PLATFORM_DIR)/make_tracks.tcl
endif

# Ensure final report_power has a nonzero vectorless switching activity source.
export POWER_ACTIVITY_TCL ?= $(PLATFORM_DIR)/scripts/power_activity_vectorless.tcl

#-----------------------------------------------------
# IR Drop
#-----------------------------------------------------
export PWR_NETS_VOLTAGES ?= VDD 0.7
export GND_NETS_VOLTAGES ?= VSS 0.0
export IR_DROP_LAYER ?= M1
export PDNSIM_DONT_REQUIRE_TERMINALS ?= 0

# DRC/LVS
export KLAYOUT_DRC_FILE = $(PLATFORM_DIR)/$(PLATFORM).lydrc
export CDL_FILE = $(PLATFORM_DIR)/cdl/gt2_6t_w31_svt.cdl \
                  $(PLATFORM_DIR)/cdl/gt2_6t_w31_lvt.cdl
export KLAYOUT_LVS_FILE = $(PLATFORM_DIR)/$(PLATFORM).lylvs
export KLAYOUT_LVS_MODE ?= abstract

# Clear stale PSM marker categories before final IR checks.  OpenROAD reports
# clean PG connectivity after the markers are removed, but stale markers from
# earlier checks otherwise get dumped back into VDD.rpt/VSS.rpt.
export PRE_FINAL_REPORT_TCL ?= $(RUN_DIR)/pre_final_report_clear_psm.tcl

# Test note: tapcell LEFs now expose VDD/VSS on both M1 access and BPR rail; do not disconnect tap PG pins.

# Disabled for now: moving the hotspot before global route substantially changed
# the global/detail routing problem and produced far more transient DRCs.  The
# same local cell nudge is tested in PRE_DETAIL_ROUTE_TCL instead.
# export PRE_GLOBAL_ROUTE_TCL ?= $(RUN_DIR)/pre_global_route_move_hotspot.tcl

# This academic flow has no bump source file; use PDN straps as IR voltage sources.
export PDNSIM_SOURCE_TYPE ?= STRAPS


# Dense/RDL follow-up experiment: tighter floorplan and faster clock than the
# 2000ps topmesh reference.  Keep signal routing capped at M9; use upper layers
# for PDN only.
export MAX_ROUTING_LAYER := M9
export NUM_CORES ?= 80

# Disable GUI image capture in headless/batch signoff runs.
export SAVE_FINAL_IMAGES ?= 0
