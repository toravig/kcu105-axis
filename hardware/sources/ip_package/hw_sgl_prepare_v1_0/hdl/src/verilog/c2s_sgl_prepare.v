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
// Project    : Kintex UltraScale PCIe Subsystems  
// File       : c2s_sgl_prepare.v
//
// Revision History
// ------------------------------
// Version   |    Description
// ----------|-------------------
// 1.0       |    Initial Release
//-----------------------------------------------------------------------------

//`timescale 1ps / 1ps
(* CORE_GENERATION_INFO = "" *)
module  c2s_sgl_prepare # 
  (
    parameter BUFFER_SIZE          = 512,
    parameter START_ADDRESS        = 32'hC0000000,
    parameter BIT64_ADDR_EN        = 0,              // 1: 64-bit address enable  
                                                     // 0: 32-bit address enable                                          
// AXI Master Interface Parameters
    parameter   M_ID_WIDTH         = 4,           
    parameter   M_ADDR_WIDTH       = 32,          
    parameter   M_LEN_WIDTH        = 4,           
    parameter   M_DATA_WIDTH       = 128,          
    parameter   M_REGION_WIDTH     = 4,
    parameter   M_BCOUNT_WIDTH     = 10,
              
// AXI Streaming Interface Parameters
    parameter AXIS_TDATA_WIDTH   =  128,
    parameter AXIS_TKEEP_WIDTH   =  16
  ) 
  (
    // Global Inputs
    input                                        aclk, //AXI clock
    input                                        nRESET,
                                                 
    // Hardware SGL submission block Interface   
    output                                       sgl_available,
    input                                        sgl_done,
    input                                        sgl_error,
    output      [(BIT64_ADDR_EN*32 + 112)-1 : 0] sgl_data,
    
 // AXI MM Interface 
    input                                        m_awvalid,                  // Write Address Channel
    output                                       m_awready,                  //
    input       [M_ID_WIDTH-1:0]                 m_awid,                     //
    input       [M_ADDR_WIDTH-1:0]               m_awaddr,                   //
    input       [M_LEN_WIDTH-1:0]                m_awlen,                    //
    input       [2:0]                            m_awsize,                   //
    input       [1:0]                            m_awburst,                  //
    input       [2:0]                            m_awprot,                   //
    input       [3:0]                            m_awcache,                  //
    input       [M_REGION_WIDTH-1:0]             m_awregion,                 // Write Address Channel - non-standard AXI ports
    input       [M_BCOUNT_WIDTH-1:0]             m_awbcount,                 //   For FIFO DMA transactions, m_awregion indicates source DMA Channel, m_awbcount
    input                                        m_aweop,                    //   indicates exact byte count of transaction, and m_aweop indicates end of DMA packet
                                                 
    input                                        m_wvalid,                   // Write Data Channel
    output                                       m_wready,                   //
    input       [M_ID_WIDTH-1:0]                 m_wid,                      //
    input       [M_DATA_WIDTH-1:0]               m_wdata,                    //
    input       [(M_DATA_WIDTH/8)-1:0]           m_wstrb,                    //
    input                                        m_wlast,                    //
                                                 
    output                                       m_bvalid,                   // Write Response Channel
    input                                        m_bready,                   //
    output      [M_ID_WIDTH-1:0]                 m_bid,                      //
    output      [1:0]                            m_bresp,                    //
                                                 
    input                                        m_arvalid,                  // Read Address Channel
    output                                       m_arready,                  //
    input       [M_ID_WIDTH-1:0]                 m_arid,                     //
    input       [M_ADDR_WIDTH-1:0]               m_araddr,                   //
    input       [M_LEN_WIDTH-1:0]                m_arlen,                    //
    input       [2:0]                            m_arsize,                   //
    input       [1:0]                            m_arburst,                  //
    input       [2:0]                            m_arprot,                   //
    input       [3:0]                            m_arcache,                  //
    input       [M_REGION_WIDTH-1:0]             m_arregion,                 // Read Address Channel - non-standard AXI ports
    input       [M_BCOUNT_WIDTH-1:0]             m_arbcount,                 //   For FIFO DMA transactions, m_arregion indicates source DMA Channel, m_arbcount
    input                                        m_areop,                    //   indicates exact byte count of transaction, and m_areop indicates end of DMA packet
                                                 
    output                                       m_rvalid,                   // Read Data Channel
    input                                        m_rready,                   //
    output      [M_ID_WIDTH-1:0]                 m_rid,                      //
    output      [M_DATA_WIDTH-1:0]               m_rdata,                    //
    output      [1:0]                            m_rresp,                    //
    output                                       m_rlast,                    //
                                                 
 // AXI Streaming Interface                      
    input       [AXIS_TDATA_WIDTH-1:0]           axi_stream_c2s_tdata,
    input       [AXIS_TKEEP_WIDTH-1:0]           axi_stream_c2s_tkeep,
    input                                        axi_stream_c2s_tvalid,
    input                                        axi_stream_c2s_tlast,
    output                                       axi_stream_c2s_tready
    
  );
  
