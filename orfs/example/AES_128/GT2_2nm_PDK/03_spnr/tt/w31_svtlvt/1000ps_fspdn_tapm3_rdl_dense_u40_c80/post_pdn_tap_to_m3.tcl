# Post-PDN tap-cell power hookup repair for GT2N FSPDN.
#
# Purpose:
#   Connect tap-cell VDD/VSS M1 access pins into the frontside PDN without using
#   global M1 PDN stripes.  This avoids the VDD/VSS shorts seen when a full-chip
#   M1 stripe crosses an opposite-net tap access pin.
#
# Topology per disconnected tap pin:
#   tap M1 access pin -> V1_0 -> local M2 jog -> V2_0 -> same-net M3 stripe
#
# Important constraints:
#   - No new M1 wire is created.  The only M1 special-net geometry is the V1_0
#     enclosure centered on the existing same-net tap access pin.
#   - M2 jogs are shifted away from global M2 PDN stripe tracks to avoid shorts
#     or tight M2 spacing against the mesh.
#   - Adjacent VDD/VSS tap access pins are close in the same row.  Using the
#     nearest same-net M3 stripe can route VDD and VSS M2 jogs toward each other
#     and create real same-layer shorts.  Route VDD to the left same-net M3
#     stripe and VSS to the right same-net M3 stripe so the jogs move apart.

set ::tap_m3_out_dir "$::env(REPORTS_DIR)/tap_pg_to_m3"
file mkdir $::tap_m3_out_dir

proc tap_m3_um_to_dbu {v} {
  return [expr {int(round(double($v) * 2000.0))}]
}

proc tap_m3_select_stripe_x {cx base_x pitch core_xmin core_xmax side} {
  # Choose a same-net M3 stripe that actually exists in the core.  Earlier
  # versions bounded this against the die, which let edge taps select an
  # out-of-core stripe center on larger/lower-utilization floorplans.
  set rel [expr {double($cx - $base_x) / double($pitch)}]
  if {$side eq "left"} {
    set n [expr {int(floor($rel))}]
  } elseif {$side eq "right"} {
    set n [expr {int(ceil($rel))}]
  } else {
    set n [expr {int(floor($rel + 0.5))}]
  }

  set n_min [expr {int(ceil(double($core_xmin - $base_x) / double($pitch)))}]
  set n_max [expr {int(floor(double($core_xmax - $base_x) / double($pitch)))}]
  if {$n_min > $n_max} {
    error "No in-core M3 stripe candidate for base=$base_x pitch=$pitch core_x=($core_xmin,$core_xmax)"
  }

  if {$n < $n_min} { set n $n_min }
  if {$n > $n_max} { set n $n_max }

  set tx [expr {$base_x + $n * $pitch}]

  # If side preference had to be clamped at an edge, choose the nearest in-core
  # same-net stripe.  This keeps the old left/right separation where possible
  # but avoids disconnected edge taps.
  set nearest_n [expr {int(floor((double($cx - $base_x) / double($pitch)) + 0.5))}]
  if {$nearest_n < $n_min} { set nearest_n $n_min }
  if {$nearest_n > $n_max} { set nearest_n $n_max }
  set nearest_tx [expr {$base_x + $nearest_n * $pitch}]
  if {abs($nearest_tx - $cx) < abs($tx - $cx) && ($tx < $core_xmin || $tx > $core_xmax)} {
    set tx $nearest_tx
  }
  return $tx
}

proc tap_m3_nearest_track {coord offset pitch} {
  set n [expr {int(floor((double($coord - $offset) / double($pitch)) + 0.5))}]
  return [expr {$offset + $n * $pitch}]
}

proc tap_m3_stagger_y {net_name m2_y y1 y2 m2_pitch} {
  if {$net_name ne "VSS"} { return $m2_y }
  set delta [expr {2 * $m2_pitch}]
  foreach candidate [list [expr {$m2_y - $delta}] [expr {$m2_y + $delta}] [expr {$m2_y - $m2_pitch}] [expr {$m2_y + $m2_pitch}]] {
    if {$candidate >= $y1 && $candidate <= $y2} { return $candidate }
  }
  return $m2_y
}

proc tap_m3_nearest_global_m2_y {m2_y} {
  # M2 PDN stripes from pdn_no_bpr_m2m3_rdl_dense.tcl fall on a combined 6um grid.
  set base 16080
  set pitch 6000
  set n [expr {int(floor((double($m2_y - $base) / double($pitch)) + 0.5))}]
  return [expr {$base + $n * $pitch}]
}

proc tap_m3_clear_of_global_m2 {m2_y} {
  # M2 width is 24 DBU and same-layer spacing is 24 DBU, so 48 DBU center
  # separation keeps a local jog clear of a global M2 stripe.
  return [expr {abs($m2_y - [tap_m3_nearest_global_m2_y $m2_y]) >= 48}]
}

