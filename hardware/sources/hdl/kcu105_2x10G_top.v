//-----------------------------------------------------------------------------
//
// (c) Copyright 2013-2014 Xilinx, Inc. All rights reserved.
//
// This file contains confidential and proprietary information of Xilinx, Inc.
// and is protected under U.S. and international copyright and other
// intellectual property laws.
//
// DISCLAIMER
//
// This disclaimer is not a license and does not grant any rights to the
// materials distributed herewith. Except as otherwise provided in a valid
// license issued to you by Xilinx, and to the maximum extent permitted by
// applicable law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND WITH ALL
// FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS,
// IMPLIED, OR STATUTORY, INCLUDING BUT NOT LIMITED TO WARRANTIES OF
// MERCHANTABILITY, NON-INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE;
// and (2) Xilinx shall not be liable (whether in contract or tort, including
// negligence, or under any other theory of liability) for any loss or damage
// of any kind or nature related to, arising under or in connection with these
// materials, including for any direct, or any indirect, special, incidental,
// or consequential loss or damage (including loss of data, profits, goodwill,
// or any type of loss or damage suffered as a result of any action brought by
// a third party) even if such damage or loss was reasonably foreseeable or
// Xilinx had been advised of the possibility of the same.
//
// CRITICAL APPLICATIONS
//
// Xilinx products are not designed or intended to be fail-safe, or for use in
// any application requiring fail-safe performance, such as life-support or
// safety devices or systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any other
// applications that could lead to death, personal injury, or severe property
// or environmental damage (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and liability of any use of
// Xilinx products in Critical Applications, subject only to applicable laws
// and regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS PART OF THIS FILE
// AT ALL TIMES.
//
//-----------------------------------------------------------------------------
// Project    : Kintex UltraScale PCIe Streaming Dataplane Reference Design
// File       : kcu105_2x10g_top.v
//
// Revision History
// ----------------
// Version       Description
//        
// EA          EA Release Vivado 2014.3
//-----------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module kcu105_2x10g_top 
   (led,
    pcie_ref_clk_n,
    pcie_ref_clk_p,
    pcie_rx_n,
    pcie_rx_p,
    pcie_tx_n,
    pcie_tx_p,
    perst_n,
`ifdef SIMULATION    
    pcie3_ext_pipe_interface_commands_in,
    pcie3_ext_pipe_interface_commands_out,
    pcie3_ext_pipe_interface_rx_0_sigs,
    pcie3_ext_pipe_interface_rx_1_sigs,
    pcie3_ext_pipe_interface_rx_2_sigs,
    pcie3_ext_pipe_interface_rx_3_sigs,
    pcie3_ext_pipe_interface_rx_4_sigs,
    pcie3_ext_pipe_interface_rx_5_sigs,
    pcie3_ext_pipe_interface_rx_6_sigs,
    pcie3_ext_pipe_interface_rx_7_sigs,
    pcie3_ext_pipe_interface_tx_0_sigs,
    pcie3_ext_pipe_interface_tx_1_sigs,
    pcie3_ext_pipe_interface_tx_2_sigs,
    pcie3_ext_pipe_interface_tx_3_sigs,
    pcie3_ext_pipe_interface_tx_4_sigs,
    pcie3_ext_pipe_interface_tx_5_sigs,
    pcie3_ext_pipe_interface_tx_6_sigs,
    pcie3_ext_pipe_interface_tx_7_sigs,
`endif    
    clk125_in,
    muxaddr_out,
    pmbus_alert,
    pmbus_clk,
    pmbus_data,
    vauxn0,
    vauxn2,
    vauxn8,
    vauxp0,
    vauxp2,
    vauxp8,    
    refclk_p,
    refclk_n,
    xphy_txp,
    xphy_txn,
    xphy_rxp,
    xphy_rxn,
    tx_disable
    );
  output  [6:0]                  led; 
  input                          pcie_ref_clk_n;
  input                          pcie_ref_clk_p;
  input   [7:0]                  pcie_rx_n;
  input   [7:0]                  pcie_rx_p;
  output  [7:0]                  pcie_tx_n;
  output  [7:0]                  pcie_tx_p;
  input                          perst_n;
  input                          clk125_in;
  output  [2:0]                  muxaddr_out;
  input                          pmbus_alert;
  inout                          pmbus_clk;
  inout                          pmbus_data;
  input                          vauxn0;
  input                          vauxn2;
  input                          vauxn8;
  input                          vauxp0;
  input                          vauxp2;
  input                          vauxp8;
  input                          refclk_p;
  input                          refclk_n;
  output  [1:0]                  xphy_txp;
  output  [1:0]                  xphy_txn;
  input   [1:0]                  xphy_rxp;
  input   [1:0]                  xphy_rxn;
  output  [1:0]                  tx_disable;
