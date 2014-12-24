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
// File       : board.v
// Version    : 1.0 
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
//
// Description: Top level testbench
//
//------------------------------------------------------------------------------

`timescale 1ps/1ps

`include "board_common.vh"

`define SIMULATION

module board;

  parameter          REF_CLK_FREQ       = 0 ;      // 0 - 100 MHz, 1 - 125 MHz,  2 - 250 MHz

  localparam         REF_CLK_HALF_CYCLE = (REF_CLK_FREQ == 0) ? 5000 :
                                          (REF_CLK_FREQ == 1) ? 4000 :
                                          (REF_CLK_FREQ == 2) ? 2000 : 0;

  localparam   [2:0] PF0_DEV_CAP_MAX_PAYLOAD_SIZE = 3'b010;
  `ifdef LINKWIDTH
  localparam   [3:0] LINK_WIDTH = 4'h`LINKWIDTH;
  `else
  localparam   [3:0] LINK_WIDTH = 4'h8;
  `endif
  `ifdef LINKSPEED
  localparam   [2:0] LINK_SPEED = 3'h`LINKSPEED;
  `else
  localparam   [2:0] LINK_SPEED = 3'h2;
  `endif


  // System-level clock and reset
  reg                sys_rst_n;

  reg                sys_clk;

  //
  // PCI-Express Serial Interconnect
  //

  wire  [(LINK_WIDTH-1):0]  ep_pci_exp_txn;
  wire  [(LINK_WIDTH-1):0]  ep_pci_exp_txp;
  wire  [(LINK_WIDTH-1):0]  rp_pci_exp_txn;
  wire  [(LINK_WIDTH-1):0]  rp_pci_exp_txp;

  wire  [25:0]  common_commands_in_ep;
  wire  [83:0]  pipe_rx_0_sigs_ep;
  wire  [83:0]  pipe_rx_1_sigs_ep;
  wire  [83:0]  pipe_rx_2_sigs_ep;
  wire  [83:0]  pipe_rx_3_sigs_ep;
  wire  [83:0]  pipe_rx_4_sigs_ep;
  wire  [83:0]  pipe_rx_5_sigs_ep;
  wire  [83:0]  pipe_rx_6_sigs_ep;
  wire  [83:0]  pipe_rx_7_sigs_ep;
  
  wire  [16:0]  common_commands_out_ep;
  wire  [69:0]  pipe_tx_0_sigs_ep;
  wire  [69:0]  pipe_tx_1_sigs_ep;
  wire  [69:0]  pipe_tx_2_sigs_ep;
  wire  [69:0]  pipe_tx_3_sigs_ep;
  wire  [69:0]  pipe_tx_4_sigs_ep;
  wire  [69:0]  pipe_tx_5_sigs_ep;
  wire  [69:0]  pipe_tx_6_sigs_ep;
  wire  [69:0]  pipe_tx_7_sigs_ep;

  wire  [25:0]  common_commands_in_rp;
  wire  [83:0]  pipe_rx_0_sigs_rp;
  wire  [83:0]  pipe_rx_1_sigs_rp;
  wire  [83:0]  pipe_rx_2_sigs_rp;
  wire  [83:0]  pipe_rx_3_sigs_rp;
  wire  [83:0]  pipe_rx_4_sigs_rp;
  wire  [83:0]  pipe_rx_5_sigs_rp;
  wire  [83:0]  pipe_rx_6_sigs_rp;
  wire  [83:0]  pipe_rx_7_sigs_rp;
  
  wire  [16:0]  common_commands_out_rp;
  wire  [69:0]  pipe_tx_0_sigs_rp;
  wire  [69:0]  pipe_tx_1_sigs_rp;
  wire  [69:0]  pipe_tx_2_sigs_rp;
  wire  [69:0]  pipe_tx_3_sigs_rp;
  wire  [69:0]  pipe_tx_4_sigs_rp;
  wire  [69:0]  pipe_tx_5_sigs_rp;
  wire  [69:0]  pipe_tx_6_sigs_rp;
  wire  [69:0]  pipe_tx_7_sigs_rp;

