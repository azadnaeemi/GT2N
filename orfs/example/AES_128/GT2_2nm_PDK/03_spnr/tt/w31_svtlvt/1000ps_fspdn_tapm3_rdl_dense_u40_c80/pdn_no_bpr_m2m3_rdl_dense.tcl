# GT2N FSPDN PDN: tap-to-M3 local access plus dense upper-metal/RDL mesh.
#
# Compared with pdn_no_bpr_m2m3_topmesh.tcl:
#   - keeps the known-good bottom access topology: no BPR, no followpin, no M1
#     global PDN stripes; tap M1 pins are repaired by post_pdn_tap_to_m3.tcl.
#   - doubles/strengthens the M10-M13 mesh to reduce upper-stack resistance.
#   - adds RDL above M13 as the lowest-resistance frontside supply source layer.
#
# Signal routing is still limited by config.mk MAX_ROUTING_LAYER=M9, so M10-M13
# and RDL are intended as PDN-only resources.

####################################
# global connections
####################################
add_global_connection -net {VDD} -inst_pattern {.*} -pin_pattern {^(vdd|VDD|VPWR)$} -power
add_global_connection -net {VSS} -inst_pattern {.*} -pin_pattern {^(vss|VSS|VGND)$} -ground
global_connect

####################################
# voltage domain and mesh
####################################
set_voltage_domain -name {CORE} -power {VDD} -ground {VSS}
define_pdn_grid -name {grid} -voltage_domains {CORE} -pins {RDL}

# Bottom mesh is deliberately unchanged; post_pdn_tap_to_m3.tcl assumes the M2/M3
# stripe families below when choosing legal tap-to-M3 jogs.
add_pdn_stripe -grid {grid} -layer {M2}  -width {0.012} -pitch {6.0}  -offset {3.0}
add_pdn_stripe -grid {grid} -layer {M3}  -width {0.014} -pitch {6.0}  -offset {3.0}  -extend_to_boundary
add_pdn_stripe -grid {grid} -layer {M4}  -width {0.028} -pitch {8.0}  -offset {4.0}
add_pdn_stripe -grid {grid} -layer {M5}  -width {0.028} -pitch {8.0}  -offset {4.0}
add_pdn_stripe -grid {grid} -layer {M6}  -width {0.076} -pitch {12.0} -offset {6.0}
add_pdn_stripe -grid {grid} -layer {M7}  -width {0.076} -pitch {12.0} -offset {6.0}
add_pdn_stripe -grid {grid} -layer {M8}  -width {0.076} -pitch {12.0} -offset {6.0}
add_pdn_stripe -grid {grid} -layer {M9}  -width {0.076} -pitch {12.0} -offset {6.0}

# Strengthened top mesh.  M10/M11 min pitch is 0.112um and M12/M13 min pitch is
# 0.72um; these values are intentionally conservative relative to the tech LEF.
add_pdn_stripe -grid {grid} -layer {M10} -width {0.224} -pitch {8.0}  -offset {4.0}
add_pdn_stripe -grid {grid} -layer {M11} -width {0.224} -pitch {8.0}  -offset {4.0}
add_pdn_stripe -grid {grid} -layer {M12} -width {0.720} -pitch {12.0} -offset {6.0}
add_pdn_stripe -grid {grid} -layer {M13} -width {0.720} -pitch {12.0} -offset {6.0}

# RDL is horizontal, min width/spacing 1.6um, pitch 3.2um.  Use a moderate pitch
# so it acts as a low-resistance supply bus without overwhelming the layout.
add_pdn_stripe -grid {grid} -layer {RDL} -width {1.600} -pitch {12.8} -offset {0.8} -extend_to_boundary

add_pdn_connect -grid {grid} -layers {M2 M3}
add_pdn_connect -grid {grid} -layers {M3 M4}
add_pdn_connect -grid {grid} -layers {M4 M5}
add_pdn_connect -grid {grid} -layers {M5 M6}
add_pdn_connect -grid {grid} -layers {M6 M7}
add_pdn_connect -grid {grid} -layers {M7 M8}
add_pdn_connect -grid {grid} -layers {M8 M9}
add_pdn_connect -grid {grid} -layers {M9 M10}
add_pdn_connect -grid {grid} -layers {M10 M11}
add_pdn_connect -grid {grid} -layers {M11 M12}
add_pdn_connect -grid {grid} -layers {M12 M13}
add_pdn_connect -grid {grid} -layers {M13 RDL}
