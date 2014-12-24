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
// File       : hw_sgl_prepare.v
//
// Revision History
// ------------------------------
// Version   |    Description
// ----------|-------------------
// 1.0       |    Initial Release
//-----------------------------------------------------------------------------

//`timescale 1ps / 1ps
(* CORE_GENERATION_INFO = "" *)
module  hw_sgl_prepare # 
  (
    parameter START_ADDRESS        = 32'hC0000000,
    parameter BIT64_ADDR_EN        = 0,              // 1: 64-bit address enable  
                                                     // 0: 32-bit address enable                                          
// AXI Master Interface Parameters
    parameter   M_ID_WIDTH         = 4,           
    parameter   M_ADDR_WIDTH       = 32,          
    parameter   M_LEN_WIDTH        = 4,           
    parameter   M_DATA_WIDTH       = 128,          
              
// AXI Streaming Interface Parameters
    parameter AXIS_TDATA_WIDTH   =  128,
    parameter AXIS_TKEEP_WIDTH   =  16
  ) 
  (
    // Global Inputs
    input                                                             aclk, //AXI clock
    input                                                             nRESET,
     
    input                                                             s2c_channel_reset,
    input                                                             c2s_channel_reset,
   
    // Hardware SGL submission block Interface
    output      [1                              : 0]                  sgl_available,
    input       [1                              : 0]                  sgl_done,
    input       [1                              : 0]                  sgl_error,
    output      [(2*(BIT64_ADDR_EN*32 + 112))-1 : 0]                  sgl_data,
    
 // AXI MM Interface 
    input                                                             m_awvalid,                  // Write Address Channel
    output                                                            m_awready,                  //
    input       [M_ID_WIDTH-1:0]                                      m_awid,                     //
    input       [M_ADDR_WIDTH-1:0]                                    m_awaddr,                   //
    input       [M_LEN_WIDTH-1:0]                                     m_awlen,                    //
    input       [2:0]                                                 m_awsize,                   //
    input       [1:0]                                                 m_awburst,                  //
    input       [2:0]                                                 m_awprot,                   //
    input       [3:0]                                                 m_awcache,                  //
//  input       [M_REGION_WIDTH-1:0]                                  m_awregion,                 // Write Address Channel - non-standard AXI ports
//  input       [M_BCOUNT_WIDTH-1:0]                                  m_awbcount,                 //   For FIFO DMA transactions, m_awregion indicates source DMA Channel, m_awbcount indicates exact byte count of transaction,
//  input                                                             m_aweop,                    //    m_aweop indicates end of DMA packet
    input       [47:0]                                                m_awuser,                   // Write Address Channel - non-standard AXI ports {bcount[9:0], region[10:0], eop}
                                                                     
    input                                                             m_wvalid,                   // Write Data Channel
    output                                                            m_wready,                   //
    input       [M_ID_WIDTH-1:0]                                      m_wid,                      //
    input       [M_DATA_WIDTH-1:0]                                    m_wdata,                    //
    input       [(M_DATA_WIDTH/8)-1:0]                                m_wstrb,                    //
    input                                                             m_wlast,                    //
                                                                      
    output                                                            m_bvalid,                   // Write Response Channel
    input                                                             m_bready,                   //
    output      [M_ID_WIDTH-1:0]                                      m_bid,                      //
    output      [1:0]                                                 m_bresp,                    //
                                                                      
    input                                                             m_arvalid,                  // Read Address Channel
    output                                                            m_arready,                  //
    input       [M_ID_WIDTH-1:0]                                      m_arid,                     //
    input       [M_ADDR_WIDTH-1:0]                                    m_araddr,                   //
    input       [M_LEN_WIDTH-1:0]                                     m_arlen,                    //
    input       [2:0]                                                 m_arsize,                   //
    input       [1:0]                                                 m_arburst,                  //
    input       [2:0]                                                 m_arprot,                   //
    input       [3:0]                                                 m_arcache,                  //
  //input       [M_REGION_WIDTH-1:0]                                  m_arregion,                 // Read Address Channel - non-standard AXI ports
  //input       [M_BCOUNT_WIDTH-1:0]                                  m_arbcount,                 //   For FIFO DMA transactions, m_arregion indicates source DMA Channel, m_arbcount
  //input                                                             m_areop,                    //   indicates exact byte count of transaction, and m_areop indicates end of DMA packet
    input       [47:0]                                                m_aruser,                   // Write Address Channel - non-standard AXI ports {bcount[9:0], region[10:0], eop}
                                                                      
    output                                                            m_rvalid,                   // Read Data Channel
    input                                                             m_rready,                   //
    output      [M_ID_WIDTH-1:0]                                      m_rid,                      //
    output      [M_DATA_WIDTH-1:0]                                    m_rdata,                    //
    output      [1:0]                                                 m_rresp,                    //
    output                                                            m_rlast,                     //
                                                                      
 // AXI Streaming output Interface                                    
    input       [AXIS_TDATA_WIDTH-1:0]                                axi_stream_c2s_tdata,
    input       [AXIS_TKEEP_WIDTH-1:0]                                axi_stream_c2s_tkeep,
    input                                                             axi_stream_c2s_tvalid,
    input                                                             axi_stream_c2s_tlast,
    output                                                            axi_stream_c2s_tready,
                                                                      
 // AXI Streaming input Interface                                     
    output      [AXIS_TDATA_WIDTH-1:0]                                axi_stream_s2c_tdata,
    output      [AXIS_TKEEP_WIDTH-1:0]                                axi_stream_s2c_tkeep,
    output                                                            axi_stream_s2c_tvalid,
    output                                                            axi_stream_s2c_tlast,
    input                                                             axi_stream_s2c_tready
                                                                      
  );
  
  
  localparam BUFFER_SIZE     = 512; 

  reg    [1:0]               sgl_done_ff;
  reg    [1:0]               sgl_done_ff2;
  reg    [1:0]               sgl_done_ff3;
  reg    [1:0]               sgl_error_ff;
  reg    [1:0]               sgl_error_ff2;
    
  wire   [1:0]               sgl_done_pulse;
  
