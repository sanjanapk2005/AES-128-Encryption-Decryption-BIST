create_clock -name clk -period 60 [get_ports clk]
set_clock_uncertainty 0.2 [get_clocks clk]

set_input_delay  -clock clk 6 [all_inputs]
set_output_delay -clock clk 6 [all_outputs]

set_load 0.05 [all_outputs]
