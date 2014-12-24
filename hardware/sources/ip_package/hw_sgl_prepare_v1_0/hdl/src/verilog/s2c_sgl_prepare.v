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
// File       : s2c_sgl_prepare.v
//
// Revision History
// ------------------------------
// Version   |    Description
// ----------|-------------------
// 1.0       |    Initial Release
//-----------------------------------------------------------------------------

//`timescale 1ps / 1ps
(* CORE_GENERATION_INFO = "" *)
module  s2c_sgl_prepare # 
  (
    parameter BUFFER_SIZE          = 512,
    parameter START_ADDRESS        = 32'hC0000000,
    parameter NUM_OF_SGL_ELEMENTS  = 8,
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
    output  reg                                  sgl_available,
    input                                        sgl_done,
    input                                        sgl_error,
    output  reg [(BIT64_ADDR_EN*32 + 112)-1 : 0] sgl_data,
    
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
    input       [M_BCOUNT_WIDTH-1:0]             m_awbcount,                 //   For FIFO DMA transactions, m_awregion indicates source DMA Channel, m_awbcount indicates exact byte count of transaction,
    input                                        m_aweop,                    //    m_aweop indicates end of DMA packet
                                                
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
    output                                       m_rlast,                     //
                                                
 // AXI Streaming Interface                     
    output      [AXIS_TDATA_WIDTH-1:0]           axi_stream_s2c_tdata,
    output      [AXIS_TKEEP_WIDTH-1:0]           axi_stream_s2c_tkeep,
    output                                       axi_stream_s2c_tvalid,
    output                                       axi_stream_s2c_tlast,
    input                                        axi_stream_s2c_tready
                                                
  );
  
// State Parameters
localparam START                                  = 10'b0000000001; // 1 
localparam UPDATE_FIRST_SGL_ELEMENT               = 10'b0000000010; // 2
localparam UPDATE_SECOND_SGL_ELEMENT              = 10'b0000000100; // 4 
localparam UPDATE_THIRD_SGL_ELEMENT               = 10'b0000001000; // 8 
localparam UPDATE_FOURTH_SGL_ELEMENT              = 10'b0000010000; // 10 
localparam UPDATE_FIFTH_SGL_ELEMENT               = 10'b0000100000; // 20 
localparam UPDATE_SIXTH_SGL_ELEMENT               = 10'b0001000000; // 40 
localparam UPDATE_SEVENTH_SGL_ELEMENT             = 10'b0010000000; // 80 
localparam UPDATE_EIGHTH_SGL_ELEMENT              = 10'b0100000000; // 100               
localparam WAIT_FOR_DATA_PACKET                   = 10'b1000000000; // 200 


//-------------------------------------------------------------------------
// Register Declarations 
//-------------------------------------------------------------------------
reg    [10:0]                                    CurrentState_r;
reg    [10:0]                                    NextState_r;
                                               
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
wire   [(BIT64_ADDR_EN*32 + 32)-1 : 0]          buffer_address_r;   
wire   [15: 0]                                  user_id_r;      
wire   [ 7: 0]                                  flags_r;            
wire   [23: 0]                                  byte_count_r;    
wire                                            m_awvalid_int; 
wire                                            m_awready_int; 
wire                                            m_wvalid_int;  
wire                                            m_wready_int;  
wire                                            m_awvalid_bram;
wire                                            m_wvalid_bram; 
wire                                            m_awready_bram; 
wire                                            m_wready_bram; 
wire                                            bram_en_a;    
wire                                            bram_aclk;    
wire                                            bram_rst_a;    
wire [15:0]                                     bram_we_a;    
wire [13:0]                                     bram_addr_a;  
wire [127:0]                                    bram_wrdata_a;
wire [127:0]                                    bram_rddata_a;
wire                                            bram_en_b;    
wire [14:0]                                     bram_addr_b;
wire [127:0]                                    bram_rddata_b;
wire                                            rd_valid_rdy;    
wire                                            rd_start_rdy;    
wire                                            rd_done;    
 
