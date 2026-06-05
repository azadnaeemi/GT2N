set tapcell_distance 14
if {[info exists ::env(TAPCELL_DISTANCE)] && $::env(TAPCELL_DISTANCE) ne ""} {
  set tapcell_distance $::env(TAPCELL_DISTANCE)
}

tapcell \
  -distance $tapcell_distance \
  -tapcell_master "$::env(TAP_CELL_NAME)"
