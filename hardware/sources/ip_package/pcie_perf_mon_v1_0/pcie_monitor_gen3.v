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
// File       : pcie_monitor_gen3.v
//
//-----------------------------------------------------------------------------
//
//
// Monitors the PCIe AXI interface to keep track of byte count sent/received during
// a one second time period.  Last two bits of byte count are dropped and replaced
// with a 2-bit sample count indicating that sample period to which the information
// belongs.  Software will read the registers every second, and will group together
// data from the same sample count.
//
`timescale 1ps / 1ps

module pcie_monitor_gen3
#( parameter TDATA_WIDTH = 128,
   parameter TKEEP_WIDTH = TDATA_WIDTH/32)
 (
   input                   clk,
   input                   reset,
   //input [7:0]             clk_period_in_ns,
   input [1:0]             scaling_factor,   
   input [31:0]            one_second_cnt,

   // PCIe Completer Request Interface
   input [TDATA_WIDTH-1:0] m_axis_cq_tdata,
   input                   m_axis_cq_tlast,
   input                   m_axis_cq_tvalid,
   input                   m_axis_cq_tready,
   input [84:0]            m_axis_cq_tuser,
   
   // PCIe Completer Completion Interface
   input [TDATA_WIDTH-1:0] s_axis_cc_tdata,
   input                   s_axis_cc_tlast,
   input                   s_axis_cc_tvalid,
   input                   s_axis_cc_tready,
   input [32:0]            s_axis_cc_tuser,

   // PCIe Requester Request Interface
   input [TDATA_WIDTH-1:0] s_axis_rq_tdata,
   input                   s_axis_rq_tlast,
   input                   s_axis_rq_tvalid,
   input                   s_axis_rq_tready,
   input [TKEEP_WIDTH-1:0] s_axis_rq_tkeep,
   input [59:0]            s_axis_rq_tuser,
   
   // PCIe Requester Completion Interface
   input [TDATA_WIDTH-1:0] m_axis_rc_tdata,
   input                   m_axis_rc_tlast,
   input                   m_axis_rc_tvalid,
   input                   m_axis_rc_tready,
   input [74:0]            m_axis_rc_tuser,

   input       [11:0]    fc_cpld,
   input       [7:0]     fc_cplh,
   input       [11:0]    fc_npd,
   input       [7:0]     fc_nph,
   input       [11:0]    fc_pd,
   input       [7:0]     fc_ph,
   output      [2:0]     fc_sel,
   
   output reg  [11:0]    init_fc_cpld,
   output reg  [7:0]     init_fc_cplh,
   output reg  [11:0]    init_fc_npd,
   output reg  [7:0]     init_fc_nph,
   output reg  [11:0]    init_fc_pd,
   output reg  [7:0]     init_fc_ph,


   output reg  [31:0]    tx_byte_count,
   output reg  [31:0]    rx_byte_count
 //  output reg  [31:0]    tx_payload_count,
 //  output reg  [31:0]    rx_payload_count

);

   reg  [33:0] s_axis_byte_count;
   reg  [33:0] m_axis_byte_count;
   reg  [33:0] s_axis_payload_count;
   reg  [33:0] m_axis_payload_count;
   reg  [31:0] tx_byte_count_int;
   reg  [31:0] rx_byte_count_int;
   reg  [31:0] tx_payload_count_int;
   reg  [31:0] rx_payload_count_int;
   reg  [1:0]  sample_cnt;
   reg  [1:0]  capture_count;
   reg         captured_initfc;
   reg  [30:0] running_test_time;
//   wire [30:0] one_second_cnt;
 reg  [31:0]    tx_payload_count;
 reg  [31:0]    rx_payload_count;
  // CQ Interface
  reg        m_axis_cq_tlast_reg = 'd0;
  reg        m_axis_cq_tvalid_reg = 'd0;
  reg        m_axis_cq_tready_reg = 'd0;
  reg        m_axis_cq_tsop_reg = 'd0;
  reg        m_axis_cq_tdsc_reg = 'd0;
  reg        m_axis_cq_tdsc_latched = 'd0;
  reg [3:0]  m_axis_cq_Fbyte_en_reg = 'd0; 
  reg [3:0]  m_axis_cq_Lbyte_en_reg = 'd0; 
  reg [3:0]  m_axis_cq_ReqType_reg = 'd0; 
  reg [10:0] m_axis_cq_DWcnt_reg = 'd0;
  reg [33:0] m_axis_cq_payload_byte_cnt = 'd0;
  reg [33:0] m_axis_cq_total_byte_cnt = 'd0;
  reg [33:0] m_axis_cq_payload_byte_cnt_r = 'd0;
  reg [33:0] m_axis_cq_total_byte_cnt_r = 'd0;

  // CC Interface
  reg        s_axis_cc_tlast_reg = 'd0;
  reg        s_axis_cc_tvalid_reg = 'd0;
  reg        s_axis_cc_tready_reg = 'd0;
  reg        s_axis_cc_tsop_reg = 'd0;
  reg        s_axis_cc_tdsc_reg = 'd0;
  reg        s_axis_cc_tdsc_latched = 'd0;
  reg        expect_tstart_on_cc_intr = 'd0;
  reg [10:0] s_axis_cc_DWcnt_reg = 'd0;
  reg [12:0] s_axis_cc_Bytecnt_reg = 'd0;
  reg [33:0] s_axis_cc_payload_byte_cnt = 'd0;
  reg [33:0] s_axis_cc_total_byte_cnt = 'd0;
  reg [33:0] s_axis_cc_payload_byte_cnt_r = 'd0;
  reg [33:0] s_axis_cc_total_byte_cnt_r = 'd0;

  // RQ Interface
  reg        s_axis_rq_tlast_reg = 'd0;
  reg        s_axis_rq_tlast_r1 = 'd0;
  reg        s_axis_rq_tlast_r2 = 'd0;
  reg        s_axis_rq_tlast_r3 = 'd0;
  reg        s_axis_rq_tvalid_reg = 'd0;
  reg        s_axis_rq_tvalid_r1 = 'd0;
  reg        s_axis_rq_tvalid_r2 = 'd0;
  reg        s_axis_rq_tvalid_r3 = 'd0;
  reg        s_axis_rq_tready_reg = 'd0;
  reg        s_axis_rq_tready_r1 = 'd0;
  reg        s_axis_rq_tready_r2 = 'd0;
  reg        s_axis_rq_tready_r3 = 'd0;
  reg        s_axis_rq_tsop_reg = 'd0;
  reg        s_axis_rq_tsop_r1 = 'd0;
  reg        s_axis_rq_tsop_r2 = 'd0;
  reg        s_axis_rq_tdsc_reg = 'd0;
  reg        s_axis_rq_tdsc_r1 = 'd0;
  reg        s_axis_rq_tdsc_r2 = 'd0;
  reg        s_axis_rq_tdsc_r3 = 'd0;
  reg        s_axis_rq_tdsc_latched = 'd0;
  reg        expect_tstart_on_rq_intr = 'd0;
  reg [3:0]  s_axis_rq_Fbyte_en_reg = 'd0; 
  reg [3:0]  s_axis_rq_Fbyte_en_r1 = 'd0; 
  reg [3:0]  s_axis_rq_Fbyte_en_r2 = 'd0; 
  reg [3:0]  s_axis_rq_Lbyte_en_reg = 'd0; 
  reg [3:0]  s_axis_rq_Lbyte_en_r1 = 'd0; 
  reg [3:0]  s_axis_rq_Lbyte_en_r2 = 'd0; 
  reg [3:0]  s_axis_rq_ReqType_reg = 'd0; 
  reg [3:0]  s_axis_rq_ReqType_r1 = 'd0; 
  reg [3:0]  s_axis_rq_ReqType_r2 = 'd0; 
  reg [3:0]  s_axis_rq_ReqType_r3 = 'd0; 
  reg [33:0] s_axis_rq_payload_byte_cnt = 'd0;
  reg [33:0] s_axis_rq_total_byte_cnt = 'd0;
  reg [33:0] s_axis_rq_payload_byte_cnt_r = 'd0;
  reg [33:0] s_axis_rq_total_byte_cnt_r = 'd0;
  reg [TKEEP_WIDTH-1:0] s_axis_rq_tkeep_reg = 'd0;
  reg [TKEEP_WIDTH-1:0] s_axis_rq_tkeep_r1 = 'd0;
  reg [2:0]  no_of_valid_bytes_in_first_DW = 'd0;
  reg [2:0]  no_of_valid_bytes_in_last_DW = 'd0;
  reg [3:0]  no_of_valid_DW = 'd0;

  // RC Interface
  reg        m_axis_rc_tlast_reg = 'd0;
  reg        m_axis_rc_tvalid_reg = 'd0;
  reg        m_axis_rc_tready_reg = 'd0;
  reg        m_axis_rc_tsop_reg = 'd0;
  reg        m_axis_rc_tdsc_reg = 'd0;
  reg        m_axis_rc_tdsc_latched = 'd0;
  reg [15:0] m_axis_rc_byte_en_reg = 'd0; 
  //[AAV]
  //reg [31:0] m_axis_rc_byte_en_reg = 'd0; 
  reg [10:0] m_axis_rc_DWcnt_reg = 'd0;
  reg [10:0] m_axis_rc_DWcnt_latched = 'd0;
  reg [15:0] m_axis_rc_payload_byte_cnt_per_pkt = 'd0;
  reg [33:0] m_axis_rc_payload_byte_cnt = 'd0;
  reg [33:0] m_axis_rc_total_byte_cnt = 'd0;
  reg [33:0] m_axis_rc_total_byte_cnt_r = 'd0;
  reg [33:0] m_axis_rc_payload_byte_cnt_r = 'd0;
  reg        m_axis_rc_tlast_r1 = 'd0;
  reg        m_axis_rc_tlast_r2 = 'd0;
  reg        m_axis_rc_tvalid_r1 = 'd0;
  reg        m_axis_rc_tvalid_r2 = 'd0;
  reg        m_axis_rc_tready_r1 = 'd0;
  reg        m_axis_rc_tready_r2 = 'd0;
  reg        m_axis_rc_tsop_r1 = 'd0;
  reg        m_axis_rc_tdsc_r1 = 'd0;
  reg        m_axis_rc_tdsc_r2 = 'd0;
  //reg [31:0] m_axis_rc_byte_en_r1 = 'd0; 
  //[AAV]
  reg [15:0] m_axis_rc_byte_en_r1 = 'd0; 

localparam DESC_BYTE_CNT_CQ_INTR = 16;
localparam DESC_BYTE_CNT_CC_INTR = 12;
localparam DESC_BYTE_CNT_RQ_INTR = 16;
localparam DESC_BYTE_CNT_RC_INTR = 12;
localparam NUM_BYTES_1DW_MEMWR   = 4;
localparam CPLD_1DW   = 4;
localparam MEMRD = 4'h0;
localparam MEMWR = 4'h1;

/******************************************************************************
* Number of Descriptor bytes on CQ Interface (DESC_BYTE_CNT_CQ_INTR) = 16
* Number of Descriptor bytes on CC Interface (DESC_BYTE_CNT_CC_INTR) = 12
* Number of Descriptor bytes on RQ Interface (DESC_BYTE_CNT_RQ_INTR) = 16
* Number of Descriptor bytes on RC Interface (DESC_BYTE_CNT_RC_INTR) = 12
******************************************************************************/

/******************************************************************************
// Completer Request Interface:
// The type of transactions on this interface are 
// 1. Memory Write -> To program any 32-bit (4 byte) register in DMA.
// 2. Memory Read  -> Request to read any 32-bit (4 byte) register of DMA. 
//                    Response to this read request is followed by completion
//                    with data on Completer Completion Interface.
// Since it is all 32-bit read/write to/from registers, this interface will always 
// have DW count as 1
// If a Memory read request is received on CQ interface, then
//    --> Total Payload count will not be incremented and held onto previous value
//    --> Total Byte count (including descriptor) is incremented by 16
******************************************************************************/

always @(posedge clk)   
begin
   if (reset)
   begin
       m_axis_cq_tlast_reg    <= 'b0;
       m_axis_cq_tvalid_reg   <= 'b0;
       m_axis_cq_tready_reg   <= 'b0;
       m_axis_cq_Fbyte_en_reg <= 'b0;
       m_axis_cq_Lbyte_en_reg <= 'b0;
       m_axis_cq_tsop_reg     <= 'b0;
       m_axis_cq_tdsc_reg     <= 'b0;
       m_axis_cq_DWcnt_reg    <= 'b0;
       m_axis_cq_ReqType_reg  <= 'b0;
   end
   else
   begin
       m_axis_cq_tlast_reg    <= m_axis_cq_tlast;
       m_axis_cq_tvalid_reg   <= m_axis_cq_tvalid;
       m_axis_cq_tready_reg   <= m_axis_cq_tready;
       m_axis_cq_Fbyte_en_reg <= m_axis_cq_tuser[3:0];
       m_axis_cq_Lbyte_en_reg <= m_axis_cq_tuser[7:4];
       m_axis_cq_tsop_reg     <= m_axis_cq_tuser[40];
       m_axis_cq_tdsc_reg     <= m_axis_cq_tuser[41];
       m_axis_cq_DWcnt_reg    <= m_axis_cq_tdata[74:64];
       m_axis_cq_ReqType_reg  <= m_axis_cq_tdata[78:75];
   end
end

always @(posedge clk)
begin
   if (reset)
       m_axis_cq_tdsc_latched <= 1'b0;
   else if(m_axis_cq_tlast_reg)
       m_axis_cq_tdsc_latched <= 1'b0;
   else if(m_axis_cq_tvalid_reg && m_axis_cq_tready_reg && m_axis_cq_tdsc_reg)
       m_axis_cq_tdsc_latched <= 1'b1;
end

always @(posedge clk)
begin
   if (reset || !running_test_time)
   begin
      m_axis_cq_payload_byte_cnt <= 'h0;
      m_axis_cq_total_byte_cnt <= 'h0;
   end
   else if(m_axis_cq_tlast_reg && m_axis_cq_tvalid_reg && m_axis_cq_tready_reg)
   begin
      if(m_axis_cq_tdsc_latched)
      begin
         m_axis_cq_payload_byte_cnt <= m_axis_cq_payload_byte_cnt;
         m_axis_cq_total_byte_cnt   <= m_axis_cq_total_byte_cnt;
      end
      else if(m_axis_cq_tsop_reg) /*[AAV] && ({m_axis_cq_Fbyte_en_reg,m_axis_cq_Lbyte_en_reg} == 8'b1111_0000))*/
      begin
         // Memory Read Request on CQ interface will not have any payload associated with it 
         if(m_axis_cq_ReqType_reg == MEMRD)
         begin
               m_axis_cq_payload_byte_cnt <= m_axis_cq_payload_byte_cnt;
               m_axis_cq_total_byte_cnt   <= m_axis_cq_total_byte_cnt + DESC_BYTE_CNT_CQ_INTR;
         end
         // Memory Write Request on CQ interface will have 4 bytes of payload associated with it 
         else if(m_axis_cq_ReqType_reg == MEMWR)
         begin
               m_axis_cq_payload_byte_cnt <= m_axis_cq_payload_byte_cnt + NUM_BYTES_1DW_MEMWR;
               m_axis_cq_total_byte_cnt   <= m_axis_cq_total_byte_cnt + NUM_BYTES_1DW_MEMWR + DESC_BYTE_CNT_CQ_INTR;
         end
      end
   end
end

/******************************************************************************
      Completer Completion Interface
 The Completer Completion interface is used for sending the completion to the
 MemRd request received on Completer Request Interface. In this case, it would
 just be 1 DW CplD. 
******************************************************************************/

always @(posedge clk)   
begin
   if (reset)
   begin
       s_axis_cc_tlast_reg   <= 'b0;
       s_axis_cc_tvalid_reg  <= 'b0;
       s_axis_cc_tready_reg  <= 'b0;
       s_axis_cc_tdsc_reg    <= 'b0;
       s_axis_cc_DWcnt_reg   <= 'b0;
       s_axis_cc_Bytecnt_reg <= 'b0;
   end
   else
   begin
       s_axis_cc_tlast_reg   <= s_axis_cc_tlast;
       s_axis_cc_tvalid_reg  <= s_axis_cc_tvalid;
       s_axis_cc_tready_reg  <= s_axis_cc_tready;
       s_axis_cc_tdsc_reg    <= s_axis_cc_tuser[0];
       s_axis_cc_DWcnt_reg   <= s_axis_cc_tdata[42:32];
       s_axis_cc_Bytecnt_reg <= s_axis_cc_tdata[28:16];
   end
end

always@(posedge clk)
begin
    if (reset || (s_axis_cc_tlast_reg && s_axis_cc_tvalid_reg && s_axis_cc_tready_reg))
      expect_tstart_on_cc_intr <= 1'b1;
    else if (expect_tstart_on_cc_intr && s_axis_cc_tvalid_reg && s_axis_cc_tready_reg)
      expect_tstart_on_cc_intr <= 1'b0;
end 
  
always @(expect_tstart_on_cc_intr,s_axis_cc_tvalid_reg,s_axis_cc_tready_reg)
     s_axis_cc_tsop_reg <= expect_tstart_on_cc_intr && s_axis_cc_tvalid_reg && s_axis_cc_tready_reg;

always @(posedge clk)
begin
   if (reset)
       s_axis_cc_tdsc_latched <= 1'b0;
   else if(s_axis_cc_tlast_reg)
       s_axis_cc_tdsc_latched <= 1'b0;
   else if(s_axis_cc_tvalid_reg && s_axis_cc_tready_reg && s_axis_cc_tdsc_reg)
       s_axis_cc_tdsc_latched <= 1'b1;
end

always @(posedge clk)
begin
   if (reset || !running_test_time)
   begin
      s_axis_cc_payload_byte_cnt <= 'h0;
      s_axis_cc_total_byte_cnt   <= 'h0;
   end
   else if(s_axis_cc_tlast_reg && s_axis_cc_tvalid_reg && s_axis_cc_tready_reg)
   begin
      if(s_axis_cc_tdsc_latched)
      begin
         s_axis_cc_payload_byte_cnt <= s_axis_cc_payload_byte_cnt;
         s_axis_cc_total_byte_cnt   <= s_axis_cc_total_byte_cnt;
      end
      else if(s_axis_cc_tsop_reg)
      begin
         s_axis_cc_payload_byte_cnt <= s_axis_cc_payload_byte_cnt + CPLD_1DW;
         s_axis_cc_total_byte_cnt   <= s_axis_cc_total_byte_cnt + CPLD_1DW + DESC_BYTE_CNT_CC_INTR;
      end
   end
end

/******************************************************************************
      Requester reQuest Interface
The Requester request interface is for transfer of requests with any associated
payload from the client application to the Integrated Block.
Each packet on this interface must start with a descripto which is 16 bytes long.
In DWORD aligned mode, the transfer starts with 16 desc bytes, followed immediately 
by payload bytes in the next Dword.
******************************************************************************/
 
always @(posedge clk)   
begin
   if (reset)
   begin
       s_axis_rq_tlast_reg    <= 'b0;
       s_axis_rq_tvalid_reg   <= 'b0;
       s_axis_rq_tready_reg   <= 'b0;
       s_axis_rq_Fbyte_en_reg <= 'b0;
       s_axis_rq_Lbyte_en_reg <= 'b0;
       s_axis_rq_tdsc_reg     <= 'b0;
       s_axis_rq_ReqType_reg  <= 'b0;
       s_axis_rq_tkeep_reg    <= 'b0;
   end
   else
   begin
       s_axis_rq_tlast_reg    <= s_axis_rq_tlast;
       s_axis_rq_tvalid_reg   <= s_axis_rq_tvalid;
       s_axis_rq_tready_reg   <= s_axis_rq_tready;
       s_axis_rq_Fbyte_en_reg <= s_axis_rq_tuser[3:0];
       s_axis_rq_Lbyte_en_reg <= s_axis_rq_tuser[7:4];
       s_axis_rq_tdsc_reg     <= s_axis_rq_tuser[11];
       s_axis_rq_ReqType_reg  <= s_axis_rq_tdata[78:75];
       s_axis_rq_tkeep_reg    <= s_axis_rq_tkeep;
   end
end

always@(posedge clk)
begin
    if (reset || (s_axis_rq_tlast_reg && s_axis_rq_tvalid_reg && s_axis_rq_tready_reg))
      expect_tstart_on_rq_intr <= 1'b1;
    else if (expect_tstart_on_rq_intr && s_axis_rq_tvalid_reg && s_axis_rq_tready_reg)
      expect_tstart_on_rq_intr <= 1'b0;
end 
  
// Generating start of packet indication for each packet received on this interface.
always @(expect_tstart_on_rq_intr,s_axis_rq_tvalid_reg,s_axis_rq_tready_reg)
      s_axis_rq_tsop_reg <= expect_tstart_on_rq_intr && s_axis_rq_tvalid_reg && s_axis_rq_tready_reg;
  
// Additional stages of pipelining for easing timing.
always @(posedge clk)   
begin
   if (reset)
   begin
       s_axis_rq_tlast_r1    <= 'b0;
       s_axis_rq_tvalid_r1   <= 'b0;
       s_axis_rq_tready_r1   <= 'b0;
       s_axis_rq_tkeep_r1    <= 'b0;
       s_axis_rq_tdsc_r1     <= 'b0;
       s_axis_rq_tsop_r1     <= 'b0;
       s_axis_rq_tsop_r2     <= 'b0;

       s_axis_rq_tlast_r2    <= 'b0;
       s_axis_rq_tvalid_r2   <= 'b0;
       s_axis_rq_tready_r2   <= 'b0;
       s_axis_rq_tdsc_r2     <= 'b0;
       s_axis_rq_ReqType_r2  <= 'b0;

       s_axis_rq_tlast_r3    <= 'b0;
       s_axis_rq_tvalid_r3   <= 'b0;
       s_axis_rq_tready_r3   <= 'b0;
       s_axis_rq_tdsc_r3     <= 'b0;
       s_axis_rq_ReqType_r3  <= 'b0;
   end
   else
   begin

       s_axis_rq_tlast_r1    <= s_axis_rq_tlast_reg;
       s_axis_rq_tvalid_r1   <= s_axis_rq_tvalid_reg;
       s_axis_rq_tready_r1   <= s_axis_rq_tready_reg;
       s_axis_rq_tkeep_r1    <= s_axis_rq_tkeep_reg;
       s_axis_rq_tdsc_r1     <= s_axis_rq_tdsc_latched;
       s_axis_rq_tsop_r1     <= s_axis_rq_tsop_reg;

       s_axis_rq_tlast_r2    <= s_axis_rq_tlast_r1;
       s_axis_rq_tvalid_r2   <= s_axis_rq_tvalid_r1;
       s_axis_rq_tready_r2   <= s_axis_rq_tready_r1;
       s_axis_rq_tdsc_r2     <= s_axis_rq_tdsc_r1;
       s_axis_rq_ReqType_r2  <= s_axis_rq_ReqType_r1;
       s_axis_rq_tsop_r2     <= s_axis_rq_tsop_r1;

       s_axis_rq_tlast_r3    <= s_axis_rq_tlast_r2;
       s_axis_rq_tvalid_r3   <= s_axis_rq_tvalid_r2;
       s_axis_rq_tready_r3   <= s_axis_rq_tready_r2;
       s_axis_rq_tdsc_r3     <= s_axis_rq_tdsc_r2;
       s_axis_rq_ReqType_r3  <= s_axis_rq_ReqType_r2;
   end
end

// The first byte, last byte enables and Req type are presented in the first beat of the packet.
// Hence latching them on every SOP.
always @(posedge clk)
begin
   if (reset)
   begin
       s_axis_rq_Fbyte_en_r1 <= 'b0;
       s_axis_rq_Lbyte_en_r1 <= 'b0;
       s_axis_rq_ReqType_r1  <= 'b0;
   end
   else if(s_axis_rq_tsop_reg && s_axis_rq_tvalid_reg && s_axis_rq_tready_reg)
   begin
       s_axis_rq_Fbyte_en_r1 <= s_axis_rq_Fbyte_en_reg;
       s_axis_rq_Lbyte_en_r1 <= s_axis_rq_Lbyte_en_reg;
       s_axis_rq_ReqType_r1  <= s_axis_rq_ReqType_reg;
   end
end

// No. of valid bytes present in the first DW can be calculated based on
// s_axis_rq_Fbyte_en_r1
always@(posedge clk)
begin
if(reset)
    no_of_valid_bytes_in_first_DW <= 3'd0;
else
  case(s_axis_rq_Fbyte_en_r1)
    4'b1111 : no_of_valid_bytes_in_first_DW <= 3'd4;
    4'b1110 : no_of_valid_bytes_in_first_DW <= 3'd3;
    4'b1100 : no_of_valid_bytes_in_first_DW <= 3'd2;
    4'b1000 : no_of_valid_bytes_in_first_DW <= 3'd1;
    4'b0000 : no_of_valid_bytes_in_first_DW <= 3'd0; // Zero length MemRd/MemWr
  endcase
end

// No. of valid bytes present in the last DW can be calculated based on
// s_axis_rq_Lbyte_en_r1
always@(posedge clk)
begin
if(reset)
    no_of_valid_bytes_in_last_DW <= 3'd0;
else
  case(s_axis_rq_Lbyte_en_r1)
    4'b1111 : no_of_valid_bytes_in_last_DW <= 3'd4;
    4'b0111 : no_of_valid_bytes_in_last_DW <= 3'd3;
    4'b0011 : no_of_valid_bytes_in_last_DW <= 3'd2;
    4'b0001 : no_of_valid_bytes_in_last_DW <= 3'd1;
  endcase
end

// the tkeep signal(one per Dword) is set to indicate the valid DWs in the
// packet including the descriptor bytes.During the transfer of a packet, the tkeep
// bits can be 0 only in the last beat of the packet, when the packet does not fill
// the entire width of the interface.
always@(posedge clk)
begin
if(reset)
    no_of_valid_DW <= 4'd0;
else
  case(s_axis_rq_tkeep_r1)
    //8'hFF : no_of_valid_DW <= 4'd8;
    //8'h7F : no_of_valid_DW <= 4'd7;
    //8'h3F : no_of_valid_DW <= 4'd6;
    //8'h1F : no_of_valid_DW <= 4'd5;
    4'hF : no_of_valid_DW <= 4'd4;
    4'h7 : no_of_valid_DW <= 4'd3;
    4'h3 : no_of_valid_DW <= 4'd2;
    4'h1 : no_of_valid_DW <= 4'd1;
  endcase
end

always @(posedge clk)
begin
   if (reset)
       s_axis_rq_tdsc_latched <= 1'b0;
   else if(s_axis_rq_tlast_reg)
       s_axis_rq_tdsc_latched <= 1'b0;
   else if(s_axis_rq_tvalid_reg && s_axis_rq_tready_reg && s_axis_rq_tdsc_reg)
       s_axis_rq_tdsc_latched <= 1'b1;
end

reg [15:0] no_of_pl_bytes_excluding_sop;
// At sop, maximum of 4 DWs can be valid(Since first 4DWs are Desc bytes)
// So, a 5 bit counter is sufficient
reg [4:0] no_of_valid_bytes_at_sop;

always @(posedge clk)
begin
   if (reset)
       no_of_valid_bytes_at_sop <= 'd0;
   else if(s_axis_rq_tvalid_r2 && s_axis_rq_tready_r2)
   begin
      if(s_axis_rq_tsop_r2)
      // First 4 DWs are descriptor bytes and next DW may not have all valid bytes.
           // instead of multiplying by 4, do a left shift by two which is equivalent but won't infer a DSP
           // [AAV]
           no_of_valid_bytes_at_sop <= 0; //((no_of_valid_DW-5)<<2) + no_of_valid_bytes_in_first_DW;
   end
end

always @(posedge clk)
begin
   if (reset)
       no_of_pl_bytes_excluding_sop <= 'd0;
   else if(s_axis_rq_tvalid_r2 && s_axis_rq_tready_r2)
   begin
      if(s_axis_rq_tsop_r2)
         no_of_pl_bytes_excluding_sop <= 'd0;
      else if(s_axis_rq_tlast_r2)
         // instead of multiplying by 4, do a left shift by two which is equivalent but won't infer a DSP
         // The Last DWORD may not have all the bytes enabled. Number of valid bytes in the last DWORD can be obtained from last byte enable signals.
         // On EOP valid bytes are (no_of_valid_DW-1)*4 + no_of_valid_bytes_in_last_DW;
         no_of_pl_bytes_excluding_sop  <= no_of_pl_bytes_excluding_sop + ((no_of_valid_DW-1)<<2) + no_of_valid_bytes_in_last_DW;
      else
        // For an intermediate beat between SOP and EOP, all the bytes will be valid.
        // Hence adding 32 bytes in every such cycle.
         no_of_pl_bytes_excluding_sop  <= no_of_pl_bytes_excluding_sop + (TDATA_WIDTH/8);
         //no_of_pl_bytes_excluding_sop  <= no_of_pl_bytes_excluding_sop + 6'd32;
   end
end

always @(posedge clk)
begin
   if (reset || !running_test_time)
   begin
      s_axis_rq_payload_byte_cnt <= 'h0;
      s_axis_rq_total_byte_cnt   <= 'h0;
   end
   // If Discontinue bit is asserted by the Integrated Block, the payload and byte count counts should be 
   // held and not incremented.
   else if( s_axis_rq_tlast_r3 && s_axis_rq_tvalid_r3 && s_axis_rq_tready_r3 && !s_axis_rq_tdsc_r3)
   begin
      s_axis_rq_total_byte_cnt   <= s_axis_rq_total_byte_cnt   + no_of_pl_bytes_excluding_sop + no_of_valid_bytes_at_sop + DESC_BYTE_CNT_RQ_INTR;
     if(s_axis_rq_ReqType_r3 != MEMRD) // MemWR request 
      s_axis_rq_payload_byte_cnt <= s_axis_rq_payload_byte_cnt + no_of_pl_bytes_excluding_sop + no_of_valid_bytes_at_sop;
     else // For MemRD requests, there is no associated payload.Not considering Zero Length Memory Read requests here.
      s_axis_rq_payload_byte_cnt <= s_axis_rq_payload_byte_cnt;
   end
end

/******************************************************************************
      Requester Completion Interface
Completions for requests generated by clinet logic are presented on the RC
interface. The RC interface sends completion data received from the link to 
the client application as AXI-4 Stream packets. Each packet starts with a
descriptor and can have payload data following the descriptor. Each descriptor
is always 12 bytes long, as is sent in the first 12 bytes of the completion
packet. For 256-bit interface, the descriptor is transferred during the first
beat.
Bits [42:32] of the descriptor indicate the Dword count. These 11 bits indicate
the size of the payload of the current packet in Dwords. The Dword count is set
to 1 while transferring a completion for a zero-length memory read. In all othe
cases, the Dword count corresponds to the actual number of Dwords in the payload
of the current packet.
******************************************************************************/

always @(posedge clk)   
begin
   if (reset)
   begin
       m_axis_rc_tlast_reg    <= 'b0;
       m_axis_rc_tvalid_reg   <= 'b0;
       m_axis_rc_tready_reg   <= 'b0;
       m_axis_rc_byte_en_reg  <= 'b0;
       m_axis_rc_tsop_reg     <= 'b0;
       m_axis_rc_tdsc_reg     <= 'b0;
       m_axis_rc_DWcnt_reg    <= 'b0;

       m_axis_rc_tlast_r1     <= 'b0;
       m_axis_rc_tvalid_r1    <= 'b0;
       m_axis_rc_tready_r1    <= 'b0;
       m_axis_rc_byte_en_r1   <= 'b0;
       m_axis_rc_tsop_r1      <= 'b0;
       m_axis_rc_tdsc_r1      <= 'b0;

       m_axis_rc_tlast_r2     <= 'b0;
       m_axis_rc_tvalid_r2    <= 'b0;
       m_axis_rc_tready_r2    <= 'b0;
       m_axis_rc_tdsc_r2      <= 'b0;
   end
   else
   begin
       m_axis_rc_tlast_reg    <= m_axis_rc_tlast;
       m_axis_rc_tvalid_reg   <= m_axis_rc_tvalid;
       m_axis_rc_tready_reg   <= m_axis_rc_tready;
       //m_axis_rc_byte_en_reg  <= m_axis_rc_tuser[31:0];
       //[AAV]
       m_axis_rc_byte_en_reg  <= m_axis_rc_tuser[15:0];
       m_axis_rc_tsop_reg     <= m_axis_rc_tuser[32];
       m_axis_rc_tdsc_reg     <= m_axis_rc_tuser[42];
       m_axis_rc_DWcnt_reg    <= m_axis_rc_tdata[42:32]; 

       // Adding additional pipeline stages for better timing
       m_axis_rc_tlast_r1     <= m_axis_rc_tlast_reg;
       m_axis_rc_tvalid_r1    <= m_axis_rc_tvalid_reg;
       m_axis_rc_tready_r1    <= m_axis_rc_tready_reg;
       m_axis_rc_byte_en_r1   <= m_axis_rc_byte_en_reg;
       m_axis_rc_tsop_r1      <= m_axis_rc_tsop_reg;
       m_axis_rc_tdsc_r1      <= m_axis_rc_tdsc_latched;

       m_axis_rc_tlast_r2     <= m_axis_rc_tlast_r1;
       m_axis_rc_tvalid_r2    <= m_axis_rc_tvalid_r1;
       m_axis_rc_tready_r2    <= m_axis_rc_tready_r1;
       m_axis_rc_tdsc_r2      <= m_axis_rc_tdsc_r1;
   end
end

// Aborting a completion transfer:
// For any completion with associated payload, the Integrated Block can signal
// an error in the payload by asserting "discontinue" bit in "tuser" field.
// The client application must discard the entire packet when the "discontinue"
// bit is asserted for that packet.
always @(posedge clk)
begin
   if (reset)
       m_axis_rc_tdsc_latched <= 1'b0;
   else if(m_axis_rc_tlast_reg)
       m_axis_rc_tdsc_latched <= 1'b0;
   else if(m_axis_rc_tvalid_reg && m_axis_rc_tready_reg && m_axis_rc_tdsc_reg)
       m_axis_rc_tdsc_latched <= 1'b1;
end

// DWord Count is present in the descriptor field, which is only during the
// first beat of the packet. Hence latching on to that value on 'sop', so that
// DW_cnt can be used to calculate the payload and byte counts associated with 
// the current packet.
always @(posedge clk)
begin
   if (reset)
       m_axis_rc_DWcnt_latched <= 'b0;
   else if(m_axis_rc_tsop_reg && m_axis_rc_tvalid_reg && m_axis_rc_tready_reg)
       m_axis_rc_DWcnt_latched <= m_axis_rc_DWcnt_reg;
end

// A temporary variable to hold the No.of invalid bytes of that DW. A Dword consists
// of 4 bytes, this variable would hold the information on how many of those 4 bytes
// are invalid.
reg [1:0] m_axis_rc_temp_var;

always @(posedge clk)
begin
   if (reset)
      m_axis_rc_temp_var <= 'd0;
   // In this case, all the bytes of the DW are valid.
   else if((m_axis_rc_byte_en_reg == 16'hFFFF) ||
           (m_axis_rc_byte_en_reg == 16'h0FFF) ||
           (m_axis_rc_byte_en_reg == 16'h00FF) ||
           (m_axis_rc_byte_en_reg == 16'h000F))
      m_axis_rc_temp_var <= 'd0;
   // In this case, 3 bytes of the DW are valid, and 1 byte is not valid.
   else if((m_axis_rc_byte_en_reg == 16'h7FFF) ||
           (m_axis_rc_byte_en_reg == 16'h07FF) ||
           (m_axis_rc_byte_en_reg == 16'h007F) ||
           (m_axis_rc_byte_en_reg == 16'h0007))
      m_axis_rc_temp_var <= 'd1;
   // In this case, 2 bytes of the DW are valid, and 2 bytes are not valid.
   else if((m_axis_rc_byte_en_reg == 16'h3FFF) ||
           (m_axis_rc_byte_en_reg == 16'h03FF) ||
           (m_axis_rc_byte_en_reg == 16'h003F) ||
           (m_axis_rc_byte_en_reg == 16'h0003))
      m_axis_rc_temp_var <= 'd2;
   // In this case, 1 byte of the DW are valid, and 3 bytes are not valid.
   else if((m_axis_rc_byte_en_reg == 16'h1FFF) ||
           (m_axis_rc_byte_en_reg == 16'h01FF) ||
           (m_axis_rc_byte_en_reg == 16'h001F) ||
           (m_axis_rc_byte_en_reg == 16'h0001))
      m_axis_rc_temp_var <= 'd3;
end

//[AAV]
/*
always @(posedge clk)
begin
   if (reset)
      m_axis_rc_temp_var <= 'd0;
   // In this case, all the bytes of the DW are valid.
   else if((m_axis_rc_byte_en_reg == 32'hFFFF_FFFF) || (m_axis_rc_byte_en_reg == 32'h0000_FFFF) ||
           (m_axis_rc_byte_en_reg == 32'h0FFF_FFFF) || (m_axis_rc_byte_en_reg == 32'h0000_0FFF) ||
           (m_axis_rc_byte_en_reg == 32'h00FF_FFFF) || (m_axis_rc_byte_en_reg == 32'h0000_00FF) ||
           (m_axis_rc_byte_en_reg == 32'h000F_FFFF) || (m_axis_rc_byte_en_reg == 32'h0000_000F))
      m_axis_rc_temp_var <= 'd0;
   // In this case, 3 bytes of the DW are valid, and 1 byte is not valid.
   else if((m_axis_rc_byte_en_reg == 32'h7FFF_FFFF) || (m_axis_rc_byte_en_reg == 32'h0000_7FFF) ||
           (m_axis_rc_byte_en_reg == 32'h07FF_FFFF) || (m_axis_rc_byte_en_reg == 32'h0000_07FF) ||
           (m_axis_rc_byte_en_reg == 32'h007F_FFFF) || (m_axis_rc_byte_en_reg == 32'h0000_007F) ||
           (m_axis_rc_byte_en_reg == 32'h0007_FFFF) || (m_axis_rc_byte_en_reg == 32'h0000_0007))
      m_axis_rc_temp_var <= 'd1;
   // In this case, 2 bytes of the DW are valid, and 2 bytes are not valid.
   else if((m_axis_rc_byte_en_reg == 32'h3FFF_FFFF) || (m_axis_rc_byte_en_reg == 32'h0000_3FFF) ||
           (m_axis_rc_byte_en_reg == 32'h03FF_FFFF) || (m_axis_rc_byte_en_reg == 32'h0000_03FF) ||
           (m_axis_rc_byte_en_reg == 32'h003F_FFFF) || (m_axis_rc_byte_en_reg == 32'h0000_003F) ||
           (m_axis_rc_byte_en_reg == 32'h0003_FFFF) || (m_axis_rc_byte_en_reg == 32'h0000_0003))
      m_axis_rc_temp_var <= 'd2;
   // In this case, 1 byte of the DW are valid, and 3 bytes are not valid.
   else if((m_axis_rc_byte_en_reg == 32'h1FFF_FFFF) || (m_axis_rc_byte_en_reg == 32'h0000_1FFF) ||
           (m_axis_rc_byte_en_reg == 32'h01FF_FFFF) || (m_axis_rc_byte_en_reg == 32'h0000_01FF) ||
           (m_axis_rc_byte_en_reg == 32'h001F_FFFF) || (m_axis_rc_byte_en_reg == 32'h0000_001F) ||
           (m_axis_rc_byte_en_reg == 32'h0001_FFFF) || (m_axis_rc_byte_en_reg == 32'h0000_0001))
      m_axis_rc_temp_var <= 'd3;
end
*/
always @(posedge clk)
begin
   if (reset)
      m_axis_rc_payload_byte_cnt_per_pkt <= 'h0;
   else if(m_axis_rc_tlast_r1 && m_axis_rc_tvalid_r1 && m_axis_rc_tready_r1)
      m_axis_rc_payload_byte_cnt_per_pkt <= (m_axis_rc_DWcnt_latched<<2)-m_axis_rc_temp_var;
     //[AAV]
   /*
   case (m_axis_rc_temp_var)
     // instead of multiplying by 4, do a left shift by two which is equivalent but won't infer a DSP
     2'd0 : m_axis_rc_payload_byte_cnt_per_pkt <= (m_axis_rc_DWcnt_latched<<2);
     2'd1 : m_axis_rc_payload_byte_cnt_per_pkt <= (m_axis_rc_DWcnt_latched<<2) - 'd1;
     2'd2 : m_axis_rc_payload_byte_cnt_per_pkt <= (m_axis_rc_DWcnt_latched<<2) - 'd2;
     2'd3 : m_axis_rc_payload_byte_cnt_per_pkt <= (m_axis_rc_DWcnt_latched<<2) - 'd3;
   endcase
   */
end

always@(posedge clk)
begin
  if(reset || !running_test_time)
  begin
    m_axis_rc_payload_byte_cnt <= 'd0;
    m_axis_rc_total_byte_cnt   <= 'd0;
  end
  else if(m_axis_rc_tlast_r2 && m_axis_rc_tvalid_r2 && m_axis_rc_tready_r2 & !m_axis_rc_tdsc_r2)
  begin
    m_axis_rc_payload_byte_cnt <= m_axis_rc_payload_byte_cnt + m_axis_rc_payload_byte_cnt_per_pkt;
    // For every AXI-4 Stream packet that this interface receives, the first 12 bytes are Descriptor bytes.
    // Hence adding 12 bytes to the total payload byte count will give the total byte count for that packet.
    m_axis_rc_total_byte_cnt   <= m_axis_rc_total_byte_cnt + m_axis_rc_payload_byte_cnt_per_pkt   + DESC_BYTE_CNT_RC_INTR;
  end
end

/********************************************************************
            Scaling factor and total byte counts
********************************************************************/

always@(posedge clk)
begin
  if(reset)
  begin
    s_axis_cc_payload_byte_cnt_r <= 'h0;
    s_axis_cc_total_byte_cnt_r   <= 'h0;
    m_axis_cq_payload_byte_cnt_r <= 'h0;
    m_axis_cq_total_byte_cnt_r   <= 'h0;

    s_axis_rq_payload_byte_cnt_r <= 'h0;
    s_axis_rq_total_byte_cnt_r   <= 'h0;
    m_axis_rc_payload_byte_cnt_r <= 'h0;
    m_axis_rc_total_byte_cnt_r   <= 'h0;
  end
  else
  begin
    s_axis_cc_payload_byte_cnt_r <= s_axis_cc_payload_byte_cnt;
    s_axis_cc_total_byte_cnt_r   <= s_axis_cc_total_byte_cnt;
    m_axis_cq_payload_byte_cnt_r <= m_axis_cq_payload_byte_cnt;
    m_axis_cq_total_byte_cnt_r   <= m_axis_cq_total_byte_cnt;

    s_axis_rq_payload_byte_cnt_r <= s_axis_rq_payload_byte_cnt;
    s_axis_rq_total_byte_cnt_r   <= s_axis_rq_total_byte_cnt;
    m_axis_rc_payload_byte_cnt_r <= m_axis_rc_payload_byte_cnt;
    m_axis_rc_total_byte_cnt_r   <= m_axis_rc_total_byte_cnt;
  end
end

always@(posedge clk)
begin
  if(reset)
  begin
    s_axis_payload_count <= 'h0;
    s_axis_byte_count    <= 'h0;
    m_axis_payload_count <= 'h0;
    m_axis_byte_count    <= 'h0;
  end
  else
  begin
    s_axis_payload_count <= s_axis_cc_payload_byte_cnt_r + s_axis_rq_payload_byte_cnt_r;
    s_axis_byte_count    <= s_axis_cc_total_byte_cnt_r   + s_axis_rq_total_byte_cnt_r;
    m_axis_payload_count <= m_axis_cq_payload_byte_cnt_r + m_axis_rc_payload_byte_cnt_r;
    m_axis_byte_count    <= m_axis_cq_total_byte_cnt_r   + m_axis_rc_total_byte_cnt_r;
  end
end

always@(posedge clk)
begin
  if(reset)
  begin
    tx_byte_count_int    <= 'h0;
    tx_payload_count_int <= 'h0;
    rx_byte_count_int    <= 'h0;
    rx_payload_count_int <= 'h0;
  end
  else
  begin
    tx_byte_count_int    <= (s_axis_byte_count    >> scaling_factor);
    tx_payload_count_int <= (s_axis_payload_count >> scaling_factor);
    rx_byte_count_int    <= (m_axis_byte_count    >> scaling_factor);
    rx_payload_count_int <= (m_axis_payload_count >> scaling_factor);
  end
end

// Only taking into account 125 MHz and 250 MHz
//assign one_second_cnt = (clk_period_in_ns == 4) ? 'hEE6B280 : 'h7735940;
   
// Keep track of time during test
always @(posedge clk)
begin: TIMER_PROC

   if (reset) begin
   
       running_test_time <= 'h0;
       sample_cnt <= 'h0;
       
   end else if (running_test_time == 'h0) begin
       
       running_test_time <= one_second_cnt[30:0];
       sample_cnt <= sample_cnt + 1'b1;
       
   end else begin
       running_test_time <= running_test_time - 1'b1;
       sample_cnt <= sample_cnt;

   end
end

// Concatenate sample_cnt with byte count at end of sample period.
always @(posedge clk)
begin: COPY_PROC

   if (reset == 1'b1) begin
   
      tx_byte_count     <= 'h0;
      rx_byte_count     <= 'h0;
      tx_payload_count  <= 'h0;
      rx_payload_count  <= 'h0;
       
   end else if (running_test_time == 'h0) begin
       
      tx_byte_count     <= {tx_byte_count_int[31:2], sample_cnt}   ;
      rx_byte_count     <= {rx_byte_count_int[31:2], sample_cnt}   ;
      tx_payload_count  <= {tx_payload_count_int[31:2], sample_cnt};
      rx_payload_count  <= {rx_payload_count_int[31:2], sample_cnt};
       
   end
end

/******************************************************************************
      Flow Control 
******************************************************************************/


// Capturing Initfc values on the Host System

always @(posedge clk) begin
  if (reset == 1'b1 ) 
    captured_initfc <= 1'b0;
  else if (capture_count == 'h3) 
    captured_initfc <= 1'b1;
    
  if (capture_count == 'h3) begin
    init_fc_cpld   <=  fc_cpld;
    init_fc_cplh   <=  fc_cplh;
    init_fc_npd    <=  fc_npd;
    init_fc_nph    <=  fc_nph; 
    init_fc_pd     <=  fc_pd;  
    init_fc_ph     <=  fc_ph;  
  end

  if (reset == 1'b0 && captured_initfc == 1'b0) 
    capture_count <= capture_count + 1'b1;
  else  
    capture_count <= 'h0;
end

assign fc_sel = (captured_initfc) ? 3'b000 : 3'b101; 


endmodule