proc tap_m3_avoid_global_m2 {m2_y y1 y2 m2_pitch} {
  if {[tap_m3_clear_of_global_m2 $m2_y]} { return $m2_y }
  for {set step 1} {$step <= 8} {incr step} {
    foreach sign {-1 1} {
      set candidate [expr {$m2_y + $sign * $step * $m2_pitch}]
      if {$candidate < $y1 || $candidate > $y2} { continue }
      if {[tap_m3_clear_of_global_m2 $candidate]} { return $candidate }
    }
  }
  return $m2_y
}

proc tap_m3_add_from_report {net_name rpt_file m3_base_x m3_pitch stripe_side} {
  set block [ord::get_db_block]
  set tech [ord::get_db_tech]
  set net [$block findNet $net_name]
  if {$net == "NULL"} { error "Cannot find net $net_name" }

  set m2 [$tech findLayer M2]
  set via1 [$tech findVia V1_0]
  set via2 [$tech findVia V2_0]
  if {$m2 == "NULL" || $via1 == "NULL" || $via2 == "NULL"} {
    error "Cannot find M2, V1_0, or V2_0 for tap-to-M3 hookup."
  }

  set m2_offset 12
  set m2_pitch 48
  set m2_half_width 12
  set core_area [$block getCoreArea]
  set core_xmin [$core_area xMin]
  set core_xmax [$core_area xMax]
  set swire [odb::dbSWire_create $net "ROUTED"]
  set count 0
  set staggered_count 0
  set avoided_count 0

  if {![file exists $rpt_file]} {
    puts "TAP_TO_M3 $net_name no_report=$rpt_file added=0"
    return 0
  }

  set fh [open $rpt_file r]
  while {[gets $fh line] >= 0} {
    if {![regexp {bbox = \(([0-9.]+), ([0-9.]+)\) - \(([0-9.]+), ([0-9.]+)\) on Layer M1} $line -> x1u y1u x2u y2u]} {
      continue
    }

    set x1 [tap_m3_um_to_dbu $x1u]
    set x2 [tap_m3_um_to_dbu $x2u]
    set y1 [tap_m3_um_to_dbu $y1u]
    set y2 [tap_m3_um_to_dbu $y2u]
    set cx [expr {int(round(($x1 + $x2) / 2.0))}]
    set cy [expr {int(round(($y1 + $y2) / 2.0))}]
    set m3_x [tap_m3_select_stripe_x $cx $m3_base_x $m3_pitch $core_xmin $core_xmax $stripe_side]

    set m2_y [tap_m3_nearest_track $cy $m2_offset $m2_pitch]
    set staggered [tap_m3_stagger_y $net_name $m2_y $y1 $y2 $m2_pitch]
    if {$staggered != $m2_y} {
      incr staggered_count
      set m2_y $staggered
    }
    set safe_y [tap_m3_avoid_global_m2 $m2_y $y1 $y2 $m2_pitch]
    if {$safe_y != $m2_y} {
      incr avoided_count
      set m2_y $safe_y
    }

    set lx [expr {min($cx, $m3_x)}]
    set ux [expr {max($cx, $m3_x)}]
    if {$ux == $lx} { incr ux }

    odb::dbSBox_create $swire $m2 $lx [expr {$m2_y - $m2_half_width}] $ux [expr {$m2_y + $m2_half_width}] "STRIPE"
    odb::dbSBox_create $swire $via1 $cx $m2_y "STRIPE"
    odb::dbSBox_create $swire $via2 $m3_x $m2_y "STRIPE"
    incr count
  }
  close $fh

  puts "TAP_TO_M3 $net_name added=$count stripe_side=$stripe_side staggered_m2=$staggered_count pdn_m2_avoided=$avoided_count"
  return $count
}

proc tap_m3_repair_net {net_name m3_base_x m3_pitch stripe_side} {
  global tap_m3_out_dir
  set before_rpt "$tap_m3_out_dir/${net_name}.before.rpt"
  catch {file delete -force $before_rpt}
  set before_status [catch {check_power_grid -net $net_name -error_file $before_rpt} before_msg]
  puts "TAP_TO_M3 $net_name before_status=$before_status before_msg=$before_msg"

  set added [tap_m3_add_from_report $net_name $before_rpt $m3_base_x $m3_pitch $stripe_side]

  set after_rpt "$tap_m3_out_dir/${net_name}.after.rpt"
  catch {file delete -force $after_rpt}
  set after_status [catch {check_power_grid -net $net_name -error_file $after_rpt} after_msg]
  puts "TAP_TO_M3 $net_name after_status=$after_status after_msg=$after_msg added=$added"
  if {$after_status != 0} {
    error "Tap-to-M3 PG repair failed for $net_name; see $after_rpt"
  }
}

# With pdn_no_bpr_m2m3_rdl_dense.tcl / pdngen's alternating-net pattern:
#   VDD M3 stripe centers: 22080 + 12000*n DBU, route left
#   VSS M3 stripe centers: 16080 + 12000*n DBU, route right
tap_m3_repair_net VDD 22080 12000 left
tap_m3_repair_net VSS 16080 12000 right
