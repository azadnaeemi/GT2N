# GT2N FSPDN IO-pin keepout generator.
#
# User-facing summary:
#   - FSPDN-oriented.
#   - Prevents IO pins from being placed directly on M2/M3 PDN stripe tracks.
#   - Avoids signal-to-PDN shorts caused by OpenROAD IO placement being unaware
#     of future PDN stripes.
#
# Problem addressed:
#   GT2N's current frontside-PDN flow uses global M2/M3 supply stripes before
#   signal routing.  OpenROAD's IO placer is not aware of those future special
#   nets, so it may place signal IO pins exactly on the same top/bottom M3 or
#   left/right M2 tracks that the PDN later occupies.  That creates real
#   signal-to-VDD/VSS shorts in the final GDS/LVS for IO-heavy designs.
#
# Approach:
#   Before io_placement.tcl calls place_pins, compute the M2/M3 PDN stripe
#   centerlines from the already-created floorplan core area and append PPL
#   -exclude intervals to PLACE_PINS_ARGS.  This keeps the existing M2/M3 IO
#   layers but prevents signal pins from landing directly on the PG stripe grid.
#
# Assumptions:
#   - Matches pdn_no_bpr_m2m3*.tcl: M2/M3 stripes have 6.0um same-net pitch and
#     3.0um first same-net offset from the core boundary, with alternating VDD
#     and VSS stripes interleaved every 3.0um.
#   - Exclusion intervals are intentionally wider than the raw stripe width so
#     neighboring pin shapes and route access do not touch the PG stripe.

if {[info exists ::env(GT2N_IO_PDN_AVOID)] && $::env(GT2N_IO_PDN_AVOID) == "0"} {
  puts "GT2N_IO_PDN_AVOID disabled; not adding IO pin exclusions."
  return
}

proc gt2n_io_dbu_to_um {v} {
  return [expr {double($v) / 2000.0}]
}

proc gt2n_io_add_exclusion {args_var edge lo_dbu hi_dbu die_lo die_hi} {
  upvar 1 $args_var args
  set lo [expr {max($lo_dbu, $die_lo)}]
  set hi [expr {min($hi_dbu, $die_hi)}]
  if {$hi <= $lo} {
    return
  }
  lappend args -exclude [format "%s:%.6f-%.6f" $edge [gt2n_io_dbu_to_um $lo] [gt2n_io_dbu_to_um $hi]]
}

proc gt2n_io_add_pdn_stripe_exclusions {args_var edges core_lo core_hi die_lo die_hi} {
  upvar 1 $args_var args

  set dbu 2000
  set first_offset [expr {int(round(3.0 * $dbu))}]
  set alternating_pitch [expr {int(round(3.0 * $dbu))}]

  # Cover more than the physical stripe.  M2/M3 pins are tiny, but one or two
  # routing tracks of margin avoid accidental touch/overlap after GDS export.
  set half_width [expr {int(round(0.090 * $dbu))}]

  set center [expr {$core_lo + $first_offset}]
  while {$center <= $core_hi} {
    set lo [expr {$center - $half_width}]
    set hi [expr {$center + $half_width}]
    foreach edge $edges {
      gt2n_io_add_exclusion args $edge $lo $hi $die_lo $die_hi
    }
    incr center $alternating_pitch
  }
}

set block [ord::get_db_block]
set die_area [$block getDieArea]
set core_area [$block getCoreArea]

set avoid_args {}

# Top/bottom pins use vertical M3 in this flow; exclude vertical M3 PG stripes.
gt2n_io_add_pdn_stripe_exclusions avoid_args {top bottom} \
  [$core_area xMin] [$core_area xMax] [$die_area xMin] [$die_area xMax]

# Left/right pins use horizontal M2 in this flow; exclude horizontal M2 PG stripes.
gt2n_io_add_pdn_stripe_exclusions avoid_args {left right} \
  [$core_area yMin] [$core_area yMax] [$die_area yMin] [$die_area yMax]

set old_args {}
if {[info exists ::env(PLACE_PINS_ARGS)] && $::env(PLACE_PINS_ARGS) ne ""} {
  set old_args $::env(PLACE_PINS_ARGS)
}
set ::env(PLACE_PINS_ARGS) [concat $old_args $avoid_args]

puts "GT2N_IO_PDN_AVOID added [expr {[llength $avoid_args] / 2}] IO exclusion intervals for M2/M3 PDN stripes."