// State Parameters
localparam START                                 = 5'b00001;   
localparam WAIT_FOR_DATA_PACKET                  = 5'b00010;   
localparam PREPARE_SGL_ELEMENT                   = 5'b00100;                 
localparam UPDATE_SGL_ELEMENT                    = 5'b01000;   
localparam SEND_DATA_PACKET                      = 5'b10000; 

//localparam BUFFER_SIZE                           = 10'd512;
localparam MAX_ARSIZE                            = 3'd4; 
localparam BUFF_THRESHOLD                        = 9'h1F0;
localparam BUFF_0_BASE                           = START_ADDRESS;
localparam BUFF_1_BASE                           = START_ADDRESS + 10'h200;
                                                           
//-------------------------------------------------------------------------
// Register Declarations 
//-------------------------------------------------------------------------
//---------------------------------------------
// SGL ELEMENT Registers - 112 bits
//     |-----------------|-------------|-------------|--------------|        
//     |   [ 111: 48]    |  [ 47: 32]  |  [ 31: 24]  |   [ 23:  0]  |        
//     |-----------------|-------------|-------------|--------------|        
//     | buffer_address_r|  user_id_r  |   flags_r   | byte_count_r |        
//     |-----------------|-------------|-------------|--------------|        
 //--------------------------------------------
// Source Address   ; BIT64_ADDR_EN => 1: 64-bit address enable  
 //                                    0: 32-bit address enable  
reg    [(BIT64_ADDR_EN*32 + 32)-1 : 0]          buffer_address_r;   
reg    [15: 0]                                  user_id_r;      
reg    [ 7: 0]                                  flags_r;            
reg    [23: 0]                                  byte_count_r;       
 
wire                                            strm_fifo_valid_out;
reg                                             strm_fifo_tready_in;
wire  [AXIS_TDATA_WIDTH-1:0]                    strm_fifo_tdata_out;
wire  [AXIS_TKEEP_WIDTH-1:0]                    strm_fifo_tkeep_out;
wire  [4:0]                                     extra_valid_bytes;
wire                                            strm_fifo_tlast_out;
reg   [2:0]                                     WrBuffer_r;
reg   [2:0]                                     RdBuffer_r;
reg                                             submit_sgl_element_r;
reg   [7:0]                                     Buffer_full;
// reg   [2:0]                                     Buffer_1_full;
reg   [7:0]                                     Buffer_tlast;
// reg   [2:0]                                     Buffer_1_tlast;


reg  [9:0]                                      RdByteCount_r;
reg  [M_ID_WIDTH-1:0]                           BuffEndArid_r;
reg                                             m_arvalid_int;
reg                                             m_arready_int;
wire                                            m_arvalid_bram;
wire                                            m_arready_bram;
  
wire                                            bram_en_a;    
wire                                            bram_aclk;    
wire                                            bram_rst_a;    
wire [15:0]                                     bram_we_a;    
wire [13:0]                                     bram_addr_a;  
wire [127:0]                                    bram_wrdata_a;
wire [127:0]                                    bram_rddata_a;
wire [15:0]                                     bram_wr_b;
wire [13:0]                                     bram_addrb;
reg  [8:0]                                      BufferAdd_r;


