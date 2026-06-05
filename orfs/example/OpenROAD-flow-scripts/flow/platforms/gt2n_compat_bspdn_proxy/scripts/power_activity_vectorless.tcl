# Vectorless activity annotation for OpenSTA/OpenROAD report_power.
#
# The ISPD 2026 Pin-3D OpenROAD flow reports power in vectorless mode using a
# default switching activity.  Without an explicit activity source, OpenROAD can
# report zero switching power, which makes the power table unusable for PPA.
#
# This hook is sourced by flow/scripts/final_report.tcl after SPEF is read and
# before report_power / PDNSim consume STA power data.
#
# activity is in transitions per clock period; duty is static high probability.
# Innovus/Voltus reports from the reference AES run used vectorless activity:
#   Sequential Element Activity: 0.200000
#   Primary Input Activity:      0.200000
# Match that default here unless the run overrides GT2N_POWER_ACTIVITY.
if { [info exists ::env(GT2N_POWER_ACTIVITY)] } {
  set gt2n_default_activity $::env(GT2N_POWER_ACTIVITY)
} else {
  set gt2n_default_activity 0.20
}
set gt2n_default_duty 0.50

puts "GT2N vectorless power activity: global activity=$gt2n_default_activity duty=$gt2n_default_duty"
set_power_activity -global -activity $gt2n_default_activity -duty $gt2n_default_duty
set_power_activity -input -activity $gt2n_default_activity -duty $gt2n_default_duty

# Optional debug/compatibility mode.  The preferred flow lets OpenSTA propagate
# activity from primary inputs and sequential elements.  Force-annotating every
# output pin is intentionally disabled by default because it can over-constrain
# activity propagation and diverge from Innovus/Voltus vectorless behavior.
set gt2n_force_output_activity 0
if { [info exists ::env(GT2N_FORCE_OUTPUT_ACTIVITY)] } {
  set gt2n_force_output_activity $::env(GT2N_FORCE_OUTPUT_ACTIVITY)
}
if { $gt2n_force_output_activity } {
  set gt2n_output_pins [get_pins -hierarchical * -filter "direction == output"]
  puts "GT2N vectorless power activity: force-annotating [llength $gt2n_output_pins] output pins"
  if { [llength $gt2n_output_pins] > 0 } {
    set_power_activity -pins $gt2n_output_pins -activity $gt2n_default_activity -duty $gt2n_default_duty
  }
} else {
  puts "GT2N vectorless power activity: output-pin force annotation disabled"
}
report_activity_annotation

if { [info exists ::env(REPORTS_DIR)] } {
  set gt2n_power_detail "$::env(REPORTS_DIR)/6_power_vectorless_detail.rpt"
  puts "Writing detailed vectorless power report: $gt2n_power_detail"
  report_power -digits 9 > $gt2n_power_detail
}
