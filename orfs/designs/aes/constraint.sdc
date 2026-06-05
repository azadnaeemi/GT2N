# AES-128 constraints, shared by the GT2N and ASAP7 A/B flows.
#
# This is a *macro* — meant to drop into a larger design — so it uses the
# platform-independent macro pattern (set_max_delay optimization targets, no
# set_input_delay/set_output_delay, hence no spurious hold cells). The PDK
# makes the times concrete; we pin SDC units to ps and set the optimization
# targets relative to the clock so the same file works for both PDKs. See
# platforms/common/constraints.sdc (added by an ORFS patch).
set_units -time ps -resistance Ohm -capacitance pF -voltage V -current mA

set clk_name core_clock
set clk_port_name clk
set clk_period 1000

# Optimization targets (ps), relative to the clock — not timing-closure checks.
set in2reg_max [expr { $clk_period * 0.8 }]
set reg2out_max [expr { $clk_period * 0.8 }]
set in2out_max [expr { $clk_period * 0.6 }]

source $::env(FLOW_HOME)/platforms/common/constraints.sdc
