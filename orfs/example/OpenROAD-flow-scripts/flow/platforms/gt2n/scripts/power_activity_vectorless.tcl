# Vectorless activity annotation for OpenSTA/OpenROAD report_power.
#
# OpenSTA can report zero switching power if no activity source is provided.
# This hook is sourced by flow/scripts/final_report.tcl after SPEF is read and
# before report_power/PDNSim consume STA power data.
#
# The default follows the common Innovus/Voltus-style vectorless setup used for
# GT2N bring-up: 0.20 transitions per clock period and 0.50 duty.  Override with
# GT2N_POWER_ACTIVITY when a different activity assumption is needed.
if { [info exists ::env(GT2N_POWER_ACTIVITY)] && $::env(GT2N_POWER_ACTIVITY) ne "" } {
  set gt2n_default_activity $::env(GT2N_POWER_ACTIVITY)
} else {
  set gt2n_default_activity 0.20
}
set gt2n_default_duty 0.50

puts "GT2N vectorless power activity: global activity=$gt2n_default_activity duty=$gt2n_default_duty"
set_power_activity -global -activity $gt2n_default_activity -duty $gt2n_default_duty
set_power_activity -input -activity $gt2n_default_activity -duty $gt2n_default_duty

report_activity_annotation

if { [info exists ::env(REPORTS_DIR)] } {
  set gt2n_power_detail "$::env(REPORTS_DIR)/6_power_vectorless_detail.rpt"
  puts "Writing detailed vectorless power report: $gt2n_power_detail"
  report_power -digits 9 > $gt2n_power_detail
}
