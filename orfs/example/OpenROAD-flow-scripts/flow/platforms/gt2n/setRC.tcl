# RC wrapper for ORFS scripts.
#
# Stock ORFS scripts sometimes source $(PLATFORM_DIR)/setRC.tcl directly,
# bypassing the run-level LAYER_PARASITICS_FILE override.  GT2N FSPDN/router
# views use gt2_fspdn_tech.lef, where BPR/BM*/BRDL are intentionally not
# routable.  In that case, use the frontside-only RC deck; otherwise use the
# full frontside+backside RC deck.

set tech_lef_name ""
if { [info exists ::env(TECH_LEF)] } {
  set tech_lef_name [file tail $::env(TECH_LEF)]
}

if { $tech_lef_name == "gt2_fspdn_tech.lef" } {
  source [file join $::env(PLATFORM_DIR) setRC_fspdn.tcl]
} else {
  source [file join $::env(PLATFORM_DIR) setRC_full.tcl]
}
