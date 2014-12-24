
################################################################
# This is a generated script based on design: kcu105_2x10G
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2014.3
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   puts "ERROR: This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source kcu105_2x10G_script.tcl

# If you do not already have a project created,
# you can create a project using the following command:
#    create_project project_1 myproj -part xcku040-ffva1156-2-e


# CHANGE DESIGN NAME HERE
set design_name kcu105_2x10G

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# CHECKING IF PROJECT EXISTS
if { [get_projects -quiet] eq "" } {
   puts "ERROR: Please open or create a project!"
   return 1
}


# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "ERROR: Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      puts "INFO: Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   puts "INFO: Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "ERROR: Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "ERROR: Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   puts "INFO: Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   puts "INFO: Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

puts "INFO: Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   puts $errMsg
   return $nRet
}

##################################################################
# DESIGN PROCs
##################################################################


# Hierarchical cell: s2c_dre
proc create_hier_cell_s2c_dre_1 { parentCell nameHier } {

  if { $parentCell eq "" || $nameHier eq "" } {
     puts "ERROR: create_hier_cell_s2c_dre_1() - Empty argument(s)!"
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     puts "ERROR: Unable to find parent cell <$parentCell>!"
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     puts "ERROR: Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M_AXIS
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S_AXIS

  # Create pins
  create_bd_pin -dir I -type clk m_aclk
  create_bd_pin -dir I -type rst m_aresetn
  create_bd_pin -dir I -type clk s_axis_aclk
  create_bd_pin -dir I -type rst s_axis_aresetn

  # Create instance: clk_250_to_156, and set properties
  set clk_250_to_156 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_clock_converter:1.1 clk_250_to_156 ]
  set_property -dict [ list CONFIG.HAS_TKEEP {1} CONFIG.HAS_TLAST {1} CONFIG.TDATA_NUM_BYTES {8}  ] $clk_250_to_156

  # Create instance: dwidth_128_to_64bit, and set properties
  set dwidth_128_to_64bit [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_dwidth_converter:1.1 dwidth_128_to_64bit ]
  set_property -dict [ list CONFIG.M_TDATA_NUM_BYTES {8}  ] $dwidth_128_to_64bit

  # Create instance: tx_packet_fifo, and set properties
  set tx_packet_fifo [ create_bd_cell -type ip -vlnv xilinx.com:ip:fifo_generator:12.0 tx_packet_fifo ]
  set_property -dict [ list CONFIG.Clock_Type_AXI {Common_Clock} CONFIG.Enable_TLAST {true} CONFIG.FIFO_Application_Type_axis {Packet_FIFO} CONFIG.FIFO_Implementation_axis {Common_Clock_Block_RAM} CONFIG.FIFO_Implementation_rach {Common_Clock_Distributed_RAM} CONFIG.FIFO_Implementation_rdch {Common_Clock_Builtin_FIFO} CONFIG.FIFO_Implementation_wach {Common_Clock_Distributed_RAM} CONFIG.FIFO_Implementation_wdch {Common_Clock_Builtin_FIFO} CONFIG.FIFO_Implementation_wrch {Common_Clock_Distributed_RAM} CONFIG.HAS_TKEEP {true} CONFIG.INTERFACE_TYPE {AXI_STREAM} CONFIG.Input_Depth_axis {2048} CONFIG.Input_Depth_rdch {512} CONFIG.Input_Depth_wdch {512} CONFIG.TDATA_NUM_BYTES {8} CONFIG.TUSER_WIDTH {0}  ] $tx_packet_fifo

  # Create interface connections
  connect_bd_intf_net -intf_net clk_250_to_156_M_AXIS [get_bd_intf_pins clk_250_to_156/M_AXIS] [get_bd_intf_pins tx_packet_fifo/S_AXIS]
  connect_bd_intf_net -intf_net dwidth_128_to_64bit_M_AXIS [get_bd_intf_pins clk_250_to_156/S_AXIS] [get_bd_intf_pins dwidth_128_to_64bit/M_AXIS]
  connect_bd_intf_net -intf_net hw_sgl_top_s2c [get_bd_intf_pins S_AXIS] [get_bd_intf_pins dwidth_128_to_64bit/S_AXIS]
  connect_bd_intf_net -intf_net tx_packet_fifo_M_AXIS [get_bd_intf_pins M_AXIS] [get_bd_intf_pins tx_packet_fifo/M_AXIS]

  # Create port connections
  connect_bd_net -net M01_ARESETN_1 [get_bd_pins s_axis_aresetn] [get_bd_pins clk_250_to_156/s_axis_aresetn] [get_bd_pins dwidth_128_to_64bit/aresetn]
  connect_bd_net -net mac_phy_ch0_core_clk156_out [get_bd_pins m_aclk] [get_bd_pins clk_250_to_156/m_axis_aclk] [get_bd_pins tx_packet_fifo/s_aclk]
  connect_bd_net -net pcie_dma_wrapper_0_user_clk [get_bd_pins s_axis_aclk] [get_bd_pins clk_250_to_156/s_axis_aclk] [get_bd_pins dwidth_128_to_64bit/aclk]
  connect_bd_net -net reset_156_inv_Res [get_bd_pins m_aresetn] [get_bd_pins clk_250_to_156/m_axis_aresetn] [get_bd_pins tx_packet_fifo/s_aresetn]
  
  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: mac_phy_ch1
proc create_hier_cell_mac_phy_ch1 { parentCell nameHier } {

  if { $parentCell eq "" || $nameHier eq "" } {
     puts "ERROR: create_hier_cell_mac_phy_ch1() - Empty argument(s)!"
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     puts "ERROR: Unable to find parent cell <$parentCell>!"
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     puts "ERROR: Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 m_axis_rx
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 s_axis_pause
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 s_axis_tx

  # Create pins
  create_bd_pin -dir I areset
  create_bd_pin -dir I areset_clk156
  create_bd_pin -dir I -type clk clk156
  create_bd_pin -dir O -from 7 -to 0 core_status
  create_bd_pin -dir I gtrxreset
  create_bd_pin -dir I gttxreset
  create_bd_pin -dir I -from 4 -to 0 prtad
  create_bd_pin -dir I qpll0lock
  create_bd_pin -dir I qpll0outclk
  create_bd_pin -dir I qpll0outrefclk
  create_bd_pin -dir I reset_counter_done
  create_bd_pin -dir I -type rst rx_axis_aresetn
  create_bd_pin -dir I rx_dcm_locked
  create_bd_pin -dir O rx_resetdone
  create_bd_pin -dir O rx_statistics_valid
  create_bd_pin -dir O -from 29 -to 0 rx_statistics_vector
  create_bd_pin -dir I rxn
  create_bd_pin -dir I rxp
  create_bd_pin -dir I s_axi_aclk
  create_bd_pin -dir I s_axi_aresetn
  create_bd_pin -dir I sim_speedup_control
  create_bd_pin -dir O tx_disable
  create_bd_pin -dir I tx_fault
  create_bd_pin -dir I -from 7 -to 0 tx_ifg_delay
  create_bd_pin -dir O tx_resetdone
  create_bd_pin -dir O txclk322
  create_bd_pin -dir O txn
  create_bd_pin -dir O txp
  create_bd_pin -dir I txuserrdy
  create_bd_pin -dir I txusrclk
  create_bd_pin -dir I txusrclk2

  # Create instance: ten_gig_eth_mac_ch1, and set properties
  set ten_gig_eth_mac_ch1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:ten_gig_eth_mac:14.0 ten_gig_eth_mac_ch1 ]

  # Create instance: ten_gig_eth_pcs_pma_ch1, and set properties
  set ten_gig_eth_pcs_pma_ch1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:ten_gig_eth_pcs_pma:5.0 ten_gig_eth_pcs_pma_ch1 ]
  set_property -dict [ list CONFIG.Locations {X0Y9} CONFIG.SupportLevel {0} CONFIG.base_kr {BASE-R}  ] $ten_gig_eth_pcs_pma_ch1

  # Create instance: xlconstant_high_2_0, and set properties
  set xlconstant_high_2_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_high_2_0 ]
  set_property -dict [ list CONFIG.CONST_VAL {101} CONFIG.CONST_WIDTH {3}  ] $xlconstant_high_2_0

  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins s_axis_pause] [get_bd_intf_pins ten_gig_eth_mac_ch1/s_axis_pause]
  connect_bd_intf_net -intf_net axis_data_fifo_tx_ch0_M_AXIS [get_bd_intf_pins s_axis_tx] [get_bd_intf_pins ten_gig_eth_mac_ch1/s_axis_tx]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M04_AXI [get_bd_intf_pins s_axi] [get_bd_intf_pins ten_gig_eth_mac_ch1/s_axi]
  connect_bd_intf_net -intf_net ten_gig_eth_mac_ch0_m_axis_rx [get_bd_intf_pins m_axis_rx] [get_bd_intf_pins ten_gig_eth_mac_ch1/m_axis_rx]
  connect_bd_intf_net -intf_net ten_gig_eth_mac_ch0_xgmii_xgmac [get_bd_intf_pins ten_gig_eth_mac_ch1/xgmii_xgmac] [get_bd_intf_pins ten_gig_eth_pcs_pma_ch1/xgmii_interface]
  connect_bd_intf_net -intf_net ten_gig_eth_pcs_pma_ch0_core_to_gt_drp [get_bd_intf_pins ten_gig_eth_pcs_pma_ch1/core_to_gt_drp] [get_bd_intf_pins ten_gig_eth_pcs_pma_ch1/gt_drp]

  # Create port connections
  connect_bd_net -net areset_clk156_1 [get_bd_pins areset_clk156] [get_bd_pins ten_gig_eth_pcs_pma_ch1/areset_clk156]
  connect_bd_net -net gtrxreset_1 [get_bd_pins gtrxreset] [get_bd_pins ten_gig_eth_pcs_pma_ch1/gtrxreset]
  connect_bd_net -net gttxreset_1 [get_bd_pins gttxreset] [get_bd_pins ten_gig_eth_pcs_pma_ch1/gttxreset]
  connect_bd_net -net hdp_patgen_0_tx_ifg_delay [get_bd_pins tx_ifg_delay] [get_bd_pins ten_gig_eth_mac_ch1/tx_ifg_delay]
  connect_bd_net -net microblaze_0_Clk [get_bd_pins clk156] [get_bd_pins ten_gig_eth_mac_ch1/rx_clk0] [get_bd_pins ten_gig_eth_mac_ch1/tx_clk0] [get_bd_pins ten_gig_eth_pcs_pma_ch1/clk156] [get_bd_pins ten_gig_eth_pcs_pma_ch1/dclk]
  connect_bd_net -net prtad_1 [get_bd_pins prtad] [get_bd_pins ten_gig_eth_pcs_pma_ch1/prtad]
  connect_bd_net -net qpll0lock_1 [get_bd_pins qpll0lock] [get_bd_pins ten_gig_eth_pcs_pma_ch1/qpll0lock]
  connect_bd_net -net qpll0outclk_1 [get_bd_pins qpll0outclk] [get_bd_pins ten_gig_eth_pcs_pma_ch1/qpll0outclk]
  connect_bd_net -net qpll0outrefclk_1 [get_bd_pins qpll0outrefclk] [get_bd_pins ten_gig_eth_pcs_pma_ch1/qpll0outrefclk]
  connect_bd_net -net reset_counter_done_1 [get_bd_pins reset_counter_done] [get_bd_pins ten_gig_eth_pcs_pma_ch1/reset_counter_done]
  connect_bd_net -net reset_mac [get_bd_pins areset] [get_bd_pins ten_gig_eth_mac_ch1/reset] [get_bd_pins ten_gig_eth_pcs_pma_ch1/areset]
  connect_bd_net -net reset_n_mac_1 [get_bd_pins rx_axis_aresetn] [get_bd_pins ten_gig_eth_mac_ch1/rx_axis_aresetn] [get_bd_pins ten_gig_eth_mac_ch1/tx_axis_aresetn]
  connect_bd_net -net rst_clk_156_156M_peripheral_aresetn [get_bd_pins s_axi_aresetn] [get_bd_pins ten_gig_eth_mac_ch1/s_axi_aresetn]
  connect_bd_net -net rxn_1 [get_bd_pins rxn] [get_bd_pins ten_gig_eth_pcs_pma_ch1/rxn]
  connect_bd_net -net rxp_1 [get_bd_pins rxp] [get_bd_pins ten_gig_eth_pcs_pma_ch1/rxp]
  connect_bd_net -net s_axi_aclk_1 [get_bd_pins s_axi_aclk] [get_bd_pins ten_gig_eth_mac_ch1/s_axi_aclk]
  connect_bd_net -net s_axis_pause_tvalid_1 [get_bd_pins tx_fault] [get_bd_pins ten_gig_eth_pcs_pma_ch1/tx_fault]
  connect_bd_net -net sim_speedup_control_1 [get_bd_pins sim_speedup_control] [get_bd_pins ten_gig_eth_pcs_pma_ch1/sim_speedup_control]
  connect_bd_net -net ten_gig_eth_mac_ch0_mdc [get_bd_pins ten_gig_eth_mac_ch1/mdc] [get_bd_pins ten_gig_eth_pcs_pma_ch1/mdc]
  connect_bd_net -net ten_gig_eth_mac_ch0_mdio_out [get_bd_pins ten_gig_eth_mac_ch1/mdio_out] [get_bd_pins ten_gig_eth_pcs_pma_ch1/mdio_in]
  connect_bd_net -net ten_gig_eth_mac_ch1_rx_statistics_valid [get_bd_pins rx_statistics_valid] [get_bd_pins ten_gig_eth_mac_ch1/rx_statistics_valid]
  connect_bd_net -net ten_gig_eth_mac_ch1_rx_statistics_vector [get_bd_pins rx_statistics_vector] [get_bd_pins ten_gig_eth_mac_ch1/rx_statistics_vector]
  connect_bd_net -net ten_gig_eth_pcs_pma_ch0_core_status [get_bd_pins core_status] [get_bd_pins ten_gig_eth_pcs_pma_ch1/core_status]
  connect_bd_net -net ten_gig_eth_pcs_pma_ch0_drp_req [get_bd_pins ten_gig_eth_pcs_pma_ch1/drp_gnt] [get_bd_pins ten_gig_eth_pcs_pma_ch1/drp_req]
  connect_bd_net -net ten_gig_eth_pcs_pma_ch0_mdio_out [get_bd_pins ten_gig_eth_mac_ch1/mdio_in] [get_bd_pins ten_gig_eth_pcs_pma_ch1/mdio_out]
  connect_bd_net -net ten_gig_eth_pcs_pma_ch0_tx_disable [get_bd_pins tx_disable] [get_bd_pins ten_gig_eth_pcs_pma_ch1/tx_disable]
  connect_bd_net -net ten_gig_eth_pcs_pma_ch0_txn [get_bd_pins txn] [get_bd_pins ten_gig_eth_pcs_pma_ch1/txn]
  connect_bd_net -net ten_gig_eth_pcs_pma_ch0_txp [get_bd_pins txp] [get_bd_pins ten_gig_eth_pcs_pma_ch1/txp]
  connect_bd_net -net ten_gig_eth_pcs_pma_ch1_rx_resetdone [get_bd_pins rx_resetdone] [get_bd_pins ten_gig_eth_pcs_pma_ch1/rx_resetdone]
  connect_bd_net -net ten_gig_eth_pcs_pma_ch1_tx_resetdone [get_bd_pins tx_resetdone] [get_bd_pins ten_gig_eth_pcs_pma_ch1/tx_resetdone]
  connect_bd_net -net ten_gig_eth_pcs_pma_ch1_txclk322 [get_bd_pins txclk322] [get_bd_pins ten_gig_eth_pcs_pma_ch1/txclk322]
  connect_bd_net -net txuserrdy_1 [get_bd_pins txuserrdy] [get_bd_pins ten_gig_eth_pcs_pma_ch1/txuserrdy]
  connect_bd_net -net txusrclk2_1 [get_bd_pins txusrclk2] [get_bd_pins ten_gig_eth_pcs_pma_ch1/txusrclk2]
  connect_bd_net -net txusrclk_1 [get_bd_pins txusrclk] [get_bd_pins ten_gig_eth_pcs_pma_ch1/txusrclk]
  connect_bd_net -net xlconstant_0_const [get_bd_pins rx_dcm_locked] [get_bd_pins ten_gig_eth_mac_ch1/rx_dcm_locked] [get_bd_pins ten_gig_eth_mac_ch1/tx_dcm_locked] [get_bd_pins ten_gig_eth_pcs_pma_ch1/signal_detect]
  connect_bd_net -net xlconstant_high_2_0_dout [get_bd_pins ten_gig_eth_pcs_pma_ch1/pma_pmd_type] [get_bd_pins xlconstant_high_2_0/dout]
  
  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: c2s_dre