`ifdef ETH_TEST

  wire [1:0] xphy_txp, xphy_txn, xphy_rxp, xphy_rxn;
  reg clk156_25;

  assign xphy_rxp = xphy_txp;
  assign xphy_rxn = xphy_txn;

  initial 
    clk156_25 = 1'b0;

    //- 156.25MHz clock
  always #(3200) clk156_25 = ~clk156_25;

`endif


`ifdef ETH_TEST
  defparam board.dut.kcu105_2x10G_i.pcie3_ultrascale_0.inst.EXT_PIPE_SIM = "TRUE";
`else
  defparam board.dut.kcu105_base_i.pcie3_ultrascale_0.inst.EXT_PIPE_SIM = "TRUE";
`endif    
//defparam board.dut.kcu105_base_i.pcie3_ultrascale_0.inst.EXT_PIPE_SIM = "TRUE";

defparam board.RP.pcie3_uscale_rp_top_i.pcie3_uscale_core_top_inst.EXT_PIPE_SIM = "TRUE";
        


  // PCI-Express Model Root Port Instance
  //

  xilinx_pcie3_uscale_rp
  #(
     .PF0_DEV_CAP_MAX_PAYLOAD_SIZE(PF0_DEV_CAP_MAX_PAYLOAD_SIZE)
     //ONLY FOR RP
  ) RP (

    // SYS Inteface
    .sys_clk_n(~sys_clk),
    .sys_clk_p(sys_clk),
    .sys_rst_n(sys_rst_n),
    .common_commands_in (common_commands_in_rp ),
    .pipe_rx_0_sigs     (pipe_rx_0_sigs_rp     ),
    .pipe_rx_1_sigs     (pipe_rx_1_sigs_rp     ),
    .pipe_rx_2_sigs     (pipe_rx_2_sigs_rp     ),
    .pipe_rx_3_sigs     (pipe_rx_3_sigs_rp     ),
    .pipe_rx_4_sigs     (pipe_rx_4_sigs_rp     ),
    .pipe_rx_5_sigs     (pipe_rx_5_sigs_rp     ),
    .pipe_rx_6_sigs     (pipe_rx_6_sigs_rp     ),
    .pipe_rx_7_sigs     (pipe_rx_7_sigs_rp     ),
                                            
    .common_commands_out(common_commands_out_rp),
    .pipe_tx_0_sigs     (pipe_tx_0_sigs_rp     ),
    .pipe_tx_1_sigs     (pipe_tx_1_sigs_rp     ),
    .pipe_tx_2_sigs     (pipe_tx_2_sigs_rp     ),
    .pipe_tx_3_sigs     (pipe_tx_3_sigs_rp     ),
    .pipe_tx_4_sigs     (pipe_tx_4_sigs_rp     ),
    .pipe_tx_5_sigs     (pipe_tx_5_sigs_rp     ),
    .pipe_tx_6_sigs     (pipe_tx_6_sigs_rp     ),
    .pipe_tx_7_sigs     (pipe_tx_7_sigs_rp     ),

  
    // PCI-Express Interface
    .pci_exp_txn(rp_pci_exp_txn),
    .pci_exp_txp(rp_pci_exp_txp),
    .pci_exp_rxn(ep_pci_exp_txn),
    .pci_exp_rxp(ep_pci_exp_txp)
  );

  //------------------------------------------------------------------------------//
  // Simulation endpoint with PIO Slave
  //------------------------------------------------------------------------------//
  //
  // PCI-Express Endpoint Instance
  //
`ifdef ETH_TEST
  kcu105_2x10g_top
