current_design aes

# Keep SDC units aligned with GT2N liberty files (time_unit : 1ps).
set_units -time ps -resistance Ohm -capacitance pF -voltage V -current mA

# User tunables
set clk_name core_clock
set clk_port [get_ports clk]
set rst_port [get_ports reset]
set clk_period 1000
set io_delay_ratio_max 0.20
set io_delay_ratio_min 0.10
set io_delay_max [expr $clk_period * $io_delay_ratio_max]
set io_delay_min [expr $clk_period * $io_delay_ratio_min]

# Clock and IO timing constraints
create_clock -name $clk_name -period $clk_period $clk_port
set non_clock_inputs [all_inputs -no_clocks]
set_input_delay -max $io_delay_max -clock $clk_name $non_clock_inputs
set_input_delay -min $io_delay_min -clock $clk_name $non_clock_inputs
set_output_delay -max $io_delay_max -clock $clk_name [all_outputs]
set_output_delay -min $io_delay_min -clock $clk_name [all_outputs]

# Match key Innovus/DC synthesis intent.
set_false_path -from $rst_port
set_max_fanout 20 $clk_port
set_max_fanout 20 $rst_port
