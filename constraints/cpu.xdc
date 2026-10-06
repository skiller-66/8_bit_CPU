# 100 MHz target clock (10 ns). Tighten later to find Fmax.
create_clock -period 10.000 -name sys_clk [get_ports clk]
