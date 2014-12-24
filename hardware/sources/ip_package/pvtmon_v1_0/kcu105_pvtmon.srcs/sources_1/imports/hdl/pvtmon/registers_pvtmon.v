//-----------------------------------------------------------------------------
//
// (c) Copyright 2012-2013 Xilinx, Inc. All rights reserved.
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
// Project    : Virtex-7 XT Connectivity Domain Targeted Reference Design 
// File       : registers.v
//
//-----------------------------------------------------------------------------
//

module registers_pvtmon #(
  parameter ADDR_WIDTH  = 32,
  parameter DATA_WIDTH  = 32,
  parameter NUM_POWER_REG = 13
) (
    //-IPIC Interface

  input [ADDR_WIDTH-1:0]        Bus2IP_Addr,
  input                         Bus2IP_RNW,
  input                         Bus2IP_CS,
  input [DATA_WIDTH-1:0]        Bus2IP_Data,
  output reg [DATA_WIDTH-1:0]   IP2Bus_Data,
  output reg                    IP2Bus_WrAck,
  output reg                    IP2Bus_RdAck,
  output                        IP2Bus_Error,
    //- User registers
  input [(NUM_POWER_REG * 32) - 1: 0] power_status_reg,
    //- System signals
  input                         Clk,
  input                         Resetn
);

  //- Address offset definitions
  localparam [15:0] 
        //- Design Info registers
      DESIGN_VERSION      = 16'h0000,
      SCRATCHPAD          = 16'h0004,
        //- Power Monitor registers
      PWR_VCCINT_REG      = 16'h0040,
      PWR_VCCAUX_REG      = 16'h0044,
      PWR_VCC3_3_REG      = 16'h0048,
      PWR_VADJ            = 16'h004C,
      PWR_VCC1_5_REG      = 16'h0050,
      PWR_VCC2_5_REG      = 16'h0054,
      PWR_MGT_AVCC_REG    = 16'h0058,
      PWR_MGT_AVTT_REG    = 16'h005C,
      PWR_VCCAUX_IO_REG   = 16'h0060,
      PWR_VCCBRAM_REG     = 16'h0064,
      PWR_MGT_VCCAUX_REG  = 16'h0068,
      PWR_VCC1_8_REG      = 16'h006C,
      DIE_TEMP_REG        = 16'h0070;

  reg [31:0] scratch_reg = 0;

  assign IP2Bus_Error = 1'b0;

 /*
  * On the assertion of CS, RNW port is checked for read or a write
  * transaction. 
  * In case of a write transaction, the relevant register is written to and
  * WrAck generated.
  * In case of reads, the read data along with RdAck is generated.
  */
 
  always @(posedge Clk)
    if (Resetn == 1'b0)
    begin
      scratch_reg   <= 32'hDEAD_DEAF;
      IP2Bus_Data   <= 32'd0;
      IP2Bus_WrAck  <= 1'b0;
      IP2Bus_RdAck  <= 1'b0;
    end
    else
    begin
        //- Write transaction
      if (Bus2IP_CS & ~Bus2IP_RNW)
      begin
        if (Bus2IP_Addr[11:8] == 'h0)
        case (Bus2IP_Addr[7:0])
          SCRATCHPAD[7:0] : scratch_reg <= Bus2IP_Data;
        endcase
        IP2Bus_WrAck  <= 1'b1;
        IP2Bus_Data   <= 32'd0;
        IP2Bus_RdAck  <= 1'b0;  
      end
        //- Read transaction
      else if (Bus2IP_CS & Bus2IP_RNW)
      begin
       if(Bus2IP_Addr[11:8]=='h0) 
        case (Bus2IP_Addr[7:0])
            /* [31:20] : Rsvd
             * [19:16] : Device, 0 -> A7, 1 -> K7, 2 -> V7, 3 -> V7 XT 
             * [15:8]  : DMA version (major, minor)
             * [7:0]   : Design version (major, minor)
             */
          DESIGN_VERSION[7:0]    : IP2Bus_Data <= {12'd0,4'h3,8'h10,8'h10};
          SCRATCHPAD[7:0]        : IP2Bus_Data <= scratch_reg; 
          PWR_VCCINT_REG[7:0]    : IP2Bus_Data <= power_status_reg[31:0];
          PWR_VCCAUX_REG[7:0]    : IP2Bus_Data <= power_status_reg[63:32];
          PWR_VCC3_3_REG[7:0]    : IP2Bus_Data <= power_status_reg[95:64];
          PWR_VADJ[7:0]          : IP2Bus_Data <= power_status_reg[127:96];
          PWR_VCC1_5_REG[7:0]    : IP2Bus_Data <= power_status_reg[159:128];
          PWR_VCC2_5_REG[7:0]    : IP2Bus_Data <= power_status_reg[191:160];
          PWR_MGT_AVCC_REG[7:0]  : IP2Bus_Data <= power_status_reg[223:192];
          PWR_MGT_AVTT_REG[7:0]  : IP2Bus_Data <= power_status_reg[255:224];
          PWR_VCCAUX_IO_REG[7:0] : IP2Bus_Data <= power_status_reg[287:256];
          //PWR_VCCBRAM_REG[7:0]   : IP2Bus_Data <= power_status_reg[383:352];
          PWR_VCCBRAM_REG[7:0]   : IP2Bus_Data <= power_status_reg[319:288];
          PWR_MGT_VCCAUX_REG[7:0]: IP2Bus_Data <= power_status_reg[351:320];
          PWR_VCC1_8_REG[7:0]    : IP2Bus_Data <= power_status_reg[383:352];
          DIE_TEMP_REG[7:0]      : IP2Bus_Data <= power_status_reg[415:384];
          
        endcase
        IP2Bus_RdAck  <= 1'b1;
        IP2Bus_WrAck  <= 1'b0;
      end
      else
      begin
        IP2Bus_Data   <= 32'd0;
        IP2Bus_WrAck  <= 1'b0;
        IP2Bus_RdAck  <= 1'b0;
      end
    end
  
endmodule
