
###############################################################################
# Pinout and Related I/O Constraints
###############################################################################
##### SYS RESET###########
set_property PACKAGE_PIN K22 [get_ports perst_n]
set_property PULLUP true [get_ports perst_n]
set_property IOSTANDARD LVCMOS18 [get_ports perst_n]
set_false_path -from [get_ports perst_n]

##### REFCLK_IBUF###########
set_property LOC GTHE3_COMMON_X0Y1 [get_cells refclk_ibuf]

###############################################################################
# User Time Names / User Time Groups / Time Specs
###############################################################################
create_clock -name sys_clk -period 10 [get_ports pcie_ref_clk_p]
set_clock_groups -name async1 -asynchronous -group [get_clocks -include_generated_clocks -of_objects [get_ports pcie_ref_clk_p]] -group [get_clocks -include_generated_clocks -of_objects [get_pins [all_fanin -flat -startpoints_only [get_pins {kcu105_base_i/pcie3_ultrascale_0/inst/gt_top_i/phy_clk_i/CLK_USERCLK_IN}]]]]

###############################################################################
# User Physical Constraints
###############################################################################

##-------------------------------------
## LED Status Pinout   (bottom to top)
##-------------------------------------

set_property PACKAGE_PIN AP8 [get_ports {led[0]}]
set_property PACKAGE_PIN H23 [get_ports {led[1]}]
set_property PACKAGE_PIN P20 [get_ports {led[2]}]
set_property PACKAGE_PIN P21 [get_ports {led[3]}]

set_property IOSTANDARD LVCMOS18 [get_ports {led[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {led[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {led[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {led[3]}]

set_false_path -from [get_pins kcu105_base_i/nwl_dma_x8g2_wrapper_0/inst/p_rst_reg/C]
set_false_path -from [get_pins {kcu105_base_i/user_axilite_control_0/inst/axi_lite_ipif_inst/I_SLAVE_ATTACHMENT/bus2ip_addr_reg_reg[6]/C}]
set_false_path -from [get_pins {kcu105_base_i/reset_top/proc_sys_reset_0/U0/ACTIVE_LOW_BSR_OUT_DFF[0].interconnect_aresetn_reg[0]/C}]

##-------------------------------------
## PMBus Pinout
##-------------------------------------
create_clock -period 8.000 -name sysclk -waveform {0.000 4.000} [get_ports clk125_in]

set_property IOSTANDARD LVCMOS18 [get_ports clk125_in]
set_property PACKAGE_PIN G10 [get_ports clk125_in]

set_property PACKAGE_PIN J24 [get_ports pmbus_clk]
set_property PACKAGE_PIN J25 [get_ports pmbus_data]
set_property PACKAGE_PIN AK10 [get_ports pmbus_alert]
set_property IOSTANDARD LVCMOS18 [get_ports pmbus_clk]
set_property IOSTANDARD LVCMOS18 [get_ports pmbus_data]
set_property IOSTANDARD LVCMOS18 [get_ports pmbus_alert]

##--------------------------------------
## SYSMON
##--------------------------------------
set_property IOSTANDARD ANALOG [get_ports vauxp0]
set_property PACKAGE_PIN E13 [get_ports vauxn0]
set_property IOSTANDARD ANALOG [get_ports vauxn0]
set_property IOSTANDARD ANALOG [get_ports vauxp8]
set_property PACKAGE_PIN B11 [get_ports vauxn8]
set_property IOSTANDARD ANALOG [get_ports vauxn8]
set_property IOSTANDARD ANALOG [get_ports vauxp2]
set_property PACKAGE_PIN H13 [get_ports vauxn2]
set_property IOSTANDARD ANALOG [get_ports vauxn2]
set_property PACKAGE_PIN T27 [get_ports {muxaddr_out[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {muxaddr_out[0]}]
set_property PACKAGE_PIN R27 [get_ports {muxaddr_out[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {muxaddr_out[1]}]
set_property PACKAGE_PIN N27 [get_ports {muxaddr_out[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {muxaddr_out[2]}]