`ifdef SIMULATION  
  input   [25:0]                 pcie3_ext_pipe_interface_commands_in;
  output  [16:0]                 pcie3_ext_pipe_interface_commands_out;
  input   [83:0]                 pcie3_ext_pipe_interface_rx_0_sigs;
  input   [83:0]                 pcie3_ext_pipe_interface_rx_1_sigs;
  input   [83:0]                 pcie3_ext_pipe_interface_rx_2_sigs;
  input   [83:0]                 pcie3_ext_pipe_interface_rx_3_sigs;
  input   [83:0]                 pcie3_ext_pipe_interface_rx_4_sigs;
  input   [83:0]                 pcie3_ext_pipe_interface_rx_5_sigs;
  input   [83:0]                 pcie3_ext_pipe_interface_rx_6_sigs;
  input   [83:0]                 pcie3_ext_pipe_interface_rx_7_sigs;
  output  [69:0]                 pcie3_ext_pipe_interface_tx_0_sigs;
  output  [69:0]                 pcie3_ext_pipe_interface_tx_1_sigs;
  output  [69:0]                 pcie3_ext_pipe_interface_tx_2_sigs;
  output  [69:0]                 pcie3_ext_pipe_interface_tx_3_sigs;
  output  [69:0]                 pcie3_ext_pipe_interface_tx_4_sigs;
  output  [69:0]                 pcie3_ext_pipe_interface_tx_5_sigs;
  output  [69:0]                 pcie3_ext_pipe_interface_tx_6_sigs;
  output  [69:0]                 pcie3_ext_pipe_interface_tx_7_sigs;
`else  
  wire    [25:0]                 pcie3_ext_pipe_interface_commands_in;
  wire    [16:0]                 pcie3_ext_pipe_interface_commands_out;
  wire    [83:0]                 pcie3_ext_pipe_interface_rx_0_sigs;
  wire    [83:0]                 pcie3_ext_pipe_interface_rx_1_sigs;
  wire    [83:0]                 pcie3_ext_pipe_interface_rx_2_sigs;
  wire    [83:0]                 pcie3_ext_pipe_interface_rx_3_sigs;
  wire    [83:0]                 pcie3_ext_pipe_interface_rx_4_sigs;
  wire    [83:0]                 pcie3_ext_pipe_interface_rx_5_sigs;
  wire    [83:0]                 pcie3_ext_pipe_interface_rx_6_sigs;
  wire    [83:0]                 pcie3_ext_pipe_interface_rx_7_sigs;
  wire    [69:0]                 pcie3_ext_pipe_interface_tx_0_sigs;
  wire    [69:0]                 pcie3_ext_pipe_interface_tx_1_sigs;
  wire    [69:0]                 pcie3_ext_pipe_interface_tx_2_sigs;
  wire    [69:0]                 pcie3_ext_pipe_interface_tx_3_sigs;
  wire    [69:0]                 pcie3_ext_pipe_interface_tx_4_sigs;
  wire    [69:0]                 pcie3_ext_pipe_interface_tx_5_sigs;
  wire    [69:0]                 pcie3_ext_pipe_interface_tx_6_sigs;
  wire    [69:0]                 pcie3_ext_pipe_interface_tx_7_sigs;