reg    [9: 0]                                   receivebyte_count_r;
reg                                             submit_sgl_element_r;
reg    [2:0]                                    sgl_element_count_r;
reg                                             rd_valid_r;
reg                                             is_eop_r;
reg    [3:0]                                    rd_awid_r;
wire   [3:0]                                    m_bid_int;
reg                                             rd_start_r;
reg    [31: 0]                                  rd_addr_r;
reg    [9: 0]                                   rd_bcnt_r;

 
//-------------------------------------------------------------------------
// Updating sgl_element submition count
//-------------------------------------------------------------------------
always @(posedge aclk or negedge nRESET)
begin
  if(nRESET == 1'b0)
  begin
    sgl_element_count_r <= 3'h0;
  end
  else
  begin
    if ((sgl_available == 1'b1) && (sgl_done ==1'b1))
    begin
      if (sgl_element_count_r == NUM_OF_SGL_ELEMENTS - 1'b1)
      begin
        sgl_element_count_r <= 3'h0;
      end
      else
      begin
        sgl_element_count_r <= sgl_element_count_r + 1'b1;
      end              
    end
    else 
    begin
      sgl_element_count_r <= sgl_element_count_r;
    end
  end  
end  
//-------------------------------------------------------------------------
// Updating Current State 
//-------------------------------------------------------------------------
always @(posedge aclk or negedge nRESET)
begin
  if(nRESET == 1'b0)
  begin
    CurrentState_r <= START;
  end
  else
  begin
    CurrentState_r <= NextState_r;
  end  
end  

//-------------------------------------------------------------------------
// Updating Next State                                                                                                                
//-------------------------------------------------------------------------                                                 
always@ ( * )                                                                                                      
begin                                                                                                                           
  case(CurrentState_r) 
    START:
    begin 
      if(nRESET == 1'b0) begin
        NextState_r = START;
      end
      else begin
        NextState_r = UPDATE_FIRST_SGL_ELEMENT;
      end    
    end //End of START
    
    UPDATE_FIRST_SGL_ELEMENT:
    begin
      if (sgl_done == 1'b1 )
      begin
        NextState_r = UPDATE_SECOND_SGL_ELEMENT;
      end
      else
      begin
        NextState_r = CurrentState_r;
      end
    end //End of UPDATE_FIRST_SGL_ELEMENT     
    
    UPDATE_SECOND_SGL_ELEMENT:
    begin
      if (sgl_done == 1'b1 )
      begin
        NextState_r = UPDATE_THIRD_SGL_ELEMENT;
      end
      else
      begin
        NextState_r = CurrentState_r;
      end
    end //End of UPDATE_FIRST_SGL_ELEMENT     
    
    UPDATE_THIRD_SGL_ELEMENT:
    begin
      if (sgl_done == 1'b1 )
      begin
        NextState_r = UPDATE_FOURTH_SGL_ELEMENT;
      end
      else
      begin
        NextState_r = CurrentState_r;
      end
    end //End of UPDATE_THIRD_SGL_ELEMENT     
    
    UPDATE_FOURTH_SGL_ELEMENT:
    begin
      if (sgl_done == 1'b1 )
      begin
        NextState_r = UPDATE_FIFTH_SGL_ELEMENT;
      end
      else
      begin
        NextState_r = CurrentState_r;
      end
    end //End of UPDATE_FOURTH_SGL_ELEMENT     
    
    UPDATE_FIFTH_SGL_ELEMENT:
    begin
      if (sgl_done == 1'b1 )
      begin
        NextState_r = UPDATE_SIXTH_SGL_ELEMENT;
      end
      else
      begin
        NextState_r = CurrentState_r;
      end
    end //End of UPDATE_FIFTH_SGL_ELEMENT     
    
    UPDATE_SIXTH_SGL_ELEMENT:
    begin
      if (sgl_done == 1'b1 )
      begin
        NextState_r = UPDATE_SEVENTH_SGL_ELEMENT;
      end
      else
      begin
        NextState_r = CurrentState_r;
      end
    end //End of UPDATE_SIXTH_SGL_ELEMENT     
    
    UPDATE_SEVENTH_SGL_ELEMENT:
    begin
      if (sgl_done == 1'b1 )
      begin
        NextState_r = UPDATE_EIGHTH_SGL_ELEMENT;
      end
      else
      begin
        NextState_r = CurrentState_r;
      end
    end //End of UPDATE_SEVENTH_SGL_ELEMENT     
    
    UPDATE_EIGHTH_SGL_ELEMENT: 
    begin
      if (sgl_done == 1'b1 )
      begin
        NextState_r = WAIT_FOR_DATA_PACKET;
      end
      else
      begin
        NextState_r = CurrentState_r;
      end
    end //End of UPDATE_EIGHTH_SGL_ELEMENT     
    
    WAIT_FOR_DATA_PACKET:
    begin
       NextState_r = CurrentState_r;
    end //End of WAIT_FOR_DATA_PACKET     
       
    default: begin
      NextState_r = START;
    end 
  endcase
end // End of always


//-------------------------------------------------------------------------  
// Receive byte count
//  monitor receivee byte count to check the requested buffer received
//  submit a fresh sgl element once requested buffer received or with end of packet
//  no more sgl elments submitted once FIFO reaches full threshold
//-------------------------------------------------------------------------  
always @(posedge aclk or negedge nRESET)
begin
  if(nRESET == 1'b0)
  begin
    receivebyte_count_r <= 10'h000;
    submit_sgl_element_r  <= 1'b0;
  end
  else   
  begin
    // reset receive byte count once it reaches requested buffer size
    if (receivebyte_count_r == BUFFER_SIZE)
    begin
      receivebyte_count_r <= 10'h000;
    end
    else if ((m_awvalid_bram == 1'b1) && (m_awready_bram == 1'b1))
    begin
    // reset receive byte count with eop
      if (m_aweop == 1'b1)
      begin
        receivebyte_count_r <= 10'h000;
      end
      else
      begin
        // increment receive byte count with every awvalid
        receivebyte_count_r <= receivebyte_count_r + m_awbcount;   
      end  
    end
    // deassert with sgl done ack
    if ((sgl_available == 1'b1) && (sgl_done == 1'b1))
    begin
      submit_sgl_element_r <= 1'b0;
    end
    // Submit sgl with requested buffer receive or end of packet
    else if (rd_done == 1'b1)
    begin
      submit_sgl_element_r <= 1'b1;
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
assign buffer_address_r =  (sgl_element_count_r == 3'd7 ) ? START_ADDRESS + 12'hE00 :
                           (sgl_element_count_r == 3'd6 ) ? START_ADDRESS + 12'hC00 :  
                           (sgl_element_count_r == 3'd5 ) ? START_ADDRESS + 12'hA00 :  
                           (sgl_element_count_r == 3'd4 ) ? START_ADDRESS + 12'h800 :  
                           (sgl_element_count_r == 3'd3 ) ? START_ADDRESS + 12'h600 :  
                           (sgl_element_count_r == 3'd2 ) ? START_ADDRESS + 12'h400 :  
                           (sgl_element_count_r == 3'd1 ) ? START_ADDRESS + 12'h200 :  START_ADDRESS;
assign user_id_r        = 16'hffff;      // NON zero value                                                                                                                      
assign flags_r          = {m_awcache, 2'b00,1'b1,1'b1};                                                                                                                          
assign byte_count_r     = BUFFER_SIZE;                                                                                                                                          
                                                                                                                                                                                 
always @(posedge aclk or negedge nRESET)                                                                                                                                         
begin                                                                                                                                                                          
  if(nRESET == 1'b0)                                                                                                                                                            
  begin
    sgl_available        <= 1'b0;
    sgl_data             <= 112'h0000_0000_0000_0000_0000_0000;
  end
  else
  begin
   // Clear with sgl done ack from submit block
    if ( sgl_done == 1'b1)
    begin
      sgl_available      <= 1'b0;
      sgl_data           <= 112'h0000_0000_0000_0000_0000_0000;
    end 
    // Assert SGL available signal with valid SGL Element during UPDATE_SGL_ELEMENT state
//     else if ( (CurrentState_r == UPDATE_FIRST_SGL_ELEMENT) || (CurrentState_r == UPDATE_SECOND_SGL_ELEMENT) || (CurrentState_r == UPDATE_THIRD_SGL_ELEMENT) || (CurrentState_r == UPDATE_FOURTH_SGL_ELEMENT) || (CurrentState_r == UPDATE_FIFTH_SGL_ELEMENT) || (CurrentState_r == UPDATE_SIXTH_SGL_ELEMENT) || (CurrentState_r == UPDATE_SEVENTH_SGL_ELEMENT) || (CurrentState_r == UPDATE_EIGHTH_SGL_ELEMENT) || (submit_sgl_element_r == 1'b1))
    else if ( (| CurrentState_r[8:1]) || (submit_sgl_element_r == 1'b1))
    begin
      sgl_available      <= 1'b1;
      sgl_data           <= {buffer_address_r,user_id_r,flags_r,byte_count_r};
    end 
    else
    begin
      sgl_available      <= 1'b0;
      sgl_data           <= 112'h0000_0000_0000_0000_0000_0000;
    end 
  end
end  



assign m_awvalid_int = ((rd_valid_r == 1'b0) && (rd_valid_rdy == 1'b1)) ? 1'b1 : 1'b0 ;
assign m_awready_int = ((rd_valid_r == 1'b0) && (rd_valid_rdy == 1'b1)) ? 1'b1 : 1'b0 ;
assign m_wvalid_int  = ((rd_valid_r == 1'b0) && (rd_valid_rdy == 1'b1)) ? 1'b1 : 1'b0 ;
assign m_wready_int  = ((rd_valid_r == 1'b0) && (rd_valid_rdy == 1'b1)) ? 1'b1 : 1'b0 ;


assign m_awvalid_bram = m_awvalid      & m_awvalid_int;
assign m_awready      = m_awready_bram & m_awready_int;
assign m_wvalid_bram  = m_wvalid       & m_wvalid_int;
assign m_wready       = m_wready_bram  & m_wready_int;
assign m_bid          = m_awid;
 
axi_bram_ctrl_s2c axi_bram_ctrl_i                                                                                            
(                                                                                                                            
    .s_axi_aclk    (aclk ),                                                                                                  
    .s_axi_aresetn (nRESET ),                                                                                                
    .s_axi_awid    ({m_awaddr[11:9],1'b0}),   //internal AWID for bresp tracking                                                                                              
    .s_axi_awaddr  (m_awaddr[13:0]),                                                                                         
    .s_axi_awlen   ({4'h0, m_awlen}),                                    
    .s_axi_awsize  (m_awsize),                                   
    .s_axi_awburst (m_awburst),                                  
    .s_axi_awlock  (1'b0),                                           
    .s_axi_awcache (m_awcache),                                  
    .s_axi_awprot  (m_awprot),                                   
    .s_axi_awvalid (m_awvalid_bram),                                   
    .s_axi_awready (m_awready_bram),                                  
    .s_axi_wdata   (m_wdata),                                    
    .s_axi_wstrb   (m_wstrb),                                    
    .s_axi_wlast   (m_wlast),                                    
    .s_axi_wvalid  (m_wvalid_bram),                                   
    .s_axi_wready  (m_wready_bram),                                   
    .s_axi_bid     (m_bid_int),                                      
    .s_axi_bresp   (m_bresp),                                    
    .s_axi_bvalid  (m_bvalid),                                   
    .s_axi_bready  (m_bready),                                   
    .s_axi_arid    (4'h0 ),                                     
    .s_axi_araddr  (14'h0000),                                   
    .s_axi_arlen   (8'h00),                                    
    .s_axi_arsize  (3'h0),                                   
    .s_axi_arburst (2'h0),                                  
    .s_axi_arlock  (1'b0),                                           
    .s_axi_arcache (4'h0),                                  
    .s_axi_arprot  (3'h0),                                   
    .s_axi_arvalid (1'b0),                                  
    .s_axi_arready ( ),                                  
    .s_axi_rid     ( ),                                      
    .s_axi_rdata   ( ),                                    
    .s_axi_rresp   ( ),                                    
    .s_axi_rlast   ( ),                                    
    .s_axi_rvalid  ( ),                                   
    .s_axi_rready  (1'b0),                                   
    .bram_rst_a    (bram_rst_a),                                     
    .bram_clk_a    (bram_aclk  ),                                      
    .bram_en_a     (bram_en_a     ),                              
    .bram_we_a     (bram_we_a     ),                              
    .bram_addr_a   (bram_addr_a   ),                              
    .bram_wrdata_a (bram_wrdata_a ),                              
    .bram_rddata_a (bram_rddata_a )                               
  );

  
//-------------------------------------------------------------------------  
// BMG Instantiation
//-------------------------------------------------------------------------     

blk_mem_gen_s2c blk_mem_gen_i 
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
    .enb   (bram_en_b),
    .web   (16'h0000),
    .addrb ({17'h00000,bram_addr_b}),
    .dinb  (128'h0000_0000_0000_0000_0000_0000_0000_0000),
    .doutb (bram_rddata_b)
  );


//-------------------------------------------------------------------------
// RD Engine interface logic
//-------------------------------------------------------------------------

always @(posedge aclk or negedge nRESET)
begin
  if(nRESET == 1'b0)
  begin
    rd_valid_r  <= 1'b0;
    rd_addr_r   <= 32'h0000_0000;
    rd_bcnt_r   <= 10'h000;
    is_eop_r    <= 1'b0;
    rd_awid_r   <= 4'hF;
  end
  else
  begin
    if ((rd_valid_r == 1'b1) && (rd_valid_rdy == 1'b1))
    begin
      rd_valid_r  <= 1'b0;
      rd_addr_r   <= 32'h0000_0000;
      rd_bcnt_r   <= 10'h000;
      is_eop_r    <= 1'b0;
      rd_awid_r   <= rd_awid_r;
    end 
    else if (((receivebyte_count_r + m_awbcount == BUFFER_SIZE) || (m_aweop == 1'b1)) && (m_awvalid_bram == 1'b1) && (m_awready_bram == 1'b1))
    begin
      rd_valid_r  <= 1'b1;
      rd_addr_r   <= m_awaddr & 32'hFFFF_FE00; // masking 9 LSB bits with zero
      rd_bcnt_r   <= receivebyte_count_r + m_awbcount;
      is_eop_r    <= m_aweop;
      rd_awid_r   <= {m_awaddr[11:9],1'b0};
    end
    else
    begin
      rd_valid_r  <= rd_valid_r;
      rd_addr_r   <= rd_addr_r;
      rd_bcnt_r   <= rd_bcnt_r;
      is_eop_r    <= is_eop_r; 
      rd_awid_r   <= rd_awid_r;
    end
  end  
end  

always @(posedge aclk or negedge nRESET)
begin
  if(nRESET == 1'b0)
  begin
    rd_start_r  <= 1'b0;
  end
  else
  begin
    if ((rd_start_r == 1'b1) && (rd_start_rdy == 1'b1))
    begin
      rd_start_r  <= 1'b0;
    end 
    else if ((m_bvalid == 1'b1) && (m_bready == 1'b1) && ( m_bid_int == rd_awid_r ))
    begin
      rd_start_r  <= 1'b1;
    end
    else
    begin
      rd_start_r  <= rd_start_r;
    end
  end  
end  

//-------------------------------------------------------------------------  
// Read Engine Instantiation
//-------------------------------------------------------------------------     

rd_engine rd_engine_i 
(
    .aclk                   (aclk),
    .nRESET                 (nRESET),
    .rd_valid               (rd_valid_r),
    .rd_valid_rdy           (rd_valid_rdy),
    .rd_start               (rd_start_r),
    .rd_start_rdy           (rd_start_rdy),
    .rd_done                (rd_done),
    .rd_done_ack            (~submit_sgl_element_r),
    .rd_address             (rd_addr_r),                                 
    .rd_bcnt                (rd_bcnt_r),                                 
    .is_eop                 (is_eop_r),                                  
    .bram_addr_b            (bram_addr_b),                                          
    .bram_en_b              (bram_en_b),                                          
    .bram_rddata_b          (bram_rddata_b),
    .axi_stream_s2c_tdata   (axi_stream_s2c_tdata),
    .axi_stream_s2c_tkeep   (axi_stream_s2c_tkeep),
    .axi_stream_s2c_tvalid  (axi_stream_s2c_tvalid),
    .axi_stream_s2c_tlast   (axi_stream_s2c_tlast),
    .axi_stream_s2c_tready  (axi_stream_s2c_tready) 
  );

   
endmodule