//-------------------------------------------------------------------------
// Synchronizing SGL Submit input interface
//-------------------------------------------------------------------------
always @(posedge aclk or negedge nRESET)
begin
  if(nRESET == 1'b0)
  begin
    sgl_done_ff          <= 2'b00;
    sgl_done_ff2         <= 2'b00;
    sgl_error_ff          <= 2'b00;
    sgl_error_ff2         <= 2'b00;
  end
  else
  begin
    sgl_done_ff          <= sgl_done;
    sgl_done_ff2         <= sgl_done_ff;
    sgl_done_ff3         <= sgl_done_ff2;
    sgl_error_ff         <= sgl_error;
    sgl_error_ff2        <= sgl_error_ff;
  end  
end  

assign sgl_done_pulse[0] = (s2c_channel_reset == 1'b0 ) ? (~sgl_done_ff3[0] & sgl_done_ff2[0]) : 1'b0;
assign sgl_done_pulse[1] = (c2s_channel_reset == 1'b0 ) ? (~sgl_done_ff3[1] & sgl_done_ff2[1]) : 1'b0;
  
//-------------------------------------------------------------------------  
// S2C(Destination) SGL Preparation Block Instantiation
//-------------------------------------------------------------------------      
s2c_sgl_prepare # (
    .BUFFER_SIZE                 ( BUFFER_SIZE        ),                            
    .START_ADDRESS               ( START_ADDRESS      ),
    .BIT64_ADDR_EN               ( BIT64_ADDR_EN      ),
    .M_ID_WIDTH                  ( M_ID_WIDTH         ),
    .M_ADDR_WIDTH                ( M_ADDR_WIDTH       ),
    .M_LEN_WIDTH                 ( M_LEN_WIDTH        ),
    .M_DATA_WIDTH                ( M_DATA_WIDTH       ),
    .AXIS_TDATA_WIDTH            ( AXIS_TDATA_WIDTH   ),
    .AXIS_TKEEP_WIDTH            ( AXIS_TDATA_WIDTH/8 ) 
) s2c_sgl_prepare_inst (
 .aclk                           ( aclk ), 
 .nRESET                         ( nRESET & (~s2c_channel_reset) ),
                                 
 .sgl_available                  ( sgl_available[0] ),
 .sgl_done                       ( sgl_done_pulse[0] ),
 .sgl_error                      ( sgl_error_ff2[0] ),
 .sgl_data                       (  sgl_data    [111:0]),        
                                 
 .m_awvalid                      ( m_awvalid  ),                 
 .m_awready                      ( m_awready  ),                 
 .m_awid                         ( m_awid     ),                    
 .m_awaddr                       ( m_awaddr   ),                  
 .m_awlen                        ( m_awlen    ),                   
 .m_awsize                       ( m_awsize   ),                  
 .m_awburst                      ( m_awburst  ),                 
 .m_awprot                       ( m_awprot   ),                  
 .m_awcache                      ( m_awcache  ),                 
 .m_awregion                     ( m_awuser[11:1]),                                                      
 .m_awbcount                     ( m_awuser[21:12]),                                                     
 .m_aweop                        ( m_awuser[0]),                                                         
                                
 .m_wvalid                       ( m_wvalid ),                  
 .m_wready                       ( m_wready ),                  
 .m_wid                          ( m_wid    ),                     
 .m_wdata                        ( m_wdata  ),                   
 .m_wstrb                        ( m_wstrb  ),                   
 .m_wlast                        ( m_wlast  ),                   
                                 
 .m_bvalid                       ( m_bvalid ),                  
 .m_bready                       ( m_bready ),                  
 .m_bid                          ( m_bid    ),                     
 .m_bresp                        ( m_bresp  ),                   
                                 
 .m_arvalid                      ( ),                 
 .m_arready                      ( ),                 
 .m_arid                         ( ),                    
 .m_araddr                       ( ),                  
 .m_arlen                        ( ),                   
 .m_arsize                       ( ),                  
 .m_arburst                      ( ),                 
 .m_arprot                       ( ),                  
 .m_arcache                      ( ),                 
 .m_arregion                     ( ),                
 .m_arbcount                     ( ),                
 .m_areop                        ( ),                   
                                 
 .m_rvalid                       ( ),                  
 .m_rready                       ( ),                  
 .m_rid                          ( ),                     
 .m_rdata                        ( ),                   
 .m_rresp                        ( ),                   
 .m_rlast                        ( ),                   
                                 
 .axi_stream_s2c_tdata           ( axi_stream_s2c_tdata  ),
 .axi_stream_s2c_tkeep           ( axi_stream_s2c_tkeep  ),
 .axi_stream_s2c_tvalid          ( axi_stream_s2c_tvalid ),
 .axi_stream_s2c_tlast           ( axi_stream_s2c_tlast  ),
 .axi_stream_s2c_tready          ( axi_stream_s2c_tready )

);

//-------------------------------------------------------------------------  
// C2S(Source) SGL Preparation Block Instantiation
//-------------------------------------------------------------------------      
c2s_sgl_prepare # (                                                                 
    .BUFFER_SIZE                 ( BUFFER_SIZE        ),                            
    .START_ADDRESS               ( START_ADDRESS      ),                            
    .BIT64_ADDR_EN               ( BIT64_ADDR_EN      ),                            
    .M_ID_WIDTH                  ( M_ID_WIDTH         ),                            
    .M_ADDR_WIDTH                ( M_ADDR_WIDTH       ),                            
    .M_LEN_WIDTH                 ( M_LEN_WIDTH        ),                            
    .M_DATA_WIDTH                ( M_DATA_WIDTH       ),                            
    .AXIS_TDATA_WIDTH            ( AXIS_TDATA_WIDTH   ),                            
    .AXIS_TKEEP_WIDTH            ( AXIS_TDATA_WIDTH/8 )                             
) c2s_sgl_prepare_inst (                                                            
 .aclk                           ( aclk   ),                                  
 .nRESET                         ( nRESET & (~c2s_channel_reset) ),                                                  
                                                                                                             
 .sgl_available                  ( sgl_available[1] ),                                                                      
 .sgl_done                       ( sgl_done_pulse[1] ),                                             
 .sgl_error                      ( sgl_error_ff2[1] ),                                             
 .sgl_data                       ( sgl_data     [ 223:112 ]),                                         
                                                                                                           
 .m_awvalid                      ( ),                                                                      
 .m_awready                      ( ),                                                     
 .m_awid                         ( ),                                                     
 .m_awaddr                       ( ),                                                     
 .m_awlen                        ( ),                                                     
 .m_awsize                       ( ),                                                     
 .m_awburst                      ( ),                                                     
 .m_awprot                       ( ),                                                     
 .m_awcache                      ( ),                                                     
 .m_awregion                     ( ),                                                     
 .m_awbcount                     ( ),                                                     
 .m_aweop                        ( ),                                                     
                                                                                          
 .m_wvalid                       ( ),                                                                      
 .m_wready                       ( ),                                            
 .m_wid                          ( ),                                            
 .m_wdata                        ( ),                                            
 .m_wstrb                        ( ),                                            
 .m_wlast                        ( ),                                            
                                                                                 
 .m_bvalid                       ( ),                                            
 .m_bready                       ( ),                                                   
 .m_bid                          ( ),                                                   
 .m_bresp                        ( ),                                                   
                                                                                        
 .m_arvalid                      ( m_arvalid  ),                                                   
 .m_arready                      ( m_arready  ),                                                         
 .m_arid                         ( m_arid     ),                                                         
 .m_araddr                       ( m_araddr   ),                                                         
 .m_arlen                        ( m_arlen    ),                                                         
 .m_arsize                       ( m_arsize   ),                                                         
 .m_arburst                      ( m_arburst  ),                                                         
 .m_arprot                       ( m_arprot   ),                                                         
 .m_arcache                      ( m_arcache  ),                                                         
 .m_arregion                     ( m_aruser[11:1]),                                                         
 .m_arbcount                     ( m_aruser[21:12]),                                                         
 .m_areop                        ( m_aruser[0]),                                                         

                                                                                                         
 .m_rvalid                       ( m_rvalid   ),                                                                      
 .m_rready                       ( m_rready   ),                                                          
 .m_rid                          ( m_rid      ),                                                          
 .m_rdata                        ( m_rdata    ),                                                          
 .m_rresp                        ( m_rresp    ),                                                          
 .m_rlast                        ( m_rlast    ),                                                          
                                                                                               
 .axi_stream_c2s_tdata           ( axi_stream_c2s_tdata  ),                                                                      
 .axi_stream_c2s_tkeep           ( axi_stream_c2s_tkeep  ),                                              
 .axi_stream_c2s_tvalid          ( axi_stream_c2s_tvalid ),                                              
 .axi_stream_c2s_tlast           ( axi_stream_c2s_tlast  ),                                              
 .axi_stream_c2s_tready          ( axi_stream_c2s_tready )                                               
                                                                                   
);                                                                                                         

endmodule