`else  
 kcu105_base_top 
`endif 
  dut (

  // SYS Inteface
  .perst_n          (sys_rst_n),
  .pcie_ref_clk_n   (~sys_clk),
  .pcie_ref_clk_p   ( sys_clk),
  .pcie3_ext_pipe_interface_commands_in(common_commands_in_ep),
  .pcie3_ext_pipe_interface_commands_out(common_commands_out_ep),
  .pcie3_ext_pipe_interface_rx_0_sigs(pipe_rx_0_sigs_ep),
  .pcie3_ext_pipe_interface_rx_1_sigs(pipe_rx_1_sigs_ep),
  .pcie3_ext_pipe_interface_rx_2_sigs(pipe_rx_2_sigs_ep),
  .pcie3_ext_pipe_interface_rx_3_sigs(pipe_rx_3_sigs_ep),
  .pcie3_ext_pipe_interface_rx_4_sigs(pipe_rx_4_sigs_ep),
  .pcie3_ext_pipe_interface_rx_5_sigs(pipe_rx_5_sigs_ep),
  .pcie3_ext_pipe_interface_rx_6_sigs(pipe_rx_6_sigs_ep),
  .pcie3_ext_pipe_interface_rx_7_sigs(pipe_rx_7_sigs_ep),
  .pcie3_ext_pipe_interface_tx_0_sigs(pipe_tx_0_sigs_ep),
  .pcie3_ext_pipe_interface_tx_1_sigs(pipe_tx_1_sigs_ep),
  .pcie3_ext_pipe_interface_tx_2_sigs(pipe_tx_2_sigs_ep),
  .pcie3_ext_pipe_interface_tx_3_sigs(pipe_tx_3_sigs_ep),
  .pcie3_ext_pipe_interface_tx_4_sigs(pipe_tx_4_sigs_ep),
  .pcie3_ext_pipe_interface_tx_5_sigs(pipe_tx_5_sigs_ep),
  .pcie3_ext_pipe_interface_tx_6_sigs(pipe_tx_6_sigs_ep),
  .pcie3_ext_pipe_interface_tx_7_sigs(pipe_tx_7_sigs_ep),
  // PCI-Express Interface
  .pcie_tx_n     (ep_pci_exp_txn),
  .pcie_tx_p     (ep_pci_exp_txp),
  .pcie_rx_n     (rp_pci_exp_txn),
  .pcie_rx_p     (rp_pci_exp_txp),
`ifdef ETH_TEST
  .refclk_p       (clk156_25),
  .refclk_n       (~clk156_25),
  .xphy_txp       (xphy_txp),
  .xphy_txn       (xphy_txn),
  .xphy_rxp       (xphy_rxp),
  .xphy_rxn       (xphy_rxn),
`endif
  .led              ()
);

