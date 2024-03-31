# for 正点原子 NAVIGATOR ZYNQ7020 
create_clock -period 20.000 -name clk [get_ports clk]
set_property -dict {PACKAGE_PIN U18 IOSTANDARD LVCMOS33} [get_ports clk]
set_property -dict {PACKAGE_PIN N16 IOSTANDARD LVCMOS33} [get_ports rst_n]
set_property -dict {PACKAGE_PIN J15 IOSTANDARD LVCMOS33} [get_ports uart_txd]
set_property -dict {PACKAGE_PIN H15 IOSTANDARD LVCMOS33} [get_ports {led}]

# rs232
# set_property -dict {PACKAGE_PIN M15 IOSTANDARD LVCMOS33} [get_ports uart_txd]