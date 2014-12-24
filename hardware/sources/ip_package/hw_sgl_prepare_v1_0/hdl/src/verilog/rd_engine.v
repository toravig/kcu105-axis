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
// File       : rd_engine.v
//
// Revision History
// ------------------------------
// Version   |    Description
// ----------|-------------------
// 1.0       |    Initial Release
//-----------------------------------------------------------------------------

//`timescale 1ps / 1ps
(* CORE_GENERATION_INFO = "" *)
module  rd_engine # 
  (
// AXI Streaming Interface Parameters
    parameter AXIS_TDATA_WIDTH   =  128,
    parameter AXIS_TKEEP_WIDTH   =  16
  ) 
  (
    // Global Inputs
    input                                        aclk, //AXI clock
    input                                        nRESET,
    
    // SGL Prepare block interface
    input                                        rd_valid, 
    output                                       rd_valid_rdy, 
    input                                        rd_start, 
    output                                       rd_start_rdy,     
    output   reg                                 rd_done, 
    input                                        rd_done_ack, 
    input  [31 : 0]                              rd_address,
    input  [9  : 0]                              rd_bcnt,
    input                                        is_eop, 
    
    // BRAM Read Native Inteface
    output [14:0]                                bram_addr_b,
    output                                       bram_en_b, 
    input  [127:0]                               bram_rddata_b,
    
    
 // AXI Streaming Interface                     
    output      [AXIS_TDATA_WIDTH-1:0]           axi_stream_s2c_tdata,
    output  reg [AXIS_TKEEP_WIDTH-1:0]           axi_stream_s2c_tkeep,
    output                                       axi_stream_s2c_tvalid,
    output  reg                                  axi_stream_s2c_tlast,
    input                                        axi_stream_s2c_tready    
                                                
  );
  
  
// State Parameters
localparam WAIT_FOR_RD_VALID                      = 3'b001;   
localparam WAIT_FOR_RD_START                      = 3'b010;   
localparam READ_DATA                              = 3'b100;   
  
// Register Declarations 
reg    [2:0]                                    CurrentState_r;
reg    [2:0]                                    NextState_r;

reg                                             rd_valid_ff;
reg                                             rd_start_ff;
wire                                            rd_valid_queue_rd_r;
wire                                            rd_start_queue_rd_r;

// Wire Declarations 
wire                                            rd_valid_pulse;
wire                                            rd_start_pulse;
  
wire                                            rd_valid_queue_empty;
wire                                            valid_rd_request;
wire   [31 : 0]                                 rd_address_int;
wire   [9  : 0]                                 rd_bcnt_int;
wire                                            is_eop_int;
wire                                            rd_start_queue_empty;
wire                                            valid_start_request;
wire                                            rd_valid_rdy_int;   
wire                                            rd_start_rdy_int;   
 