proc create_hier_cell_c2s_dre_1 { parentCell nameHier } {

  if { $parentCell eq "" || $nameHier eq "" } {
     puts "ERROR: create_hier_cell_c2s_dre_1() - Empty argument(s)!"
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     puts "ERROR: Unable to find parent cell <$parentCell>!"
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     puts "ERROR: Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M_AXIS
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 s_axis

  # Create pins
  create_bd_pin -dir I -type clk aclk
  create_bd_pin -dir I -type rst aresetn
  create_bd_pin -dir I -from 47 -to 0 mac_id
  create_bd_pin -dir I mac_id_valid
  create_bd_pin -dir I reset
  create_bd_pin -dir I -type clk rx_clk
  create_bd_pin -dir I rx_statistics_valid
  create_bd_pin -dir I -from 29 -to 0 rx_statistics_vector
  create_bd_pin -dir I -type rst s_axis_aresetn
  create_bd_pin -dir I soft_reset

  # Create instance: axis_clock_converter_0, and set properties
  set axis_clock_converter_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_clock_converter:1.1 axis_clock_converter_0 ]
  set_property -dict [ list CONFIG.HAS_TKEEP {1} CONFIG.HAS_TLAST {1} CONFIG.TDATA_NUM_BYTES {8} CONFIG.TDEST_WIDTH {2}  ] $axis_clock_converter_0

  # Create instance: axis_dwidth_converter_0, and set properties
  set axis_dwidth_converter_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_dwidth_converter:1.1 axis_dwidth_converter_0 ]
  set_property -dict [ list CONFIG.M_TDATA_NUM_BYTES {16}  ] $axis_dwidth_converter_0

  # Create instance: rx_interface_0, and set properties
  set rx_interface_0 [ create_bd_cell -type ip -vlnv xilinx.com:user:rx_interface:1.0 rx_interface_0 ]
  set_property -dict [ list CONFIG.FIFO_CNT_WIDTH {13}  ] $rx_interface_0

  # Create interface connections
  connect_bd_intf_net -intf_net axis_clock_converter_0_M_AXIS [get_bd_intf_pins axis_clock_converter_0/M_AXIS] [get_bd_intf_pins axis_dwidth_converter_0/S_AXIS]
  connect_bd_intf_net -intf_net axis_dwidth_converter_0_M_AXIS [get_bd_intf_pins M_AXIS] [get_bd_intf_pins axis_dwidth_converter_0/M_AXIS]
  connect_bd_intf_net -intf_net mac_phy_ch0_m_axis_rx [get_bd_intf_pins s_axis] [get_bd_intf_pins rx_interface_0/s_axis]
  connect_bd_intf_net -intf_net rx_interface_0_m_axis [get_bd_intf_pins axis_clock_converter_0/S_AXIS] [get_bd_intf_pins rx_interface_0/m_axis]

  # Create port connections
  connect_bd_net -net M01_ARESETN_1 [get_bd_pins aresetn] [get_bd_pins axis_clock_converter_0/m_axis_aresetn] [get_bd_pins axis_dwidth_converter_0/aresetn]
  connect_bd_net -net logic_high_const [get_bd_pins mac_id_valid] [get_bd_pins rx_interface_0/mac_id_valid]
  connect_bd_net -net logic_low_const [get_bd_pins soft_reset] [get_bd_pins rx_interface_0/promiscuous_mode_en] [get_bd_pins rx_interface_0/soft_reset]
  connect_bd_net -net mac_id_cons_const [get_bd_pins mac_id] [get_bd_pins rx_interface_0/mac_id]
  connect_bd_net -net mac_phy_ch0_areset_clk156_out [get_bd_pins reset] [get_bd_pins rx_interface_0/reset]
  connect_bd_net -net mac_phy_ch0_core_clk156_out [get_bd_pins rx_clk] [get_bd_pins axis_clock_converter_0/s_axis_aclk] [get_bd_pins rx_interface_0/user_clk]
  connect_bd_net -net mac_phy_ch0_rx_statistics_valid [get_bd_pins rx_statistics_valid] [get_bd_pins rx_interface_0/rx_statistics_valid]
  connect_bd_net -net mac_phy_ch0_rx_statistics_vector [get_bd_pins rx_statistics_vector] [get_bd_pins rx_interface_0/rx_statistics_vector]
  connect_bd_net -net pcie_dma_wrapper_0_user_clk [get_bd_pins aclk] [get_bd_pins axis_clock_converter_0/m_axis_aclk] [get_bd_pins axis_dwidth_converter_0/aclk]
  connect_bd_net -net reset_156_inv_Res [get_bd_pins s_axis_aresetn] [get_bd_pins axis_clock_converter_0/s_axis_aresetn]
  
  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: s2c_dre
proc create_hier_cell_s2c_dre { parentCell nameHier } {

  if { $parentCell eq "" || $nameHier eq "" } {
     puts "ERROR: create_hier_cell_s2c_dre() - Empty argument(s)!"
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     puts "ERROR: Unable to find parent cell <$parentCell>!"
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     puts "ERROR: Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M_AXIS
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S_AXIS

  # Create pins
  create_bd_pin -dir I -type clk m_aclk
  create_bd_pin -dir I -type rst m_aresetn
  create_bd_pin -dir I -type clk s_axis_aclk
  create_bd_pin -dir I -type rst s_axis_aresetn

  # Create instance: clk_250_to_156, and set properties
  set clk_250_to_156 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_clock_converter:1.1 clk_250_to_156 ]
  set_property -dict [ list CONFIG.HAS_TKEEP {1} CONFIG.HAS_TLAST {1} CONFIG.TDATA_NUM_BYTES {8}  ] $clk_250_to_156

  # Create instance: dwidth_128_to_64bit, and set properties
  set dwidth_128_to_64bit [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_dwidth_converter:1.1 dwidth_128_to_64bit ]
  set_property -dict [ list CONFIG.M_TDATA_NUM_BYTES {8}  ] $dwidth_128_to_64bit

  # Create instance: tx_packet_fifo, and set properties
  set tx_packet_fifo [ create_bd_cell -type ip -vlnv xilinx.com:ip:fifo_generator:12.0 tx_packet_fifo ]
  set_property -dict [ list CONFIG.Clock_Type_AXI {Common_Clock} CONFIG.Enable_TLAST {true} CONFIG.FIFO_Application_Type_axis {Packet_FIFO} CONFIG.FIFO_Implementation_axis {Common_Clock_Block_RAM} CONFIG.FIFO_Implementation_rach {Common_Clock_Distributed_RAM} CONFIG.FIFO_Implementation_rdch {Common_Clock_Builtin_FIFO} CONFIG.FIFO_Implementation_wach {Common_Clock_Distributed_RAM} CONFIG.FIFO_Implementation_wdch {Common_Clock_Builtin_FIFO} CONFIG.FIFO_Implementation_wrch {Common_Clock_Distributed_RAM} CONFIG.HAS_TKEEP {true} CONFIG.INTERFACE_TYPE {AXI_STREAM} CONFIG.Input_Depth_axis {2048} CONFIG.Input_Depth_rdch {512} CONFIG.Input_Depth_wdch {512} CONFIG.TDATA_NUM_BYTES {8} CONFIG.TUSER_WIDTH {0}  ] $tx_packet_fifo

  # Create interface connections
  connect_bd_intf_net -intf_net clk_250_to_156_M_AXIS [get_bd_intf_pins clk_250_to_156/M_AXIS] [get_bd_intf_pins tx_packet_fifo/S_AXIS]
  connect_bd_intf_net -intf_net dwidth_128_to_64bit_M_AXIS [get_bd_intf_pins clk_250_to_156/S_AXIS] [get_bd_intf_pins dwidth_128_to_64bit/M_AXIS]
  connect_bd_intf_net -intf_net hw_sgl_top_s2c [get_bd_intf_pins S_AXIS] [get_bd_intf_pins dwidth_128_to_64bit/S_AXIS]
  connect_bd_intf_net -intf_net tx_packet_fifo_M_AXIS [get_bd_intf_pins M_AXIS] [get_bd_intf_pins tx_packet_fifo/M_AXIS]

  # Create port connections
  connect_bd_net -net M01_ARESETN_1 [get_bd_pins s_axis_aresetn] [get_bd_pins clk_250_to_156/s_axis_aresetn] [get_bd_pins dwidth_128_to_64bit/aresetn]
  connect_bd_net -net mac_phy_ch0_core_clk156_out [get_bd_pins m_aclk] [get_bd_pins clk_250_to_156/m_axis_aclk] [get_bd_pins tx_packet_fifo/s_aclk]
  connect_bd_net -net pcie_dma_wrapper_0_user_clk [get_bd_pins s_axis_aclk] [get_bd_pins clk_250_to_156/s_axis_aclk] [get_bd_pins dwidth_128_to_64bit/aclk]
  connect_bd_net -net reset_156_inv_Res [get_bd_pins m_aresetn] [get_bd_pins clk_250_to_156/m_axis_aresetn] [get_bd_pins tx_packet_fifo/s_aresetn]
  
  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: mac_phy_ch0
proc create_hier_cell_mac_phy_ch0 { parentCell nameHier } {

  if { $parentCell eq "" || $nameHier eq "" } {
     puts "ERROR: create_hier_cell_mac_phy_ch0() - Empty argument(s)!"
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     puts "ERROR: Unable to find parent cell <$parentCell>!"
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     puts "ERROR: Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 m_axis_rx
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 refclk_diff_port
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 s_axis_pause
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 s_axis_tx

  # Create pins
  create_bd_pin -dir I areset
  create_bd_pin -dir O -type rst areset_clk156_out
  create_bd_pin -dir I -type clk clk156
  create_bd_pin -dir O -type clk core_clk156_out
  create_bd_pin -dir O -from 7 -to 0 core_status
  create_bd_pin -dir O -type rst gtrxreset_out
  create_bd_pin -dir O -type rst gttxreset_out
  create_bd_pin -dir I -from 4 -to 0 prtad
  create_bd_pin -dir O qpll0lock_out
  create_bd_pin -dir O -type clk qpll0outclk_out
  create_bd_pin -dir O -type clk qpll0outrefclk_out
  create_bd_pin -dir O reset_counter_done_out
  create_bd_pin -dir O resetdone
  create_bd_pin -dir I -type rst rx_axis_aresetn
  create_bd_pin -dir I rx_dcm_locked
  create_bd_pin -dir O rx_statistics_valid
  create_bd_pin -dir O -from 29 -to 0 rx_statistics_vector
  create_bd_pin -dir I rxn
  create_bd_pin -dir I rxp
  create_bd_pin -dir I s_axi_aclk
  create_bd_pin -dir I s_axi_aresetn
  create_bd_pin -dir I sim_speedup_control
  create_bd_pin -dir O tx_disable
  create_bd_pin -dir I tx_fault
  create_bd_pin -dir I -from 7 -to 0 tx_ifg_delay
  create_bd_pin -dir O txn
  create_bd_pin -dir O txp
  create_bd_pin -dir O txuserrdy_out
  create_bd_pin -dir O -type clk txusrclk2_out
  create_bd_pin -dir O -type clk txusrclk_out

  # Create instance: ten_gig_eth_mac_ch0, and set properties
  set ten_gig_eth_mac_ch0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:ten_gig_eth_mac:14.0 ten_gig_eth_mac_ch0 ]

  # Create instance: ten_gig_eth_pcs_pma_ch0, and set properties
  set ten_gig_eth_pcs_pma_ch0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:ten_gig_eth_pcs_pma:5.0 ten_gig_eth_pcs_pma_ch0 ]
  set_property -dict [ list CONFIG.Locations {X0Y10} CONFIG.SupportLevel {1} CONFIG.base_kr {BASE-R}  ] $ten_gig_eth_pcs_pma_ch0

  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins s_axis_pause] [get_bd_intf_pins ten_gig_eth_mac_ch0/s_axis_pause]
  connect_bd_intf_net -intf_net Conn2 [get_bd_intf_pins refclk_diff_port] [get_bd_intf_pins ten_gig_eth_pcs_pma_ch0/refclk_diff_port]
  connect_bd_intf_net -intf_net axis_data_fifo_tx_ch0_M_AXIS [get_bd_intf_pins s_axis_tx] [get_bd_intf_pins ten_gig_eth_mac_ch0/s_axis_tx]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M04_AXI [get_bd_intf_pins s_axi] [get_bd_intf_pins ten_gig_eth_mac_ch0/s_axi]
  connect_bd_intf_net -intf_net ten_gig_eth_mac_ch0_m_axis_rx [get_bd_intf_pins m_axis_rx] [get_bd_intf_pins ten_gig_eth_mac_ch0/m_axis_rx]
  connect_bd_intf_net -intf_net ten_gig_eth_mac_ch0_xgmii_xgmac [get_bd_intf_pins ten_gig_eth_mac_ch0/xgmii_xgmac] [get_bd_intf_pins ten_gig_eth_pcs_pma_ch0/xgmii_interface]
  connect_bd_intf_net -intf_net ten_gig_eth_pcs_pma_ch0_core_to_gt_drp [get_bd_intf_pins ten_gig_eth_pcs_pma_ch0/core_to_gt_drp] [get_bd_intf_pins ten_gig_eth_pcs_pma_ch0/gt_drp]

  # Create port connections
  connect_bd_net -net hdp_patgen_0_tx_ifg_delay [get_bd_pins tx_ifg_delay] [get_bd_pins ten_gig_eth_mac_ch0/tx_ifg_delay]
  connect_bd_net -net microblaze_0_Clk [get_bd_pins clk156] [get_bd_pins ten_gig_eth_mac_ch0/rx_clk0] [get_bd_pins ten_gig_eth_mac_ch0/tx_clk0]
  connect_bd_net -net prtad_1 [get_bd_pins prtad] [get_bd_pins ten_gig_eth_pcs_pma_ch0/prtad]
  connect_bd_net -net reset_mac [get_bd_pins areset] [get_bd_pins ten_gig_eth_mac_ch0/reset] [get_bd_pins ten_gig_eth_pcs_pma_ch0/reset]
  connect_bd_net -net reset_n_mac_1 [get_bd_pins rx_axis_aresetn] [get_bd_pins ten_gig_eth_mac_ch0/rx_axis_aresetn] [get_bd_pins ten_gig_eth_mac_ch0/tx_axis_aresetn]
  connect_bd_net -net rst_clk_156_156M_peripheral_aresetn [get_bd_pins s_axi_aresetn] [get_bd_pins ten_gig_eth_mac_ch0/s_axi_aresetn]
  connect_bd_net -net rxn_1 [get_bd_pins rxn] [get_bd_pins ten_gig_eth_pcs_pma_ch0/rxn]
  connect_bd_net -net rxp_1 [get_bd_pins rxp] [get_bd_pins ten_gig_eth_pcs_pma_ch0/rxp]
  connect_bd_net -net s_axi_aclk_1 [get_bd_pins s_axi_aclk] [get_bd_pins ten_gig_eth_mac_ch0/s_axi_aclk]
  connect_bd_net -net s_axis_pause_tvalid_1 [get_bd_pins tx_fault] [get_bd_pins ten_gig_eth_pcs_pma_ch0/tx_fault]
  connect_bd_net -net sim_speedup_control_1 [get_bd_pins sim_speedup_control] [get_bd_pins ten_gig_eth_pcs_pma_ch0/sim_speedup_control]
  connect_bd_net -net ten_gig_eth_mac_ch0_mdc [get_bd_pins ten_gig_eth_mac_ch0/mdc] [get_bd_pins ten_gig_eth_pcs_pma_ch0/mdc]
  connect_bd_net -net ten_gig_eth_mac_ch0_mdio_out [get_bd_pins ten_gig_eth_mac_ch0/mdio_out] [get_bd_pins ten_gig_eth_pcs_pma_ch0/mdio_in]
  connect_bd_net -net ten_gig_eth_mac_ch0_rx_statistics_valid [get_bd_pins rx_statistics_valid] [get_bd_pins ten_gig_eth_mac_ch0/rx_statistics_valid]
  connect_bd_net -net ten_gig_eth_mac_ch0_rx_statistics_vector [get_bd_pins rx_statistics_vector] [get_bd_pins ten_gig_eth_mac_ch0/rx_statistics_vector]
  connect_bd_net -net ten_gig_eth_pcs_pma_ch0_areset_clk156_out [get_bd_pins areset_clk156_out] [get_bd_pins ten_gig_eth_pcs_pma_ch0/areset_clk156_out]
  connect_bd_net -net ten_gig_eth_pcs_pma_ch0_core_clk156_out [get_bd_pins core_clk156_out] [get_bd_pins ten_gig_eth_pcs_pma_ch0/core_clk156_out] [get_bd_pins ten_gig_eth_pcs_pma_ch0/dclk]
  connect_bd_net -net ten_gig_eth_pcs_pma_ch0_core_status [get_bd_pins core_status] [get_bd_pins ten_gig_eth_pcs_pma_ch0/core_status]
  connect_bd_net -net ten_gig_eth_pcs_pma_ch0_drp_req [get_bd_pins ten_gig_eth_pcs_pma_ch0/drp_gnt] [get_bd_pins ten_gig_eth_pcs_pma_ch0/drp_req]
  connect_bd_net -net ten_gig_eth_pcs_pma_ch0_gtrxreset_out [get_bd_pins gtrxreset_out] [get_bd_pins ten_gig_eth_pcs_pma_ch0/gtrxreset_out]
  connect_bd_net -net ten_gig_eth_pcs_pma_ch0_gttxreset_out [get_bd_pins gttxreset_out] [get_bd_pins ten_gig_eth_pcs_pma_ch0/gttxreset_out]
  connect_bd_net -net ten_gig_eth_pcs_pma_ch0_mdio_out [get_bd_pins ten_gig_eth_mac_ch0/mdio_in] [get_bd_pins ten_gig_eth_pcs_pma_ch0/mdio_out]
  connect_bd_net -net ten_gig_eth_pcs_pma_ch0_qpll0lock_out [get_bd_pins qpll0lock_out] [get_bd_pins ten_gig_eth_pcs_pma_ch0/qpll0lock_out]
  connect_bd_net -net ten_gig_eth_pcs_pma_ch0_qpll0outclk_out [get_bd_pins qpll0outclk_out] [get_bd_pins ten_gig_eth_pcs_pma_ch0/qpll0outclk_out]
  connect_bd_net -net ten_gig_eth_pcs_pma_ch0_qpll0outrefclk_out [get_bd_pins qpll0outrefclk_out] [get_bd_pins ten_gig_eth_pcs_pma_ch0/qpll0outrefclk_out]
  connect_bd_net -net ten_gig_eth_pcs_pma_ch0_reset_counter_done_out [get_bd_pins reset_counter_done_out] [get_bd_pins ten_gig_eth_pcs_pma_ch0/reset_counter_done_out]
  connect_bd_net -net ten_gig_eth_pcs_pma_ch0_resetdone [get_bd_pins resetdone] [get_bd_pins ten_gig_eth_pcs_pma_ch0/resetdone]
  connect_bd_net -net ten_gig_eth_pcs_pma_ch0_tx_disable [get_bd_pins tx_disable] [get_bd_pins ten_gig_eth_pcs_pma_ch0/tx_disable]
  connect_bd_net -net ten_gig_eth_pcs_pma_ch0_txn [get_bd_pins txn] [get_bd_pins ten_gig_eth_pcs_pma_ch0/txn]
  connect_bd_net -net ten_gig_eth_pcs_pma_ch0_txp [get_bd_pins txp] [get_bd_pins ten_gig_eth_pcs_pma_ch0/txp]
  connect_bd_net -net ten_gig_eth_pcs_pma_ch0_txuserrdy_out [get_bd_pins txuserrdy_out] [get_bd_pins ten_gig_eth_pcs_pma_ch0/txuserrdy_out]
  connect_bd_net -net ten_gig_eth_pcs_pma_ch0_txusrclk2_out [get_bd_pins txusrclk2_out] [get_bd_pins ten_gig_eth_pcs_pma_ch0/txusrclk2_out]
  connect_bd_net -net ten_gig_eth_pcs_pma_ch0_txusrclk_out [get_bd_pins txusrclk_out] [get_bd_pins ten_gig_eth_pcs_pma_ch0/txusrclk_out]
  connect_bd_net -net xlconstant_0_const [get_bd_pins rx_dcm_locked] [get_bd_pins ten_gig_eth_mac_ch0/rx_dcm_locked] [get_bd_pins ten_gig_eth_mac_ch0/tx_dcm_locked] [get_bd_pins ten_gig_eth_pcs_pma_ch0/signal_detect]
  
  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: c2s_dre