//-------------------------------------------------------------------------  
// Streaming FIFO Instantiation
//-------------------------------------------------------------------------  
c2s_strm_fifo c2s_fifo_generator_i 
(
    .s_aclk             (aclk),
    .s_aresetn          (nRESET),
    .s_axis_tvalid      (axi_stream_c2s_tvalid),
    .s_axis_tready      (axi_stream_c2s_tready),
    .s_axis_tdata       (axi_stream_c2s_tdata),
    .s_axis_tkeep       (axi_stream_c2s_tkeep),
    .s_axis_tlast       (axi_stream_c2s_tlast),                                                 
    .m_axis_tvalid      (strm_fifo_valid_out),                                                                    
    .m_axis_tready      (strm_fifo_tready_in),                                                                    
    .m_axis_tdata       (strm_fifo_tdata_out),                                                                    
    .m_axis_tkeep       (strm_fifo_tkeep_out),                                                                    
    .m_axis_tlast       (strm_fifo_tlast_out)                                                                                           
);


//-------------------------------------------------------------------------  
// Sttreaming FIFO TREADY control logic
//-------------------------------------------------------------------------                                                 
always @(posedge aclk or negedge nRESET)
begin
  if(nRESET == 1'b0)
  begin
    strm_fifo_tready_in   <= 1'b1;
  end
  else
  begin
    // Deassert FIFO trdy with TLAST out of streaming FIFO
    if (strm_fifo_tlast_out & strm_fifo_valid_out & strm_fifo_tready_in)
    begin
      strm_fifo_tready_in   <= 1'b0;
    end
    // Deassert FIFO trdy with local buffer_0 full 
    else if ((BufferAdd_r == BUFF_THRESHOLD) && (bram_wr_b[0] == 1'b1))
    begin
      strm_fifo_tready_in   <= 1'b0;
    end
    // Deassert FIFO trdy with local buffer_1 full or with TLAST
    else if (((Buffer_full[WrBuffer_r] == 1'b1) || (Buffer_tlast[WrBuffer_r] == 1'b1)))
    begin
      strm_fifo_tready_in   <= 1'b0;
    end
//     // Deassert FIFO trdy with local buffer_1 full or with TLAST
//     else if (((Buffer_1_full[WrBuffer_r] == 1'b1) || (Buffer_1_tlast[WrBuffer_r] == 1'b1)))
//     begin
//       strm_fifo_tready_in   <= 1'b0;
//     end
    // Deassert FIFO trdy during sgl submission
    else if (submit_sgl_element_r == 1'b1)
    begin
      strm_fifo_tready_in   <= 1'b0;
    end
    else
    begin
      strm_fifo_tready_in   <= 1'b1;
    end    
  end
end  

//-------------------------------------------------------------------------
// Buffer Write address control
//-------------------------------------------------------------------------
always @(posedge aclk or negedge nRESET)
begin
  if(nRESET == 1'b0)
  begin
    BufferAdd_r <= 9'h000;
  end
  else
  begin
    // Buffer full or TLAST detected
    if (((BufferAdd_r == BUFF_THRESHOLD) && (bram_wr_b[0] == 1'b1)) || (strm_fifo_tlast_out & strm_fifo_valid_out & strm_fifo_tready_in))
    begin
      BufferAdd_r <= 9'h000;
    end
    // Increment with wr en
    else if  (bram_wr_b[0] == 1'b1)
    begin
      BufferAdd_r <= BufferAdd_r + 5'd16;
    end
    else 
    begin  
      BufferAdd_r <= BufferAdd_r;
    end       
  end  
end  
// MSB is the write buffer ID
assign bram_addrb = {2'h0,WrBuffer_r,BufferAdd_r};

//-------------------------------------------------------------------------
// Buffer full status latching
//-------------------------------------------------------------------------
always @(posedge aclk or negedge nRESET)
begin
  if(nRESET == 1'b0)
  begin
    Buffer_full  <= 8'h00;
  end
  else
  begin
  
//     begin : BUFFER_FULL_GEN
//       integer i;
//         for(i=0; i<8; i=i+1)
//           // buffer is already full and the write buffer pointer is incremented 
//           if ((Buffer_full[i] == 1'b1) && (WrBuffer_r != i))
//           begin
//             Buffer_full[i] <= 1'b0;
//           end
//           else if ((BufferAdd_r == BUFF_THRESHOLD) && (bram_wr_b[0] == 1'b1))
//           begin
//             Buffer_full[WrBuffer_r] <= 1'b1;
//           end
//           else
//           begin
//             Buffer_full <= Buffer_full;
//           end
//     end

    
    if ((BufferAdd_r == BUFF_THRESHOLD) && (bram_wr_b[0] == 1'b1))
    begin
      Buffer_full[WrBuffer_r] <= 1'b1;
    end
    // buffer is already full and the write buffer pointer is incremented 
    else if (WrBuffer_r == 3'h0)
    begin
      Buffer_full[7:1] <= 7'h00;
    end
    else if (WrBuffer_r == 3'h1)
    begin
      Buffer_full[7:2] <= 6'h00;
      Buffer_full[0]   <= 1'h0;
    end
    else if (WrBuffer_r == 3'h2)
    begin
      Buffer_full[7:3] <= 5'h00;
      Buffer_full[1:0] <= 2'h0;
    end
    else if (WrBuffer_r == 3'h3)
    begin
      Buffer_full[7:4] <= 4'h0;
      Buffer_full[2:0] <= 3'h0;
    end
    else if (WrBuffer_r == 3'h4)
    begin
      Buffer_full[7:5] <= 3'h0;
      Buffer_full[3:0] <= 4'h0;
    end
    else if (WrBuffer_r == 3'h5)
    begin
      Buffer_full[7:6] <= 2'h0;
      Buffer_full[4:0] <= 5'h00;
    end
    else if (WrBuffer_r == 3'h6)
    begin
      Buffer_full[7]   <= 1'h0;
      Buffer_full[5:0] <= 6'h00;
    end
    else if (WrBuffer_r == 3'h7)
    begin
      Buffer_full[6:0] <= 7'h00;
    end
    else
    begin
      Buffer_full <= Buffer_full;
    end
    

// // // // //   // clear with first read request of buffer 0
// // // // //     if ((RdBuffer_r == 1'b0) &&  (m_rvalid == 1'b1) && (m_rready == 1'b1))
// // // // //     begin
// // // // //       Buffer_full <= 1'b0;
// // // // //     end
// // // // //   // Set when write address reaches threshold
// // // // //     else if ((WrBuffer_r == 1'b0) && ((BufferAdd_r == BUFF_THRESHOLD) && (bram_wr_b[0] == 1'b1)))
// // // // //     begin
// // // // //       Buffer_full <= 1'b1;
// // // // //     end
// // // // //     else
// // // // //     begin
// // // // //       Buffer_full <= Buffer_full;
// // // // //     end
// // // // //     
// // // // //   // clear when read buffer sets to 0
// // // // //     if ((RdBuffer_r == 1'b1) && (m_rvalid == 1'b1) && (m_rready == 1'b1))
// // // // //     begin
// // // // //       Buffer_1_full <= 1'b0;
// // // // //     end
// // // // //   // Set when write address reaches threshold
// // // // //     else if ((WrBuffer_r == 1'b1) && ((BufferAdd_r == BUFF_THRESHOLD) && (bram_wr_b[0] == 1'b1)))
// // // // //     begin
// // // // //       Buffer_1_full <= 1'b1;
// // // // //     end
// // // // //     else
// // // // //     begin
// // // // //       Buffer_1_full <= Buffer_1_full;
// // // // //     end
    
  end  
end  

//-------------------------------------------------------------------------
// Buffer TLAST Detection status latching
//-------------------------------------------------------------------------
always @(posedge aclk or negedge nRESET)
begin
  if(nRESET == 1'b0)
  begin
    Buffer_tlast <= 8'h00;
  end
  else
  begin
  
//     begin : BUFFER_LAST_GEN
//       integer i;
//         for(i=0; i<8; i=i+1)
//           // buffer is already full and the write buffer pointer is incremented 
//           if ((Buffer_tlast[i] == 1'b1) && (WrBuffer_r != i))
//           begin
//             Buffer_tlast[i] <= 1'b0;
//           end
//           else if ((strm_fifo_tlast_out == 1'b1) && (strm_fifo_valid_out == 1'b1) && (strm_fifo_tready_in == 1'b1))
//           begin
//             Buffer_tlast[WrBuffer_r] <= 1'b1;
//           end
//           else
//           begin
//             Buffer_tlast <= Buffer_tlast;
//           end
//     end
  
    if ((strm_fifo_tlast_out == 1'b1) && (strm_fifo_valid_out == 1'b1) && (strm_fifo_tready_in == 1'b1))
    begin
      Buffer_tlast[WrBuffer_r] <= 1'b1;
    end
    // buffer is already full and the write buffer pointer is incremented 
    else if (WrBuffer_r == 3'h0)
    begin
      Buffer_tlast[7:1] <= 7'h00;
    end
    else if (WrBuffer_r == 3'h1)
    begin
      Buffer_tlast[7:2] <= 6'h00;
      Buffer_tlast[0]   <= 1'h0;
    end
    else if (WrBuffer_r == 3'h2)
    begin
      Buffer_tlast[7:3] <= 5'h00;
      Buffer_tlast[1:0] <= 2'h0;
    end
    else if (WrBuffer_r == 3'h3)
    begin
      Buffer_tlast[7:4] <= 4'h0;
      Buffer_tlast[2:0] <= 3'h0;
    end
    else if (WrBuffer_r == 3'h4)
    begin
      Buffer_tlast[7:5] <= 3'h0;
      Buffer_tlast[3:0] <= 4'h0;
    end
    else if (WrBuffer_r == 3'h5)
    begin
      Buffer_tlast[7:6] <= 2'h0;
      Buffer_tlast[4:0] <= 5'h00;
    end
    else if (WrBuffer_r == 3'h6)
    begin
      Buffer_tlast[7]   <= 1'h0;
      Buffer_tlast[5:0] <= 6'h00;
    end
    else if (WrBuffer_r == 3'h7)
    begin
      Buffer_tlast[6:0] <= 7'h00;
    end
    else
    begin
      Buffer_tlast <= Buffer_tlast;
    end
      
// // // // // // //   // clear when read buffer sets to 0
// // // // // // //     if ((RdBuffer_r == 1'b0) &&  (m_rvalid == 1'b1) && (m_rready == 1'b1))
// // // // // // //     begin
// // // // // // //       Buffer_tlast <= 1'b0;
// // // // // // //     end
// // // // // // //   // Set when TLAST event occurs
// // // // // // //     else if ((WrBuffer_r == 1'b0) && (strm_fifo_tlast_out & strm_fifo_valid_out & strm_fifo_tready_in))
// // // // // // //     begin
// // // // // // //       Buffer_tlast <= 1'b1;
// // // // // // //     end
// // // // // // //     else
// // // // // // //     begin
// // // // // // //       Buffer_tlast <= Buffer_tlast;
// // // // // // //     end
// // // // // // //     
// // // // // // //   // clear when read buffer sets to 0
// // // // // // //     if ((RdBuffer_r == 1'b1) &&  (m_rvalid == 1'b1) && (m_rready == 1'b1))
// // // // // // //     begin
// // // // // // //       Buffer_1_tlast <= 1'b0;
// // // // // // //     end
// // // // // // //   // Set when TLAST event occurs
// // // // // // //     else if ((WrBuffer_r == 1'b1) && (strm_fifo_tlast_out & strm_fifo_valid_out & strm_fifo_tready_in))
// // // // // // //     begin
// // // // // // //       Buffer_1_tlast <= 1'b1;
// // // // // // //     end
// // // // // // //     else
// // // // // // //     begin
// // // // // // //       Buffer_1_tlast <= Buffer_1_tlast;
// // // // // // //     end
    
  end  
end  

//-------------------------------------------------------------------------
// Write Buffer control
//-------------------------------------------------------------------------
always @(posedge aclk or negedge nRESET)
begin
  if(nRESET == 1'b0)
  begin
    WrBuffer_r <= 3'h0;
  end
  else
  begin
    if ((WrBuffer_r == 3'h7) && (RdBuffer_r == 3'h0))
    begin
      WrBuffer_r <= WrBuffer_r;
    end
    else if (WrBuffer_r + 1'b1 != RdBuffer_r)
    begin
      // with TLAST
      if (strm_fifo_tlast_out & strm_fifo_valid_out & strm_fifo_tready_in)
      begin
        WrBuffer_r <= WrBuffer_r + 1'b1;
      end
      // Buffer full
      else if ((BufferAdd_r == BUFF_THRESHOLD) && (bram_wr_b[0] == 1'b1))
      begin
        WrBuffer_r <= WrBuffer_r + 1'b1;
      end
      // Buffer is already full or TLAST was detected
      else if (((Buffer_full[WrBuffer_r] == 1'b1) || (Buffer_tlast[WrBuffer_r] == 1'b1)))
      begin
        WrBuffer_r <= WrBuffer_r + 1'b1;
      end
      else 
      begin
        WrBuffer_r <= WrBuffer_r;
      end
    end
    else
    begin
      WrBuffer_r <= WrBuffer_r;
    end  
  end  
end  

//-------------------------------------------------------------------------
// SGL Submit control
//-------------------------------------------------------------------------
always @(posedge aclk or negedge nRESET)
begin
  if(nRESET == 1'b0)
  begin
    submit_sgl_element_r  <= 1'b0;
  end
  else
  begin
    if ((sgl_available == 1'b1) && (sgl_done == 1'b1))
    begin
      submit_sgl_element_r  <= 1'b0;
    end
    else if ((BufferAdd_r == BUFF_THRESHOLD) && (bram_wr_b[0] == 1'b1))
    begin
      submit_sgl_element_r  <= 1'b1;
    end
    else if (strm_fifo_tlast_out & strm_fifo_valid_out & strm_fifo_tready_in)
    begin
      submit_sgl_element_r  <= 1'b1;
    end
    else
    begin
      submit_sgl_element_r  <= submit_sgl_element_r;
    end
  end  
end  

//------------------------------------------------------------------------------------------------  
// Buffer Data availability count logic
//------------------------------------------------------------------------------------------------      
// Byte enable consideration
assign extra_valid_bytes = (strm_fifo_tkeep_out == 16'h0000 ) ? 5'd0  :
                           (strm_fifo_tkeep_out == 16'h0001 ) ? 5'd1  :  
                           (strm_fifo_tkeep_out == 16'h0003 ) ? 5'd2  :  
                           (strm_fifo_tkeep_out == 16'h0007 ) ? 5'd3  :  
                           (strm_fifo_tkeep_out == 16'h000F ) ? 5'd4  :  
                           (strm_fifo_tkeep_out == 16'h001F ) ? 5'd5  :  
                           (strm_fifo_tkeep_out == 16'h003F ) ? 5'd6  :  
                           (strm_fifo_tkeep_out == 16'h007F ) ? 5'd7  :  
                           (strm_fifo_tkeep_out == 16'h00FF ) ? 5'd8  :  
                           (strm_fifo_tkeep_out == 16'h01FF ) ? 5'd9  :  
                           (strm_fifo_tkeep_out == 16'h03FF ) ? 5'd10 :  
                           (strm_fifo_tkeep_out == 16'h07FF ) ? 5'd11 :  
                           (strm_fifo_tkeep_out == 16'h0FFF ) ? 5'd12 :  
                           (strm_fifo_tkeep_out == 16'h1FFF ) ? 5'd13 :  
                           (strm_fifo_tkeep_out == 16'h3FFF ) ? 5'd14 :  
                           (strm_fifo_tkeep_out == 16'h7FFF ) ? 5'd15 : 5'd16 ; 

//-----------------------------------------------------------------------------------------------------------  
// SGL Element Preparation 
//----------------------------------------------------------------------------------------------------------- 
                                                
always @(posedge aclk or negedge nRESET)
begin
  if(nRESET == 1'b0)
  begin
    buffer_address_r   <= 32'h00000000;
    user_id_r          <= {13'hFFF,WrBuffer_r}; 
    byte_count_r       <= BUFFER_SIZE; 
    flags_r            <= 8'h00;
  end
  else
  begin
    if  (strm_fifo_tlast_out & strm_fifo_valid_out & strm_fifo_tready_in)
    begin
      buffer_address_r   <= START_ADDRESS + {WrBuffer_r,9'h000};
      user_id_r          <= {13'hFFF,WrBuffer_r}; 
      flags_r            <= {m_arcache,1'b0,1'b1,1'b1,1'b1}; // EOP== "1" ==> TlastDetected_r sets EOP bit in the element
      byte_count_r       <= (BufferAdd_r + extra_valid_bytes);
    end
    else if  ((BufferAdd_r == BUFF_THRESHOLD) && (bram_wr_b[0] == 1'b1))
    begin
      buffer_address_r   <= START_ADDRESS + {WrBuffer_r,9'h000};
      user_id_r          <= {13'hFFF,WrBuffer_r}; 
      flags_r            <= {m_arcache,1'b0,1'b1,1'b0,1'b1}; // EOP ==0
      byte_count_r       <= (BufferAdd_r + extra_valid_bytes);
    end
    else
    begin
      buffer_address_r   <= buffer_address_r;
      user_id_r          <= user_id_r;
      byte_count_r       <= byte_count_r;
      flags_r            <= flags_r;   
    end
  end
end  

//-------------------------------------------------------------------------  
// SGL Element update logic 
//     |-----------------|-------------|-------------|--------------|
//     |   [ 79: 48]     |  [ 47: 32]  |  [ 31: 24]  |   [ 23:  0]  |
//     |-----------------|-------------|-------------|--------------|
//     | buffer_address_r|  user_id_r  |   flags_r   | byte_count_r |        
//     |-----------------|-------------|-------------|--------------|
//-------------------------------------------------------------------------    

assign sgl_available = (submit_sgl_element_r == 1'b1) ? 1'b1 : 1'b0;
assign sgl_data      = (submit_sgl_element_r == 1'b1) ? {buffer_address_r,user_id_r,flags_r,byte_count_r} : 112'h0000_0000_0000_0000_0000_0000;
                                        


//-------------------------------------------------------------------------
// Buffer Read Byte count 
//-------------------------------------------------------------------------
always @(posedge aclk or negedge nRESET)
begin
  if(nRESET == 1'b0)
  begin
    RdByteCount_r <= 10'b0;
  end
  else
  begin
      // reset read byte count once it reaches sgl buffer size
    if (RdByteCount_r == BUFFER_SIZE) 
    begin
      RdByteCount_r <= 10'h000;
    end
    else if ((m_arvalid == 1'b1) && (m_arready == 1'b1))
    begin
    // reset read byte count with eop
      if (m_areop == 1'b1)
      begin
        RdByteCount_r <= 10'h000;
      end
      else
      begin
        // increment read byte count with every arvalid
        RdByteCount_r <= RdByteCount_r + m_arbcount;   
      end  
    end        
    else 
    begin
      RdByteCount_r <= RdByteCount_r;   
    end    
  end  
end  
//-------------------------------------------------------------------------
// Buffer end read id latch
//-------------------------------------------------------------------------
always @(posedge aclk or negedge nRESET)
begin
  if(nRESET == 1'b0)
  begin
    BuffEndArid_r <= 4'h0;
  end
  else 
  begin
    if ( (m_arvalid == 1'b1) && (m_arready == 1'b1) && (RdByteCount_r + m_arbcount == BUFFER_SIZE) )
    begin
      BuffEndArid_r <= m_arid;
    end
    else if ((m_arvalid == 1'b1) && (m_arready == 1'b1) && (m_areop == 1'b1))
    begin
      BuffEndArid_r <= m_arid;
    end
    else
    begin
      BuffEndArid_r <= BuffEndArid_r;
    end
  end
end  

//-------------------------------------------------------------------------
//  Read Buffer control
//-------------------------------------------------------------------------
always @(posedge aclk or negedge nRESET)
begin
  if(nRESET == 1'b0)
  begin
    RdBuffer_r <= 3'h0;
  end
  else
  begin
    // Wait for last read id of the current buffer 
    if ((m_rlast == 1'b1) && (m_rvalid == 1'b1) && (m_rready == 1'b1) && ( m_rid == BuffEndArid_r))
    begin
      if (RdBuffer_r == 3'h7)
      begin
        RdBuffer_r <= 3'h0;
      end
      else
      begin
        RdBuffer_r <= RdBuffer_r + 1'b1;
      end
    end
    else
    begin
      RdBuffer_r <= RdBuffer_r;
    end  
  end  
end  

//-------------------------------------------------------------------------
//  archannel throattle
//-------------------------------------------------------------------------
always @(posedge aclk or negedge nRESET)
begin
  if(nRESET == 1'b0)
  begin
    m_arvalid_int <= 1'b1;
    m_arready_int <= 1'b1;
  end
  else
  begin
    if ((m_arvalid == 1'b1) && (m_arready == 1'b1) && (RdByteCount_r + m_arbcount == BUFFER_SIZE))
    begin
      m_arvalid_int <= 1'b0;
      m_arready_int <= 1'b0;
    end
    else if ((m_arvalid == 1'b1) && (m_arready == 1'b1) && (m_areop == 1'b1))
    begin
      m_arvalid_int <= 1'b0;
      m_arready_int <= 1'b0;
    end
    else if ((m_rlast == 1'b1) && (m_rvalid == 1'b1) && (m_rready == 1'b1) && ( m_rid == BuffEndArid_r))
    begin
      m_arvalid_int <= 1'b1;
      m_arready_int <= 1'b1;
    end
    else
    begin
      m_arvalid_int <= m_arvalid_int;
      m_arready_int <= m_arready_int;
    end
  
  end  
end  

//-------------------------------------------------------------------------  
// AXI Bram Controller
//-------------------------------------------------------------------------    
assign m_arvalid_bram     = m_arvalid & m_arvalid_int;
assign m_arready          = m_arready_bram & m_arready_int;

 
axi_bram_ctrl_0 axi_bram_ctrl_i 
(                                                                 
    .s_axi_aclk    (aclk ),                                       
    .s_axi_aresetn (nRESET ),                                           
    .s_axi_awid    (4'h0 ),                                     
    .s_axi_awaddr  (14'h0000),                                   
    .s_axi_awlen   (8'h00),                                    
    .s_axi_awsize  (3'h0 ),                                   
    .s_axi_awburst (2'h0),                                  
    .s_axi_awlock  (1'b0),                                           
    .s_axi_awcache (4'h0 ),                                  
    .s_axi_awprot  (3'h0 ),                                   
    .s_axi_awvalid (1'b0),                                   
    .s_axi_awready ( ),                                  
    .s_axi_wdata   (128'h0000_0000_0000_0000_0000_0000_0000_0000),                                    
    .s_axi_wstrb   (16'h0000 ),                                    
    .s_axi_wlast   (1'b0 ),                                    
    .s_axi_wvalid  (1'b0 ),                                   
    .s_axi_wready  ( ),                                   
    .s_axi_bid     ( ),                                      
    .s_axi_bresp   ( ),                                    
    .s_axi_bvalid  ( ),                                   
    .s_axi_bready  (1'b0 ),                                   
    .s_axi_arid    (m_arid ),                                     
    .s_axi_araddr  (m_araddr [13:0] ),                                   
    .s_axi_arlen   ({4'h0, m_arlen}),                                    
    .s_axi_arsize  (m_arsize ),                                   
    .s_axi_arburst (m_arburst ),                                  
    .s_axi_arlock  (1'b0),                                           
    .s_axi_arcache (m_arcache ),                                  
    .s_axi_arprot  (m_arprot ),                                   
    .s_axi_arvalid (m_arvalid_bram ),                                  
    .s_axi_arready (m_arready_bram ),                                  
    .s_axi_rid     (m_rid ),                                      
    .s_axi_rdata   (m_rdata ),                                    
    .s_axi_rresp   (m_rresp ),                                    
    .s_axi_rlast   (m_rlast ),                                    
    .s_axi_rvalid  (m_rvalid ),                                   
    .s_axi_rready  (m_rready ),                                   
    .bram_rst_a    (bram_rst_a),                                     
    .bram_clk_a    (bram_aclk  ),                                      
    .bram_en_a     (bram_en_a     ),                              
    .bram_we_a     (bram_we_a     ),                              
    .bram_addr_a   (bram_addr_a   ),                              
    .bram_wrdata_a (bram_wrdata_a ),                              
    .bram_rddata_a (bram_rddata_a )                               
  );

  
//-------------------------------------------------------------------------  
// Local Buffer_0 Instantiation
//-------------------------------------------------------------------------     
blk_mem_gen_0 blk_mem_gen_i 
(
    .clka  ( bram_aclk ),
    .rsta  ( bram_rst_a ),
    .ena   ( bram_en_a),
    .wea   ( bram_we_a),
    .addra ( {18'h00000,bram_addr_a}),
    .dina  ( bram_wrdata_a),
    .douta ( bram_rddata_a),
    .clkb  (aclk ),
    .rstb  (1'b0 ),
    .enb   (1'b1 ),
    .web   (bram_wr_b ),
    .addrb ({18'h00000,bram_addrb}),
    .dinb  (strm_fifo_tdata_out ),
    .doutb ( )
  );
 
  
 assign bram_wr_b = ((strm_fifo_valid_out == 1'b1) && (strm_fifo_tready_in == 1'b1)) ? strm_fifo_tkeep_out : 16'h0000;

endmodule

