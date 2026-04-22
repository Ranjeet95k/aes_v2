## Clock - 100 MHz on W5
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports clk]

## Reset - active high, assign a button (e.g. T17 = BTN0 on Basys3)
set_property PACKAGE_PIN T17 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports rst]

## UART RX
set_property PACKAGE_PIN U14 [get_ports rx]
set_property IOSTANDARD LVCMOS33 [get_ports rx]

## UART TX
set_property PACKAGE_PIN V14 [get_ports tx]
set_property IOSTANDARD LVCMOS33 [get_ports tx]

create_clock -period 20.000 [get_ports clk]