proc create_hier_cell_c2s_dre { parentCell nameHier } {

  if { $parentCell eq "" || $nameHier eq "" } {
     puts "ERROR: create_hier_cell_c2s_dre() - Empty argument(s)!"
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     puts "ERROR: Unable to find parent cell <$parentCell>!"
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     puts "ERROR: Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M_AXIS
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 s_axis

  # Create pins
  create_bd_pin -dir I -type clk aclk
  create_bd_pin -dir I -type rst aresetn
  create_bd_pin -dir I -from 47 -to 0 mac_id
  create_bd_pin -dir I mac_id_valid
  create_bd_pin -dir I reset
  create_bd_pin -dir I -type clk rx_clk
  create_bd_pin -dir I rx_statistics_valid
  create_bd_pin -dir I -from 29 -to 0 rx_statistics_vector
  create_bd_pin -dir I -type rst s_axis_aresetn
  create_bd_pin -dir I soft_reset

  # Create instance: axis_clock_converter_0, and set properties
  set axis_clock_converter_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_clock_converter:1.1 axis_clock_converter_0 ]
  set_property -dict [ list CONFIG.HAS_TKEEP {1} CONFIG.HAS_TLAST {1} CONFIG.TDATA_NUM_BYTES {8} CONFIG.TDEST_WIDTH {2}  ] $axis_clock_converter_0

  # Create instance: axis_dwidth_converter_0, and set properties
  set axis_dwidth_converter_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_dwidth_converter:1.1 axis_dwidth_converter_0 ]
  set_property -dict [ list CONFIG.M_TDATA_NUM_BYTES {16}  ] $axis_dwidth_converter_0

  # Create instance: rx_interface_0, and set properties
  set rx_interface_0 [ create_bd_cell -type ip -vlnv xilinx.com:user:rx_interface:1.0 rx_interface_0 ]
  set_property -dict [ list CONFIG.FIFO_CNT_WIDTH {13}  ] $rx_interface_0

  # Create interface connections
  connect_bd_intf_net -intf_net axis_clock_converter_0_M_AXIS [get_bd_intf_pins axis_clock_converter_0/M_AXIS] [get_bd_intf_pins axis_dwidth_converter_0/S_AXIS]
  connect_bd_intf_net -intf_net axis_dwidth_converter_0_M_AXIS [get_bd_intf_pins M_AXIS] [get_bd_intf_pins axis_dwidth_converter_0/M_AXIS]
  connect_bd_intf_net -intf_net mac_phy_ch0_m_axis_rx [get_bd_intf_pins s_axis] [get_bd_intf_pins rx_interface_0/s_axis]
  connect_bd_intf_net -intf_net rx_interface_0_m_axis [get_bd_intf_pins axis_clock_converter_0/S_AXIS] [get_bd_intf_pins rx_interface_0/m_axis]

  # Create port connections
  connect_bd_net -net M01_ARESETN_1 [get_bd_pins aresetn] [get_bd_pins axis_clock_converter_0/m_axis_aresetn] [get_bd_pins axis_dwidth_converter_0/aresetn]
  connect_bd_net -net logic_high_const [get_bd_pins mac_id_valid] [get_bd_pins rx_interface_0/mac_id_valid]
  connect_bd_net -net logic_low_const [get_bd_pins soft_reset] [get_bd_pins rx_interface_0/promiscuous_mode_en] [get_bd_pins rx_interface_0/soft_reset]
  connect_bd_net -net mac_id_cons_const [get_bd_pins mac_id] [get_bd_pins rx_interface_0/mac_id]
  connect_bd_net -net mac_phy_ch0_areset_clk156_out [get_bd_pins reset] [get_bd_pins rx_interface_0/reset]
  connect_bd_net -net mac_phy_ch0_core_clk156_out [get_bd_pins rx_clk] [get_bd_pins axis_clock_converter_0/s_axis_aclk] [get_bd_pins rx_interface_0/user_clk]
  connect_bd_net -net mac_phy_ch0_rx_statistics_valid [get_bd_pins rx_statistics_valid] [get_bd_pins rx_interface_0/rx_statistics_valid]
  connect_bd_net -net mac_phy_ch0_rx_statistics_vector [get_bd_pins rx_statistics_vector] [get_bd_pins rx_interface_0/rx_statistics_vector]
  connect_bd_net -net pcie_dma_wrapper_0_user_clk [get_bd_pins aclk] [get_bd_pins axis_clock_converter_0/m_axis_aclk] [get_bd_pins axis_dwidth_converter_0/aclk]
  connect_bd_net -net reset_156_inv_Res [get_bd_pins s_axis_aresetn] [get_bd_pins axis_clock_converter_0/s_axis_aresetn]
  
  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: reset_top
proc create_hier_cell_reset_top { parentCell nameHier } {

  if { $parentCell eq "" || $nameHier eq "" } {
     puts "ERROR: create_hier_cell_reset_top() - Empty argument(s)!"
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     puts "ERROR: Unable to find parent cell <$parentCell>!"
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     puts "ERROR: Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins

  # Create pins
  create_bd_pin -dir I -type rst ext_reset_in
  create_bd_pin -dir O interconnect_areset
  create_bd_pin -dir O -type rst interconnect_aresetn
  create_bd_pin -dir I -type clk slowest_sync_clk

  # Create instance: proc_sys_reset_0, and set properties
  set proc_sys_reset_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_0 ]
  set_property -dict [ list CONFIG.C_AUX_RESET_HIGH {0}  ] $proc_sys_reset_0

  # Create instance: util_vector_logic_0, and set properties
  set util_vector_logic_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:1.0 util_vector_logic_0 ]
  set_property -dict [ list CONFIG.C_OPERATION {not} CONFIG.C_SIZE {1}  ] $util_vector_logic_0

  # Create port connections
  connect_bd_net -net M01_ARESETN_1 [get_bd_pins interconnect_aresetn] [get_bd_pins proc_sys_reset_0/interconnect_aresetn] [get_bd_pins util_vector_logic_0/Op1]
  connect_bd_net -net pcie_dma_wrapper_0_user_clk [get_bd_pins slowest_sync_clk] [get_bd_pins proc_sys_reset_0/slowest_sync_clk]
  connect_bd_net -net pcie_dma_wrapper_0_user_lnk_up1 [get_bd_pins ext_reset_in] [get_bd_pins proc_sys_reset_0/ext_reset_in]
  connect_bd_net -net user_linkup_n [get_bd_pins interconnect_areset] [get_bd_pins util_vector_logic_0/Res]
  
  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: hw_sgl_submit
