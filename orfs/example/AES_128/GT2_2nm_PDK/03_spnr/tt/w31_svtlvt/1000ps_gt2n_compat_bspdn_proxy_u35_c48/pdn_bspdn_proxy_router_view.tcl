# GT2N pure-BSPDN router-view PDN stub.
#
# User-facing summary:
#   - BSPDN-only.
#   - Creates VDD/VSS net annotations with global_connect.
#   - Prevents ORFS pdngen from creating a dummy frontside PDN.
#   - Keeps the BSPDN router view signal/frontside-only until the post-GDS
#     backside grid insertion.
#
# Purpose:
#   Keep OpenROAD/TritonRoute completely out of BPR/BM/backside PG routing and
#   also avoid the FSPDN tap-to-M3 frontside workaround.  This run is intended to
#   place and route only the signal network in a frontside-compatible view.
#
# Physical BSPDN is materialized after GDS stream-out by
#   gt2n_compat_bspdn_proxy/scripts/add_bspdn_signoff_grid.rb
# which inserts real BPR/BM*/BRDL/BV* VDD/VSS geometry into the GDS.
#
# ORFS's generic scripts/pdn.tcl always calls `pdngen` after sourcing this file.
# A truly empty grid is rejected by pdngen, and adding dummy frontside PG shapes
# would make this no longer a pure-BSPDN router view.  Therefore this script
# preserves the OpenDB PG net annotations with global_connect, then shadows the
# pdngen Tcl command with a local no-op for this OpenROAD process only.  The
# physical/signoff BSPDN grid is inserted later by the deterministic post-GDS
# KLayout step named above.

add_global_connection -net {VDD} -inst_pattern {.*} -pin_pattern {^(vdd|VDD|VPWR)$} -power
add_global_connection -net {VSS} -inst_pattern {.*} -pin_pattern {^(vss|VSS|VGND)$} -ground
global_connect

set_voltage_domain -name {CORE} -power {VDD} -ground {VSS}
define_pdn_grid -name {grid} -voltage_domains {CORE}

if {[llength [info commands pdngen]] != 0} {
  if {[llength [info commands gt2n_bspdn_proxy_real_pdngen]] == 0} {
    rename pdngen gt2n_bspdn_proxy_real_pdngen
  }
}

proc pdngen {args} {
  puts "GT2N-BSPDN-PROXY: skipping OpenROAD pdngen in pure BSPDN router view."
  return
}