`endif  

 
localparam  LED_CTR_WIDTH               = 26;   
localparam  PL_LINK_CAP_MAX_LINK_SPEED  = 2;    //4-GEN3;2-GEN2
localparam  NUM_LANES                   = 8;   
  
  wire    [6:0]                  led;
  wire                           pcie_ref_clk_n;
  wire                           pcie_ref_clk_p;
  wire    [7:0]                  pcie_rx_n;
  wire    [7:0]                  pcie_rx_p;
  wire    [7:0]                  pcie_tx_n;
  wire    [7:0]                  pcie_tx_p;
  wire                           perst_n;
  wire                           user_lnk_up;
  wire    [2:0]                  cfg_current_speed;
  wire    [3:0]                  cfg_negotiated_width;
  reg     [LED_CTR_WIDTH-1:0]    led_ctr;
  reg                            lane_width_error;
  reg                            link_speed_error;  
  wire    [7:0]                  xphy_status_ch0;
  wire    [7:0]                  xphy_status_ch1;
  wire                           resetdone_0;
  wire                           rx_resetdone_1;
  wire                           tx_resetdone_1;
  wire                           sim_speedup_control_0;
  wire                           sim_speedup_control_1;
          
IBUFDS_GTE3 refclk_ibuf (.O(sys_clk_gt), .ODIV2(sys_clk), .I(pcie_ref_clk_p), .CEB(1'b0), .IB(pcie_ref_clk_n));

// PCIe PERST# input buffer
IBUF perst_n_ibuf (.I(perst_n), .O(sys_reset));
  
        
kcu105_2x10G kcu105_2x10G_i
       (.cfg_current_speed                     (cfg_current_speed),
        .cfg_negotiated_width                  (cfg_negotiated_width),
        .core_status_0                         (xphy_status_ch0),
        .core_status_1                         (xphy_status_ch1),
        .pcie_7x_mgt_rxn                       (pcie_rx_n),
        .pcie_7x_mgt_rxp                       (pcie_rx_p),
        .pcie_7x_mgt_txn                       (pcie_tx_n),
        .pcie_7x_mgt_txp                       (pcie_tx_p),
        .prtad_0                               (5'h00),
        .prtad_1                               (5'h01),
        .refclk_diff_port_clk_n                (refclk_n),
        .refclk_diff_port_clk_p                (refclk_p),
        .resetdone_0                           (resetdone_0),
        .rx_resetdone_1                        (rx_resetdone_1),
        .rxn_0                                 (xphy_rxn[0]),
        .rxn_1                                 (xphy_rxn[1]),
        .rxp_0                                 (xphy_rxp[0]),
        .rxp_1                                 (xphy_rxp[1]),
        .sim_speedup_control_0                 (sim_speedup_control_0),
        .sim_speedup_control_1                 (sim_speedup_control_1),
        .s_axis_pause_0_tdata                  (16'b0),
        .s_axis_pause_0_tvalid                 (1'b0),
        .s_axis_pause_1_tdata                  (16'b0),
        .s_axis_pause_1_tvalid                 (1'b0),
        .sys_clk                               (sys_clk),
        .sys_clk_gt                            (sys_clk_gt),
        .sys_reset                             (sys_reset),
        .clk125_in                             (clk125_in),
        .muxaddr_out                           (muxaddr_out),
        .pmbus_alert                           (pmbus_alert),
        .pmbus_clk                             (pmbus_clk),
        .pmbus_control                         (pmbus_control),
        .pmbus_data                            (pmbus_data),
        .vauxn0                                (vauxn0),
        .vauxn2                                (vauxn2),
        .vauxn8                                (vauxn8),
        .vauxp0                                (vauxp0),
        .vauxp2                                (vauxp2),
        .vauxp8                                (vauxp8),
        .tx_disable_0                          (tx_disable[0]),
        .tx_disable_1                          (tx_disable[1]),
        .tx_resetdone_1                        (tx_resetdone_1),
        .txn_0                                 (xphy_txn[0]),
        .txn_1                                 (xphy_txn[1]),
        .txp_0                                 (xphy_txp[0]),
        .txp_1                                 (xphy_txp[1]),
  //      `ifdef SIMULATION
        .pcie3_ext_pipe_interface_commands_in  (pcie3_ext_pipe_interface_commands_in),
        .pcie3_ext_pipe_interface_commands_out (pcie3_ext_pipe_interface_commands_out),
        .pcie3_ext_pipe_interface_rx_0_sigs    (pcie3_ext_pipe_interface_rx_0_sigs),
        .pcie3_ext_pipe_interface_rx_1_sigs    (pcie3_ext_pipe_interface_rx_1_sigs),
        .pcie3_ext_pipe_interface_rx_2_sigs    (pcie3_ext_pipe_interface_rx_2_sigs),
        .pcie3_ext_pipe_interface_rx_3_sigs    (pcie3_ext_pipe_interface_rx_3_sigs),
        .pcie3_ext_pipe_interface_rx_4_sigs    (pcie3_ext_pipe_interface_rx_4_sigs),
        .pcie3_ext_pipe_interface_rx_5_sigs    (pcie3_ext_pipe_interface_rx_5_sigs),
        .pcie3_ext_pipe_interface_rx_6_sigs    (pcie3_ext_pipe_interface_rx_6_sigs),
        .pcie3_ext_pipe_interface_rx_7_sigs    (pcie3_ext_pipe_interface_rx_7_sigs),
        .pcie3_ext_pipe_interface_tx_0_sigs    (pcie3_ext_pipe_interface_tx_0_sigs),
        .pcie3_ext_pipe_interface_tx_1_sigs    (pcie3_ext_pipe_interface_tx_1_sigs),
        .pcie3_ext_pipe_interface_tx_2_sigs    (pcie3_ext_pipe_interface_tx_2_sigs),
        .pcie3_ext_pipe_interface_tx_3_sigs    (pcie3_ext_pipe_interface_tx_3_sigs),
        .pcie3_ext_pipe_interface_tx_4_sigs    (pcie3_ext_pipe_interface_tx_4_sigs),
        .pcie3_ext_pipe_interface_tx_5_sigs    (pcie3_ext_pipe_interface_tx_5_sigs),
        .pcie3_ext_pipe_interface_tx_6_sigs    (pcie3_ext_pipe_interface_tx_6_sigs),
        .pcie3_ext_pipe_interface_tx_7_sigs    (pcie3_ext_pipe_interface_tx_7_sigs), 
  //      `endif
        .user_clk                              (user_clk),
        .user_linkup                           (user_lnk_up));
        