proc create_hier_cell_hw_sgl_submit { parentCell nameHier } {

  if { $parentCell eq "" || $nameHier eq "" } {
     puts "ERROR: create_hier_cell_hw_sgl_submit() - Empty argument(s)!"
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     puts "ERROR: Unable to find parent cell <$parentCell>!"
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     puts "ERROR: Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins

  # Create pins
  create_bd_pin -dir I -type clk aclk
  create_bd_pin -dir I -type rst nRESET
  create_bd_pin -dir O -from 1 -to 0 sgl_alloc_channel
  create_bd_pin -dir I -from 3 -to 0 sgl_alloc_dst_aready
  create_bd_pin -dir I -from 3 -to 0 sgl_alloc_dst_empty
  create_bd_pin -dir I -from 3 -to 0 sgl_alloc_dst_full
  create_bd_pin -dir O sgl_alloc_dst_src_n
  create_bd_pin -dir O -from 2 -to 0 sgl_alloc_num_sgl
  create_bd_pin -dir I sgl_alloc_ready
  create_bd_pin -dir I -from 3 -to 0 sgl_alloc_src_aready
  create_bd_pin -dir I -from 3 -to 0 sgl_alloc_src_empty
  create_bd_pin -dir I -from 3 -to 0 sgl_alloc_src_full
  create_bd_pin -dir O sgl_alloc_valid
  create_bd_pin -dir I -from 1 -to 0 sgl_available_0_1
  create_bd_pin -dir I -from 1 -to 0 sgl_available_2_3
  create_bd_pin -dir I -from 223 -to 0 sgl_data_0_1
  create_bd_pin -dir I -from 223 -to 0 sgl_data_2_3
  create_bd_pin -dir I -from 3 -to 0 sgl_dma_ch_en
  create_bd_pin -dir I -from 3 -to 0 sgl_dma_ch_reset
  create_bd_pin -dir O -from 1 -to 0 sgl_done_1_0
  create_bd_pin -dir O -from 1 -to 0 sgl_done_3_2
  create_bd_pin -dir O -from 1 -to 0 sgl_error_1_0
  create_bd_pin -dir O -from 1 -to 0 sgl_error_3_2
  create_bd_pin -dir O -from 1 -to 0 sgl_wr_channel
  create_bd_pin -dir O -from 127 -to 0 sgl_wr_data
  create_bd_pin -dir O sgl_wr_dst_src_n
  create_bd_pin -dir I sgl_wr_ready
  create_bd_pin -dir O sgl_wr_valid

  # Create instance: hw_sgl_submit_0, and set properties
  set hw_sgl_submit_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:hw_sgl_submit_4ch:1.0 hw_sgl_submit_0 ]

  # Create instance: sgl_done_1_0, and set properties
  set sgl_done_1_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 sgl_done_1_0 ]
  set_property -dict [ list CONFIG.DIN_FROM {1} CONFIG.DIN_WIDTH {4}  ] $sgl_done_1_0

  # Create instance: sgl_done_3_2, and set properties
  set sgl_done_3_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 sgl_done_3_2 ]
  set_property -dict [ list CONFIG.DIN_FROM {3} CONFIG.DIN_TO {2} CONFIG.DIN_WIDTH {4}  ] $sgl_done_3_2

  # Create instance: sgl_error_1_0, and set properties
  set sgl_error_1_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 sgl_error_1_0 ]
  set_property -dict [ list CONFIG.DIN_FROM {1} CONFIG.DIN_WIDTH {4}  ] $sgl_error_1_0

  # Create instance: sgl_error_3_2, and set properties
  set sgl_error_3_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 sgl_error_3_2 ]
  set_property -dict [ list CONFIG.DIN_FROM {3} CONFIG.DIN_TO {2} CONFIG.DIN_WIDTH {4}  ] $sgl_error_3_2

  # Create instance: xlconcat_0, and set properties
  set xlconcat_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_0 ]
  set_property -dict [ list CONFIG.IN0_WIDTH {2} CONFIG.IN1_WIDTH {2}  ] $xlconcat_0

  # Create instance: xlconcat_1, and set properties
  set xlconcat_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_1 ]
  set_property -dict [ list CONFIG.IN0_WIDTH {224} CONFIG.IN1_WIDTH {224}  ] $xlconcat_1

  # Create port connections
  connect_bd_net -net In0_1 [get_bd_pins sgl_data_0_1] [get_bd_pins xlconcat_1/In0]
  connect_bd_net -net In1_1 [get_bd_pins sgl_data_2_3] [get_bd_pins xlconcat_1/In1]
  connect_bd_net -net In1_2 [get_bd_pins sgl_available_2_3] [get_bd_pins xlconcat_0/In1]
  connect_bd_net -net hw_sgl_submit_0_sgl_alloc_channel [get_bd_pins sgl_alloc_channel] [get_bd_pins hw_sgl_submit_0/sgl_alloc_channel]
  connect_bd_net -net hw_sgl_submit_0_sgl_alloc_dst_src_n [get_bd_pins sgl_alloc_dst_src_n] [get_bd_pins hw_sgl_submit_0/sgl_alloc_dst_src_n]
  connect_bd_net -net hw_sgl_submit_0_sgl_alloc_num_sgl [get_bd_pins sgl_alloc_num_sgl] [get_bd_pins hw_sgl_submit_0/sgl_alloc_num_sgl]
  connect_bd_net -net hw_sgl_submit_0_sgl_alloc_valid [get_bd_pins sgl_alloc_valid] [get_bd_pins hw_sgl_submit_0/sgl_alloc_valid]
  connect_bd_net -net hw_sgl_submit_0_sgl_done [get_bd_pins hw_sgl_submit_0/sgl_done] [get_bd_pins sgl_done_1_0/Din] [get_bd_pins sgl_done_3_2/Din]
  connect_bd_net -net hw_sgl_submit_0_sgl_error [get_bd_pins hw_sgl_submit_0/sgl_error] [get_bd_pins sgl_error_1_0/Din] [get_bd_pins sgl_error_3_2/Din]
  connect_bd_net -net hw_sgl_submit_0_sgl_wr_channel [get_bd_pins sgl_wr_channel] [get_bd_pins hw_sgl_submit_0/sgl_wr_channel]
  connect_bd_net -net hw_sgl_submit_0_sgl_wr_data [get_bd_pins sgl_wr_data] [get_bd_pins hw_sgl_submit_0/sgl_wr_data]
  connect_bd_net -net hw_sgl_submit_0_sgl_wr_dst_src_n [get_bd_pins sgl_wr_dst_src_n] [get_bd_pins hw_sgl_submit_0/sgl_wr_dst_src_n]
  connect_bd_net -net hw_sgl_submit_0_sgl_wr_valid [get_bd_pins sgl_wr_valid] [get_bd_pins hw_sgl_submit_0/sgl_wr_valid]
  connect_bd_net -net pcie_dma_wrapper_0_sgl_alloc_ready [get_bd_pins sgl_alloc_ready] [get_bd_pins hw_sgl_submit_0/sgl_alloc_ready]
  connect_bd_net -net pcie_dma_wrapper_0_sgl_wr_ready [get_bd_pins sgl_wr_ready] [get_bd_pins hw_sgl_submit_0/sgl_wr_ready]
  connect_bd_net -net pcie_dma_wrapper_0_user_clk [get_bd_pins aclk] [get_bd_pins hw_sgl_submit_0/aclk]
  connect_bd_net -net pcie_dma_wrapper_0_user_lnk_up [get_bd_pins nRESET] [get_bd_pins hw_sgl_submit_0/nRESET]
  connect_bd_net -net sgl_alloc_dst_aready_1 [get_bd_pins sgl_alloc_dst_aready] [get_bd_pins hw_sgl_submit_0/sgl_alloc_dst_aready]
  connect_bd_net -net sgl_alloc_dst_empty_1 [get_bd_pins sgl_alloc_dst_empty] [get_bd_pins hw_sgl_submit_0/sgl_alloc_dst_empty]
  connect_bd_net -net sgl_alloc_dst_full_1 [get_bd_pins sgl_alloc_dst_full] [get_bd_pins hw_sgl_submit_0/sgl_alloc_dst_full]
  connect_bd_net -net sgl_alloc_src_aready_1 [get_bd_pins sgl_alloc_src_aready] [get_bd_pins hw_sgl_submit_0/sgl_alloc_src_aready]
  connect_bd_net -net sgl_alloc_src_empty_1 [get_bd_pins sgl_alloc_src_empty] [get_bd_pins hw_sgl_submit_0/sgl_alloc_src_empty]
  connect_bd_net -net sgl_alloc_src_full_1 [get_bd_pins sgl_alloc_src_full] [get_bd_pins hw_sgl_submit_0/sgl_alloc_src_full]
  connect_bd_net -net sgl_available_1_0 [get_bd_pins sgl_available_0_1] [get_bd_pins xlconcat_0/In0]
  connect_bd_net -net sgl_dma_ch_en_1 [get_bd_pins sgl_dma_ch_en] [get_bd_pins hw_sgl_submit_0/sgl_dma_ch_en]
  connect_bd_net -net sgl_dma_ch_reset_1 [get_bd_pins sgl_dma_ch_reset] [get_bd_pins hw_sgl_submit_0/sgl_dma_ch_reset]
  connect_bd_net -net sgl_done_1_0_Dout [get_bd_pins sgl_done_1_0] [get_bd_pins sgl_done_1_0/Dout]
  connect_bd_net -net sgl_done_3_2_Dout [get_bd_pins sgl_done_3_2] [get_bd_pins sgl_done_3_2/Dout]
  connect_bd_net -net sgl_error_0_1_Dout [get_bd_pins sgl_error_1_0] [get_bd_pins sgl_error_1_0/Dout]
  connect_bd_net -net sgl_error_2_3_Dout [get_bd_pins sgl_error_3_2] [get_bd_pins sgl_error_3_2/Dout]
  connect_bd_net -net xlconcat_0_dout [get_bd_pins hw_sgl_submit_0/sgl_available] [get_bd_pins xlconcat_0/dout]
  connect_bd_net -net xlconcat_1_dout [get_bd_pins hw_sgl_submit_0/sgl_data] [get_bd_pins xlconcat_1/dout]
  
  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: eth_pipe_1
