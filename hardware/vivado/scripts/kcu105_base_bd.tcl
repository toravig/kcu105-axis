
################################################################
# This is a generated script based on design: kcu105_base
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
# source kcu105_base_script.tcl

# If you do not already have a project created,
# you can create a project using the following command:
#    create_project project_1 myproj -part xcku040-ffva1156-2-e


# CHANGE DESIGN NAME HERE
set design_name kcu105_base

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
  create_bd_pin -dir I -from 1 -to 0 sgl_available
  create_bd_pin -dir I -from 223 -to 0 sgl_data
  create_bd_pin -dir I -from 3 -to 0 sgl_dma_ch_en
  create_bd_pin -dir I -from 3 -to 0 sgl_dma_ch_reset
  create_bd_pin -dir O -from 1 -to 0 sgl_done
  create_bd_pin -dir O -from 1 -to 0 sgl_error
  create_bd_pin -dir O -from 1 -to 0 sgl_wr_channel
  create_bd_pin -dir O -from 127 -to 0 sgl_wr_data
  create_bd_pin -dir O sgl_wr_dst_src_n
  create_bd_pin -dir I sgl_wr_ready
  create_bd_pin -dir O sgl_wr_valid

  # Create instance: hw_sgl_submit_0, and set properties
  set hw_sgl_submit_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:hw_sgl_submit_2ch:1.0 hw_sgl_submit_0 ]

  # Create instance: xlconcat_0, and set properties
  set xlconcat_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_0 ]

  # Create instance: xlconcat_1, and set properties
  set xlconcat_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_1 ]

  # Create instance: xlconstant_0, and set properties
  set xlconstant_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_0 ]
  set_property -dict [ list CONFIG.CONST_VAL {0}  ] $xlconstant_0

  # Create instance: xlslice_0, and set properties
  set xlslice_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_0 ]
  set_property -dict [ list CONFIG.DIN_FROM {1} CONFIG.DIN_WIDTH {4}  ] $xlslice_0

  # Create instance: xlslice_1, and set properties
  set xlslice_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_1 ]
  set_property -dict [ list CONFIG.DIN_FROM {1} CONFIG.DIN_WIDTH {4}  ] $xlslice_1

  # Create instance: xlslice_2, and set properties
  set xlslice_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_2 ]
  set_property -dict [ list CONFIG.DIN_FROM {1} CONFIG.DIN_WIDTH {4}  ] $xlslice_2

  # Create instance: xlslice_3, and set properties
  set xlslice_3 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_3 ]
  set_property -dict [ list CONFIG.DIN_FROM {1} CONFIG.DIN_WIDTH {4}  ] $xlslice_3

  # Create instance: xlslice_4, and set properties
  set xlslice_4 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_4 ]
  set_property -dict [ list CONFIG.DIN_FROM {1} CONFIG.DIN_WIDTH {4}  ] $xlslice_4

  # Create instance: xlslice_5, and set properties
  set xlslice_5 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_5 ]
  set_property -dict [ list CONFIG.DIN_FROM {1} CONFIG.DIN_WIDTH {4}  ] $xlslice_5

  # Create instance: xlslice_6, and set properties
  set xlslice_6 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_6 ]
  set_property -dict [ list CONFIG.DIN_FROM {1} CONFIG.DIN_WIDTH {4}  ] $xlslice_6

  # Create instance: xlslice_7, and set properties
  set xlslice_7 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_7 ]
  set_property -dict [ list CONFIG.DIN_FROM {1} CONFIG.DIN_WIDTH {4}  ] $xlslice_7

  # Create port connections
  connect_bd_net -net hw_sgl_prepare_0_sgl_available [get_bd_pins sgl_available] [get_bd_pins hw_sgl_submit_0/sgl_available]
  connect_bd_net -net hw_sgl_prepare_0_sgl_data [get_bd_pins sgl_data] [get_bd_pins hw_sgl_submit_0/sgl_data]
  connect_bd_net -net hw_sgl_submit_0_sgl_alloc_channel [get_bd_pins hw_sgl_submit_0/sgl_alloc_channel] [get_bd_pins xlconcat_0/In0]
  connect_bd_net -net hw_sgl_submit_0_sgl_alloc_dst_src_n [get_bd_pins sgl_alloc_dst_src_n] [get_bd_pins hw_sgl_submit_0/sgl_alloc_dst_src_n]
  connect_bd_net -net hw_sgl_submit_0_sgl_alloc_num_sgl [get_bd_pins sgl_alloc_num_sgl] [get_bd_pins hw_sgl_submit_0/sgl_alloc_num_sgl]
  connect_bd_net -net hw_sgl_submit_0_sgl_alloc_valid [get_bd_pins sgl_alloc_valid] [get_bd_pins hw_sgl_submit_0/sgl_alloc_valid]
  connect_bd_net -net hw_sgl_submit_0_sgl_done [get_bd_pins sgl_done] [get_bd_pins hw_sgl_submit_0/sgl_done]
  connect_bd_net -net hw_sgl_submit_0_sgl_error [get_bd_pins sgl_error] [get_bd_pins hw_sgl_submit_0/sgl_error]
  connect_bd_net -net hw_sgl_submit_0_sgl_wr_channel [get_bd_pins hw_sgl_submit_0/sgl_wr_channel] [get_bd_pins xlconcat_1/In0]
  connect_bd_net -net hw_sgl_submit_0_sgl_wr_data [get_bd_pins sgl_wr_data] [get_bd_pins hw_sgl_submit_0/sgl_wr_data]
  connect_bd_net -net hw_sgl_submit_0_sgl_wr_dst_src_n [get_bd_pins sgl_wr_dst_src_n] [get_bd_pins hw_sgl_submit_0/sgl_wr_dst_src_n]
  connect_bd_net -net hw_sgl_submit_0_sgl_wr_valid [get_bd_pins sgl_wr_valid] [get_bd_pins hw_sgl_submit_0/sgl_wr_valid]
  connect_bd_net -net pcie_dma_wrapper_0_sgl_alloc_dst_aready [get_bd_pins sgl_alloc_dst_aready] [get_bd_pins xlslice_6/Din]
  connect_bd_net -net pcie_dma_wrapper_0_sgl_alloc_dst_empty [get_bd_pins sgl_alloc_dst_empty] [get_bd_pins xlslice_7/Din]
  connect_bd_net -net pcie_dma_wrapper_0_sgl_alloc_dst_full [get_bd_pins sgl_alloc_dst_full] [get_bd_pins xlslice_5/Din]
  connect_bd_net -net pcie_dma_wrapper_0_sgl_alloc_ready [get_bd_pins sgl_alloc_ready] [get_bd_pins hw_sgl_submit_0/sgl_alloc_ready]
  connect_bd_net -net pcie_dma_wrapper_0_sgl_alloc_src_aready [get_bd_pins sgl_alloc_src_aready] [get_bd_pins xlslice_3/Din]
  connect_bd_net -net pcie_dma_wrapper_0_sgl_alloc_src_empty [get_bd_pins sgl_alloc_src_empty] [get_bd_pins xlslice_4/Din]
  connect_bd_net -net pcie_dma_wrapper_0_sgl_alloc_src_full [get_bd_pins sgl_alloc_src_full] [get_bd_pins xlslice_2/Din]
  connect_bd_net -net pcie_dma_wrapper_0_sgl_dma_ch_en [get_bd_pins sgl_dma_ch_en] [get_bd_pins xlslice_0/Din]
  connect_bd_net -net pcie_dma_wrapper_0_sgl_dma_ch_reset [get_bd_pins sgl_dma_ch_reset] [get_bd_pins xlslice_1/Din]
  connect_bd_net -net pcie_dma_wrapper_0_sgl_wr_ready [get_bd_pins sgl_wr_ready] [get_bd_pins hw_sgl_submit_0/sgl_wr_ready]
  connect_bd_net -net pcie_dma_wrapper_0_user_clk [get_bd_pins aclk] [get_bd_pins hw_sgl_submit_0/aclk]
  connect_bd_net -net pcie_dma_wrapper_0_user_lnk_up [get_bd_pins nRESET] [get_bd_pins hw_sgl_submit_0/nRESET]
  connect_bd_net -net xlconcat_0_dout [get_bd_pins sgl_alloc_channel] [get_bd_pins xlconcat_0/dout]
  connect_bd_net -net xlconcat_1_dout [get_bd_pins sgl_wr_channel] [get_bd_pins xlconcat_1/dout]
  connect_bd_net -net xlconstant_0_const [get_bd_pins xlconcat_0/In1] [get_bd_pins xlconcat_1/In1] [get_bd_pins xlconstant_0/dout]
  connect_bd_net -net xlslice_0_Dout [get_bd_pins hw_sgl_submit_0/sgl_dma_ch_en] [get_bd_pins xlslice_0/Dout]
  connect_bd_net -net xlslice_1_Dout [get_bd_pins hw_sgl_submit_0/sgl_dma_ch_reset] [get_bd_pins xlslice_1/Dout]
  connect_bd_net -net xlslice_2_Dout [get_bd_pins hw_sgl_submit_0/sgl_alloc_src_full] [get_bd_pins xlslice_2/Dout]
  connect_bd_net -net xlslice_3_Dout [get_bd_pins hw_sgl_submit_0/sgl_alloc_src_aready] [get_bd_pins xlslice_3/Dout]
  connect_bd_net -net xlslice_4_Dout [get_bd_pins hw_sgl_submit_0/sgl_alloc_src_empty] [get_bd_pins xlslice_4/Dout]
  connect_bd_net -net xlslice_5_Dout [get_bd_pins hw_sgl_submit_0/sgl_alloc_dst_full] [get_bd_pins xlslice_5/Dout]
  connect_bd_net -net xlslice_6_Dout [get_bd_pins hw_sgl_submit_0/sgl_alloc_dst_aready] [get_bd_pins xlslice_6/Dout]
  connect_bd_net -net xlslice_7_Dout [get_bd_pins hw_sgl_submit_0/sgl_alloc_dst_empty] [get_bd_pins xlslice_7/Dout]
  
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

  # Create ports
  set cfg_current_speed [ create_bd_port -dir O -from 2 -to 0 cfg_current_speed ]
  set cfg_negotiated_width [ create_bd_port -dir O -from 3 -to 0 cfg_negotiated_width ]
  set clk125_in [ create_bd_port -dir I clk125_in ]
  set muxaddr_out [ create_bd_port -dir O -from 2 -to 0 muxaddr_out ]
  set pmbus_alert [ create_bd_port -dir I pmbus_alert ]
  set pmbus_clk [ create_bd_port -dir IO pmbus_clk ]
  set pmbus_control [ create_bd_port -dir O pmbus_control ]
  set pmbus_data [ create_bd_port -dir IO pmbus_data ]
  set sys_clk [ create_bd_port -dir I -type clk sys_clk ]
  set sys_clk_gt [ create_bd_port -dir I -type clk sys_clk_gt ]
  set sys_reset [ create_bd_port -dir I -type rst sys_reset ]
  set_property -dict [ list CONFIG.POLARITY {ACTIVE_LOW}  ] $sys_reset
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
  set_property -dict [ list CONFIG.M00_HAS_REGSLICE {1} CONFIG.M01_HAS_REGSLICE {1} CONFIG.M02_HAS_REGSLICE {1} CONFIG.M03_HAS_REGSLICE {1} CONFIG.NUM_MI {4} CONFIG.S00_HAS_REGSLICE {3}  ] $axi_lite_interconnect_1

  # Create instance: axi_perf_mon_0, and set properties
  set axi_perf_mon_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_perf_mon:5.0 axi_perf_mon_0 ]
  set_property -dict [ list CONFIG.C_METRIC_COUNT_SCALE {1} CONFIG.C_NUM_MONITOR_SLOTS {2} CONFIG.C_NUM_OF_COUNTERS {2} CONFIG.C_SLOT_0_AXI_PROTOCOL {AXI4S} CONFIG.C_SLOT_1_AXI_PROTOCOL {AXI4S}  ] $axi_perf_mon_0

  # Create instance: axi_stream_gen_check_0, and set properties
  set axi_stream_gen_check_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_stream_gen_check:1.0 axi_stream_gen_check_0 ]

  # Create instance: ch_0_reset, and set properties
  set ch_0_reset [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 ch_0_reset ]
  set_property -dict [ list CONFIG.DIN_WIDTH {4}  ] $ch_0_reset

  # Create instance: ch_1_reset, and set properties
  set ch_1_reset [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 ch_1_reset ]
  set_property -dict [ list CONFIG.DIN_FROM {1} CONFIG.DIN_TO {1} CONFIG.DIN_WIDTH {4}  ] $ch_1_reset

  # Create instance: hw_sgl_prepare_0, and set properties
  set hw_sgl_prepare_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:hw_sgl_prepare:1.0 hw_sgl_prepare_0 ]
  set_property -dict [ list CONFIG.START_ADDRESS {0x44000000}  ] $hw_sgl_prepare_0

  # Create instance: hw_sgl_submit
  create_hier_cell_hw_sgl_submit [current_bd_instance .] hw_sgl_submit

  # Create instance: main_interconnect_0, and set properties
  set main_interconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 main_interconnect_0 ]
  set_property -dict [ list CONFIG.ENABLE_ADVANCED_OPTIONS {1} CONFIG.ENABLE_PROTOCOL_CHECKERS {0} CONFIG.M00_HAS_REGSLICE {1} CONFIG.M01_HAS_DATA_FIFO {1} CONFIG.S00_HAS_REGSLICE {3} CONFIG.STRATEGY {2}  ] $main_interconnect_0

  # Create instance: nwl_dma_x8g2_wrapper_0, and set properties
  set nwl_dma_x8g2_wrapper_0 [ create_bd_cell -type ip -vlnv xilinx.com:user:nwl_dma_x8g2_wrapper:1.0 nwl_dma_x8g2_wrapper_0 ]
  set_property -dict [ list CONFIG.M_DATA_WIDTH {128} CONFIG.NUM_DMA_CHANNELS {4} CONFIG.P_DATA_WIDTH {128} CONFIG.S_DATA_WIDTH {128}  ] $nwl_dma_x8g2_wrapper_0

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

  # Create instance: xlconstant_0, and set properties
  set xlconstant_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_0 ]
  set_property -dict [ list CONFIG.CONST_VAL {0} CONFIG.CONST_WIDTH {8}  ] $xlconstant_0

  # Create interface connections
  connect_bd_intf_net -intf_net S00_AXI_1 [get_bd_intf_pins main_interconnect_0/S00_AXI] [get_bd_intf_pins nwl_dma_x8g2_wrapper_0/m]
  set_property -dict [ list HDL_ATTRIBUTE.MARK_DEBUG {true}  ] [get_bd_intf_nets S00_AXI_1]
  connect_bd_intf_net -intf_net axi_interconnect_0_M00_AXI [get_bd_intf_pins axi_lite_interconnect_1/S00_AXI] [get_bd_intf_pins main_interconnect_0/M00_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M01_AXI [get_bd_intf_pins hw_sgl_prepare_0/m] [get_bd_intf_pins main_interconnect_0/M01_AXI]
  set_property -dict [ list HDL_ATTRIBUTE.MARK_DEBUG {true}  ] [get_bd_intf_nets axi_interconnect_0_M01_AXI]
  connect_bd_intf_net -intf_net axi_lite_interconnect_1_M00_AXI [get_bd_intf_pins axi_lite_interconnect_1/M00_AXI] [get_bd_intf_pins user_axilite_control_0/s_axi]
  connect_bd_intf_net -intf_net axi_lite_interconnect_1_M01_AXI [get_bd_intf_pins axi_lite_interconnect_1/M01_AXI] [get_bd_intf_pins axi_stream_gen_check_0/s00_axi]
  connect_bd_intf_net -intf_net axi_lite_interconnect_1_M02_AXI [get_bd_intf_pins axi_lite_interconnect_1/M02_AXI] [get_bd_intf_pins axi_perf_mon_0/S_AXI]
  connect_bd_intf_net -intf_net axi_lite_interconnect_1_M03_AXI [get_bd_intf_pins axi_lite_interconnect_1/M03_AXI] [get_bd_intf_pins pvtmon_axi_slave_0/s_axi]
  connect_bd_intf_net -intf_net axi_stream_gen_check_0_c2s_stream [get_bd_intf_pins axi_stream_gen_check_0/c2s_stream] [get_bd_intf_pins hw_sgl_prepare_0/axi_stream_c2s]
connect_bd_intf_net -intf_net axi_stream_gen_check_0_c2s_stream [get_bd_intf_pins axi_perf_mon_0/SLOT_1_AXIS] [get_bd_intf_pins hw_sgl_prepare_0/axi_stream_c2s]
  connect_bd_intf_net -intf_net hw_sgl_prepare_0_axi_stream_s2c [get_bd_intf_pins axi_stream_gen_check_0/s2c_stream] [get_bd_intf_pins hw_sgl_prepare_0/axi_stream_s2c]
connect_bd_intf_net -intf_net hw_sgl_prepare_0_axi_stream_s2c [get_bd_intf_pins axi_perf_mon_0/SLOT_0_AXIS] [get_bd_intf_pins hw_sgl_prepare_0/axi_stream_s2c]
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
  connect_bd_intf_net -intf_net pcie3_ultrascale_0_pcie3_cfg_status [get_bd_intf_pins nwl_dma_x8g2_wrapper_0/cfg_status] [get_bd_intf_pins pcie3_ultrascale_0/pcie3_cfg_status]
  connect_bd_intf_net -intf_net pcie3_ultrascale_0_pcie3_ext_pipe_interface [get_bd_intf_ports pcie3_ext_pipe_interface] [get_bd_intf_pins pcie3_ultrascale_0/pcie3_ext_pipe_interface]
  connect_bd_intf_net -intf_net pcie3_ultrascale_0_pcie_7x_mgt [get_bd_intf_ports pcie_7x_mgt] [get_bd_intf_pins pcie3_ultrascale_0/pcie_7x_mgt]
  connect_bd_intf_net -intf_net pcie3_ultrascale_0_pcie_cfg_fc [get_bd_intf_pins pcie3_ultrascale_0/pcie_cfg_fc] [get_bd_intf_pins pcie_mon_gen3_128bit_0/fc]
  connect_bd_intf_net -intf_net pcie_mon_gen3_128bit_0_init_fc [get_bd_intf_pins pcie_mon_gen3_128bit_0/init_fc] [get_bd_intf_pins user_axilite_control_0/init_fc]

  # Create port connections
  connect_bd_net -net M01_ARESETN_1 [get_bd_pins axi_lite_interconnect_1/ARESETN] [get_bd_pins axi_lite_interconnect_1/M00_ARESETN] [get_bd_pins axi_lite_interconnect_1/M01_ARESETN] [get_bd_pins axi_lite_interconnect_1/M02_ARESETN] [get_bd_pins axi_lite_interconnect_1/M03_ARESETN] [get_bd_pins axi_lite_interconnect_1/S00_ARESETN] [get_bd_pins axi_perf_mon_0/core_aresetn] [get_bd_pins axi_perf_mon_0/s_axi_aresetn] [get_bd_pins axi_perf_mon_0/slot_0_axis_aresetn] [get_bd_pins axi_perf_mon_0/slot_1_axis_aresetn] [get_bd_pins axi_stream_gen_check_0/s00_axi_aresetn] [get_bd_pins hw_sgl_prepare_0/nRESET] [get_bd_pins hw_sgl_submit/nRESET] [get_bd_pins main_interconnect_0/ARESETN] [get_bd_pins main_interconnect_0/M00_ARESETN] [get_bd_pins main_interconnect_0/M01_ARESETN] [get_bd_pins main_interconnect_0/S00_ARESETN] [get_bd_pins nwl_dma_x8g2_wrapper_0/user_lnk_up] [get_bd_pins pvtmon_axi_slave_0/s_axi_areset_n] [get_bd_pins reset_top/interconnect_aresetn] [get_bd_pins user_axilite_control_0/ddr4_calib_done] [get_bd_pins user_axilite_control_0/s_axi_areset_n]
  set_property -dict [ list HDL_ATTRIBUTE.MARK_DEBUG {true}  ] [get_bd_nets M01_ARESETN_1]
  connect_bd_net -net Net [get_bd_ports pmbus_clk] [get_bd_pins pvtmon_axi_slave_0/pmbus_clk]
  connect_bd_net -net Net1 [get_bd_ports pmbus_data] [get_bd_pins pvtmon_axi_slave_0/pmbus_data]
  connect_bd_net -net ch_1_reset_Dout [get_bd_pins ch_1_reset/Dout] [get_bd_pins hw_sgl_prepare_0/c2s_channel_reset]
  connect_bd_net -net clk125_in_1 [get_bd_ports clk125_in] [get_bd_pins pvtmon_axi_slave_0/clk125_in]
  connect_bd_net -net hw_sgl_prepare_0_sgl_available [get_bd_pins hw_sgl_prepare_0/sgl_available] [get_bd_pins hw_sgl_submit/sgl_available]
  set_property -dict [ list HDL_ATTRIBUTE.MARK_DEBUG {true}  ] [get_bd_nets hw_sgl_prepare_0_sgl_available]
  connect_bd_net -net hw_sgl_prepare_0_sgl_data [get_bd_pins hw_sgl_prepare_0/sgl_data] [get_bd_pins hw_sgl_submit/sgl_data]
  set_property -dict [ list HDL_ATTRIBUTE.MARK_DEBUG {true}  ] [get_bd_nets hw_sgl_prepare_0_sgl_data]
  connect_bd_net -net hw_sgl_submit_0_sgl_done [get_bd_pins hw_sgl_prepare_0/sgl_done] [get_bd_pins hw_sgl_submit/sgl_done]
  set_property -dict [ list HDL_ATTRIBUTE.MARK_DEBUG {true}  ] [get_bd_nets hw_sgl_submit_0_sgl_done]
  connect_bd_net -net hw_sgl_submit_0_sgl_error [get_bd_pins hw_sgl_prepare_0/sgl_error] [get_bd_pins hw_sgl_submit/sgl_error]
  set_property -dict [ list HDL_ATTRIBUTE.MARK_DEBUG {true}  ] [get_bd_nets hw_sgl_submit_0_sgl_error]
  connect_bd_net -net hw_sgl_submit_sgl_alloc_channel [get_bd_pins hw_sgl_submit/sgl_alloc_channel] [get_bd_pins nwl_dma_x8g2_wrapper_0/sgl_alloc_channel]
  set_property -dict [ list HDL_ATTRIBUTE.MARK_DEBUG {true}  ] [get_bd_nets hw_sgl_submit_sgl_alloc_channel]
  connect_bd_net -net hw_sgl_submit_sgl_alloc_dst_src_n [get_bd_pins hw_sgl_submit/sgl_alloc_dst_src_n] [get_bd_pins nwl_dma_x8g2_wrapper_0/sgl_alloc_dst_src_n]
  set_property -dict [ list HDL_ATTRIBUTE.MARK_DEBUG {true}  ] [get_bd_nets hw_sgl_submit_sgl_alloc_dst_src_n]
  connect_bd_net -net hw_sgl_submit_sgl_alloc_num_sgl [get_bd_pins hw_sgl_submit/sgl_alloc_num_sgl] [get_bd_pins nwl_dma_x8g2_wrapper_0/sgl_alloc_num_sgl]
  set_property -dict [ list HDL_ATTRIBUTE.MARK_DEBUG {true}  ] [get_bd_nets hw_sgl_submit_sgl_alloc_num_sgl]
  connect_bd_net -net hw_sgl_submit_sgl_alloc_valid [get_bd_pins hw_sgl_submit/sgl_alloc_valid] [get_bd_pins nwl_dma_x8g2_wrapper_0/sgl_alloc_valid]
  set_property -dict [ list HDL_ATTRIBUTE.MARK_DEBUG {true}  ] [get_bd_nets hw_sgl_submit_sgl_alloc_valid]
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
  connect_bd_net -net nwl_dma_x8g2_wrapper_0_sgl_dma_ch_reset [get_bd_pins ch_0_reset/Din] [get_bd_pins ch_1_reset/Din] [get_bd_pins hw_sgl_submit/sgl_dma_ch_reset] [get_bd_pins nwl_dma_x8g2_wrapper_0/sgl_dma_ch_reset]
  set_property -dict [ list HDL_ATTRIBUTE.MARK_DEBUG {true}  ] [get_bd_nets nwl_dma_x8g2_wrapper_0_sgl_dma_ch_reset]
  connect_bd_net -net nwl_dma_x8g2_wrapper_0_sgl_wr_ready [get_bd_pins hw_sgl_submit/sgl_wr_ready] [get_bd_pins nwl_dma_x8g2_wrapper_0/sgl_wr_ready]
  set_property -dict [ list HDL_ATTRIBUTE.MARK_DEBUG {true}  ] [get_bd_nets nwl_dma_x8g2_wrapper_0_sgl_wr_ready]
  connect_bd_net -net pcie3_ultrascale_0_cfg_current_speed [get_bd_ports cfg_current_speed] [get_bd_pins pcie3_ultrascale_0/cfg_current_speed]
  connect_bd_net -net pcie3_ultrascale_0_cfg_negotiated_width [get_bd_ports cfg_negotiated_width] [get_bd_pins pcie3_ultrascale_0/cfg_negotiated_width]
  connect_bd_net -net pcie3_ultrascale_0_user_reset [get_bd_pins nwl_dma_x8g2_wrapper_0/user_reset] [get_bd_pins pcie3_ultrascale_0/user_reset]
  set_property -dict [ list HDL_ATTRIBUTE.MARK_DEBUG {true}  ] [get_bd_nets pcie3_ultrascale_0_user_reset]
  connect_bd_net -net pcie_dma_wrapper_0_user_clk [get_bd_ports user_clk] [get_bd_pins axi_lite_interconnect_1/ACLK] [get_bd_pins axi_lite_interconnect_1/M00_ACLK] [get_bd_pins axi_lite_interconnect_1/M01_ACLK] [get_bd_pins axi_lite_interconnect_1/M02_ACLK] [get_bd_pins axi_lite_interconnect_1/M03_ACLK] [get_bd_pins axi_lite_interconnect_1/S00_ACLK] [get_bd_pins axi_perf_mon_0/core_aclk] [get_bd_pins axi_perf_mon_0/s_axi_aclk] [get_bd_pins axi_perf_mon_0/slot_0_axis_aclk] [get_bd_pins axi_perf_mon_0/slot_1_axis_aclk] [get_bd_pins axi_stream_gen_check_0/s00_axi_aclk] [get_bd_pins axi_stream_gen_check_0/user_clk] [get_bd_pins hw_sgl_prepare_0/aclk] [get_bd_pins hw_sgl_submit/aclk] [get_bd_pins main_interconnect_0/ACLK] [get_bd_pins main_interconnect_0/M00_ACLK] [get_bd_pins main_interconnect_0/M01_ACLK] [get_bd_pins main_interconnect_0/S00_ACLK] [get_bd_pins nwl_dma_x8g2_wrapper_0/user_clk] [get_bd_pins pcie3_ultrascale_0/user_clk] [get_bd_pins pcie_mon_gen3_128bit_0/clk] [get_bd_pins pvtmon_axi_slave_0/s_axi_clk] [get_bd_pins reset_top/slowest_sync_clk] [get_bd_pins user_axilite_control_0/s_axi_aclk]
  connect_bd_net -net pcie_mon_gen3_128bit_0_rx_byte_count [get_bd_pins pcie_mon_gen3_128bit_0/rx_byte_count] [get_bd_pins user_axilite_control_0/rx_pcie_bc]
  connect_bd_net -net pcie_mon_gen3_128bit_0_tx_byte_count [get_bd_pins pcie_mon_gen3_128bit_0/tx_byte_count] [get_bd_pins user_axilite_control_0/tx_pcie_bc]
  connect_bd_net -net pmbus_alert_1 [get_bd_ports pmbus_alert] [get_bd_pins pvtmon_axi_slave_0/pmbus_alert]
  connect_bd_net -net pvtmon_axi_slave_0_muxaddr_out [get_bd_ports muxaddr_out] [get_bd_pins pvtmon_axi_slave_0/muxaddr_out]
  connect_bd_net -net pvtmon_axi_slave_0_pmbus_control [get_bd_ports pmbus_control] [get_bd_pins pvtmon_axi_slave_0/pmbus_control]
  connect_bd_net -net reset_top_interconnect_areset [get_bd_pins axi_stream_gen_check_0/reset] [get_bd_pins pcie_mon_gen3_128bit_0/reset] [get_bd_pins reset_top/interconnect_areset]
  connect_bd_net -net sys_clk_1 [get_bd_ports sys_clk] [get_bd_pins pcie3_ultrascale_0/sys_clk]
  connect_bd_net -net sys_clk_gt_1 [get_bd_ports sys_clk_gt] [get_bd_pins pcie3_ultrascale_0/sys_clk_gt]
  connect_bd_net -net sys_reset_1 [get_bd_ports sys_reset] [get_bd_pins pcie3_ultrascale_0/sys_reset]
  connect_bd_net -net user_axilite_control_1_clk_period [get_bd_pins pcie_mon_gen3_128bit_0/one_second_cnt] [get_bd_pins user_axilite_control_0/clk_period]
  connect_bd_net -net user_axilite_control_1_scaling_factor [get_bd_pins pcie_mon_gen3_128bit_0/scaling_factor] [get_bd_pins user_axilite_control_0/scaling_factor]
  connect_bd_net -net user_link_up [get_bd_ports user_linkup] [get_bd_pins pcie3_ultrascale_0/user_lnk_up] [get_bd_pins reset_top/ext_reset_in]
  set_property -dict [ list HDL_ATTRIBUTE.MARK_DEBUG {true}  ] [get_bd_nets user_link_up]
  connect_bd_net -net vauxn0_1 [get_bd_ports vauxn0] [get_bd_pins pvtmon_axi_slave_0/vauxn0]
  connect_bd_net -net vauxn2_1 [get_bd_ports vauxn2] [get_bd_pins pvtmon_axi_slave_0/vauxn2]
  connect_bd_net -net vauxn8_1 [get_bd_ports vauxn8] [get_bd_pins pvtmon_axi_slave_0/vauxn8]
  connect_bd_net -net vauxp0_1 [get_bd_ports vauxp0] [get_bd_pins pvtmon_axi_slave_0/vauxp0]
  connect_bd_net -net vauxp2_1 [get_bd_ports vauxp2] [get_bd_pins pvtmon_axi_slave_0/vauxp2]
  connect_bd_net -net vauxp8_1 [get_bd_ports vauxp8] [get_bd_pins pvtmon_axi_slave_0/vauxp8]
  connect_bd_net -net xlconstant_0_const [get_bd_pins user_axilite_control_0/phy_0_status] [get_bd_pins user_axilite_control_0/phy_1_status] [get_bd_pins xlconstant_0/dout]
  connect_bd_net -net xlslice_0_Dout [get_bd_pins ch_0_reset/Dout] [get_bd_pins hw_sgl_prepare_0/s2c_channel_reset]

  # Create address segments
  create_bd_addr_seg -range 0x10000 -offset 0x44A10000 [get_bd_addr_spaces nwl_dma_x8g2_wrapper_0/m] [get_bd_addr_segs axi_perf_mon_0/S_AXI/Reg] SEG_axi_perf_mon_0_Reg
  create_bd_addr_seg -range 0x1000 -offset 0x44A00000 [get_bd_addr_spaces nwl_dma_x8g2_wrapper_0/m] [get_bd_addr_segs axi_stream_gen_check_0/s00_axi/reg0] SEG_axi_stream_gen_check_0_reg0
  create_bd_addr_seg -range 0x10000 -offset 0x44000000 [get_bd_addr_spaces nwl_dma_x8g2_wrapper_0/m] [get_bd_addr_segs hw_sgl_prepare_0/m/reg0] SEG_hw_sgl_prepare_0_reg0
  create_bd_addr_seg -range 0x1000 -offset 0x44A02000 [get_bd_addr_spaces nwl_dma_x8g2_wrapper_0/m] [get_bd_addr_segs pvtmon_axi_slave_0/s_axi/reg0] SEG_pvtmon_axi_slave_0_reg0
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