assign led[4] = xphy_status_ch0[0];
assign led[5] = xphy_status_ch1[0];
assign led[6] = resetdone_0 & rx_resetdone_1 & tx_resetdone_1;
        
        
// LEDs - Status
// ---------------
// Heart beat LED; flashes when primary PCIe core clock is present
always @(posedge user_clk)
begin
    led_ctr <= led_ctr + {{(LED_CTR_WIDTH-1){1'b0}}, 1'b1};
end

`ifdef SIMULATION
// Initialize for simulation
initial
begin
    led_ctr = {LED_CTR_WIDTH{1'b0}};
end
`endif

always @(posedge user_clk)
begin
   lane_width_error  <= (cfg_negotiated_width != NUM_LANES); // Negotiated Link Width
   link_speed_error  <= (cfg_current_speed != PL_LINK_CAP_MAX_LINK_SPEED);
end

// led[1] lights up when PCIe core has trained
assign led[0] = user_lnk_up; 

// led[1] flashes to indicate PCIe clock is running
assign led[1] = led_ctr[LED_CTR_WIDTH-1];  // Flashes when user_clk is present

// led[2] lights up when the correct lane width is acheived
// If the link is not operating at full width, it flashes at twice the speed of the heartbeat on led[1]
assign led[2] = lane_width_error ? led_ctr[LED_CTR_WIDTH-2] : 1'b1;
assign led[3] = link_speed_error ? led_ctr[LED_CTR_WIDTH-2] : 1'b1;

// Ethernet PHY Simulation speed control
`ifdef SIMULATION
  assign sim_speedup_control_0 = user_lnk_up;
  assign sim_speedup_control_1 = user_lnk_up;
`else  
  assign sim_speedup_control_0 = 1'b1;
  assign sim_speedup_control_1 = 1'b1;
`endif


        
endmodule