proc create_hier_cell_eth_pipe_1 { parentCell nameHier } {

  if { $parentCell eq "" || $nameHier eq "" } {
     puts "ERROR: create_hier_cell_eth_pipe_1() - Empty argument(s)!"
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     puts "ERROR: Unable to find parent cell <$parentCell>!"
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     puts "ERROR: Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 c2s_dre_m_axis
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 s2c_dre_s_axis
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 s_axis_pause

  # Create pins
  create_bd_pin -dir I areset_clk156
  create_bd_pin -dir I clk_156
  create_bd_pin -dir O -from 7 -to 0 core_status
  create_bd_pin -dir I gtrxreset
  create_bd_pin -dir I gttxreset
  create_bd_pin -dir I mac_areset
  create_bd_pin -dir I -from 47 -to 0 mac_id
  create_bd_pin -dir I -from 4 -to 0 prtad
  create_bd_pin -dir I qpll0lock
  create_bd_pin -dir I qpll0outclk
  create_bd_pin -dir I qpll0outrefclk
  create_bd_pin -dir I reset_counter_done
  create_bd_pin -dir O rx_resetdone
  create_bd_pin -dir I rxn
  create_bd_pin -dir I rxp
  create_bd_pin -dir I sim_speedup_control
  create_bd_pin -dir O tx_disable
  create_bd_pin -dir O tx_resetdone
  create_bd_pin -dir O txn
  create_bd_pin -dir O txp
  create_bd_pin -dir I txuserrdy
  create_bd_pin -dir I txusrclk
  create_bd_pin -dir I txusrclk2
  create_bd_pin -dir I user_clk
  create_bd_pin -dir I user_resetn

  # Create instance: c2s_dre
  create_hier_cell_c2s_dre_1 $hier_obj c2s_dre

  # Create instance: logic_high, and set properties
  set logic_high [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 logic_high ]

  # Create instance: logic_low, and set properties
  set logic_low [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 logic_low ]

  # Create instance: logic_low_8bit, and set properties
  set logic_low_8bit [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 logic_low_8bit ]
  set_property -dict [ list CONFIG.CONST_VAL {0} CONFIG.CONST_WIDTH {8}  ] $logic_low_8bit

  # Create instance: mac_phy_ch1
  create_hier_cell_mac_phy_ch1 $hier_obj mac_phy_ch1

  # Create instance: reset_156_inv, and set properties
  set reset_156_inv [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:1.0 reset_156_inv ]
  set_property -dict [ list CONFIG.C_OPERATION {not} CONFIG.C_SIZE {1}  ] $reset_156_inv

  # Create instance: s2c_dre
  create_hier_cell_s2c_dre_1 $hier_obj s2c_dre

  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins s2c_dre_s_axis] [get_bd_intf_pins s2c_dre/S_AXIS]
  connect_bd_intf_net -intf_net Conn2 [get_bd_intf_pins c2s_dre_m_axis] [get_bd_intf_pins c2s_dre/M_AXIS]
  connect_bd_intf_net -intf_net Conn3 [get_bd_intf_pins s_axi] [get_bd_intf_pins mac_phy_ch1/s_axi]
  connect_bd_intf_net -intf_net mac_phy_ch0_m_axis_rx [get_bd_intf_pins c2s_dre/s_axis] [get_bd_intf_pins mac_phy_ch1/m_axis_rx]
  connect_bd_intf_net -intf_net s_axis_pause_1 [get_bd_intf_pins s_axis_pause] [get_bd_intf_pins mac_phy_ch1/s_axis_pause]
  connect_bd_intf_net -intf_net tx_packet_fifo_M_AXIS [get_bd_intf_pins mac_phy_ch1/s_axis_tx] [get_bd_intf_pins s2c_dre/M_AXIS]

  # Create port connections
  connect_bd_net -net M01_ARESETN_1 [get_bd_pins user_resetn] [get_bd_pins c2s_dre/aresetn] [get_bd_pins mac_phy_ch1/rx_axis_aresetn] [get_bd_pins s2c_dre/s_axis_aresetn]
  connect_bd_net -net areset_1 [get_bd_pins mac_areset] [get_bd_pins mac_phy_ch1/areset]
  connect_bd_net -net gtrxreset_1 [get_bd_pins gtrxreset] [get_bd_pins mac_phy_ch1/gtrxreset]
  connect_bd_net -net gttxreset_1 [get_bd_pins gttxreset] [get_bd_pins mac_phy_ch1/gttxreset]
  connect_bd_net -net logic_high_const [get_bd_pins c2s_dre/mac_id_valid] [get_bd_pins logic_high/dout] [get_bd_pins mac_phy_ch1/rx_dcm_locked]
  connect_bd_net -net logic_low_8bit_const [get_bd_pins logic_low_8bit/dout] [get_bd_pins mac_phy_ch1/tx_ifg_delay]
  connect_bd_net -net logic_low_const [get_bd_pins c2s_dre/soft_reset] [get_bd_pins logic_low/dout] [get_bd_pins mac_phy_ch1/tx_fault]
  connect_bd_net -net mac_id_1 [get_bd_pins mac_id] [get_bd_pins c2s_dre/mac_id]
  connect_bd_net -net mac_phy_ch0_areset_clk156_out [get_bd_pins areset_clk156] [get_bd_pins c2s_dre/reset] [get_bd_pins mac_phy_ch1/areset_clk156] [get_bd_pins reset_156_inv/Op1]
  connect_bd_net -net mac_phy_ch0_core_clk156_out1 [get_bd_pins clk_156] [get_bd_pins c2s_dre/rx_clk] [get_bd_pins mac_phy_ch1/clk156] [get_bd_pins mac_phy_ch1/s_axi_aclk] [get_bd_pins s2c_dre/m_aclk]
  connect_bd_net -net mac_phy_ch0_core_status [get_bd_pins core_status] [get_bd_pins mac_phy_ch1/core_status]
  connect_bd_net -net mac_phy_ch0_rx_statistics_valid [get_bd_pins c2s_dre/rx_statistics_valid] [get_bd_pins mac_phy_ch1/rx_statistics_valid]
  connect_bd_net -net mac_phy_ch0_rx_statistics_vector [get_bd_pins c2s_dre/rx_statistics_vector] [get_bd_pins mac_phy_ch1/rx_statistics_vector]
  connect_bd_net -net mac_phy_ch0_tx_disable [get_bd_pins tx_disable] [get_bd_pins mac_phy_ch1/tx_disable]
  connect_bd_net -net mac_phy_ch0_txn [get_bd_pins txn] [get_bd_pins mac_phy_ch1/txn]
  connect_bd_net -net mac_phy_ch0_txp [get_bd_pins txp] [get_bd_pins mac_phy_ch1/txp]
  connect_bd_net -net mac_phy_ch1_rx_resetdone [get_bd_pins rx_resetdone] [get_bd_pins mac_phy_ch1/rx_resetdone]
  connect_bd_net -net mac_phy_ch1_tx_resetdone [get_bd_pins tx_resetdone] [get_bd_pins mac_phy_ch1/tx_resetdone]
  connect_bd_net -net pcie_dma_wrapper_0_user_clk [get_bd_pins user_clk] [get_bd_pins c2s_dre/aclk] [get_bd_pins s2c_dre/s_axis_aclk]
  connect_bd_net -net prtad_1 [get_bd_pins prtad] [get_bd_pins mac_phy_ch1/prtad]
  connect_bd_net -net qpll0lock_1 [get_bd_pins qpll0lock] [get_bd_pins mac_phy_ch1/qpll0lock]
  connect_bd_net -net qpll0outclk_1 [get_bd_pins qpll0outclk] [get_bd_pins mac_phy_ch1/qpll0outclk]
  connect_bd_net -net qpll0outrefclk_1 [get_bd_pins qpll0outrefclk] [get_bd_pins mac_phy_ch1/qpll0outrefclk]
  connect_bd_net -net reset_156_inv_Res [get_bd_pins c2s_dre/s_axis_aresetn] [get_bd_pins mac_phy_ch1/s_axi_aresetn] [get_bd_pins reset_156_inv/Res] [get_bd_pins s2c_dre/m_aresetn]
  connect_bd_net -net reset_counter_done_1 [get_bd_pins reset_counter_done] [get_bd_pins mac_phy_ch1/reset_counter_done]
  connect_bd_net -net rxn_1 [get_bd_pins rxn] [get_bd_pins mac_phy_ch1/rxn]
  connect_bd_net -net rxp_1 [get_bd_pins rxp] [get_bd_pins mac_phy_ch1/rxp]
  connect_bd_net -net sim_speedup_control_1 [get_bd_pins sim_speedup_control] [get_bd_pins mac_phy_ch1/sim_speedup_control]
  connect_bd_net -net txuserrdy_1 [get_bd_pins txuserrdy] [get_bd_pins mac_phy_ch1/txuserrdy]
  connect_bd_net -net txusrclk2_1 [get_bd_pins txusrclk2] [get_bd_pins mac_phy_ch1/txusrclk2]
  connect_bd_net -net txusrclk_1 [get_bd_pins txusrclk] [get_bd_pins mac_phy_ch1/txusrclk]
  
  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: eth_pipe_0
proc create_hier_cell_eth_pipe_0 { parentCell nameHier } {

  if { $parentCell eq "" || $nameHier eq "" } {
     puts "ERROR: create_hier_cell_eth_pipe_0() - Empty argument(s)!"
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     puts "ERROR: Unable to find parent cell <$parentCell>!"
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     puts "ERROR: Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 c2s_dre_m_axis
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 refclk_diff_port
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 s2c_dre_s_axis
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 s_axis_pause

  # Create pins
  create_bd_pin -dir O clk_156
  create_bd_pin -dir O clk_156_reset
  create_bd_pin -dir O clk_156_resetn
  create_bd_pin -dir O -from 7 -to 0 core_status
  create_bd_pin -dir O gtrxreset_out
  create_bd_pin -dir O gttxreset_out
  create_bd_pin -dir I mac_areset
  create_bd_pin -dir I -from 47 -to 0 mac_id
  create_bd_pin -dir I -from 4 -to 0 prtad
  create_bd_pin -dir O qpll0lock_out
  create_bd_pin -dir O qpll0outclk_out
  create_bd_pin -dir O qpll0outrefclk_out
  create_bd_pin -dir O reset_counter_done_out
  create_bd_pin -dir O resetdone
  create_bd_pin -dir I rxn
  create_bd_pin -dir I rxp
  create_bd_pin -dir I sim_speedup_control
  create_bd_pin -dir O tx_disable
  create_bd_pin -dir O txn
  create_bd_pin -dir O txp
  create_bd_pin -dir O txuserrdy_out
  create_bd_pin -dir O txusrclk2_out
  create_bd_pin -dir O txusrclk_out
  create_bd_pin -dir I user_clk
  create_bd_pin -dir I user_resetn

  # Create instance: c2s_dre
  create_hier_cell_c2s_dre $hier_obj c2s_dre

  # Create instance: logic_high, and set properties
  set logic_high [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 logic_high ]

  # Create instance: logic_low, and set properties
  set logic_low [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 logic_low ]

  # Create instance: logic_low_8bit, and set properties
  set logic_low_8bit [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 logic_low_8bit ]
  set_property -dict [ list CONFIG.CONST_VAL {0} CONFIG.CONST_WIDTH {8}  ] $logic_low_8bit

  # Create instance: mac_phy_ch0
  create_hier_cell_mac_phy_ch0 $hier_obj mac_phy_ch0

  # Create instance: reset_156_inv, and set properties
  set reset_156_inv [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:1.0 reset_156_inv ]
  set_property -dict [ list CONFIG.C_OPERATION {not} CONFIG.C_SIZE {1}  ] $reset_156_inv

  # Create instance: s2c_dre
  create_hier_cell_s2c_dre $hier_obj s2c_dre

  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins s2c_dre_s_axis] [get_bd_intf_pins s2c_dre/S_AXIS]
  connect_bd_intf_net -intf_net Conn2 [get_bd_intf_pins c2s_dre_m_axis] [get_bd_intf_pins c2s_dre/M_AXIS]
  connect_bd_intf_net -intf_net Conn3 [get_bd_intf_pins s_axi] [get_bd_intf_pins mac_phy_ch0/s_axi]
  connect_bd_intf_net -intf_net mac_phy_ch0_m_axis_rx [get_bd_intf_pins c2s_dre/s_axis] [get_bd_intf_pins mac_phy_ch0/m_axis_rx]
  connect_bd_intf_net -intf_net refclk_diff_port_1 [get_bd_intf_pins refclk_diff_port] [get_bd_intf_pins mac_phy_ch0/refclk_diff_port]
  connect_bd_intf_net -intf_net s_axis_pause_1 [get_bd_intf_pins s_axis_pause] [get_bd_intf_pins mac_phy_ch0/s_axis_pause]
  connect_bd_intf_net -intf_net tx_packet_fifo_M_AXIS [get_bd_intf_pins mac_phy_ch0/s_axis_tx] [get_bd_intf_pins s2c_dre/M_AXIS]

  # Create port connections
  connect_bd_net -net M01_ARESETN_1 [get_bd_pins user_resetn] [get_bd_pins c2s_dre/aresetn] [get_bd_pins mac_phy_ch0/rx_axis_aresetn] [get_bd_pins s2c_dre/s_axis_aresetn]
  connect_bd_net -net areset_1 [get_bd_pins mac_areset] [get_bd_pins mac_phy_ch0/areset]
  connect_bd_net -net logic_high_const [get_bd_pins c2s_dre/mac_id_valid] [get_bd_pins logic_high/dout] [get_bd_pins mac_phy_ch0/rx_dcm_locked]
  connect_bd_net -net logic_low_8bit_const [get_bd_pins logic_low_8bit/dout] [get_bd_pins mac_phy_ch0/tx_ifg_delay]
  connect_bd_net -net logic_low_const [get_bd_pins c2s_dre/soft_reset] [get_bd_pins logic_low/dout] [get_bd_pins mac_phy_ch0/tx_fault]
  connect_bd_net -net mac_id_1 [get_bd_pins mac_id] [get_bd_pins c2s_dre/mac_id]
  connect_bd_net -net mac_phy_ch0_areset_clk156_out [get_bd_pins clk_156_reset] [get_bd_pins c2s_dre/reset] [get_bd_pins mac_phy_ch0/areset_clk156_out] [get_bd_pins reset_156_inv/Op1]
  create_bd_net mac_phy_ch0_core_clk156_out1
  connect_bd_net -net [get_bd_nets mac_phy_ch0_core_clk156_out1] [get_bd_pins clk_156] [get_bd_pins c2s_dre/rx_clk] [get_bd_pins mac_phy_ch0/clk156] [get_bd_pins mac_phy_ch0/core_clk156_out] [get_bd_pins mac_phy_ch0/s_axi_aclk] [get_bd_pins s2c_dre/m_aclk]
  connect_bd_net -net mac_phy_ch0_core_status [get_bd_pins core_status] [get_bd_pins mac_phy_ch0/core_status]
  connect_bd_net -net mac_phy_ch0_gtrxreset_out [get_bd_pins gtrxreset_out] [get_bd_pins mac_phy_ch0/gtrxreset_out]
  connect_bd_net -net mac_phy_ch0_gttxreset_out [get_bd_pins gttxreset_out] [get_bd_pins mac_phy_ch0/gttxreset_out]
  connect_bd_net -net mac_phy_ch0_qpll0lock_out [get_bd_pins qpll0lock_out] [get_bd_pins mac_phy_ch0/qpll0lock_out]
  connect_bd_net -net mac_phy_ch0_qpll0outclk_out [get_bd_pins qpll0outclk_out] [get_bd_pins mac_phy_ch0/qpll0outclk_out]
  connect_bd_net -net mac_phy_ch0_qpll0outrefclk_out [get_bd_pins qpll0outrefclk_out] [get_bd_pins mac_phy_ch0/qpll0outrefclk_out]
  connect_bd_net -net mac_phy_ch0_reset_counter_done_out [get_bd_pins reset_counter_done_out] [get_bd_pins mac_phy_ch0/reset_counter_done_out]
  connect_bd_net -net mac_phy_ch0_resetdone [get_bd_pins resetdone] [get_bd_pins mac_phy_ch0/resetdone]
  connect_bd_net -net mac_phy_ch0_rx_statistics_valid [get_bd_pins c2s_dre/rx_statistics_valid] [get_bd_pins mac_phy_ch0/rx_statistics_valid]
  connect_bd_net -net mac_phy_ch0_rx_statistics_vector [get_bd_pins c2s_dre/rx_statistics_vector] [get_bd_pins mac_phy_ch0/rx_statistics_vector]
  connect_bd_net -net mac_phy_ch0_tx_disable [get_bd_pins tx_disable] [get_bd_pins mac_phy_ch0/tx_disable]
  connect_bd_net -net mac_phy_ch0_txn [get_bd_pins txn] [get_bd_pins mac_phy_ch0/txn]
  connect_bd_net -net mac_phy_ch0_txp [get_bd_pins txp] [get_bd_pins mac_phy_ch0/txp]
  connect_bd_net -net mac_phy_ch0_txuserrdy_out [get_bd_pins txuserrdy_out] [get_bd_pins mac_phy_ch0/txuserrdy_out]
  connect_bd_net -net mac_phy_ch0_txusrclk2_out [get_bd_pins txusrclk2_out] [get_bd_pins mac_phy_ch0/txusrclk2_out]
  connect_bd_net -net mac_phy_ch0_txusrclk_out [get_bd_pins txusrclk_out] [get_bd_pins mac_phy_ch0/txusrclk_out]
  connect_bd_net -net pcie_dma_wrapper_0_user_clk [get_bd_pins user_clk] [get_bd_pins c2s_dre/aclk] [get_bd_pins s2c_dre/s_axis_aclk]
  connect_bd_net -net prtad_1 [get_bd_pins prtad] [get_bd_pins mac_phy_ch0/prtad]
  connect_bd_net -net reset_156_inv_Res [get_bd_pins clk_156_resetn] [get_bd_pins c2s_dre/s_axis_aresetn] [get_bd_pins mac_phy_ch0/s_axi_aresetn] [get_bd_pins reset_156_inv/Res] [get_bd_pins s2c_dre/m_aresetn]
  connect_bd_net -net rxn_1 [get_bd_pins rxn] [get_bd_pins mac_phy_ch0/rxn]
  connect_bd_net -net rxp_1 [get_bd_pins rxp] [get_bd_pins mac_phy_ch0/rxp]
  connect_bd_net -net sim_speedup_control_1 [get_bd_pins sim_speedup_control] [get_bd_pins mac_phy_ch0/sim_speedup_control]
  
  # Restore current instance
  current_bd_instance $oldCurInst
}


# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     puts "ERROR: Unable to find parent cell <$parentCell>!"
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     puts "ERROR: Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set pcie3_ext_pipe_interface [ create_bd_intf_port -mode Master -vlnv xilinx.com:display_pcie3_ultrascale:ext_pipe_rtl:1.0 pcie3_ext_pipe_interface ]
  set pcie_7x_mgt [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:pcie_7x_mgt_rtl:1.0 pcie_7x_mgt ]
  set refclk_diff_port [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 refclk_diff_port ]
  set_property -dict [ list CONFIG.FREQ_HZ {156250000}  ] $refclk_diff_port
  set s_axis_pause_0 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 s_axis_pause_0 ]
  set_property -dict [ list CONFIG.CLK_DOMAIN {} CONFIG.FREQ_HZ {156250000} CONFIG.HAS_TKEEP {0} CONFIG.HAS_TLAST {0} CONFIG.HAS_TREADY {0} CONFIG.HAS_TSTRB {0} CONFIG.LAYERED_METADATA {undef} CONFIG.PHASE {0.000} CONFIG.TDATA_NUM_BYTES {2} CONFIG.TDEST_WIDTH {0} CONFIG.TID_WIDTH {0} CONFIG.TUSER_WIDTH {0}  ] $s_axis_pause_0
  set s_axis_pause_1 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 s_axis_pause_1 ]
  set_property -dict [ list CONFIG.CLK_DOMAIN {} CONFIG.FREQ_HZ {156250000} CONFIG.HAS_TKEEP {0} CONFIG.HAS_TLAST {0} CONFIG.HAS_TREADY {0} CONFIG.HAS_TSTRB {0} CONFIG.LAYERED_METADATA {undef} CONFIG.PHASE {0.000} CONFIG.TDATA_NUM_BYTES {2} CONFIG.TDEST_WIDTH {0} CONFIG.TID_WIDTH {0} CONFIG.TUSER_WIDTH {0}  ] $s_axis_pause_1

  # Create ports
  set cfg_current_speed [ create_bd_port -dir O -from 2 -to 0 cfg_current_speed ]
  set cfg_negotiated_width [ create_bd_port -dir O -from 3 -to 0 cfg_negotiated_width ]
  set clk125_in [ create_bd_port -dir I clk125_in ]
  set core_status_0 [ create_bd_port -dir O -from 7 -to 0 core_status_0 ]
  set core_status_1 [ create_bd_port -dir O -from 7 -to 0 core_status_1 ]
  set muxaddr_out [ create_bd_port -dir O -from 2 -to 0 muxaddr_out ]
  set pmbus_alert [ create_bd_port -dir I pmbus_alert ]
  set pmbus_clk [ create_bd_port -dir IO pmbus_clk ]
  set pmbus_control [ create_bd_port -dir O pmbus_control ]
  set pmbus_data [ create_bd_port -dir IO pmbus_data ]
  set prtad_0 [ create_bd_port -dir I -from 4 -to 0 prtad_0 ]
  set prtad_1 [ create_bd_port -dir I -from 4 -to 0 prtad_1 ]
  set resetdone_0 [ create_bd_port -dir O resetdone_0 ]
  set rx_resetdone_1 [ create_bd_port -dir O rx_resetdone_1 ]
  set rxn_0 [ create_bd_port -dir I rxn_0 ]
  set rxn_1 [ create_bd_port -dir I rxn_1 ]
  set rxp_0 [ create_bd_port -dir I rxp_0 ]
  set rxp_1 [ create_bd_port -dir I rxp_1 ]
  set sim_speedup_control_0 [ create_bd_port -dir I sim_speedup_control_0 ]
  set sim_speedup_control_1 [ create_bd_port -dir I sim_speedup_control_1 ]
  set sys_clk [ create_bd_port -dir I -type clk sys_clk ]
  set sys_clk_gt [ create_bd_port -dir I -type clk sys_clk_gt ]
  set sys_reset [ create_bd_port -dir I -type rst sys_reset ]
  set_property -dict [ list CONFIG.POLARITY {ACTIVE_LOW}  ] $sys_reset
  set tx_disable_0 [ create_bd_port -dir O tx_disable_0 ]
  set tx_disable_1 [ create_bd_port -dir O tx_disable_1 ]
  set tx_resetdone_1 [ create_bd_port -dir O tx_resetdone_1 ]
  set txn_0 [ create_bd_port -dir O txn_0 ]
  set txn_1 [ create_bd_port -dir O txn_1 ]
  set txp_0 [ create_bd_port -dir O txp_0 ]
  set txp_1 [ create_bd_port -dir O txp_1 ]
  set user_clk [ create_bd_port -dir O user_clk ]
  set user_linkup [ create_bd_port -dir O user_linkup ]
  set vauxn0 [ create_bd_port -dir I vauxn0 ]
  set vauxn2 [ create_bd_port -dir I vauxn2 ]
  set vauxn8 [ create_bd_port -dir I vauxn8 ]
  set vauxp0 [ create_bd_port -dir I vauxp0 ]
  set vauxp2 [ create_bd_port -dir I vauxp2 ]
  set vauxp8 [ create_bd_port -dir I vauxp8 ]

  # Create instance: axi_lite_interconnect_1, and set properties
  set axi_lite_interconnect_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_lite_interconnect_1 ]
  set_property -dict [ list CONFIG.M00_HAS_REGSLICE {1} CONFIG.M01_HAS_REGSLICE {1} CONFIG.M02_HAS_REGSLICE {1} CONFIG.M03_HAS_REGSLICE {1} CONFIG.M04_HAS_REGSLICE {1} CONFIG.NUM_MI {5} CONFIG.S00_HAS_REGSLICE {3}  ] $axi_lite_interconnect_1

  # Create instance: axi_perf_mon_1, and set properties
  set axi_perf_mon_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_perf_mon:5.0 axi_perf_mon_1 ]
  set_property -dict [ list CONFIG.C_NUM_MONITOR_SLOTS {4} CONFIG.C_NUM_OF_COUNTERS {4} CONFIG.C_SLOT_0_AXI_PROTOCOL {AXI4S} CONFIG.C_SLOT_1_AXI_PROTOCOL {AXI4S} CONFIG.C_SLOT_2_AXI_PROTOCOL {AXI4S} CONFIG.C_SLOT_3_AXI_PROTOCOL {AXI4S}  ] $axi_perf_mon_1

  # Create instance: ch_reset_0, and set properties
  set ch_reset_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 ch_reset_0 ]
  set_property -dict [ list CONFIG.DIN_WIDTH {4}  ] $ch_reset_0

  # Create instance: ch_reset_1, and set properties
  set ch_reset_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 ch_reset_1 ]
  set_property -dict [ list CONFIG.DIN_FROM {1} CONFIG.DIN_TO {1} CONFIG.DIN_WIDTH {4}  ] $ch_reset_1

  # Create instance: ch_reset_2, and set properties
  set ch_reset_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 ch_reset_2 ]
  set_property -dict [ list CONFIG.DIN_FROM {2} CONFIG.DIN_TO {2} CONFIG.DIN_WIDTH {4}  ] $ch_reset_2

  # Create instance: ch_reset_3, and set properties
  set ch_reset_3 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 ch_reset_3 ]
  set_property -dict [ list CONFIG.DIN_FROM {3} CONFIG.DIN_TO {3} CONFIG.DIN_WIDTH {4}  ] $ch_reset_3

  # Create instance: eth_pipe_0
  create_hier_cell_eth_pipe_0 [current_bd_instance .] eth_pipe_0

  # Create instance: eth_pipe_1
  create_hier_cell_eth_pipe_1 [current_bd_instance .] eth_pipe_1

  # Create instance: hw_sgl_prepare_0, and set properties
  set hw_sgl_prepare_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:hw_sgl_prepare:1.0 hw_sgl_prepare_0 ]
  set_property -dict [ list CONFIG.START_ADDRESS {0x44000000}  ] $hw_sgl_prepare_0

  # Create instance: hw_sgl_prepare_1, and set properties
  set hw_sgl_prepare_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:hw_sgl_prepare:1.0 hw_sgl_prepare_1 ]
  set_property -dict [ list CONFIG.START_ADDRESS {0x45000000}  ] $hw_sgl_prepare_1

  # Create instance: hw_sgl_submit
  create_hier_cell_hw_sgl_submit [current_bd_instance .] hw_sgl_submit

  # Create instance: main_interconnect_0, and set properties
  set main_interconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 main_interconnect_0 ]
  set_property -dict [ list CONFIG.ENABLE_ADVANCED_OPTIONS {1} CONFIG.ENABLE_PROTOCOL_CHECKERS {0} CONFIG.M00_HAS_REGSLICE {1} CONFIG.M01_HAS_DATA_FIFO {1} CONFIG.M02_HAS_DATA_FIFO {1} CONFIG.NUM_MI {3} CONFIG.S00_HAS_REGSLICE {3} CONFIG.STRATEGY {2}  ] $main_interconnect_0

  # Create instance: nwl_dma_x8g2_wrapper_0, and set properties
  set nwl_dma_x8g2_wrapper_0 [ create_bd_cell -type ip -vlnv xilinx.com:user:nwl_dma_x8g2_wrapper:1.0 nwl_dma_x8g2_wrapper_0 ]

  # Create instance: pcie3_ultrascale_0, and set properties
  set pcie3_ultrascale_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:pcie3_ultrascale:3.1 pcie3_ultrascale_0 ]
  set_property -dict [ list CONFIG.PF0_DEVICE_ID {8082} CONFIG.PF0_MSIX_CAP_PBA_BIR {BAR_1:0} CONFIG.PF0_MSIX_CAP_PBA_OFFSET {00003000} CONFIG.PF0_MSIX_CAP_TABLE_BIR {BAR_1:0} CONFIG.PF0_MSIX_CAP_TABLE_OFFSET {00002000} CONFIG.PF0_MSIX_CAP_TABLE_SIZE {003} CONFIG.PF1_DEVICE_ID {8011} CONFIG.PL_LINK_CAP_MAX_LINK_SPEED {5.0_GT/s} CONFIG.PL_LINK_CAP_MAX_LINK_WIDTH {X8} CONFIG.axisten_freq {250} CONFIG.axisten_if_width {128_bit} CONFIG.cfg_ext_if {false} CONFIG.cfg_tx_msg_if {false} CONFIG.dedicate_perst {false} CONFIG.mode_selection {Advanced} CONFIG.per_func_status_if {false} CONFIG.pf0_bar0_64bit {true} CONFIG.pf0_bar0_scale {Megabytes} CONFIG.pf0_bar0_size {1} CONFIG.pf0_bar2_64bit {true} CONFIG.pf0_bar2_enabled {true} CONFIG.pf0_bar2_scale {Megabytes} CONFIG.pf0_bar2_size {1} CONFIG.pf0_bar2_type {Memory} CONFIG.pf0_bar4_64bit {true} CONFIG.pf0_bar4_enabled {true} CONFIG.pf0_bar4_scale {Megabytes} CONFIG.pf0_bar4_size {1} CONFIG.pf0_bar4_type {Memory} CONFIG.pf0_msix_enabled {true} CONFIG.pipe_sim {true} CONFIG.rcv_msg_if {false} CONFIG.tx_fc_if {false}  ] $pcie3_ultrascale_0

  # Create instance: pcie_mon_gen3_128bit_0, and set properties
  set pcie_mon_gen3_128bit_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:pcie_mon_gen3_128bit:1.0 pcie_mon_gen3_128bit_0 ]

  # Create instance: pvtmon_axi_slave_0, and set properties
  set pvtmon_axi_slave_0 [ create_bd_cell -type ip -vlnv xilinx.com:user:pvtmon_axi_slave:1.0 pvtmon_axi_slave_0 ]

  # Create instance: reset_top
  create_hier_cell_reset_top [current_bd_instance .] reset_top

  # Create instance: user_axilite_control_0, and set properties
  set user_axilite_control_0 [ create_bd_cell -type ip -vlnv xilinx.com:user:user_axilite_control:1.0 user_axilite_control_0 ]

  # Create interface connections
  connect_bd_intf_net -intf_net S00_AXI_1 [get_bd_intf_pins main_interconnect_0/S00_AXI] [get_bd_intf_pins nwl_dma_x8g2_wrapper_0/m]
  set_property -dict [ list HDL_ATTRIBUTE.MARK_DEBUG {true}  ] [get_bd_intf_nets S00_AXI_1]
  connect_bd_intf_net -intf_net axi_interconnect_0_M00_AXI [get_bd_intf_pins axi_lite_interconnect_1/S00_AXI] [get_bd_intf_pins main_interconnect_0/M00_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M01_AXI [get_bd_intf_pins hw_sgl_prepare_0/m] [get_bd_intf_pins main_interconnect_0/M01_AXI]
  set_property -dict [ list HDL_ATTRIBUTE.MARK_DEBUG {true}  ] [get_bd_intf_nets axi_interconnect_0_M01_AXI]
  connect_bd_intf_net -intf_net axi_lite_interconnect_1_M00_AXI [get_bd_intf_pins axi_lite_interconnect_1/M00_AXI] [get_bd_intf_pins axi_perf_mon_1/S_AXI]
  connect_bd_intf_net -intf_net axi_lite_interconnect_1_M01_AXI [get_bd_intf_pins axi_lite_interconnect_1/M01_AXI] [get_bd_intf_pins user_axilite_control_0/s_axi]
  connect_bd_intf_net -intf_net axi_lite_interconnect_1_M02_AXI [get_bd_intf_pins axi_lite_interconnect_1/M02_AXI] [get_bd_intf_pins eth_pipe_0/s_axi]
  connect_bd_intf_net -intf_net axi_lite_interconnect_1_M04_AXI [get_bd_intf_pins axi_lite_interconnect_1/M04_AXI] [get_bd_intf_pins pvtmon_axi_slave_0/s_axi]
  connect_bd_intf_net -intf_net eth_pipe_0_c2s_dre_m_axis [get_bd_intf_pins eth_pipe_0/c2s_dre_m_axis] [get_bd_intf_pins hw_sgl_prepare_0/axi_stream_c2s]
connect_bd_intf_net -intf_net eth_pipe_0_c2s_dre_m_axis [get_bd_intf_pins axi_perf_mon_1/SLOT_1_AXIS] [get_bd_intf_pins hw_sgl_prepare_0/axi_stream_c2s]
  set_property -dict [ list HDL_ATTRIBUTE.MARK_DEBUG {true}  ] [get_bd_intf_nets eth_pipe_0_c2s_dre_m_axis]
  connect_bd_intf_net -intf_net eth_pipe_1_c2s_dre_m_axis [get_bd_intf_pins eth_pipe_1/c2s_dre_m_axis] [get_bd_intf_pins hw_sgl_prepare_1/axi_stream_c2s]
connect_bd_intf_net -intf_net eth_pipe_1_c2s_dre_m_axis [get_bd_intf_pins axi_perf_mon_1/SLOT_3_AXIS] [get_bd_intf_pins hw_sgl_prepare_1/axi_stream_c2s]
  set_property -dict [ list HDL_ATTRIBUTE.MARK_DEBUG {true}  ] [get_bd_intf_nets eth_pipe_1_c2s_dre_m_axis]
  connect_bd_intf_net -intf_net hw_sgl_prepare_0_axi_stream_s2c [get_bd_intf_pins eth_pipe_0/s2c_dre_s_axis] [get_bd_intf_pins hw_sgl_prepare_0/axi_stream_s2c]
connect_bd_intf_net -intf_net hw_sgl_prepare_0_axi_stream_s2c [get_bd_intf_pins axi_perf_mon_1/SLOT_0_AXIS] [get_bd_intf_pins hw_sgl_prepare_0/axi_stream_s2c]
  set_property -dict [ list HDL_ATTRIBUTE.MARK_DEBUG {true}  ] [get_bd_intf_nets hw_sgl_prepare_0_axi_stream_s2c]
  connect_bd_intf_net -intf_net hw_sgl_prepare_1_axi_stream_s2c [get_bd_intf_pins eth_pipe_1/s2c_dre_s_axis] [get_bd_intf_pins hw_sgl_prepare_1/axi_stream_s2c]
connect_bd_intf_net -intf_net hw_sgl_prepare_1_axi_stream_s2c [get_bd_intf_pins axi_perf_mon_1/SLOT_2_AXIS] [get_bd_intf_pins hw_sgl_prepare_1/axi_stream_s2c]
  set_property -dict [ list HDL_ATTRIBUTE.MARK_DEBUG {true}  ] [get_bd_intf_nets hw_sgl_prepare_1_axi_stream_s2c]
  connect_bd_intf_net -intf_net main_interconnect_0_M02_AXI [get_bd_intf_pins hw_sgl_prepare_1/m] [get_bd_intf_pins main_interconnect_0/M02_AXI]
  set_property -dict [ list HDL_ATTRIBUTE.MARK_DEBUG {true}  ] [get_bd_intf_nets main_interconnect_0_M02_AXI]
  connect_bd_intf_net -intf_net nwl_dma_x8g2_wrapper_0_cfg_ctrl [get_bd_intf_pins nwl_dma_x8g2_wrapper_0/cfg_ctrl] [get_bd_intf_pins pcie3_ultrascale_0/pcie3_cfg_control]
  connect_bd_intf_net -intf_net nwl_dma_x8g2_wrapper_0_cfg_intr [get_bd_intf_pins nwl_dma_x8g2_wrapper_0/cfg_intr] [get_bd_intf_pins pcie3_ultrascale_0/pcie3_cfg_interrupt]
  connect_bd_intf_net -intf_net nwl_dma_x8g2_wrapper_0_cfg_mgmt [get_bd_intf_pins nwl_dma_x8g2_wrapper_0/cfg_mgmt] [get_bd_intf_pins pcie3_ultrascale_0/pcie_cfg_mgmt]
  connect_bd_intf_net -intf_net nwl_dma_x8g2_wrapper_0_cfg_msi [get_bd_intf_pins nwl_dma_x8g2_wrapper_0/cfg_msi] [get_bd_intf_pins pcie3_ultrascale_0/pcie3_cfg_msi]
  connect_bd_intf_net -intf_net nwl_dma_x8g2_wrapper_0_cfg_msix [get_bd_intf_pins nwl_dma_x8g2_wrapper_0/cfg_msix] [get_bd_intf_pins pcie3_ultrascale_0/pcie3_cfg_msix]
  connect_bd_intf_net -intf_net nwl_dma_x8g2_wrapper_0_s_axis_cc [get_bd_intf_pins nwl_dma_x8g2_wrapper_0/s_axis_cc] [get_bd_intf_pins pcie3_ultrascale_0/s_axis_cc]
connect_bd_intf_net -intf_net nwl_dma_x8g2_wrapper_0_s_axis_cc [get_bd_intf_pins nwl_dma_x8g2_wrapper_0/s_axis_cc] [get_bd_intf_pins pcie_mon_gen3_128bit_0/s_axis_cc]
  connect_bd_intf_net -intf_net nwl_dma_x8g2_wrapper_0_s_axis_rq [get_bd_intf_pins nwl_dma_x8g2_wrapper_0/s_axis_rq] [get_bd_intf_pins pcie3_ultrascale_0/s_axis_rq]
connect_bd_intf_net -intf_net nwl_dma_x8g2_wrapper_0_s_axis_rq [get_bd_intf_pins nwl_dma_x8g2_wrapper_0/s_axis_rq] [get_bd_intf_pins pcie_mon_gen3_128bit_0/s_axis_rq]
  connect_bd_intf_net -intf_net pcie3_ultrascale_0_m_axis_cq [get_bd_intf_pins nwl_dma_x8g2_wrapper_0/m_axis_cq] [get_bd_intf_pins pcie3_ultrascale_0/m_axis_cq]
connect_bd_intf_net -intf_net pcie3_ultrascale_0_m_axis_cq [get_bd_intf_pins nwl_dma_x8g2_wrapper_0/m_axis_cq] [get_bd_intf_pins pcie_mon_gen3_128bit_0/m_axis_cq]
  connect_bd_intf_net -intf_net pcie3_ultrascale_0_m_axis_rc [get_bd_intf_pins nwl_dma_x8g2_wrapper_0/m_axis_rc] [get_bd_intf_pins pcie3_ultrascale_0/m_axis_rc]
connect_bd_intf_net -intf_net pcie3_ultrascale_0_m_axis_rc [get_bd_intf_pins nwl_dma_x8g2_wrapper_0/m_axis_rc] [get_bd_intf_pins pcie_mon_gen3_128bit_0/m_axis_rc]
  connect_bd_intf_net -intf_net pcie3_ultrascale_0_pcie3_ext_pipe_interface [get_bd_intf_ports pcie3_ext_pipe_interface] [get_bd_intf_pins pcie3_ultrascale_0/pcie3_ext_pipe_interface]
  connect_bd_intf_net -intf_net pcie3_ultrascale_1_pcie3_cfg_status [get_bd_intf_pins nwl_dma_x8g2_wrapper_0/cfg_status] [get_bd_intf_pins pcie3_ultrascale_0/pcie3_cfg_status]
  connect_bd_intf_net -intf_net pcie3_ultrascale_1_pcie_7x_mgt [get_bd_intf_ports pcie_7x_mgt] [get_bd_intf_pins pcie3_ultrascale_0/pcie_7x_mgt]
  connect_bd_intf_net -intf_net pcie3_ultrascale_1_pcie_cfg_fc [get_bd_intf_pins pcie3_ultrascale_0/pcie_cfg_fc] [get_bd_intf_pins pcie_mon_gen3_128bit_0/fc]
  connect_bd_intf_net -intf_net pcie_mon_gen3_128bit_0_init_fc [get_bd_intf_pins pcie_mon_gen3_128bit_0/init_fc] [get_bd_intf_pins user_axilite_control_0/init_fc]
  connect_bd_intf_net -intf_net refclk_diff_port_1 [get_bd_intf_ports refclk_diff_port] [get_bd_intf_pins eth_pipe_0/refclk_diff_port]
  connect_bd_intf_net -intf_net s_axi_1 [get_bd_intf_pins axi_lite_interconnect_1/M03_AXI] [get_bd_intf_pins eth_pipe_1/s_axi]
  connect_bd_intf_net -intf_net s_axis_pause_1 [get_bd_intf_ports s_axis_pause_0] [get_bd_intf_pins eth_pipe_0/s_axis_pause]
  connect_bd_intf_net -intf_net s_axis_pause_2 [get_bd_intf_ports s_axis_pause_1] [get_bd_intf_pins eth_pipe_1/s_axis_pause]

  # Create port connections
  connect_bd_net -net M00_ACLK_1 [get_bd_pins axi_lite_interconnect_1/M02_ACLK] [get_bd_pins axi_lite_interconnect_1/M03_ACLK] [get_bd_pins eth_pipe_0/clk_156] [get_bd_pins eth_pipe_1/clk_156]
  connect_bd_net -net M00_ARESETN_1 [get_bd_pins axi_lite_interconnect_1/M02_ARESETN] [get_bd_pins axi_lite_interconnect_1/M03_ARESETN] [get_bd_pins eth_pipe_0/clk_156_resetn]
  connect_bd_net -net M01_ARESETN_1 [get_bd_pins axi_lite_interconnect_1/ARESETN] [get_bd_pins axi_lite_interconnect_1/M00_ARESETN] [get_bd_pins axi_lite_interconnect_1/M01_ARESETN] [get_bd_pins axi_lite_interconnect_1/M04_ARESETN] [get_bd_pins axi_lite_interconnect_1/S00_ARESETN] [get_bd_pins axi_perf_mon_1/core_aresetn] [get_bd_pins axi_perf_mon_1/s_axi_aresetn] [get_bd_pins axi_perf_mon_1/slot_0_axis_aresetn] [get_bd_pins axi_perf_mon_1/slot_1_axis_aresetn] [get_bd_pins axi_perf_mon_1/slot_2_axis_aresetn] [get_bd_pins axi_perf_mon_1/slot_3_axis_aresetn] [get_bd_pins eth_pipe_0/user_resetn] [get_bd_pins eth_pipe_1/user_resetn] [get_bd_pins hw_sgl_prepare_0/nRESET] [get_bd_pins hw_sgl_prepare_1/nRESET] [get_bd_pins hw_sgl_submit/nRESET] [get_bd_pins main_interconnect_0/ARESETN] [get_bd_pins main_interconnect_0/M00_ARESETN] [get_bd_pins main_interconnect_0/M01_ARESETN] [get_bd_pins main_interconnect_0/M02_ARESETN] [get_bd_pins main_interconnect_0/S00_ARESETN] [get_bd_pins nwl_dma_x8g2_wrapper_0/user_lnk_up] [get_bd_pins pvtmon_axi_slave_0/s_axi_areset_n] [get_bd_pins reset_top/interconnect_aresetn] [get_bd_pins user_axilite_control_0/ddr4_calib_done] [get_bd_pins user_axilite_control_0/s_axi_areset_n]
  set_property -dict [ list HDL_ATTRIBUTE.MARK_DEBUG {true}  ] [get_bd_nets M01_ARESETN_1]
  connect_bd_net -net Net [get_bd_ports pmbus_clk] [get_bd_pins pvtmon_axi_slave_0/pmbus_clk]
  connect_bd_net -net Net1 [get_bd_ports pmbus_data] [get_bd_pins pvtmon_axi_slave_0/pmbus_data]
  connect_bd_net -net areset_clk156_1 [get_bd_pins eth_pipe_0/clk_156_reset] [get_bd_pins eth_pipe_1/areset_clk156]
  connect_bd_net -net ch_reset_0_Dout [get_bd_pins ch_reset_0/Dout] [get_bd_pins hw_sgl_prepare_0/s2c_channel_reset]
  connect_bd_net -net ch_reset_1_Dout [get_bd_pins ch_reset_1/Dout] [get_bd_pins hw_sgl_prepare_0/c2s_channel_reset]
  connect_bd_net -net ch_reset_2_Dout [get_bd_pins ch_reset_2/Dout] [get_bd_pins hw_sgl_prepare_1/s2c_channel_reset]
  connect_bd_net -net ch_reset_3_Dout [get_bd_pins ch_reset_3/Dout] [get_bd_pins hw_sgl_prepare_1/c2s_channel_reset]
  connect_bd_net -net clk125_in_1 [get_bd_ports clk125_in] [get_bd_pins pvtmon_axi_slave_0/clk125_in]
  connect_bd_net -net eth_pipe_0_core_status [get_bd_ports core_status_0] [get_bd_pins eth_pipe_0/core_status] [get_bd_pins user_axilite_control_0/phy_0_status]
  connect_bd_net -net eth_pipe_0_gtrxreset_out [get_bd_pins eth_pipe_0/gtrxreset_out] [get_bd_pins eth_pipe_1/gtrxreset]
  connect_bd_net -net eth_pipe_0_gttxreset_out [get_bd_pins eth_pipe_0/gttxreset_out] [get_bd_pins eth_pipe_1/gttxreset]
  connect_bd_net -net eth_pipe_0_qpll0lock_out [get_bd_pins eth_pipe_0/qpll0lock_out] [get_bd_pins eth_pipe_1/qpll0lock]
  connect_bd_net -net eth_pipe_0_qpll0outclk_out [get_bd_pins eth_pipe_0/qpll0outclk_out] [get_bd_pins eth_pipe_1/qpll0outclk]
  connect_bd_net -net eth_pipe_0_qpll0outrefclk_out [get_bd_pins eth_pipe_0/qpll0outrefclk_out] [get_bd_pins eth_pipe_1/qpll0outrefclk]
  connect_bd_net -net eth_pipe_0_reset_counter_done_out [get_bd_pins eth_pipe_0/reset_counter_done_out] [get_bd_pins eth_pipe_1/reset_counter_done]
  connect_bd_net -net eth_pipe_0_resetdone [get_bd_ports resetdone_0] [get_bd_pins eth_pipe_0/resetdone]
  connect_bd_net -net eth_pipe_0_tx_disable [get_bd_ports tx_disable_0] [get_bd_pins eth_pipe_0/tx_disable]
  connect_bd_net -net eth_pipe_0_txn [get_bd_ports txn_0] [get_bd_pins eth_pipe_0/txn]
  connect_bd_net -net eth_pipe_0_txp [get_bd_ports txp_0] [get_bd_pins eth_pipe_0/txp]
  connect_bd_net -net eth_pipe_0_txuserrdy_out [get_bd_pins eth_pipe_0/txuserrdy_out] [get_bd_pins eth_pipe_1/txuserrdy]
  connect_bd_net -net eth_pipe_0_txusrclk2_out [get_bd_pins eth_pipe_0/txusrclk2_out] [get_bd_pins eth_pipe_1/txusrclk2]
  connect_bd_net -net eth_pipe_0_txusrclk_out [get_bd_pins eth_pipe_0/txusrclk_out] [get_bd_pins eth_pipe_1/txusrclk]
  connect_bd_net -net eth_pipe_1_core_status [get_bd_ports core_status_1] [get_bd_pins eth_pipe_1/core_status] [get_bd_pins user_axilite_control_0/phy_1_status]
  connect_bd_net -net eth_pipe_1_rx_resetdone [get_bd_ports rx_resetdone_1] [get_bd_pins eth_pipe_1/rx_resetdone]
  connect_bd_net -net eth_pipe_1_tx_disable [get_bd_ports tx_disable_1] [get_bd_pins eth_pipe_1/tx_disable]
  connect_bd_net -net eth_pipe_1_tx_resetdone [get_bd_ports tx_resetdone_1] [get_bd_pins eth_pipe_1/tx_resetdone]
  connect_bd_net -net eth_pipe_1_txn [get_bd_ports txn_1] [get_bd_pins eth_pipe_1/txn]
  connect_bd_net -net eth_pipe_1_txp [get_bd_ports txp_1] [get_bd_pins eth_pipe_1/txp]
  connect_bd_net -net hw_sgl_prepare_0_sgl_available [get_bd_pins hw_sgl_prepare_0/sgl_available] [get_bd_pins hw_sgl_submit/sgl_available_0_1]
  connect_bd_net -net hw_sgl_prepare_0_sgl_data [get_bd_pins hw_sgl_prepare_0/sgl_data] [get_bd_pins hw_sgl_submit/sgl_data_0_1]
  connect_bd_net -net hw_sgl_prepare_1_sgl_available [get_bd_pins hw_sgl_prepare_1/sgl_available] [get_bd_pins hw_sgl_submit/sgl_available_2_3]
  connect_bd_net -net hw_sgl_prepare_1_sgl_data [get_bd_pins hw_sgl_prepare_1/sgl_data] [get_bd_pins hw_sgl_submit/sgl_data_2_3]
  connect_bd_net -net hw_sgl_submit_Dout [get_bd_pins hw_sgl_prepare_0/sgl_done] [get_bd_pins hw_sgl_submit/sgl_done_1_0]
  connect_bd_net -net hw_sgl_submit_Dout1 [get_bd_pins hw_sgl_prepare_1/sgl_done] [get_bd_pins hw_sgl_submit/sgl_done_3_2]
  connect_bd_net -net hw_sgl_submit_sgl_alloc_channel [get_bd_pins hw_sgl_submit/sgl_alloc_channel] [get_bd_pins nwl_dma_x8g2_wrapper_0/sgl_alloc_channel]
  set_property -dict [ list HDL_ATTRIBUTE.MARK_DEBUG {true}  ] [get_bd_nets hw_sgl_submit_sgl_alloc_channel]
  connect_bd_net -net hw_sgl_submit_sgl_alloc_dst_src_n [get_bd_pins hw_sgl_submit/sgl_alloc_dst_src_n] [get_bd_pins nwl_dma_x8g2_wrapper_0/sgl_alloc_dst_src_n]
  set_property -dict [ list HDL_ATTRIBUTE.MARK_DEBUG {true}  ] [get_bd_nets hw_sgl_submit_sgl_alloc_dst_src_n]
  connect_bd_net -net hw_sgl_submit_sgl_alloc_num_sgl [get_bd_pins hw_sgl_submit/sgl_alloc_num_sgl] [get_bd_pins nwl_dma_x8g2_wrapper_0/sgl_alloc_num_sgl]
  set_property -dict [ list HDL_ATTRIBUTE.MARK_DEBUG {true}  ] [get_bd_nets hw_sgl_submit_sgl_alloc_num_sgl]
  connect_bd_net -net hw_sgl_submit_sgl_alloc_valid [get_bd_pins hw_sgl_submit/sgl_alloc_valid] [get_bd_pins nwl_dma_x8g2_wrapper_0/sgl_alloc_valid]
  set_property -dict [ list HDL_ATTRIBUTE.MARK_DEBUG {true}  ] [get_bd_nets hw_sgl_submit_sgl_alloc_valid]
  connect_bd_net -net hw_sgl_submit_sgl_error_1_0 [get_bd_pins hw_sgl_prepare_0/sgl_error] [get_bd_pins hw_sgl_submit/sgl_error_1_0]
  connect_bd_net -net hw_sgl_submit_sgl_error_3_2 [get_bd_pins hw_sgl_prepare_1/sgl_error] [get_bd_pins hw_sgl_submit/sgl_error_3_2]
  connect_bd_net -net hw_sgl_submit_sgl_wr_channel [get_bd_pins hw_sgl_submit/sgl_wr_channel] [get_bd_pins nwl_dma_x8g2_wrapper_0/sgl_wr_channel]
  set_property -dict [ list HDL_ATTRIBUTE.MARK_DEBUG {true}  ] [get_bd_nets hw_sgl_submit_sgl_wr_channel]
  connect_bd_net -net hw_sgl_submit_sgl_wr_data [get_bd_pins hw_sgl_submit/sgl_wr_data] [get_bd_pins nwl_dma_x8g2_wrapper_0/sgl_wr_data]
  set_property -dict [ list HDL_ATTRIBUTE.MARK_DEBUG {true}  ] [get_bd_nets hw_sgl_submit_sgl_wr_data]
  connect_bd_net -net hw_sgl_submit_sgl_wr_dst_src_n [get_bd_pins hw_sgl_submit/sgl_wr_dst_src_n] [get_bd_pins nwl_dma_x8g2_wrapper_0/sgl_wr_dst_src_n]
  set_property -dict [ list HDL_ATTRIBUTE.MARK_DEBUG {true}  ] [get_bd_nets hw_sgl_submit_sgl_wr_dst_src_n]
  connect_bd_net -net hw_sgl_submit_sgl_wr_valid [get_bd_pins hw_sgl_submit/sgl_wr_valid] [get_bd_pins nwl_dma_x8g2_wrapper_0/sgl_wr_valid]
  set_property -dict [ list HDL_ATTRIBUTE.MARK_DEBUG {true}  ] [get_bd_nets hw_sgl_submit_sgl_wr_valid]
  connect_bd_net -net nwl_dma_x8g2_wrapper_0_sgl_alloc_dst_aready [get_bd_pins hw_sgl_submit/sgl_alloc_dst_aready] [get_bd_pins nwl_dma_x8g2_wrapper_0/sgl_alloc_dst_aready]
  set_property -dict [ list HDL_ATTRIBUTE.MARK_DEBUG {true}  ] [get_bd_nets nwl_dma_x8g2_wrapper_0_sgl_alloc_dst_aready]
  connect_bd_net -net nwl_dma_x8g2_wrapper_0_sgl_alloc_dst_empty [get_bd_pins hw_sgl_submit/sgl_alloc_dst_empty] [get_bd_pins nwl_dma_x8g2_wrapper_0/sgl_alloc_dst_empty]
  set_property -dict [ list HDL_ATTRIBUTE.MARK_DEBUG {true}  ] [get_bd_nets nwl_dma_x8g2_wrapper_0_sgl_alloc_dst_empty]
  connect_bd_net -net nwl_dma_x8g2_wrapper_0_sgl_alloc_dst_full [get_bd_pins hw_sgl_submit/sgl_alloc_dst_full] [get_bd_pins nwl_dma_x8g2_wrapper_0/sgl_alloc_dst_full]
  set_property -dict [ list HDL_ATTRIBUTE.MARK_DEBUG {true}  ] [get_bd_nets nwl_dma_x8g2_wrapper_0_sgl_alloc_dst_full]
  connect_bd_net -net nwl_dma_x8g2_wrapper_0_sgl_alloc_ready [get_bd_pins hw_sgl_submit/sgl_alloc_ready] [get_bd_pins nwl_dma_x8g2_wrapper_0/sgl_alloc_ready]
  set_property -dict [ list HDL_ATTRIBUTE.MARK_DEBUG {true}  ] [get_bd_nets nwl_dma_x8g2_wrapper_0_sgl_alloc_ready]
  connect_bd_net -net nwl_dma_x8g2_wrapper_0_sgl_alloc_src_aready [get_bd_pins hw_sgl_submit/sgl_alloc_src_aready] [get_bd_pins nwl_dma_x8g2_wrapper_0/sgl_alloc_src_aready]
  set_property -dict [ list HDL_ATTRIBUTE.MARK_DEBUG {true}  ] [get_bd_nets nwl_dma_x8g2_wrapper_0_sgl_alloc_src_aready]
  connect_bd_net -net nwl_dma_x8g2_wrapper_0_sgl_alloc_src_empty [get_bd_pins hw_sgl_submit/sgl_alloc_src_empty] [get_bd_pins nwl_dma_x8g2_wrapper_0/sgl_alloc_src_empty]
  set_property -dict [ list HDL_ATTRIBUTE.MARK_DEBUG {true}  ] [get_bd_nets nwl_dma_x8g2_wrapper_0_sgl_alloc_src_empty]
  connect_bd_net -net nwl_dma_x8g2_wrapper_0_sgl_alloc_src_full [get_bd_pins hw_sgl_submit/sgl_alloc_src_full] [get_bd_pins nwl_dma_x8g2_wrapper_0/sgl_alloc_src_full]
  set_property -dict [ list HDL_ATTRIBUTE.MARK_DEBUG {true}  ] [get_bd_nets nwl_dma_x8g2_wrapper_0_sgl_alloc_src_full]
  connect_bd_net -net nwl_dma_x8g2_wrapper_0_sgl_dma_ch_en [get_bd_pins hw_sgl_submit/sgl_dma_ch_en] [get_bd_pins nwl_dma_x8g2_wrapper_0/sgl_dma_ch_en]
  set_property -dict [ list HDL_ATTRIBUTE.MARK_DEBUG {true}  ] [get_bd_nets nwl_dma_x8g2_wrapper_0_sgl_dma_ch_en]
  connect_bd_net -net nwl_dma_x8g2_wrapper_0_sgl_dma_ch_reset [get_bd_pins ch_reset_0/Din] [get_bd_pins ch_reset_1/Din] [get_bd_pins ch_reset_2/Din] [get_bd_pins ch_reset_3/Din] [get_bd_pins hw_sgl_submit/sgl_dma_ch_reset] [get_bd_pins nwl_dma_x8g2_wrapper_0/sgl_dma_ch_reset]
  set_property -dict [ list HDL_ATTRIBUTE.MARK_DEBUG {true}  ] [get_bd_nets nwl_dma_x8g2_wrapper_0_sgl_dma_ch_reset]
  connect_bd_net -net nwl_dma_x8g2_wrapper_0_sgl_wr_ready [get_bd_pins hw_sgl_submit/sgl_wr_ready] [get_bd_pins nwl_dma_x8g2_wrapper_0/sgl_wr_ready]
  set_property -dict [ list HDL_ATTRIBUTE.MARK_DEBUG {true}  ] [get_bd_nets nwl_dma_x8g2_wrapper_0_sgl_wr_ready]
  connect_bd_net -net pcie3_ultrascale_0_user_reset [get_bd_pins nwl_dma_x8g2_wrapper_0/user_reset] [get_bd_pins pcie3_ultrascale_0/user_reset]
  set_property -dict [ list HDL_ATTRIBUTE.MARK_DEBUG {true}  ] [get_bd_nets pcie3_ultrascale_0_user_reset]
  connect_bd_net -net pcie3_ultrascale_1_cfg_current_speed [get_bd_ports cfg_current_speed] [get_bd_pins pcie3_ultrascale_0/cfg_current_speed]
  connect_bd_net -net pcie3_ultrascale_1_cfg_negotiated_width [get_bd_ports cfg_negotiated_width] [get_bd_pins pcie3_ultrascale_0/cfg_negotiated_width]
  connect_bd_net -net pcie_dma_wrapper_0_user_clk [get_bd_ports user_clk] [get_bd_pins axi_lite_interconnect_1/ACLK] [get_bd_pins axi_lite_interconnect_1/M00_ACLK] [get_bd_pins axi_lite_interconnect_1/M01_ACLK] [get_bd_pins axi_lite_interconnect_1/M04_ACLK] [get_bd_pins axi_lite_interconnect_1/S00_ACLK] [get_bd_pins axi_perf_mon_1/core_aclk] [get_bd_pins axi_perf_mon_1/s_axi_aclk] [get_bd_pins axi_perf_mon_1/slot_0_axis_aclk] [get_bd_pins axi_perf_mon_1/slot_1_axis_aclk] [get_bd_pins axi_perf_mon_1/slot_2_axis_aclk] [get_bd_pins axi_perf_mon_1/slot_3_axis_aclk] [get_bd_pins eth_pipe_0/user_clk] [get_bd_pins eth_pipe_1/user_clk] [get_bd_pins hw_sgl_prepare_0/aclk] [get_bd_pins hw_sgl_prepare_1/aclk] [get_bd_pins hw_sgl_submit/aclk] [get_bd_pins main_interconnect_0/ACLK] [get_bd_pins main_interconnect_0/M00_ACLK] [get_bd_pins main_interconnect_0/M01_ACLK] [get_bd_pins main_interconnect_0/M02_ACLK] [get_bd_pins main_interconnect_0/S00_ACLK] [get_bd_pins nwl_dma_x8g2_wrapper_0/user_clk] [get_bd_pins pcie3_ultrascale_0/user_clk] [get_bd_pins pcie_mon_gen3_128bit_0/clk] [get_bd_pins pvtmon_axi_slave_0/s_axi_clk] [get_bd_pins reset_top/slowest_sync_clk] [get_bd_pins user_axilite_control_0/s_axi_aclk]
  connect_bd_net -net pcie_mon_gen3_128bit_0_rx_byte_count [get_bd_pins pcie_mon_gen3_128bit_0/rx_byte_count] [get_bd_pins user_axilite_control_0/rx_pcie_bc]
  connect_bd_net -net pcie_mon_gen3_128bit_0_tx_byte_count [get_bd_pins pcie_mon_gen3_128bit_0/tx_byte_count] [get_bd_pins user_axilite_control_0/tx_pcie_bc]
  connect_bd_net -net peripheral_areset [get_bd_pins eth_pipe_0/mac_areset] [get_bd_pins eth_pipe_1/mac_areset] [get_bd_pins pcie_mon_gen3_128bit_0/reset] [get_bd_pins reset_top/interconnect_areset]
  set_property -dict [ list HDL_ATTRIBUTE.MARK_DEBUG {true}  ] [get_bd_nets peripheral_areset]
  connect_bd_net -net pmbus_alert_1 [get_bd_ports pmbus_alert] [get_bd_pins pvtmon_axi_slave_0/pmbus_alert]
  connect_bd_net -net prtad_0 [get_bd_ports prtad_0] [get_bd_pins eth_pipe_0/prtad]
  connect_bd_net -net prtad_1 [get_bd_ports prtad_1] [get_bd_pins eth_pipe_1/prtad]
  connect_bd_net -net pvtmon_axi_slave_0_muxaddr_out [get_bd_ports muxaddr_out] [get_bd_pins pvtmon_axi_slave_0/muxaddr_out]
  connect_bd_net -net pvtmon_axi_slave_0_pmbus_control [get_bd_ports pmbus_control] [get_bd_pins pvtmon_axi_slave_0/pmbus_control]
  connect_bd_net -net rxn_1 [get_bd_ports rxn_0] [get_bd_pins eth_pipe_0/rxn]
  connect_bd_net -net rxn_2 [get_bd_ports rxn_1] [get_bd_pins eth_pipe_1/rxn]
  connect_bd_net -net rxp_1 [get_bd_ports rxp_0] [get_bd_pins eth_pipe_0/rxp]
  connect_bd_net -net rxp_2 [get_bd_ports rxp_1] [get_bd_pins eth_pipe_1/rxp]
  connect_bd_net -net sim_speedup_control_0 [get_bd_ports sim_speedup_control_0] [get_bd_pins eth_pipe_0/sim_speedup_control]
  connect_bd_net -net sim_speedup_control_1 [get_bd_ports sim_speedup_control_1] [get_bd_pins eth_pipe_1/sim_speedup_control]
  connect_bd_net -net sys_clk_1 [get_bd_ports sys_clk] [get_bd_pins pcie3_ultrascale_0/sys_clk]
  connect_bd_net -net sys_clk_gt_1 [get_bd_ports sys_clk_gt] [get_bd_pins pcie3_ultrascale_0/sys_clk_gt]
  connect_bd_net -net sys_reset_1 [get_bd_ports sys_reset] [get_bd_pins pcie3_ultrascale_0/sys_reset]
  connect_bd_net -net user_axilite_control_0_clk_period [get_bd_pins pcie_mon_gen3_128bit_0/one_second_cnt] [get_bd_pins user_axilite_control_0/clk_period]
  connect_bd_net -net user_axilite_control_0_mac_id_0 [get_bd_pins eth_pipe_0/mac_id] [get_bd_pins user_axilite_control_0/mac_id_0]
  connect_bd_net -net user_axilite_control_0_mac_id_1 [get_bd_pins eth_pipe_1/mac_id] [get_bd_pins user_axilite_control_0/mac_id_1]
  connect_bd_net -net user_axilite_control_0_scaling_factor [get_bd_pins pcie_mon_gen3_128bit_0/scaling_factor] [get_bd_pins user_axilite_control_0/scaling_factor]
  connect_bd_net -net user_link_up [get_bd_ports user_linkup] [get_bd_pins pcie3_ultrascale_0/user_lnk_up] [get_bd_pins reset_top/ext_reset_in]
  set_property -dict [ list HDL_ATTRIBUTE.MARK_DEBUG {true}  ] [get_bd_nets user_link_up]
  connect_bd_net -net vauxn0_1 [get_bd_ports vauxn0] [get_bd_pins pvtmon_axi_slave_0/vauxn0]
  connect_bd_net -net vauxn2_1 [get_bd_ports vauxn2] [get_bd_pins pvtmon_axi_slave_0/vauxn2]
  connect_bd_net -net vauxn8_1 [get_bd_ports vauxn8] [get_bd_pins pvtmon_axi_slave_0/vauxn8]
  connect_bd_net -net vauxp0_1 [get_bd_ports vauxp0] [get_bd_pins pvtmon_axi_slave_0/vauxp0]
  connect_bd_net -net vauxp2_1 [get_bd_ports vauxp2] [get_bd_pins pvtmon_axi_slave_0/vauxp2]
  connect_bd_net -net vauxp8_1 [get_bd_ports vauxp8] [get_bd_pins pvtmon_axi_slave_0/vauxp8]

  # Create address segments
  create_bd_addr_seg -range 0x10000 -offset 0x44A10000 [get_bd_addr_spaces nwl_dma_x8g2_wrapper_0/m] [get_bd_addr_segs axi_perf_mon_1/S_AXI/Reg] SEG_axi_perf_mon_1_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x44000000 [get_bd_addr_spaces nwl_dma_x8g2_wrapper_0/m] [get_bd_addr_segs hw_sgl_prepare_0/m/reg0] SEG_hw_sgl_prepare_0_reg0
  create_bd_addr_seg -range 0x10000 -offset 0x45000000 [get_bd_addr_spaces nwl_dma_x8g2_wrapper_0/m] [get_bd_addr_segs hw_sgl_prepare_1/m/reg0] SEG_hw_sgl_prepare_1_reg0
  create_bd_addr_seg -range 0x1000 -offset 0x44A02000 [get_bd_addr_spaces nwl_dma_x8g2_wrapper_0/m] [get_bd_addr_segs pvtmon_axi_slave_0/s_axi/reg0] SEG_pvtmon_axi_slave_0_reg0
  create_bd_addr_seg -range 0x10000 -offset 0x44A20000 [get_bd_addr_spaces nwl_dma_x8g2_wrapper_0/m] [get_bd_addr_segs eth_pipe_0/mac_phy_ch0/ten_gig_eth_mac_ch0/s_axi/Reg] SEG_ten_gig_eth_mac_ch0_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x44A30000 [get_bd_addr_spaces nwl_dma_x8g2_wrapper_0/m] [get_bd_addr_segs eth_pipe_1/mac_phy_ch1/ten_gig_eth_mac_ch1/s_axi/Reg] SEG_ten_gig_eth_mac_ch1_Reg
  create_bd_addr_seg -range 0x1000 -offset 0x44A01000 [get_bd_addr_spaces nwl_dma_x8g2_wrapper_0/m] [get_bd_addr_segs user_axilite_control_0/s_axi/reg0] SEG_user_axilite_control_0_reg0
  

  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""

