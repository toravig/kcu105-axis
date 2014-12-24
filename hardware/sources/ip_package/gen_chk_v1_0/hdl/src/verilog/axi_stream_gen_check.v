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

`timescale 1ps / 1ps

module axi_stream_gen_check #(
    parameter CNT_WIDTH          =  20 ,
    parameter SEQ_END_CNT_WIDTH  =  32 ,
    parameter AXIS_TDATA_WIDTH   =  128,
    parameter AXIS_TKEEP_WIDTH   =  16
)
(
    input [AXIS_TDATA_WIDTH-1:0]      axi_stream_s2c_tdata,
    input [AXIS_TKEEP_WIDTH-1:0]      axi_stream_s2c_tkeep,
    input                             axi_stream_s2c_tvalid,
    input                             axi_stream_s2c_tlast,
    output                            axi_stream_s2c_tready,
    output  [AXIS_TDATA_WIDTH-1:0]    axi_stream_c2s_tdata,
    output  [AXIS_TKEEP_WIDTH-1:0]    axi_stream_c2s_tkeep,
    output                            axi_stream_c2s_tvalid,
    output                            axi_stream_c2s_tlast,
    input                             axi_stream_c2s_tready,
    
	// Ports of Axi Slave Bus Interface S00_AXI
	input                             s00_axi_aclk,
	input                             s00_axi_aresetn,
	input  [31 : 0]                   s00_axi_awaddr,
	input  [2  : 0]                   s00_axi_awprot,
	input                             s00_axi_awvalid,
	output                            s00_axi_awready,
	input  [31 : 0]                   s00_axi_wdata,
	input  [3  : 0]                   s00_axi_wstrb,
	input                             s00_axi_wvalid,
	output                            s00_axi_wready,
	output [1  : 0]                   s00_axi_bresp,
	output                            s00_axi_bvalid,
	input                             s00_axi_bready,
	input  [31 : 0]                   s00_axi_araddr,
	input  [2  : 0]                   s00_axi_arprot,
	input                             s00_axi_arvalid,
	output                            s00_axi_arready,
	output [31 : 0]                   s00_axi_rdata,
	output [1  : 0]                   s00_axi_rresp,
	output                            s00_axi_rvalid,
	input                             s00_axi_rready,

    input                             user_clk,
    input                             reset             

);

  wire [AXIS_TDATA_WIDTH-1:0]     axi_stream_c2s_tdata_i;
  wire [AXIS_TKEEP_WIDTH-1:0]     axi_stream_c2s_tkeep_i;
  wire                            axi_stream_c2s_tlast_i;
  wire                            axi_stream_c2s_tvalid_i;
  wire                            axi_stream_c2s_tready_i;
 
  wire                             enable_loopback;
  wire                             enable_gen;
  wire                             enable_check;
  wire [CNT_WIDTH-1:0]             gen_length;
  wire [CNT_WIDTH-1:0]             check_length;
  wire [SEQ_END_CNT_WIDTH-1:0]     seq_end_cnt;
  wire                             error_flag;
  

    //If enable_loopback is asserted, connect s2c data from DMA back to c2s
    //Otherwise axi_stream_gen block drives the data in the c2s direction while
    //enable_gen is asserted. The generator block also handles tready throttling from DMA
    //In the s2c direction, data is monitored by the check block when enable_check
    //is asserted 

    assign axi_stream_c2s_tdata = enable_loopback ? axi_stream_s2c_tdata :
                                      axi_stream_c2s_tdata_i;
    assign axi_stream_c2s_tvalid = enable_loopback ? axi_stream_s2c_tvalid :
                                      axi_stream_c2s_tvalid_i;
    assign axi_stream_c2s_tlast = enable_loopback ? axi_stream_s2c_tlast :
                                      axi_stream_c2s_tlast_i;
    assign axi_stream_c2s_tkeep = enable_loopback ? axi_stream_s2c_tkeep :
                                      axi_stream_c2s_tkeep_i;
    assign axi_stream_s2c_tready = enable_loopback ? axi_stream_c2s_tready :
                                      axi_stream_c2s_tready_i;
    
    //Instantiate axi_stream_gen and axi_stream_check modules
    
    axi_stream_gen # (
          .CNT_WIDTH        (CNT_WIDTH        ),
          .SEQ_END_CNT_WIDTH(SEQ_END_CNT_WIDTH),
          .AXIS_TDATA_WIDTH (AXIS_TDATA_WIDTH ),
          .AXIS_TKEEP_WIDTH (AXIS_TKEEP_WIDTH )
    ) axi_stream_gen_i (
          .enable_gen            (enable_gen             ),
          .gen_length            (gen_length             ),
          .seq_end_cnt           (seq_end_cnt            ),
          .axi_stream_c2s_tready (axi_stream_c2s_tready  ),
          .axi_stream_c2s_tdata  (axi_stream_c2s_tdata_i ),
          .axi_stream_c2s_tkeep  (axi_stream_c2s_tkeep_i ),
          .axi_stream_c2s_tvalid (axi_stream_c2s_tvalid_i),
          .axi_stream_c2s_tlast  (axi_stream_c2s_tlast_i ),
          .user_clk              (user_clk               ),
          .reset                 (reset                  )
    );

             
    axi_stream_check # (
          .CNT_WIDTH        (CNT_WIDTH       ),
          .AXIS_TDATA_WIDTH (AXIS_TDATA_WIDTH),
          .AXIS_TKEEP_WIDTH (AXIS_TKEEP_WIDTH)
    ) axi_stream_check_i (
          .enable_check           (enable_check           ),
          .check_length           (check_length           ),  
          .seq_end_cnt            (seq_end_cnt            ),
          .axi_stream_s2c_tready  (axi_stream_c2s_tready_i),
          .axi_stream_s2c_tdata   (axi_stream_s2c_tdata   ),
          .axi_stream_s2c_tkeep   (axi_stream_s2c_tkeep   ),
          .axi_stream_s2c_tvalid  (axi_stream_s2c_tvalid  ),
          .axi_stream_s2c_tlast   (axi_stream_s2c_tlast   ),
          .error_flag             (error_flag             ),
          .user_clk               (user_clk               ),
          .reset                  (reset                  )
    );


	gen_chk_reg  # ( 
		.CNT_WIDTH(CNT_WIDTH),
		.SEQ_END_CNT_WIDTH(SEQ_END_CNT_WIDTH)
	) gen_chk_reg_inst (
		.enable_loopback(enable_loopback),        
		.enable_gen(enable_gen),             
		.enable_check(enable_check),           
		.gen_length(gen_length),             
		.check_length(check_length),           
		.seq_end_cnt(seq_end_cnt),            
		.error_flag(error_flag),             
		.S_AXI_ACLK(s00_axi_aclk),
		.S_AXI_ARESETN(s00_axi_aresetn),
		.S_AXI_AWADDR(s00_axi_awaddr[4:0]),
		.S_AXI_AWPROT(s00_axi_awprot),
		.S_AXI_AWVALID(s00_axi_awvalid),
		.S_AXI_AWREADY(s00_axi_awready),
		.S_AXI_WDATA(s00_axi_wdata),
		.S_AXI_WSTRB(s00_axi_wstrb),
		.S_AXI_WVALID(s00_axi_wvalid),
		.S_AXI_WREADY(s00_axi_wready),
		.S_AXI_BRESP(s00_axi_bresp),
		.S_AXI_BVALID(s00_axi_bvalid),
		.S_AXI_BREADY(s00_axi_bready),
		.S_AXI_ARADDR(s00_axi_araddr[4:0]),
		.S_AXI_ARPROT(s00_axi_arprot),
		.S_AXI_ARVALID(s00_axi_arvalid),
		.S_AXI_ARREADY(s00_axi_arready),
		.S_AXI_RDATA(s00_axi_rdata),
		.S_AXI_RRESP(s00_axi_rresp),
		.S_AXI_RVALID(s00_axi_rvalid),
		.S_AXI_RREADY(s00_axi_rready)
	);
    
   
    
endmodule