//
// Please refer text at the end of this file for PIPE Ports details. 
//
localparam integer USER_CLK_FREQ  = ((LINK_SPEED == 3'h4) ? 5 : 4);
localparam integer USER_CLK2_FREQ = ((3) + 1);
// USER_CLK2_FREQ = AXI Interface Frequency
//   0: Disable User Clock
//   1: 31.25 MHz
//   2: 62.50 MHz  (default)
//   3: 125.00 MHz
//   4: 250.00 MHz
//   5: 500.00 MHz
//
pcie3_ultrascale_0_phy_sig_gen #(
     .TCQ                        ( 1 ),
     .PL_LINK_CAP_MAX_LINK_WIDTH ( LINK_WIDTH ), // 1- GEN1, 2 - GEN2, 4 - GEN3
     .CLK_SHARING_EN             ( "FALSE" ),
     .PCIE_REFCLK_FREQ           ( REF_CLK_FREQ ), 
     .PCIE_USERCLK1_FREQ         ( USER_CLK_FREQ ), 
     .PCIE_USERCLK2_FREQ         ( USER_CLK2_FREQ ) 
  ) pcie3_ultrascale_0_phy_gen_rp_ep_i (
  //-----------------------------------------------------
  // SYS Inteface
    .sys_clk                    ( sys_clk ),
    .sys_rst_n                  ( sys_rst_n ),
  //---------------------- EP -------------------------------
    .common_commands_in_ep      ( common_commands_in_ep  ), 
    .pipe_rx_0_sigs_ep          ( pipe_rx_0_sigs_ep      ), 
    .pipe_rx_1_sigs_ep          ( pipe_rx_1_sigs_ep      ), 
    .pipe_rx_2_sigs_ep          ( pipe_rx_2_sigs_ep      ), 
    .pipe_rx_3_sigs_ep          ( pipe_rx_3_sigs_ep      ), 
    .pipe_rx_4_sigs_ep          ( pipe_rx_4_sigs_ep      ), 
    .pipe_rx_5_sigs_ep          ( pipe_rx_5_sigs_ep      ), 
    .pipe_rx_6_sigs_ep          ( pipe_rx_6_sigs_ep      ), 
    .pipe_rx_7_sigs_ep          ( pipe_rx_7_sigs_ep      ), 
                                                  
    .common_commands_out_ep     ( common_commands_out_ep ), 
    .pipe_tx_0_sigs_ep          ( pipe_tx_0_sigs_ep      ), 
    .pipe_tx_1_sigs_ep          ( pipe_tx_1_sigs_ep      ), 
    .pipe_tx_2_sigs_ep          ( pipe_tx_2_sigs_ep      ), 
    .pipe_tx_3_sigs_ep          ( pipe_tx_3_sigs_ep      ), 
    .pipe_tx_4_sigs_ep          ( pipe_tx_4_sigs_ep      ), 
    .pipe_tx_5_sigs_ep          ( pipe_tx_5_sigs_ep      ), 
    .pipe_tx_6_sigs_ep          ( pipe_tx_6_sigs_ep      ), 
    .pipe_tx_7_sigs_ep          ( pipe_tx_7_sigs_ep      ), 
  //---------------------- RP -------------------------------
    .common_commands_in_rp      ( common_commands_in_rp  ), 
    .pipe_rx_0_sigs_rp          ( pipe_rx_0_sigs_rp      ), 
    .pipe_rx_1_sigs_rp          ( pipe_rx_1_sigs_rp      ), 
    .pipe_rx_2_sigs_rp          ( pipe_rx_2_sigs_rp      ), 
    .pipe_rx_3_sigs_rp          ( pipe_rx_3_sigs_rp      ), 
    .pipe_rx_4_sigs_rp          ( pipe_rx_4_sigs_rp      ), 
    .pipe_rx_5_sigs_rp          ( pipe_rx_5_sigs_rp      ), 
    .pipe_rx_6_sigs_rp          ( pipe_rx_6_sigs_rp      ), 
    .pipe_rx_7_sigs_rp          ( pipe_rx_7_sigs_rp      ), 
                                                  
    .common_commands_out_rp     ( common_commands_out_rp ), 
    .pipe_tx_0_sigs_rp          ( pipe_tx_0_sigs_rp      ), 
    .pipe_tx_1_sigs_rp          ( pipe_tx_1_sigs_rp      ), 
    .pipe_tx_2_sigs_rp          ( pipe_tx_2_sigs_rp      ), 
    .pipe_tx_3_sigs_rp          ( pipe_tx_3_sigs_rp      ), 
    .pipe_tx_4_sigs_rp          ( pipe_tx_4_sigs_rp      ), 
    .pipe_tx_5_sigs_rp          ( pipe_tx_5_sigs_rp      ), 
    .pipe_tx_6_sigs_rp          ( pipe_tx_6_sigs_rp      ), 
    .pipe_tx_7_sigs_rp          ( pipe_tx_7_sigs_rp      ) 
  //-----------------------------------------------------
  );

  initial begin
    sys_clk = 0;
    forever #(REF_CLK_HALF_CYCLE) sys_clk = ~sys_clk;
  end

  //------------------------------------------------------------------------------//
  // Generate system-level reset
  //------------------------------------------------------------------------------//
  initial begin
    $display("[%t] : System Reset Is Asserted...", $realtime);
    sys_rst_n = 1'b0;
    repeat (500) @(posedge sys_clk);
    $display("[%t] : System Reset Is De-asserted...", $realtime);
    sys_rst_n = 1'b1;
  end

  initial begin

    if ($test$plusargs ("dump_all")) begin

  `ifdef NCV // Cadence TRN dump

      $recordsetup("design=board",
                   "compress",
                   "wrapsize=100M",
                   "version=1",
                   "run=1");
      $recordvars();

  `elsif VCS //Synopsys VPD dump

      $vcdplusfile("board.vpd");
      $vcdpluson;
      $vcdplusglitchon;
      $vcdplusflush;

  `else

      // Verilog VC dump
      $dumpfile("board.vcd");
      $dumpvars(0, board);

  `endif

    end

  end


endmodule // BOARD
