# GT2 layer parasitics for FSPDN tech LEF (gt2_fspdn_tech.lef).
#
# Note:
# - In this tech LEF, BPR is declared as MASTERSLICE (not ROUTING).
# - Backside routing layers/vias (BM*/BV*/BRDL) are not present.
# - Therefore this RC file only programs frontside routing/via RC.

# Frontside routing stack
set_layer_rc -layer M0   -capacitance 9.03127e-05 -resistance 6.21750e+02
set_layer_rc -layer M1   -capacitance 9.03127e-05 -resistance 4.37500e+02
set_layer_rc -layer M2   -capacitance 9.03127e-05 -resistance 6.21750e+02
set_layer_rc -layer M3   -capacitance 9.03127e-05 -resistance 4.37500e+02
set_layer_rc -layer M4   -capacitance 9.40758e-05 -resistance 1.66952e+02
set_layer_rc -layer M5   -capacitance 9.40758e-05 -resistance 1.66952e+02
set_layer_rc -layer M6   -capacitance 9.40758e-05 -resistance 2.65526e+01
set_layer_rc -layer M7   -capacitance 9.40758e-05 -resistance 2.65526e+01
set_layer_rc -layer M8   -capacitance 9.40758e-05 -resistance 2.65526e+01
set_layer_rc -layer M9   -capacitance 9.40758e-05 -resistance 2.65526e+01
set_layer_rc -layer M10  -capacitance 9.40758e-05 -resistance 7.48214e+00
set_layer_rc -layer M11  -capacitance 9.40758e-05 -resistance 7.48214e+00
set_layer_rc -layer M12  -capacitance 4.93480e-05 -resistance 6.38889e-01
set_layer_rc -layer M13  -capacitance 4.93480e-05 -resistance 6.38889e-01
set_layer_rc -layer RDL  -capacitance 8.46682e-05 -resistance 6.25000e-03

# Frontside vias
set_layer_rc -via V0  -resistance 54.99
set_layer_rc -via V1  -resistance 54.99
set_layer_rc -via V2  -resistance 54.99
set_layer_rc -via V3  -resistance 45.78
set_layer_rc -via V4  -resistance 27.80
set_layer_rc -via V5  -resistance 14.89
set_layer_rc -via V6  -resistance 13.26
set_layer_rc -via V7  -resistance 13.26
set_layer_rc -via V8  -resistance 13.26
set_layer_rc -via V9  -resistance 7.65
set_layer_rc -via V10 -resistance 6.08
set_layer_rc -via V11 -resistance 6.08
set_layer_rc -via V12 -resistance 0.95
set_layer_rc -via V13 -resistance 0.15

set_wire_rc -signal -layer M1
set_wire_rc -clock -layer M3