reg    [9:0]                                    bram_rd_req_count_r;
reg   [AXIS_TKEEP_WIDTH-1:0]                    axi_stream_s2c_tkeep_int;
//-------------------------------------------------------------------------
// Updating Current State 
//-------------------------------------------------------------------------
always @(posedge aclk or negedge nRESET)
begin
  if(nRESET == 1'b0)
  begin
    CurrentState_r <= WAIT_FOR_RD_VALID;
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
    WAIT_FOR_RD_VALID:
    begin 
      if (rd_valid_queue_empty == 1'b0 )
      begin
        NextState_r = WAIT_FOR_RD_START;
      end
      else
      begin
        NextState_r = CurrentState_r;
      end
    end //End of WAIT_FOR_RD_VALID
    
    WAIT_FOR_RD_START:
    begin
      if ((rd_start_queue_empty == 1'b0 ) && (rd_done == 1'b0))
      begin
        NextState_r = READ_DATA;
      end
      else
      begin
        NextState_r = CurrentState_r;
      end
    end //End of WAIT_FOR_RD_START     
    
    READ_DATA:
    begin
      if ((bram_rd_req_count_r == rd_bcnt_int) && (axi_stream_s2c_tready == 1'b1))
      begin
        NextState_r = WAIT_FOR_RD_VALID;
      end
      else if ((bram_rd_req_count_r > rd_bcnt_int) && (axi_stream_s2c_tready == 1'b1))
      begin
        NextState_r = WAIT_FOR_RD_VALID;
      end
      else
      begin
        NextState_r = CurrentState_r;
      end
    end //End of READ_DATA     
    
       
    default: begin
      NextState_r = WAIT_FOR_RD_VALID;
    end 
  endcase
end // End of always  
 


//-------------------------------------------------------------------------
// Valid read pulse generation
//-------------------------------------------------------------------------
always @(posedge aclk or negedge nRESET)
begin
  if(nRESET == 1'b0)
  begin
    rd_valid_ff <= 1'b0;
  end
  else
  begin
    rd_valid_ff <= rd_valid & rd_valid_rdy;
  end  
end  
  
assign rd_valid_pulse = (~rd_valid_ff) & (rd_valid & rd_valid_rdy);


//-------------------------------------------------------------------------  
// Read valid request queue 
//-------------------------------------------------------------------------     

rd_valid_queue rd_valid_queue_i 
(
    .clk         (aclk),
    .rst         (~nRESET),
    .din         ({rd_address,rd_bcnt,is_eop}),                                        
    .wr_en       (rd_valid_pulse),                                                                   
    .rd_en       (rd_valid_queue_rd_r),                                                                   
    .dout        ({rd_address_int,rd_bcnt_int,is_eop_int}),
    .full        (rd_valid_rdy_int),
    .empty       (rd_valid_queue_empty),
    .valid       (valid_rd_request)
  );
  
assign rd_valid_rdy = ~rd_valid_rdy_int;  
assign rd_valid_queue_rd_r = ((CurrentState_r == WAIT_FOR_RD_VALID) && (rd_valid_queue_empty == 1'b0)) ? 1'b1 : 1'b0;

// //-------------------------------------------------------------------------
// // rd_valid_queue FIFO read request generation
// //-------------------------------------------------------------------------
// always @(posedge aclk or negedge nRESET)
// begin
//   if(nRESET == 1'b0)
//   begin
//     rd_valid_queue_rd_r <= 1'b0;
//   end
//   else
//   begin
//     if ((CurrentState_r == WAIT_FOR_RD_VALID) && (NextState_r == WAIT_FOR_RD_START))
//     begin
//       rd_valid_queue_rd_r <= 1'b1;
//     end
//     else
//     begin
//       rd_valid_queue_rd_r <= 1'b0;
//     end
//   end  
// end  

 
//-------------------------------------------------------------------------
// Valid start pulse generation
//-------------------------------------------------------------------------
always @(posedge aclk or negedge nRESET)
begin
  if(nRESET == 1'b0)
  begin
    rd_start_ff <= 1'b0;
  end
  else
  begin
    rd_start_ff <= rd_start & rd_start_rdy;
  end  
end  
  
assign rd_start_pulse = (~rd_start_ff) & (rd_start & rd_start_rdy);

//-------------------------------------------------------------------------  
// Read start request queue 
//-------------------------------------------------------------------------     

rd_start_queue rd_start_queue_i 
(
    .clk         (aclk),
    .rst         (~nRESET),
    .din         (1'b1),                                        
    .wr_en       (rd_start_pulse),                                                                   
    .rd_en       (rd_start_queue_rd_r),                                                                   
    .dout        (),
    .full        (rd_start_rdy_int),
    .empty       (rd_start_queue_empty),
    .valid       (valid_start_request)
  );
assign rd_start_rdy = ~rd_start_rdy_int;  
assign rd_start_queue_rd_r = ((CurrentState_r == WAIT_FOR_RD_START) && (rd_start_queue_empty == 1'b0) && (rd_done == 1'b0)) ? 1'b1 : 1'b0;


// //-------------------------------------------------------------------------
// // rd_valid_queue FIFO read request generation
// //-------------------------------------------------------------------------
// always @(posedge aclk or negedge nRESET)
// begin
//   if(nRESET == 1'b0)
//   begin
//     rd_start_queue_rd_r <= 1'b0;
//   end
//   else
//   begin
//     if ((CurrentState_r == WAIT_FOR_RD_START) && (NextState_r == READ_DATA))
//     begin
//       rd_start_queue_rd_r <= 1'b1;
//     end
//     else
//     begin
//       rd_start_queue_rd_r <= 1'b0;
//     end
//   end  
// end  
  

//-------------------------------------------------------------------------
// BRAM Read logic
//-------------------------------------------------------------------------
assign bram_en_b = (((CurrentState_r == WAIT_FOR_RD_START) && (NextState_r == READ_DATA)) || (((CurrentState_r == READ_DATA) && (NextState_r == READ_DATA) && (axi_stream_s2c_tready == 1'b1))))? 1'b1 : 1'b0;

// BRAM Read Request counter
always @(posedge aclk or negedge nRESET)
begin
  if(nRESET == 1'b0)
  begin
    bram_rd_req_count_r <= 10'h000;
  end
  else
  begin
    if (( bram_rd_req_count_r  >= rd_bcnt_int ) && (axi_stream_s2c_tready == 1'b1))
    begin
      bram_rd_req_count_r <= 10'h000;
    end
    // 1 advance read
    else if ((CurrentState_r == WAIT_FOR_RD_START) && (NextState_r == READ_DATA)) 
    begin
      bram_rd_req_count_r <= bram_rd_req_count_r + 5'd16;
    end
    else if ((axi_stream_s2c_tready == 1'b1) && (axi_stream_s2c_tvalid == 1'b1)) 
    begin
      bram_rd_req_count_r <= bram_rd_req_count_r + 5'd16;
    end
    else 
    begin
      bram_rd_req_count_r <= bram_rd_req_count_r;
    end
  end  
end  
//read request address + current byte position
assign bram_addr_b = rd_address_int + bram_rd_req_count_r; 

//-------------------------------------------------------------------------
// Read done 
//-------------------------------------------------------------------------
always @(posedge aclk or negedge nRESET)
begin
  if(nRESET == 1'b0)
  begin
    rd_done <= 1'b0;
  end
  else
  begin
    if ((rd_done_ack == 1'b1) && (rd_done == 1'b1)) 
    begin
      rd_done <= 1'b0;
    end
    else if ((CurrentState_r == READ_DATA) && (NextState_r == WAIT_FOR_RD_VALID))
    begin
      rd_done <= 1'b1;
    end
  end  
end  

//-------------------------------------------------------------------------
// Streaming Interface handling
//-------------------------------------------------------------------------
// Byte enable consideration
                                                                                                                 
always@ ( * )                                                                                                      
begin                                                                                                                           
  case(rd_bcnt_int - bram_rd_req_count_r) 
    6'd1  : axi_stream_s2c_tkeep_int = 16'h0001;
    6'd2  : axi_stream_s2c_tkeep_int = 16'h0003;
    6'd3  : axi_stream_s2c_tkeep_int = 16'h0007;
    6'd4  : axi_stream_s2c_tkeep_int = 16'h000F;
    6'd5  : axi_stream_s2c_tkeep_int = 16'h001F;
    6'd6  : axi_stream_s2c_tkeep_int = 16'h003F;
    6'd7  : axi_stream_s2c_tkeep_int = 16'h007F;
    6'd8  : axi_stream_s2c_tkeep_int = 16'h00FF;
    6'd9  : axi_stream_s2c_tkeep_int = 16'h01FF;
    6'd10 : axi_stream_s2c_tkeep_int = 16'h03FF;
    6'd11 : axi_stream_s2c_tkeep_int = 16'h07FF;
    6'd12 : axi_stream_s2c_tkeep_int = 16'h0FFF;
    6'd13 : axi_stream_s2c_tkeep_int = 16'h1FFF;
    6'd14 : axi_stream_s2c_tkeep_int = 16'h3FFF;
    6'd15 : axi_stream_s2c_tkeep_int = 16'h7FFF;
       
    default: axi_stream_s2c_tkeep_int = 16'hFFFF;
  endcase
end // End of always  
 

                                  

//-------------------------------------------------------------------------
// Streaming Interface
//-------------------------------------------------------------------------
always @(posedge aclk or negedge nRESET)
begin
  if(nRESET == 1'b0)
  begin
    axi_stream_s2c_tlast      <= 1'b0;
    axi_stream_s2c_tkeep      <= 16'h0000;
  end
  else
  begin
    if (bram_en_b == 1'b1)
    begin
      axi_stream_s2c_tkeep  <= axi_stream_s2c_tkeep_int;  
    end
    else
    begin
      axi_stream_s2c_tkeep  <= axi_stream_s2c_tkeep;  
    end
    
//     if ( bram_rd_req_count_r >= rd_bcnt_int ) 
//     begin
//       if (axi_stream_s2c_tready == 1'b1)
//       begin
//         axi_stream_s2c_tlast <= 1'b0;
//       end
//       else
//       begin
//         axi_stream_s2c_tlast <= is_eop_int;
//       end  
//     end
//     else
//     begin
//       axi_stream_s2c_tlast <= 1'b0;
//     end    
    
    if ((axi_stream_s2c_tlast ==1'b1) && (axi_stream_s2c_tready == 1'b1) && (axi_stream_s2c_tvalid == 1'b1))
    begin
      axi_stream_s2c_tlast <= 1'b0;
    end
    else if ((( bram_rd_req_count_r + 5'd16) >= rd_bcnt_int ) && (bram_en_b == 1'b1) )
    begin
      axi_stream_s2c_tlast <= is_eop_int;
    end
    else
    begin
      axi_stream_s2c_tlast <= axi_stream_s2c_tlast;
    end   
  end  
end  

assign axi_stream_s2c_tdata  = bram_rddata_b;
// assign axi_stream_s2c_tkeep  = (axi_stream_s2c_tlast == 1'b1) ? axi_stream_s2c_tkeep_int : 32'hFFFFFFFF;


assign axi_stream_s2c_tvalid =  (CurrentState_r == READ_DATA) ? 1'b1 : 1'b0; 

endmodule
                                                          