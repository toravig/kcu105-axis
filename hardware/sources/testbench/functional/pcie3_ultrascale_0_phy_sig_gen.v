//-----------------------------------------------------------------------------
//
// (c) Copyright 2012-2012 Xilinx, Inc. All rights reserved.
//
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
//
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
//
//-----------------------------------------------------------------------------
//
// Project    : Ultrascale FPGA Gen3 Integrated Block for PCI Express
// File       : pcie3_ultrascale_0_phy_sig_gen.v
// Version    : 3.0 
//-----------------------------------------------------------------------------
//-- Description: 
//--
//--
//--
//-----------------------------------------------------------------------------

`timescale 1ps/1ps

module pcie3_ultrascale_0_phy_sig_gen #
(
  parameter TCQ                        = 100,
  parameter PL_LINK_CAP_MAX_LINK_WIDTH = 8,      // 1 - x1 , 2 - x2 , 4 - x4 , 8 - x8
  parameter CLK_SHARING_EN             = "FALSE",                 // Enable Clock Sharing
  parameter PCIE_REFCLK_FREQ           = 0,                       // PCIe Reference Clock Frequency
  parameter PCIE_USERCLK1_FREQ         = 2,                       // PCIe Core Clock Frequency - Core Clock Freq
  parameter PCIE_USERCLK2_FREQ         = 2                        // PCIe User Clock Frequency - User Clock Freq
)
(
  //----------------------------------------------------------------------------------------------------------------//
  input                 sys_clk,
  input                 sys_rst_n,
  //----------------------------------------------------------------------------------------------------------------//
  output wire   [25:0]  common_commands_in_ep,
  output wire   [83:0]  pipe_rx_0_sigs_ep,
  output wire   [83:0]  pipe_rx_1_sigs_ep,
  output wire   [83:0]  pipe_rx_2_sigs_ep,
  output wire   [83:0]  pipe_rx_3_sigs_ep,
  output wire   [83:0]  pipe_rx_4_sigs_ep,
  output wire   [83:0]  pipe_rx_5_sigs_ep,
  output wire   [83:0]  pipe_rx_6_sigs_ep,
  output wire   [83:0]  pipe_rx_7_sigs_ep,

  input wire  [16:0]  common_commands_out_ep,
  input wire  [69:0]  pipe_tx_0_sigs_ep,
  input wire  [69:0]  pipe_tx_1_sigs_ep,
  input wire  [69:0]  pipe_tx_2_sigs_ep,
  input wire  [69:0]  pipe_tx_3_sigs_ep,
  input wire  [69:0]  pipe_tx_4_sigs_ep,
  input wire  [69:0]  pipe_tx_5_sigs_ep,
  input wire  [69:0]  pipe_tx_6_sigs_ep,
  input wire  [69:0]  pipe_tx_7_sigs_ep,
  //----------------------------------------------------------------------------------------------------------------//
  output wire   [25:0]  common_commands_in_rp,
  output wire   [83:0]  pipe_rx_0_sigs_rp,
  output wire   [83:0]  pipe_rx_1_sigs_rp,
  output wire   [83:0]  pipe_rx_2_sigs_rp,
  output wire   [83:0]  pipe_rx_3_sigs_rp,
  output wire   [83:0]  pipe_rx_4_sigs_rp,
  output wire   [83:0]  pipe_rx_5_sigs_rp,
  output wire   [83:0]  pipe_rx_6_sigs_rp,
  output wire   [83:0]  pipe_rx_7_sigs_rp,

  input wire  [16:0]  common_commands_out_rp,
  input wire  [69:0]  pipe_tx_0_sigs_rp,
  input wire  [69:0]  pipe_tx_1_sigs_rp,
  input wire  [69:0]  pipe_tx_2_sigs_rp,
  input wire  [69:0]  pipe_tx_3_sigs_rp,
  input wire  [69:0]  pipe_tx_4_sigs_rp,
  input wire  [69:0]  pipe_tx_5_sigs_rp,
  input wire  [69:0]  pipe_tx_6_sigs_rp,
  input wire  [69:0]  pipe_tx_7_sigs_rp
  //----------------------------------------------------------------------------------------------------------------//
);

   integer i;
   localparam   DET_IDLE          = 3'b001;
   localparam   DET_STATE1        = 3'b010;
   localparam   DET_STATE2	      = 3'b011;
   localparam   SPEED_CHANGE      = 3'b100;
   
   wire pipe_clk_ep;
   wire pipe_clk_rp;
   wire phy_rdy_ep;
   wire phy_rdy_rp;
   reg [7:0] pipe_rxsync_done_ep;
   reg [7:0] pipe_rxsync_done_rp;
   wire [(PL_LINK_CAP_MAX_LINK_WIDTH-1): 0]  pipe_pclk_sel_ep;
   wire pipe_gen3_ep;
   wire [(PL_LINK_CAP_MAX_LINK_WIDTH-1): 0]  pipe_pclk_sel_rp;
   wire pipe_gen3_rp;
  //----------------------------------------------------------------------------------------------------------------//
  //              EP
  //----------------------------------------------------------------------------------------------------------------//
   assign pipe_pclk_sel_ep = (common_commands_out_ep[2:1] == 2'b10 || common_commands_out_ep[2:1] == 2'b01) ? {PL_LINK_CAP_MAX_LINK_WIDTH{1'b1}} : {PL_LINK_CAP_MAX_LINK_WIDTH{1'b0}}; 
   assign pipe_gen3_ep     = (common_commands_out_ep[2:1] == 2'b10 ) ? 1'b1 : 1'b0 ; 
  //--------------------------------------------------------------------// 
      pcie3_ultrascale_0_phy_sig_gen_clk #
      (
          .PCIE_ASYNC_EN                  ( "FALSE" ),                     // PCIe async enable
          .PCIE_TXBUF_EN                  ( "FALSE" ),                     // PCIe TX buffer enable for Gen1/Gen2 only
          .PCIE_CLK_SHARING_EN            ( CLK_SHARING_EN ),              // Enable Clock Sharing
          .PCIE_LANE                      ( PL_LINK_CAP_MAX_LINK_WIDTH ), // PCIe number of lanes
          .PCIE_LINK_SPEED                ( 3 ),                           // PCIe Maximum Link Speed
          .PCIE_REFCLK_FREQ               ( PCIE_REFCLK_FREQ ),            // PCIe Reference Clock Frequency
          .PCIE_USERCLK1_FREQ             ( PCIE_USERCLK1_FREQ  ),         // PCIe Core Clock Frequency - Core Clock Freq
          .PCIE_USERCLK2_FREQ             ( PCIE_USERCLK2_FREQ ),          // PCIe User Clock Frequency - User Clock Freq
          .PCIE_DEBUG_MODE                ( 0 )                            // Debug Enable
      )
      pipe_clock_ep_i
      (
          //---------- Input -------------------------------------
          .CLK_CLK                        ( sys_clk ),
          .CLK_TXOUTCLK                   ( sys_clk ),     // Reference clock from lane 0
          .CLK_RXOUTCLK_IN                ( {PL_LINK_CAP_MAX_LINK_WIDTH{1'b0}}), //pipe_rxoutclk_in ),
          .CLK_RST_N                      ( 1'b1 ),      // Allow system reset for error_recovery             
          .CLK_PCLK_SEL                   ( pipe_pclk_sel_ep ),
          .CLK_PCLK_SEL_SLAVE             ( {PL_LINK_CAP_MAX_LINK_WIDTH{1'b0}}), //pipe_pclk_sel_slave),
          .CLK_GEN3                       ( pipe_gen3_ep ),
          //---------- Output ------------------------------------
          .CLK_PCLK                       ( pipe_clk_ep),
          .CLK_PCLK_SLAVE                 (),
          .CLK_RXUSRCLK                   (),
          .CLK_RXOUTCLK_OUT               (),
          .CLK_DCLK                       (),
          .CLK_OOBCLK                     (),
          .CLK_USERCLK1                   ( userclk1_ep),
          .CLK_USERCLK2                   ( userclk2_ep),
          .CLK_MMCM_LOCK                  ( mmcm_lock_ep)
      );
  //--------------------------------------------------------------------// 

   assign common_commands_in_ep[0] = pipe_clk_ep; 
   assign common_commands_in_ep[1] = userclk1_ep;   //core_clk
   assign common_commands_in_ep[2] = userclk2_ep;   //user_clk
   assign common_commands_in_ep[3] = pipe_clk_ep;  //rec_clk
   assign common_commands_in_ep[4] = phy_rdy_ep; 
   assign common_commands_in_ep[5] = mmcm_lock_ep; 
   //EQ Constants
   assign common_commands_in_ep[11: 6] = 6'd40;     //pipe_txeq_fs = 6'd40;
   assign common_commands_in_ep[17:12] = 6'd15;     //pipe_txeq_lf = 6'd15;
   assign common_commands_in_ep[25:18] = pipe_rxsync_done_ep;


   // Edge detect for pipe_tx_rcvr_det
   reg  pipe_tx_rcvr_det_ep_reg0;
   reg  pipe_tx_rcvr_det_ep_reg1;
   reg  pipe_tx_rcvr_det_ep_reg2;
   wire pipe_tx_rcvr_det_ep_posedge;
   always @ (posedge pipe_clk_ep  or negedge sys_rst_n) begin
      if (!sys_rst_n) begin
         pipe_tx_rcvr_det_ep_reg0 <= 1'b0;
         pipe_tx_rcvr_det_ep_reg1 <= 1'b0;
         pipe_tx_rcvr_det_ep_reg2 <= 1'b0;
      end else begin
         pipe_tx_rcvr_det_ep_reg0 <= common_commands_out_ep[0]; //pipe_tx_rcvr_det;
         pipe_tx_rcvr_det_ep_reg1 <= pipe_tx_rcvr_det_ep_reg0;
         pipe_tx_rcvr_det_ep_reg2 <= pipe_tx_rcvr_det_ep_reg1;
      end
   end
   assign pipe_tx_rcvr_det_ep_posedge = ~pipe_tx_rcvr_det_ep_reg2 && pipe_tx_rcvr_det_ep_reg1;

   // Detect Speed Change
   reg pipe_tx_rate_ep_reg0;
   reg det_speed_change_ep;
   always @ (posedge pipe_clk_ep) begin
      pipe_tx_rate_ep_reg0 <= common_commands_out_ep[2:1];
      if (common_commands_out_ep[2:1] != pipe_tx_rate_ep_reg0) begin
         det_speed_change_ep <= 1'b1;
      end
      else begin
         det_speed_change_ep <= 1'b0;
      end
   end
   
   //State Machine for generating pipe_rx[]_status & pipe_rx[]_phy_status
   reg [2:0] rcvr_det_state_ep;
   reg [7:0] rcvr_det_counter_ep;
   reg [2:0] pipe_rxn_status_ep;
   reg       pipe_rxn_phy_status_ep;
   always @(posedge pipe_clk_ep)
     begin if (!sys_rst_n) begin
       rcvr_det_state_ep       <= DET_IDLE ;
       pipe_rxn_status_ep      <= 3'd0;
       pipe_rxn_phy_status_ep  <= 1'b0;
       rcvr_det_counter_ep     <= 8'd0;
       pipe_rxsync_done_ep     <= 8'd0;
     end else case (rcvr_det_state_ep)
     DET_IDLE :    begin
       if (pipe_tx_rcvr_det_ep_posedge) begin
         rcvr_det_state_ep       <= DET_STATE1;
         pipe_rxn_status_ep      <= 3'd3;
         pipe_rxn_phy_status_ep  <= 1'b1;
     		rcvr_det_counter_ep     <= 8'd0;
       end else begin
         rcvr_det_state_ep       <= DET_IDLE ;
        	pipe_rxn_status_ep      <= 3'd0;
        	pipe_rxn_phy_status_ep  <= 1'b0;
     	  rcvr_det_counter_ep     <= 8'd0;
       end
     end
     DET_STATE1 :    begin
       if (rcvr_det_counter_ep == 8'd159) begin
         rcvr_det_state_ep       <= DET_STATE2;
         pipe_rxn_status_ep      <= 3'd0;
         pipe_rxn_phy_status_ep  <= 1'b1;
     		rcvr_det_counter_ep     <= 8'd0;
       end else begin
         rcvr_det_state_ep       <= DET_STATE1;
         pipe_rxn_status_ep      <= 3'd0;
         pipe_rxn_phy_status_ep  <= 1'b0;
     		rcvr_det_counter_ep     <= rcvr_det_counter_ep + 1'b1;
       end
     end
     DET_STATE2 :    begin
       if (det_speed_change_ep == 1'b1) begin
         rcvr_det_state_ep       <= SPEED_CHANGE;
         pipe_rxn_status_ep      <= 3'd0;
         pipe_rxn_phy_status_ep  <= 1'b0;
         rcvr_det_counter_ep     <= 8'd0;
       end else begin
         rcvr_det_state_ep       <= DET_STATE2 ;
         pipe_rxn_status_ep      <= 3'd0;
         pipe_rxn_phy_status_ep  <= 1'b0;
         rcvr_det_counter_ep     <= 8'd0;
       end
     end
     SPEED_CHANGE :    begin
       if (rcvr_det_counter_ep == 8'd159) begin
         rcvr_det_state_ep       <= DET_IDLE;
         pipe_rxn_status_ep      <= 3'd0;
         pipe_rxn_phy_status_ep  <= 1'b1;
     		rcvr_det_counter_ep     <= 8'd0;
         if (common_commands_out_ep[2:1] == 2'b10) begin
           pipe_rxsync_done_ep   <= 8'b11111111;
         end
       end else begin
     	  rcvr_det_state_ep       <= SPEED_CHANGE ;
         pipe_rxn_status_ep      <= 3'd0;
         pipe_rxn_phy_status_ep  <= 1'b0;
     		rcvr_det_counter_ep     <= rcvr_det_counter_ep + 1'b1;
       end
     end
     default   :  begin
       rcvr_det_state_ep       <= DET_IDLE ;
       pipe_rxn_status_ep      <= 3'd0;
       pipe_rxn_phy_status_ep  <= 1'b0;
       rcvr_det_counter_ep     <= 8'd0;
     end
     endcase
   end
   
   // Edge detect for pipe_rxn_elec_idle
    reg pipe_rxn_elec_idle_ep_reg0;
    reg pipe_rxn_elec_idle_ep_reg1;
    reg pipe_rxn_elec_idle_ep_reg2;
   wire pipe_rxn_elec_idle_ep_posedge;
   wire pipe_rxn_elec_idle_ep_negedge;
   always @ (posedge pipe_clk_ep  or negedge sys_rst_n) begin // pipe_clk
     if (!sys_rst_n) begin
       pipe_rxn_elec_idle_ep_reg0 <= 1'b0;
       pipe_rxn_elec_idle_ep_reg1 <= 1'b0;
       pipe_rxn_elec_idle_ep_reg2 <= 1'b0;
     end else begin
       pipe_rxn_elec_idle_ep_reg0 <= pipe_tx_0_sigs_rp[34]; //pipe_rx0_elec_idle_ep;
       pipe_rxn_elec_idle_ep_reg1 <= pipe_rxn_elec_idle_ep_reg0;
       pipe_rxn_elec_idle_ep_reg2 <= pipe_rxn_elec_idle_ep_reg1;
     end
   end
   assign pipe_rxn_elec_idle_ep_posedge = ~pipe_rxn_elec_idle_ep_reg2  &&  pipe_rxn_elec_idle_ep_reg1;
   assign pipe_rxn_elec_idle_ep_negedge =  pipe_rxn_elec_idle_ep_reg2  && ~pipe_rxn_elec_idle_ep_reg1;
   
   //generate pipe_rxn_valid
   reg pipe_rxn_valid_ep;
   always @ (posedge pipe_clk_ep  or negedge sys_rst_n) begin // pipe_clk
     if (!sys_rst_n || pipe_rxn_elec_idle_ep_posedge ) begin
        pipe_rxn_valid_ep <= 1'b0;
     end else if (pipe_rxn_elec_idle_ep_negedge) begin
        pipe_rxn_valid_ep <= 1'b1;
     end else begin
   	   pipe_rxn_valid_ep <= pipe_rxn_valid_ep;
     end
   end
   
   //Assert phy_rdy_int after some arbitrary time after sys_rst_n
   reg           phy_rdy_int_ep;
   reg    [1:0]  reg_phy_rdy_ep;
   initial begin
      forever begin
         phy_rdy_int_ep <= 1'b0;
         wait (sys_rst_n == 1'b1);
         for (i=0; i<1000; i=i+1) begin
            @(posedge pipe_clk_ep);
         end
         if (sys_rst_n == 1'b1) begin
            phy_rdy_int_ep <= 1'b1;
         end
         wait (sys_rst_n == 1'b0);
      end
   end
   // Synchronize PHY Ready
   always @ (posedge userclk2_ep or negedge phy_rdy_int_ep) begin
   
     if (!phy_rdy_int_ep)
       reg_phy_rdy_ep[1:0] <= #TCQ 2'b11;
     else
       reg_phy_rdy_ep[1:0] <= #3600000 {reg_phy_rdy_ep[0], 1'b0};
   
   end
   assign  phy_rdy_ep = !reg_phy_rdy_ep[1];
   
  //------------------------------------------------------------------------------//
  // Lane - 0 RX BUS 
  //------------------------------------------------------------------------------//
   reg pipe_rx_0_sigs_ep_44;
   reg pipe_rx_0_sigs_ep_83;
   assign pipe_rx_0_sigs_ep[31: 0] = pipe_tx_0_sigs_rp[31: 0]; 
   assign pipe_rx_0_sigs_ep[33:32] = pipe_tx_0_sigs_rp[33:32]; 
   assign pipe_rx_0_sigs_ep[34]    = pipe_tx_0_sigs_rp[35]; 
   assign pipe_rx_0_sigs_ep[35]    = pipe_tx_0_sigs_rp[34]; 
   assign pipe_rx_0_sigs_ep[36]    = pipe_tx_0_sigs_rp[36]; 
   assign pipe_rx_0_sigs_ep[38:37] = pipe_tx_0_sigs_rp[38:37]; 
   assign pipe_rx_0_sigs_ep[41:39] = pipe_rxn_status_ep;
   assign pipe_rx_0_sigs_ep[42] = pipe_rxn_valid_ep;
   assign pipe_rx_0_sigs_ep[43] = pipe_rxn_phy_status_ep ;
   // Very simple model of pipe_txn_eqdone bits
   always @ (posedge pipe_clk_ep)
      if (pipe_tx_0_sigs_ep[43:42] != 0)
         pipe_rx_0_sigs_ep_44 <= 1'b1; //pipe_tx0_eqdone
      else
         pipe_rx_0_sigs_ep_44 <= 1'b0; //pipe_tx0_eqdone
   assign pipe_rx_0_sigs_ep[62:45] = 18'd2;
   assign pipe_rx_0_sigs_ep[80:63] = 18'd0;
   assign pipe_rx_0_sigs_ep[81] = 1'b1;
   assign pipe_rx_0_sigs_ep[82] = 1'b0;
   // Very simple model of pipe_rxn_eqdone bits
   always @ (posedge pipe_clk_ep)
      if (pipe_tx_0_sigs_ep[55:54] != 0)
         pipe_rx_0_sigs_ep_83 <= 1'b1;
      else
         pipe_rx_0_sigs_ep_83 <= 1'b0;
   assign pipe_rx_0_sigs_ep[83] = pipe_rx_0_sigs_ep_83;
   assign pipe_rx_0_sigs_ep[44] = pipe_rx_0_sigs_ep_44;
  //------------------------------------------------------------------------------//
  // Lane - 1 RX BUS 
  //------------------------------------------------------------------------------//
   reg pipe_rx_1_sigs_ep_44;
   reg pipe_rx_1_sigs_ep_83;
   assign pipe_rx_1_sigs_ep[31: 0] = pipe_tx_1_sigs_rp[31: 0]; 
   assign pipe_rx_1_sigs_ep[33:32] = pipe_tx_1_sigs_rp[33:32]; 
   assign pipe_rx_1_sigs_ep[34]    = pipe_tx_1_sigs_rp[35]; 
   assign pipe_rx_1_sigs_ep[35]    = pipe_tx_1_sigs_rp[34]; 
   assign pipe_rx_1_sigs_ep[36]    = pipe_tx_1_sigs_rp[36]; 
   assign pipe_rx_1_sigs_ep[38:37] = pipe_tx_1_sigs_rp[38:37]; 
   assign pipe_rx_1_sigs_ep[41:39] = (PL_LINK_CAP_MAX_LINK_WIDTH >= 2 ) ? pipe_rxn_status_ep : 3'b0;
   assign pipe_rx_1_sigs_ep[42] = (PL_LINK_CAP_MAX_LINK_WIDTH >= 2 ) ? pipe_rxn_valid_ep : 1'b0;
   assign pipe_rx_1_sigs_ep[43] = (PL_LINK_CAP_MAX_LINK_WIDTH >= 2 ) ? pipe_rxn_phy_status_ep : 1'b0;
   // Very simple model of pipe_txn_eqdone bits
   always @ (posedge pipe_clk_ep)
      if (pipe_tx_1_sigs_ep[43:42] != 0)
         pipe_rx_1_sigs_ep_44 <= 1'b1; //pipe_tx0_eqdone
      else
         pipe_rx_1_sigs_ep_44 <= 1'b0; //pipe_tx0_eqdone
   assign pipe_rx_1_sigs_ep[62:45] = (PL_LINK_CAP_MAX_LINK_WIDTH >= 2 ) ? 18'd2 : 18'd0;
   assign pipe_rx_1_sigs_ep[80:63] = 18'd0;
   assign pipe_rx_1_sigs_ep[81] = 1'b1;
   assign pipe_rx_1_sigs_ep[82] = 1'b0;
   // Very simple model of pipe_txn_eqdone bits
   always @ (posedge pipe_clk_ep)
      if (pipe_tx_1_sigs_ep[55:54] != 0)
         pipe_rx_1_sigs_ep_83 <= 1'b1;
      else
         pipe_rx_1_sigs_ep_83 <= 1'b0;
   assign pipe_rx_1_sigs_ep[83] = pipe_rx_1_sigs_ep_83;
   assign pipe_rx_1_sigs_ep[44] = pipe_rx_1_sigs_ep_44;
  //------------------------------------------------------------------------------//
  // Lane - 2 RX BUS 
  //------------------------------------------------------------------------------//
   reg pipe_rx_2_sigs_ep_44;
   reg pipe_rx_2_sigs_ep_83;
   assign pipe_rx_2_sigs_ep[31: 0] = pipe_tx_2_sigs_rp[31: 0]; 
   assign pipe_rx_2_sigs_ep[33:32] = pipe_tx_2_sigs_rp[33:32]; 
   assign pipe_rx_2_sigs_ep[34]    = pipe_tx_2_sigs_rp[35]; 
   assign pipe_rx_2_sigs_ep[35]    = pipe_tx_2_sigs_rp[34]; 
   assign pipe_rx_2_sigs_ep[36]    = pipe_tx_2_sigs_rp[36]; 
   assign pipe_rx_2_sigs_ep[38:37] = pipe_tx_2_sigs_rp[38:37]; 
   assign pipe_rx_2_sigs_ep[41:39] = (PL_LINK_CAP_MAX_LINK_WIDTH >= 4 ) ? pipe_rxn_status_ep : 3'b0;
   assign pipe_rx_2_sigs_ep[42] = (PL_LINK_CAP_MAX_LINK_WIDTH >= 4 ) ? pipe_rxn_valid_ep : 1'b0;
   assign pipe_rx_2_sigs_ep[43] = (PL_LINK_CAP_MAX_LINK_WIDTH >= 4 ) ? pipe_rxn_phy_status_ep : 1'b0;
   // Very simple model of pipe_txn_eqdone bits
   always @ (posedge pipe_clk_ep)
      if (pipe_tx_2_sigs_ep[43:42] != 0)
         pipe_rx_2_sigs_ep_44 <= 1'b1; //pipe_tx0_eqdone
      else
         pipe_rx_2_sigs_ep_44 <= 1'b0; //pipe_tx0_eqdone
   assign pipe_rx_2_sigs_ep[62:45] = (PL_LINK_CAP_MAX_LINK_WIDTH >= 4 ) ? 18'd2 : 18'd0;
   assign pipe_rx_2_sigs_ep[80:63] = 18'd0;
   assign pipe_rx_2_sigs_ep[81] = 1'b1;
   assign pipe_rx_2_sigs_ep[82] = 1'b0;
   // Very simple model of pipe_txn_eqdone bits
   always @ (posedge pipe_clk_ep)
      if (pipe_tx_2_sigs_ep[55:54] != 0)
         pipe_rx_2_sigs_ep_83 <= 1'b1;
      else
         pipe_rx_2_sigs_ep_83 <= 1'b0;
   assign pipe_rx_2_sigs_ep[83] = pipe_rx_2_sigs_ep_83;
   assign pipe_rx_2_sigs_ep[44] = pipe_rx_2_sigs_ep_44;
  //------------------------------------------------------------------------------//
  // Lane - 3 RX BUS 
  //------------------------------------------------------------------------------//
   reg pipe_rx_3_sigs_ep_44;
   reg pipe_rx_3_sigs_ep_83;
   assign pipe_rx_3_sigs_ep[31: 0] = pipe_tx_3_sigs_rp[31: 0]; 
   assign pipe_rx_3_sigs_ep[33:32] = pipe_tx_3_sigs_rp[33:32]; 
   assign pipe_rx_3_sigs_ep[34]    = pipe_tx_3_sigs_rp[35]; 
   assign pipe_rx_3_sigs_ep[35]    = pipe_tx_3_sigs_rp[34]; 
   assign pipe_rx_3_sigs_ep[36]    = pipe_tx_3_sigs_rp[36]; 
   assign pipe_rx_3_sigs_ep[38:37] = pipe_tx_3_sigs_rp[38:37]; 
   assign pipe_rx_3_sigs_ep[41:39] = (PL_LINK_CAP_MAX_LINK_WIDTH >= 4 ) ? pipe_rxn_status_ep : 3'b0;
   assign pipe_rx_3_sigs_ep[42] = (PL_LINK_CAP_MAX_LINK_WIDTH >= 4 ) ? pipe_rxn_valid_ep : 1'b0;
   assign pipe_rx_3_sigs_ep[43] = (PL_LINK_CAP_MAX_LINK_WIDTH >= 4 ) ? pipe_rxn_phy_status_ep : 1'b0;
   // Very simple model of pipe_txn_eqdone bits
   always @ (posedge pipe_clk_ep)
      if (pipe_tx_3_sigs_ep[43:42] != 0)
         pipe_rx_3_sigs_ep_44 <= 1'b1; //pipe_tx0_eqdone
      else
         pipe_rx_3_sigs_ep_44 <= 1'b0; //pipe_tx0_eqdone
   assign pipe_rx_3_sigs_ep[62:45] = (PL_LINK_CAP_MAX_LINK_WIDTH >= 4 ) ? 18'd2 : 18'd0;
   assign pipe_rx_3_sigs_ep[80:63] = 18'd0;
   assign pipe_rx_3_sigs_ep[81] = 1'b1;
   assign pipe_rx_3_sigs_ep[82] = 1'b0;
   // Very simple model of pipe_txn_eqdone bits
   always @ (posedge pipe_clk_ep)
      if (pipe_tx_3_sigs_ep[55:54] != 0)
         pipe_rx_3_sigs_ep_83 <= 1'b1;
      else
         pipe_rx_3_sigs_ep_83 <= 1'b0;
   assign pipe_rx_3_sigs_ep[83] = pipe_rx_3_sigs_ep_83;
   assign pipe_rx_3_sigs_ep[44] = pipe_rx_3_sigs_ep_44;
  //------------------------------------------------------------------------------//
  // Lane - 4 RX BUS 
  //------------------------------------------------------------------------------//
   reg pipe_rx_4_sigs_ep_44;
   reg pipe_rx_4_sigs_ep_83;
   assign pipe_rx_4_sigs_ep[31: 0] = pipe_tx_4_sigs_rp[31: 0]; 
   assign pipe_rx_4_sigs_ep[33:32] = pipe_tx_4_sigs_rp[33:32]; 
   assign pipe_rx_4_sigs_ep[34]    = pipe_tx_4_sigs_rp[35]; 
   assign pipe_rx_4_sigs_ep[35]    = pipe_tx_4_sigs_rp[34]; 
   assign pipe_rx_4_sigs_ep[36]    = pipe_tx_4_sigs_rp[36]; 
   assign pipe_rx_4_sigs_ep[38:37] = pipe_tx_4_sigs_rp[38:37]; 
   assign pipe_rx_4_sigs_ep[41:39] = (PL_LINK_CAP_MAX_LINK_WIDTH >= 8 ) ? pipe_rxn_status_ep : 3'b0;
   assign pipe_rx_4_sigs_ep[42] = (PL_LINK_CAP_MAX_LINK_WIDTH >= 8 ) ? pipe_rxn_valid_ep : 1'b0;
   assign pipe_rx_4_sigs_ep[43] = (PL_LINK_CAP_MAX_LINK_WIDTH >= 8 ) ? pipe_rxn_phy_status_ep : 1'b0;
   // Very simple model of pipe_txn_eqdone bits
   always @ (posedge pipe_clk_ep)
      if (pipe_tx_4_sigs_ep[43:42] != 0)
         pipe_rx_4_sigs_ep_44 <= 1'b1; //pipe_tx0_eqdone
      else
         pipe_rx_4_sigs_ep_44 <= 1'b0; //pipe_tx0_eqdone
   assign pipe_rx_4_sigs_ep[62:45] = (PL_LINK_CAP_MAX_LINK_WIDTH >= 8 ) ? 18'd2 : 18'd0;
   assign pipe_rx_4_sigs_ep[80:63] = 18'd0;
   assign pipe_rx_4_sigs_ep[81] = 1'b1;
   assign pipe_rx_4_sigs_ep[82] = 1'b0;
   // Very simple model of pipe_txn_eqdone bits
   always @ (posedge pipe_clk_ep)
      if (pipe_tx_4_sigs_ep[55:54] != 0)
         pipe_rx_4_sigs_ep_83 <= 1'b1;
      else
         pipe_rx_4_sigs_ep_83 <= 1'b0;
   assign pipe_rx_4_sigs_ep[83] = pipe_rx_4_sigs_ep_83;
   assign pipe_rx_4_sigs_ep[44] = pipe_rx_4_sigs_ep_44;
  //------------------------------------------------------------------------------//
  // Lane - 5 RX BUS 
  //------------------------------------------------------------------------------//
   reg pipe_rx_5_sigs_ep_44;
   reg pipe_rx_5_sigs_ep_83;
   assign pipe_rx_5_sigs_ep[31: 0] = pipe_tx_5_sigs_rp[31: 0]; 
   assign pipe_rx_5_sigs_ep[33:32] = pipe_tx_5_sigs_rp[33:32]; 
   assign pipe_rx_5_sigs_ep[34]    = pipe_tx_5_sigs_rp[35]; 
   assign pipe_rx_5_sigs_ep[35]    = pipe_tx_5_sigs_rp[34]; 
   assign pipe_rx_5_sigs_ep[36]    = pipe_tx_5_sigs_rp[36]; 
   assign pipe_rx_5_sigs_ep[38:37] = pipe_tx_5_sigs_rp[38:37]; 
   assign pipe_rx_5_sigs_ep[41:39] = (PL_LINK_CAP_MAX_LINK_WIDTH >= 8 ) ? pipe_rxn_status_ep : 3'b0;
   assign pipe_rx_5_sigs_ep[42] = (PL_LINK_CAP_MAX_LINK_WIDTH >= 8 ) ? pipe_rxn_valid_ep : 1'b0;
   assign pipe_rx_5_sigs_ep[43] = (PL_LINK_CAP_MAX_LINK_WIDTH >= 8 ) ? pipe_rxn_phy_status_ep : 1'b0;
   // Very simple model of pipe_txn_eqdone bits
   always @ (posedge pipe_clk_ep)
      if (pipe_tx_5_sigs_ep[43:42] != 0)
         pipe_rx_5_sigs_ep_44 <= 1'b1; //pipe_tx0_eqdone
      else
         pipe_rx_5_sigs_ep_44 <= 1'b0; //pipe_tx0_eqdone
   assign pipe_rx_5_sigs_ep[62:45] = (PL_LINK_CAP_MAX_LINK_WIDTH >= 8 ) ? 18'd2 : 18'd0;
   assign pipe_rx_5_sigs_ep[80:63] = 18'd0;
   assign pipe_rx_5_sigs_ep[81] = 1'b1;
   assign pipe_rx_5_sigs_ep[82] = 1'b0;
   // Very simple model of pipe_txn_eqdone bits
   always @ (posedge pipe_clk_ep)
      if (pipe_tx_5_sigs_ep[55:54] != 0)
         pipe_rx_5_sigs_ep_83 <= 1'b1;
      else
         pipe_rx_5_sigs_ep_83 <= 1'b0;
   assign pipe_rx_5_sigs_ep[83] = pipe_rx_5_sigs_ep_83;
   assign pipe_rx_5_sigs_ep[44] = pipe_rx_5_sigs_ep_44;
  //------------------------------------------------------------------------------//
  // Lane - 6 RX BUS 
  //------------------------------------------------------------------------------//
   reg pipe_rx_6_sigs_ep_44;
   reg pipe_rx_6_sigs_ep_83;
   assign pipe_rx_6_sigs_ep[31: 0] = pipe_tx_6_sigs_rp[31: 0]; 
   assign pipe_rx_6_sigs_ep[33:32] = pipe_tx_6_sigs_rp[33:32]; 
   assign pipe_rx_6_sigs_ep[34]    = pipe_tx_6_sigs_rp[35]; 
   assign pipe_rx_6_sigs_ep[35]    = pipe_tx_6_sigs_rp[34]; 
   assign pipe_rx_6_sigs_ep[36]    = pipe_tx_6_sigs_rp[36]; 
   assign pipe_rx_6_sigs_ep[38:37] = pipe_tx_6_sigs_rp[38:37]; 
   assign pipe_rx_6_sigs_ep[41:39] = (PL_LINK_CAP_MAX_LINK_WIDTH >= 8 ) ? pipe_rxn_status_ep : 3'b0;
   assign pipe_rx_6_sigs_ep[42] = (PL_LINK_CAP_MAX_LINK_WIDTH >= 8 ) ? pipe_rxn_valid_ep : 1'b0;
   assign pipe_rx_6_sigs_ep[43] = (PL_LINK_CAP_MAX_LINK_WIDTH >= 8 ) ? pipe_rxn_phy_status_ep : 1'b0;
   // Very simple model of pipe_txn_eqdone bits
   always @ (posedge pipe_clk_ep)
      if (pipe_tx_6_sigs_ep[43:42] != 0)
         pipe_rx_6_sigs_ep_44 <= 1'b1; //pipe_tx0_eqdone
      else
         pipe_rx_6_sigs_ep_44 <= 1'b0; //pipe_tx0_eqdone
   assign pipe_rx_6_sigs_ep[62:45] = (PL_LINK_CAP_MAX_LINK_WIDTH >= 8 ) ? 18'd2 : 18'd0;
   assign pipe_rx_6_sigs_ep[80:63] = 18'd0;
   assign pipe_rx_6_sigs_ep[81] = 1'b1;
   assign pipe_rx_6_sigs_ep[82] = 1'b0;
   // Very simple model of pipe_txn_eqdone bits
   always @ (posedge pipe_clk_ep)
      if (pipe_tx_6_sigs_ep[55:54] != 0)
         pipe_rx_6_sigs_ep_83 <= 1'b1;
      else
         pipe_rx_6_sigs_ep_83 <= 1'b0;
   assign pipe_rx_6_sigs_ep[83] = pipe_rx_6_sigs_ep_83;
   assign pipe_rx_6_sigs_ep[44] = pipe_rx_6_sigs_ep_44;
  //------------------------------------------------------------------------------//
  // Lane - 7 RX BUS 
  //------------------------------------------------------------------------------//
   reg pipe_rx_7_sigs_ep_44;
   reg pipe_rx_7_sigs_ep_83;
   assign pipe_rx_7_sigs_ep[31: 0] = pipe_tx_7_sigs_rp[31: 0]; 
   assign pipe_rx_7_sigs_ep[33:32] = pipe_tx_7_sigs_rp[33:32]; 
   assign pipe_rx_7_sigs_ep[34]    = pipe_tx_7_sigs_rp[35]; 
   assign pipe_rx_7_sigs_ep[35]    = pipe_tx_7_sigs_rp[34]; 
   assign pipe_rx_7_sigs_ep[36]    = pipe_tx_7_sigs_rp[36]; 
   assign pipe_rx_7_sigs_ep[38:37] = pipe_tx_7_sigs_rp[38:37]; 
   assign pipe_rx_7_sigs_ep[41:39] = (PL_LINK_CAP_MAX_LINK_WIDTH >= 8 ) ? pipe_rxn_status_ep : 3'b0;
   assign pipe_rx_7_sigs_ep[42] = (PL_LINK_CAP_MAX_LINK_WIDTH >= 8 ) ? pipe_rxn_valid_ep : 1'b0;
   assign pipe_rx_7_sigs_ep[43] = (PL_LINK_CAP_MAX_LINK_WIDTH >= 8 ) ? pipe_rxn_phy_status_ep : 1'b0;
   // Very simple model of pipe_txn_eqdone bits
   always @ (posedge pipe_clk_ep)
      if (pipe_tx_7_sigs_ep[43:42] != 0)
         pipe_rx_7_sigs_ep_44 <= 1'b1; //pipe_tx0_eqdone
      else
         pipe_rx_7_sigs_ep_44 <= 1'b0; //pipe_tx0_eqdone
   assign pipe_rx_7_sigs_ep[62:45] = (PL_LINK_CAP_MAX_LINK_WIDTH >= 8 ) ? 18'd2 : 18'd0;
   assign pipe_rx_7_sigs_ep[80:63] = 18'd0;
   assign pipe_rx_7_sigs_ep[81] = 1'b1;
   assign pipe_rx_7_sigs_ep[82] = 1'b0;
   // Very simple model of pipe_txn_eqdone bits
   always @ (posedge pipe_clk_ep)
      if (pipe_tx_7_sigs_ep[55:54] != 0)
         pipe_rx_7_sigs_ep_83 <= 1'b1;
      else
         pipe_rx_7_sigs_ep_83 <= 1'b0;
   assign pipe_rx_7_sigs_ep[83] = pipe_rx_7_sigs_ep_83;
   assign pipe_rx_7_sigs_ep[44] = pipe_rx_7_sigs_ep_44;
  //------------------------------------------------------------------------------//
   
   

  //----------------------------------------------------------------------------------------------------------------//
  //              RP
  //----------------------------------------------------------------------------------------------------------------//
   assign pipe_pclk_sel_rp = (common_commands_out_rp[2:1] == 2'b10 || common_commands_out_rp[2:1] == 2'b01) ? {PL_LINK_CAP_MAX_LINK_WIDTH{1'b1}} : {PL_LINK_CAP_MAX_LINK_WIDTH{1'b0}}; 
   assign pipe_gen3_rp     = (common_commands_out_rp[2:1] == 2'b10 ) ? 1'b1 : 1'b0 ; 
  //--------------------------------------------------------------------// 
      pcie3_ultrascale_0_phy_sig_gen_clk #
      (
          .PCIE_ASYNC_EN                  ( "FALSE" ),                     // PCIe async enable
          .PCIE_TXBUF_EN                  ( "FALSE" ),                     // PCIe TX buffer enable for Gen1/Gen2 only
          .PCIE_CLK_SHARING_EN            ( CLK_SHARING_EN ),              // Enable Clock Sharing
          .PCIE_LANE                      ( PL_LINK_CAP_MAX_LINK_WIDTH ), // PCIe number of lanes
          .PCIE_LINK_SPEED                ( 3 ),                           // PCIe Maximum Link Speed
          .PCIE_REFCLK_FREQ               ( PCIE_REFCLK_FREQ ),            // PCIe Reference Clock Frequency
          .PCIE_USERCLK1_FREQ             ( 5 ),//( PCIE_USERCLK1_FREQ  ),         // PCIe Core Clock Frequency - Core Clock Freq
          .PCIE_USERCLK2_FREQ             ( 4 ),//( PCIE_USERCLK2_FREQ ),          // PCIe User Clock Frequency - User Clock Freq
          .PCIE_DEBUG_MODE                ( 0 )                            // Debug Enable
      )
      pipe_clock_rp_i
      (
          //---------- Input -------------------------------------
          .CLK_CLK                        ( sys_clk ),
          .CLK_TXOUTCLK                   ( sys_clk ),     // Reference clock from lane 0
          .CLK_RXOUTCLK_IN                ( {PL_LINK_CAP_MAX_LINK_WIDTH{1'b0}}), //pipe_rxoutclk_in ),
          .CLK_RST_N                      ( 1'b1 ),      // Allow system reset for error_recovery             
          .CLK_PCLK_SEL                   ( pipe_pclk_sel_rp ),
          .CLK_PCLK_SEL_SLAVE             ( {PL_LINK_CAP_MAX_LINK_WIDTH{1'b0}}), //pipe_pclk_sel_slave),
          .CLK_GEN3                       ( pipe_gen3_rp ),
          //---------- Output ------------------------------------
          .CLK_PCLK                       ( pipe_clk_rp),
          .CLK_PCLK_SLAVE                 (),
          .CLK_RXUSRCLK                   (),
          .CLK_RXOUTCLK_OUT               (),
          .CLK_DCLK                       (),
          .CLK_OOBCLK                     (),
          .CLK_USERCLK1                   ( userclk1_rp),
          .CLK_USERCLK2                   ( userclk2_rp),
          .CLK_MMCM_LOCK                  ( mmcm_lock_rp)
      );
  //--------------------------------------------------------------------// 

   assign common_commands_in_rp[0] = pipe_clk_rp; 
   assign common_commands_in_rp[1] = userclk1_rp;   //core_clk
   assign common_commands_in_rp[2] = userclk2_rp;   //user_clk
   assign common_commands_in_rp[3] = pipe_clk_rp;  //rec_clk
   assign common_commands_in_rp[4] = phy_rdy_rp; 
   assign common_commands_in_rp[5] = mmcm_lock_rp; 
   //EQ Constants
   assign common_commands_in_rp[11: 6] = 6'd40;     //pipe_txeq_fs = 6'd40;
   assign common_commands_in_rp[17:12] = 6'd15;     //pipe_txeq_lf = 6'd15;
   assign common_commands_in_rp[25:18] = pipe_rxsync_done_rp;


   // Edge detect for pipe_tx_rcvr_det
   reg  pipe_tx_rcvr_det_rp_reg0;
   reg  pipe_tx_rcvr_det_rp_reg1;
   reg  pipe_tx_rcvr_det_rp_reg2;
   wire pipe_tx_rcvr_det_rp_posedge;
   always @ (posedge pipe_clk_rp  or negedge sys_rst_n) begin
      if (!sys_rst_n) begin
         pipe_tx_rcvr_det_rp_reg0 <= 1'b0;
         pipe_tx_rcvr_det_rp_reg1 <= 1'b0;
         pipe_tx_rcvr_det_rp_reg2 <= 1'b0;
      end else begin
         pipe_tx_rcvr_det_rp_reg0 <= common_commands_out_rp[0]; //pipe_tx_rcvr_det;
         pipe_tx_rcvr_det_rp_reg1 <= pipe_tx_rcvr_det_rp_reg0;
         pipe_tx_rcvr_det_rp_reg2 <= pipe_tx_rcvr_det_rp_reg1;
      end
   end
   assign pipe_tx_rcvr_det_rp_posedge = ~pipe_tx_rcvr_det_rp_reg2 && pipe_tx_rcvr_det_rp_reg1;

   // Detect Speed Change
   reg pipe_tx_rate_rp_reg0;
   reg det_speed_change_rp;
   always @ (posedge pipe_clk_rp) begin
      pipe_tx_rate_rp_reg0 <= common_commands_out_rp[2:1];
      if (common_commands_out_rp[2:1] != pipe_tx_rate_rp_reg0) begin
         det_speed_change_rp <= 1'b1;
      end
      else begin
         det_speed_change_rp <= 1'b0;
      end
   end
   
   //State Machine for generating pipe_rx[]_status & pipe_rx[]_phy_status
   reg [2:0] rcvr_det_state_rp;
   reg [7:0] rcvr_det_counter_rp;
   reg [2:0] pipe_rxn_status_rp;
   reg       pipe_rxn_phy_status_rp;
   always @(posedge pipe_clk_rp)
     begin if (!sys_rst_n) begin
       rcvr_det_state_rp       <= DET_IDLE ;
       pipe_rxn_status_rp      <= 3'd0;
       pipe_rxn_phy_status_rp  <= 1'b0;
       rcvr_det_counter_rp     <= 8'd0;
       pipe_rxsync_done_rp     <= 8'd0;
     end else case (rcvr_det_state_rp)
     DET_IDLE :    begin
       if (pipe_tx_rcvr_det_rp_posedge) begin
         rcvr_det_state_rp       <= DET_STATE1;
         pipe_rxn_status_rp      <= 3'd3;
         pipe_rxn_phy_status_rp  <= 1'b1;
     		rcvr_det_counter_rp     <= 8'd0;
       end else begin
         rcvr_det_state_rp       <= DET_IDLE ;
        	pipe_rxn_status_rp      <= 3'd0;
        	pipe_rxn_phy_status_rp  <= 1'b0;
     	  rcvr_det_counter_rp     <= 8'd0;
       end
     end
     DET_STATE1 :    begin
       if (rcvr_det_counter_rp == 8'd159) begin
         rcvr_det_state_rp       <= DET_STATE2;
         pipe_rxn_status_rp      <= 3'd0;
         pipe_rxn_phy_status_rp  <= 1'b1;
     		rcvr_det_counter_rp     <= 8'd0;
       end else begin
         rcvr_det_state_rp       <= DET_STATE1;
         pipe_rxn_status_rp      <= 3'd0;
         pipe_rxn_phy_status_rp  <= 1'b0;
     		rcvr_det_counter_rp     <= rcvr_det_counter_rp + 1'b1;
       end
     end
     DET_STATE2 :    begin
       if (det_speed_change_rp == 1'b1) begin
         rcvr_det_state_rp       <= SPEED_CHANGE;
         pipe_rxn_status_rp      <= 3'd0;
         pipe_rxn_phy_status_rp  <= 1'b0;
         rcvr_det_counter_rp     <= 8'd0;
       end else begin
         rcvr_det_state_rp       <= DET_STATE2 ;
         pipe_rxn_status_rp      <= 3'd0;
         pipe_rxn_phy_status_rp  <= 1'b0;
         rcvr_det_counter_rp     <= 8'd0;
       end
     end
     SPEED_CHANGE :    begin
       if (rcvr_det_counter_rp == 8'd159) begin
         rcvr_det_state_rp       <= DET_IDLE;
         pipe_rxn_status_rp      <= 3'd0;
         pipe_rxn_phy_status_rp  <= 1'b1;
     		rcvr_det_counter_rp     <= 8'd0;
         if (common_commands_out_rp[2:1] == 2'b10) begin
           pipe_rxsync_done_rp   <= 8'b11111111;
         end
       end else begin
     	  rcvr_det_state_rp       <= SPEED_CHANGE ;
         pipe_rxn_status_rp      <= 3'd0;
         pipe_rxn_phy_status_rp  <= 1'b0;
     		rcvr_det_counter_rp     <= rcvr_det_counter_rp + 1'b1;
       end
     end
     default   :  begin
       rcvr_det_state_rp       <= DET_IDLE ;
       pipe_rxn_status_rp      <= 3'd0;
       pipe_rxn_phy_status_rp  <= 1'b0;
       rcvr_det_counter_rp     <= 8'd0;
     end
     endcase
   end
   
   // Edge detect for pipe_rxn_elec_idle
    reg pipe_rxn_elec_idle_rp_reg0;
    reg pipe_rxn_elec_idle_rp_reg1;
    reg pipe_rxn_elec_idle_rp_reg2;
   wire pipe_rxn_elec_idle_rp_posedge;
   wire pipe_rxn_elec_idle_rp_negedge;
   always @ (posedge pipe_clk_rp  or negedge sys_rst_n) begin // pipe_clk
     if (!sys_rst_n) begin
       pipe_rxn_elec_idle_rp_reg0 <= 1'b0;
       pipe_rxn_elec_idle_rp_reg1 <= 1'b0;
       pipe_rxn_elec_idle_rp_reg2 <= 1'b0;
     end else begin
       pipe_rxn_elec_idle_rp_reg0 <= pipe_tx_0_sigs_ep[34]; //pipe_rx0_elec_idle_rp;
       pipe_rxn_elec_idle_rp_reg1 <= pipe_rxn_elec_idle_rp_reg0;
       pipe_rxn_elec_idle_rp_reg2 <= pipe_rxn_elec_idle_rp_reg1;
     end
   end
   assign pipe_rxn_elec_idle_rp_posedge = ~pipe_rxn_elec_idle_rp_reg2  &&  pipe_rxn_elec_idle_rp_reg1;
   assign pipe_rxn_elec_idle_rp_negedge =  pipe_rxn_elec_idle_rp_reg2  && ~pipe_rxn_elec_idle_rp_reg1;
   
   //generate pipe_rxn_valid
   reg pipe_rxn_valid_rp;
   always @ (posedge pipe_clk_rp  or negedge sys_rst_n) begin // pipe_clk
     if (!sys_rst_n || pipe_rxn_elec_idle_rp_posedge ) begin
        pipe_rxn_valid_rp <= 1'b0;
     end else if (pipe_rxn_elec_idle_rp_negedge) begin
        pipe_rxn_valid_rp <= 1'b1;
     end else begin
   	   pipe_rxn_valid_rp <= pipe_rxn_valid_rp;
     end
   end
   
   //Assert phy_rdy_int after some arbitrary time after sys_rst_n
   reg           phy_rdy_int_rp;
   reg    [1:0]  reg_phy_rdy_rp;
   initial begin
      forever begin
         phy_rdy_int_rp <= 1'b0;
         wait (sys_rst_n == 1'b1);
         for (i=0; i<1000; i=i+1) begin
            @(posedge pipe_clk_rp);
         end
         if (sys_rst_n == 1'b1) begin
            phy_rdy_int_rp <= 1'b1;
         end
         wait (sys_rst_n == 1'b0);
      end
   end
   // Synchronize PHY Ready
   always @ (posedge userclk2_rp or negedge phy_rdy_int_rp) begin
   
     if (!phy_rdy_int_rp)
       reg_phy_rdy_rp[1:0] <= #TCQ 2'b11;
     else
       reg_phy_rdy_rp[1:0] <= #3600000 {reg_phy_rdy_rp[0], 1'b0};
   
   end
   assign  phy_rdy_rp = !reg_phy_rdy_rp[1];
   
  //------------------------------------------------------------------------------//
  // Lane - 0 RX BUS 
  //------------------------------------------------------------------------------//
   reg pipe_rx_0_sigs_rp_44;
   reg pipe_rx_0_sigs_rp_83;
   assign pipe_rx_0_sigs_rp[31: 0] = pipe_tx_0_sigs_ep[31: 0]; 
   assign pipe_rx_0_sigs_rp[33:32] = pipe_tx_0_sigs_ep[33:32]; 
   assign pipe_rx_0_sigs_rp[34]    = pipe_tx_0_sigs_ep[35]; 
   assign pipe_rx_0_sigs_rp[35]    = pipe_tx_0_sigs_ep[34]; 
   assign pipe_rx_0_sigs_rp[36]    = pipe_tx_0_sigs_ep[36]; 
   assign pipe_rx_0_sigs_rp[38:37] = pipe_tx_0_sigs_ep[38:37]; 
   assign pipe_rx_0_sigs_rp[41:39] = pipe_rxn_status_rp;
   assign pipe_rx_0_sigs_rp[42] = pipe_rxn_valid_rp;
   assign pipe_rx_0_sigs_rp[43] = pipe_rxn_phy_status_rp ;
   // Very simple model of pipe_txn_eqdone bits
   always @ (posedge pipe_clk_rp)
      if (pipe_tx_0_sigs_rp[43:42] != 0)
         pipe_rx_0_sigs_rp_44 <= 1'b1; //pipe_tx0_eqdone
      else
         pipe_rx_0_sigs_rp_44 <= 1'b0; //pipe_tx0_eqdone
   assign pipe_rx_0_sigs_rp[62:45] = 18'd2;
   assign pipe_rx_0_sigs_rp[80:63] = 18'd0;
   assign pipe_rx_0_sigs_rp[81] = 1'b1;
   assign pipe_rx_0_sigs_rp[82] = 1'b0;
   // Very simple model of pipe_rxn_eqdone bits
   always @ (posedge pipe_clk_rp)
      if (pipe_tx_0_sigs_rp[55:54] != 0)
         pipe_rx_0_sigs_rp_83 <= 1'b1;
      else
         pipe_rx_0_sigs_rp_83 <= 1'b0;
   assign pipe_rx_0_sigs_rp[83] = pipe_rx_0_sigs_rp_83;
   assign pipe_rx_0_sigs_rp[44] = pipe_rx_0_sigs_rp_44;
  //------------------------------------------------------------------------------//
  // Lane - 1 RX BUS 
  //------------------------------------------------------------------------------//
   reg pipe_rx_1_sigs_rp_44;
   reg pipe_rx_1_sigs_rp_83;
   assign pipe_rx_1_sigs_rp[31: 0] = pipe_tx_1_sigs_ep[31: 0]; 
   assign pipe_rx_1_sigs_rp[33:32] = pipe_tx_1_sigs_ep[33:32]; 
   assign pipe_rx_1_sigs_rp[34]    = pipe_tx_1_sigs_ep[35]; 
   assign pipe_rx_1_sigs_rp[35]    = pipe_tx_1_sigs_ep[34]; 
   assign pipe_rx_1_sigs_rp[36]    = pipe_tx_1_sigs_ep[36]; 
   assign pipe_rx_1_sigs_rp[38:37] = pipe_tx_1_sigs_ep[38:37]; 
   assign pipe_rx_1_sigs_rp[41:39] = (PL_LINK_CAP_MAX_LINK_WIDTH >= 2 ) ? pipe_rxn_status_rp : 3'b0;
   assign pipe_rx_1_sigs_rp[42] = (PL_LINK_CAP_MAX_LINK_WIDTH >= 2 ) ? pipe_rxn_valid_rp : 1'b0;
   assign pipe_rx_1_sigs_rp[43] = (PL_LINK_CAP_MAX_LINK_WIDTH >= 2 ) ? pipe_rxn_phy_status_rp : 1'b0;
   // Very simple model of pipe_txn_eqdone bits
   always @ (posedge pipe_clk_rp)
      if (pipe_tx_1_sigs_rp[43:42] != 0)
         pipe_rx_1_sigs_rp_44 <= 1'b1; //pipe_tx0_eqdone
      else
         pipe_rx_1_sigs_rp_44 <= 1'b0; //pipe_tx0_eqdone
   assign pipe_rx_1_sigs_rp[62:45] = (PL_LINK_CAP_MAX_LINK_WIDTH >= 2 ) ? 18'd2 : 18'd0;
   assign pipe_rx_1_sigs_rp[80:63] = 18'd0;
   assign pipe_rx_1_sigs_rp[81] = 1'b1;
   assign pipe_rx_1_sigs_rp[82] = 1'b0;
   // Very simple model of pipe_txn_eqdone bits
   always @ (posedge pipe_clk_rp)
      if (pipe_tx_1_sigs_rp[55:54] != 0)
         pipe_rx_1_sigs_rp_83 <= 1'b1;
      else
         pipe_rx_1_sigs_rp_83 <= 1'b0;
   assign pipe_rx_1_sigs_rp[83] = pipe_rx_1_sigs_rp_83;
   assign pipe_rx_1_sigs_rp[44] = pipe_rx_1_sigs_rp_44;
  //------------------------------------------------------------------------------//
  // Lane - 2 RX BUS 
  //------------------------------------------------------------------------------//
   reg pipe_rx_2_sigs_rp_44;
   reg pipe_rx_2_sigs_rp_83;
   assign pipe_rx_2_sigs_rp[31: 0] = pipe_tx_2_sigs_ep[31: 0]; 
   assign pipe_rx_2_sigs_rp[33:32] = pipe_tx_2_sigs_ep[33:32]; 
   assign pipe_rx_2_sigs_rp[34]    = pipe_tx_2_sigs_ep[35]; 
   assign pipe_rx_2_sigs_rp[35]    = pipe_tx_2_sigs_ep[34]; 
   assign pipe_rx_2_sigs_rp[36]    = pipe_tx_2_sigs_ep[36]; 
   assign pipe_rx_2_sigs_rp[38:37] = pipe_tx_2_sigs_ep[38:37]; 
   assign pipe_rx_2_sigs_rp[41:39] = (PL_LINK_CAP_MAX_LINK_WIDTH >= 4 ) ? pipe_rxn_status_rp : 3'b0;
   assign pipe_rx_2_sigs_rp[42] = (PL_LINK_CAP_MAX_LINK_WIDTH >= 4 ) ? pipe_rxn_valid_rp : 1'b0;
   assign pipe_rx_2_sigs_rp[43] = (PL_LINK_CAP_MAX_LINK_WIDTH >= 4 ) ? pipe_rxn_phy_status_rp : 1'b0;
   // Very simple model of pipe_txn_eqdone bits
   always @ (posedge pipe_clk_rp)
      if (pipe_tx_2_sigs_rp[43:42] != 0)
         pipe_rx_2_sigs_rp_44 <= 1'b1; //pipe_tx0_eqdone
      else
         pipe_rx_2_sigs_rp_44 <= 1'b0; //pipe_tx0_eqdone
   assign pipe_rx_2_sigs_rp[62:45] = (PL_LINK_CAP_MAX_LINK_WIDTH >= 4 ) ? 18'd2 : 18'd0;
   assign pipe_rx_2_sigs_rp[80:63] = 18'd0;
   assign pipe_rx_2_sigs_rp[81] = 1'b1;
   assign pipe_rx_2_sigs_rp[82] = 1'b0;
   // Very simple model of pipe_txn_eqdone bits
   always @ (posedge pipe_clk_rp)
      if (pipe_tx_2_sigs_rp[55:54] != 0)
         pipe_rx_2_sigs_rp_83 <= 1'b1;
      else
         pipe_rx_2_sigs_rp_83 <= 1'b0;
   assign pipe_rx_2_sigs_rp[83] = pipe_rx_2_sigs_rp_83;
   assign pipe_rx_2_sigs_rp[44] = pipe_rx_2_sigs_rp_44;
  //------------------------------------------------------------------------------//
  // Lane - 3 RX BUS 
  //------------------------------------------------------------------------------//
   reg pipe_rx_3_sigs_rp_44;
   reg pipe_rx_3_sigs_rp_83;
   assign pipe_rx_3_sigs_rp[31: 0] = pipe_tx_3_sigs_ep[31: 0]; 
   assign pipe_rx_3_sigs_rp[33:32] = pipe_tx_3_sigs_ep[33:32]; 
   assign pipe_rx_3_sigs_rp[34]    = pipe_tx_3_sigs_ep[35]; 
   assign pipe_rx_3_sigs_rp[35]    = pipe_tx_3_sigs_ep[34]; 
   assign pipe_rx_3_sigs_rp[36]    = pipe_tx_3_sigs_ep[36]; 
   assign pipe_rx_3_sigs_rp[38:37] = pipe_tx_3_sigs_ep[38:37]; 
   assign pipe_rx_3_sigs_rp[41:39] = (PL_LINK_CAP_MAX_LINK_WIDTH >= 4 ) ? pipe_rxn_status_rp : 3'b0;
   assign pipe_rx_3_sigs_rp[42] = (PL_LINK_CAP_MAX_LINK_WIDTH >= 4 ) ? pipe_rxn_valid_rp : 1'b0;
   assign pipe_rx_3_sigs_rp[43] = (PL_LINK_CAP_MAX_LINK_WIDTH >= 4 ) ? pipe_rxn_phy_status_rp : 1'b0;
   // Very simple model of pipe_txn_eqdone bits
   always @ (posedge pipe_clk_rp)
      if (pipe_tx_3_sigs_rp[43:42] != 0)
         pipe_rx_3_sigs_rp_44 <= 1'b1; //pipe_tx0_eqdone
      else
         pipe_rx_3_sigs_rp_44 <= 1'b0; //pipe_tx0_eqdone
   assign pipe_rx_3_sigs_rp[62:45] = (PL_LINK_CAP_MAX_LINK_WIDTH >= 4 ) ? 18'd2 : 18'd0;
   assign pipe_rx_3_sigs_rp[80:63] = 18'd0;
   assign pipe_rx_3_sigs_rp[81] = 1'b1;
   assign pipe_rx_3_sigs_rp[82] = 1'b0;
   // Very simple model of pipe_txn_eqdone bits
   always @ (posedge pipe_clk_rp)
      if (pipe_tx_3_sigs_rp[55:54] != 0)
         pipe_rx_3_sigs_rp_83 <= 1'b1;
      else
         pipe_rx_3_sigs_rp_83 <= 1'b0;
   assign pipe_rx_3_sigs_rp[83] = pipe_rx_3_sigs_rp_83;
   assign pipe_rx_3_sigs_rp[44] = pipe_rx_3_sigs_rp_44;
  //------------------------------------------------------------------------------//
  // Lane - 4 RX BUS 
  //------------------------------------------------------------------------------//
   reg pipe_rx_4_sigs_rp_44;
   reg pipe_rx_4_sigs_rp_83;
   assign pipe_rx_4_sigs_rp[31: 0] = pipe_tx_4_sigs_ep[31: 0]; 
   assign pipe_rx_4_sigs_rp[33:32] = pipe_tx_4_sigs_ep[33:32]; 
   assign pipe_rx_4_sigs_rp[34]    = pipe_tx_4_sigs_ep[35]; 
   assign pipe_rx_4_sigs_rp[35]    = pipe_tx_4_sigs_ep[34]; 
   assign pipe_rx_4_sigs_rp[36]    = pipe_tx_4_sigs_ep[36]; 
   assign pipe_rx_4_sigs_rp[38:37] = pipe_tx_4_sigs_ep[38:37]; 
   assign pipe_rx_4_sigs_rp[41:39] = (PL_LINK_CAP_MAX_LINK_WIDTH >= 8 ) ? pipe_rxn_status_rp : 3'b0;
   assign pipe_rx_4_sigs_rp[42] = (PL_LINK_CAP_MAX_LINK_WIDTH >= 8 ) ? pipe_rxn_valid_rp : 1'b0;
   assign pipe_rx_4_sigs_rp[43] = (PL_LINK_CAP_MAX_LINK_WIDTH >= 8 ) ? pipe_rxn_phy_status_rp : 1'b0;
   // Very simple model of pipe_txn_eqdone bits
   always @ (posedge pipe_clk_rp)
      if (pipe_tx_4_sigs_rp[43:42] != 0)
         pipe_rx_4_sigs_rp_44 <= 1'b1; //pipe_tx0_eqdone
      else
         pipe_rx_4_sigs_rp_44 <= 1'b0; //pipe_tx0_eqdone
   assign pipe_rx_4_sigs_rp[62:45] = (PL_LINK_CAP_MAX_LINK_WIDTH >= 8 ) ? 18'd2 : 18'd0;
   assign pipe_rx_4_sigs_rp[80:63] = 18'd0;
   assign pipe_rx_4_sigs_rp[81] = 1'b1;
   assign pipe_rx_4_sigs_rp[82] = 1'b0;
   // Very simple model of pipe_txn_eqdone bits
   always @ (posedge pipe_clk_rp)
      if (pipe_tx_4_sigs_rp[55:54] != 0)
         pipe_rx_4_sigs_rp_83 <= 1'b1;
      else
         pipe_rx_4_sigs_rp_83 <= 1'b0;
   assign pipe_rx_4_sigs_rp[83] = pipe_rx_4_sigs_rp_83;
   assign pipe_rx_4_sigs_rp[44] = pipe_rx_4_sigs_rp_44;
  //------------------------------------------------------------------------------//
  // Lane - 5 RX BUS 
  //------------------------------------------------------------------------------//
   reg pipe_rx_5_sigs_rp_44;
   reg pipe_rx_5_sigs_rp_83;
   assign pipe_rx_5_sigs_rp[31: 0] = pipe_tx_5_sigs_ep[31: 0]; 
   assign pipe_rx_5_sigs_rp[33:32] = pipe_tx_5_sigs_ep[33:32]; 
   assign pipe_rx_5_sigs_rp[34]    = pipe_tx_5_sigs_ep[35]; 
   assign pipe_rx_5_sigs_rp[35]    = pipe_tx_5_sigs_ep[34]; 
   assign pipe_rx_5_sigs_rp[36]    = pipe_tx_5_sigs_ep[36]; 
   assign pipe_rx_5_sigs_rp[38:37] = pipe_tx_5_sigs_ep[38:37]; 
   assign pipe_rx_5_sigs_rp[41:39] = (PL_LINK_CAP_MAX_LINK_WIDTH >= 8 ) ? pipe_rxn_status_rp : 3'b0;
   assign pipe_rx_5_sigs_rp[42] = (PL_LINK_CAP_MAX_LINK_WIDTH >= 8 ) ? pipe_rxn_valid_rp : 1'b0;
   assign pipe_rx_5_sigs_rp[43] = (PL_LINK_CAP_MAX_LINK_WIDTH >= 8 ) ? pipe_rxn_phy_status_rp : 1'b0;
   // Very simple model of pipe_txn_eqdone bits
   always @ (posedge pipe_clk_rp)
      if (pipe_tx_5_sigs_rp[43:42] != 0)
         pipe_rx_5_sigs_rp_44 <= 1'b1; //pipe_tx0_eqdone
      else
         pipe_rx_5_sigs_rp_44 <= 1'b0; //pipe_tx0_eqdone
   assign pipe_rx_5_sigs_rp[62:45] = (PL_LINK_CAP_MAX_LINK_WIDTH >= 8 ) ? 18'd2 : 18'd0;
   assign pipe_rx_5_sigs_rp[80:63] = 18'd0;
   assign pipe_rx_5_sigs_rp[81] = 1'b1;
   assign pipe_rx_5_sigs_rp[82] = 1'b0;
   // Very simple model of pipe_txn_eqdone bits
   always @ (posedge pipe_clk_rp)
      if (pipe_tx_5_sigs_rp[55:54] != 0)
         pipe_rx_5_sigs_rp_83 <= 1'b1;
      else
         pipe_rx_5_sigs_rp_83 <= 1'b0;
   assign pipe_rx_5_sigs_rp[83] = pipe_rx_5_sigs_rp_83;
   assign pipe_rx_5_sigs_rp[44] = pipe_rx_5_sigs_rp_44;
  //------------------------------------------------------------------------------//
  // Lane - 6 RX BUS 
  //------------------------------------------------------------------------------//
   reg pipe_rx_6_sigs_rp_44;
   reg pipe_rx_6_sigs_rp_83;
   assign pipe_rx_6_sigs_rp[31: 0] = pipe_tx_6_sigs_ep[31: 0]; 
   assign pipe_rx_6_sigs_rp[33:32] = pipe_tx_6_sigs_ep[33:32]; 
   assign pipe_rx_6_sigs_rp[34]    = pipe_tx_6_sigs_ep[35]; 
   assign pipe_rx_6_sigs_rp[35]    = pipe_tx_6_sigs_ep[34]; 
   assign pipe_rx_6_sigs_rp[36]    = pipe_tx_6_sigs_ep[36]; 
   assign pipe_rx_6_sigs_rp[38:37] = pipe_tx_6_sigs_ep[38:37]; 
   assign pipe_rx_6_sigs_rp[41:39] = (PL_LINK_CAP_MAX_LINK_WIDTH >= 8 ) ? pipe_rxn_status_rp : 3'b0;
   assign pipe_rx_6_sigs_rp[42] = (PL_LINK_CAP_MAX_LINK_WIDTH >= 8 ) ? pipe_rxn_valid_rp : 1'b0;
   assign pipe_rx_6_sigs_rp[43] = (PL_LINK_CAP_MAX_LINK_WIDTH >= 8 ) ? pipe_rxn_phy_status_rp : 1'b0;
   // Very simple model of pipe_txn_eqdone bits
   always @ (posedge pipe_clk_rp)
      if (pipe_tx_6_sigs_rp[43:42] != 0)
         pipe_rx_6_sigs_rp_44 <= 1'b1; //pipe_tx0_eqdone
      else
         pipe_rx_6_sigs_rp_44 <= 1'b0; //pipe_tx0_eqdone
   assign pipe_rx_6_sigs_rp[62:45] = (PL_LINK_CAP_MAX_LINK_WIDTH >= 8 ) ? 18'd2 : 18'd0;
   assign pipe_rx_6_sigs_rp[80:63] = 18'd0;
   assign pipe_rx_6_sigs_rp[81] = 1'b1;
   assign pipe_rx_6_sigs_rp[82] = 1'b0;
   // Very simple model of pipe_txn_eqdone bits
   always @ (posedge pipe_clk_rp)
      if (pipe_tx_6_sigs_rp[55:54] != 0)
         pipe_rx_6_sigs_rp_83 <= 1'b1;
      else
         pipe_rx_6_sigs_rp_83 <= 1'b0;
   assign pipe_rx_6_sigs_rp[83] = pipe_rx_6_sigs_rp_83;
   assign pipe_rx_6_sigs_rp[44] = pipe_rx_6_sigs_rp_44;
  //------------------------------------------------------------------------------//
  // Lane - 7 RX BUS 
  //------------------------------------------------------------------------------//
   reg pipe_rx_7_sigs_rp_44;
   reg pipe_rx_7_sigs_rp_83;
   assign pipe_rx_7_sigs_rp[31: 0] = pipe_tx_7_sigs_ep[31: 0]; 
   assign pipe_rx_7_sigs_rp[33:32] = pipe_tx_7_sigs_ep[33:32]; 
   assign pipe_rx_7_sigs_rp[34]    = pipe_tx_7_sigs_ep[35]; 
   assign pipe_rx_7_sigs_rp[35]    = pipe_tx_7_sigs_ep[34]; 
   assign pipe_rx_7_sigs_rp[36]    = pipe_tx_7_sigs_ep[36]; 
   assign pipe_rx_7_sigs_rp[38:37] = pipe_tx_7_sigs_ep[38:37]; 
   assign pipe_rx_7_sigs_rp[41:39] = (PL_LINK_CAP_MAX_LINK_WIDTH >= 8 ) ? pipe_rxn_status_rp : 3'b0;
   assign pipe_rx_7_sigs_rp[42] = (PL_LINK_CAP_MAX_LINK_WIDTH >= 8 ) ? pipe_rxn_valid_rp : 1'b0;
   assign pipe_rx_7_sigs_rp[43] = (PL_LINK_CAP_MAX_LINK_WIDTH >= 8 ) ? pipe_rxn_phy_status_rp : 1'b0;
   // Very simple model of pipe_txn_eqdone bits
   always @ (posedge pipe_clk_rp)
      if (pipe_tx_7_sigs_rp[43:42] != 0)
         pipe_rx_7_sigs_rp_44 <= 1'b1; //pipe_tx0_eqdone
      else
         pipe_rx_7_sigs_rp_44 <= 1'b0; //pipe_tx0_eqdone
   assign pipe_rx_7_sigs_rp[62:45] = (PL_LINK_CAP_MAX_LINK_WIDTH >= 8 ) ? 18'd2 : 18'd0;
   assign pipe_rx_7_sigs_rp[80:63] = 18'd0;
   assign pipe_rx_7_sigs_rp[81] = 1'b1;
   assign pipe_rx_7_sigs_rp[82] = 1'b0;
   // Very simple model of pipe_txn_eqdone bits
   always @ (posedge pipe_clk_rp)
      if (pipe_tx_7_sigs_rp[55:54] != 0)
         pipe_rx_7_sigs_rp_83 <= 1'b1;
      else
         pipe_rx_7_sigs_rp_83 <= 1'b0;
   assign pipe_rx_7_sigs_rp[83] = pipe_rx_7_sigs_rp_83;
   assign pipe_rx_7_sigs_rp[44] = pipe_rx_7_sigs_rp_44;
  //------------------------------------------------------------------------------//




endmodule

//   assign pipe_rx0_chanisaligned = pipe_rxn_valid_ep;
//   assign pipe_rx1_chanisaligned = (PL_LINK_CAP_MAX_LINK_WIDTH >= 2 ) ? pipe_rxn_valid_ep : 1'b0;
//   assign pipe_rx2_chanisaligned = (PL_LINK_CAP_MAX_LINK_WIDTH >= 4 ) ? pipe_rxn_valid_ep : 1'b0;
//   assign pipe_rx3_chanisaligned = (PL_LINK_CAP_MAX_LINK_WIDTH >= 4 ) ? pipe_rxn_valid_ep : 1'b0;
//   assign pipe_rx4_chanisaligned = (PL_LINK_CAP_MAX_LINK_WIDTH >= 8 ) ? pipe_rxn_valid_ep : 1'b0;
//   assign pipe_rx5_chanisaligned = (PL_LINK_CAP_MAX_LINK_WIDTH >= 8 ) ? pipe_rxn_valid_ep : 1'b0;
//   assign pipe_rx6_chanisaligned = (PL_LINK_CAP_MAX_LINK_WIDTH >= 8 ) ? pipe_rxn_valid_ep : 1'b0;
//   assign pipe_rx7_chanisaligned = (PL_LINK_CAP_MAX_LINK_WIDTH >= 8 ) ? pipe_rxn_valid_ep : 1'b0;
   
