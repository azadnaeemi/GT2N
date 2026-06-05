# Clears stale PDNSim/PSM markers from the ODB before final reporting.
# Prevents old VDD/VSS marker reports from being carried forward after a later
# clean check. This does not change placement, routing, or layout geometry.
set block [ord::get_db_block]
set cat [$block findMarkerCategory PSM]
if {$cat != "NULL" && $cat != ""} {
  puts "Clearing stale PSM marker category with [$cat getMarkerCount] markers"
  ::odb::dbMarkerCategory_destroy $cat
} else {
  puts "No stale PSM marker category found"
}
foreach net {VDD VSS} {
  file delete -force $::env(REPORTS_DIR)/${net}.rpt
  file delete -force $::env(REPORTS_DIR)/${net}_check.rpt
}
