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
// File       : hw_sgl_submit.v
//
// Revision History
// ------------------------------
// Version   |    Description
// ----------|-------------------
// 1.0       |    Initial Release
//-----------------------------------------------------------------------------

//`timescale 1ps / 1ps
(* CORE_GENERATION_INFO = "" *)
module  hw_sgl_submit # 
  (
    parameter NUM_SGL_PREPARE_BLOCKS    = 2,
    parameter BIT64_ADDR_EN             = 0,    // 1: 64-bit address enable  
                                                // 0: 32-bit address enable                                          
    parameter NUM_DMA_CHANNELS          = (1<<NUM_SGL_PREPARE_BLOCKS), //4
    parameter SGL_CH_ADDR_WIDTH         = 3,
    parameter SGL_ELEMENT_WIDTH         = 128
  )                                    
  (
    // Global Inputs
    input                                                         aclk,
    input                                                         nRESET,
                                                                  
    // Hardware SGL Preparation block Interface
    input       [NUM_DMA_CHANNELS-1                            : 0] sgl_available,
    output  reg [NUM_DMA_CHANNELS-1                            : 0] sgl_done,
    output  reg [NUM_DMA_CHANNELS-1                            : 0] sgl_error,
    input       [(NUM_DMA_CHANNELS*(BIT64_ADDR_EN*32 + 112))-1 : 0] sgl_data, 
    
   // Direct SGL Allocate Interface 
    input       [NUM_DMA_CHANNELS-1                            : 0] sgl_dma_ch_en,              //   ..
    input       [NUM_DMA_CHANNELS-1                            : 0] sgl_dma_ch_reset,           //   ..
    output  reg                                                     sgl_alloc_valid,            // Allocate SGL
    input                                                           sgl_alloc_ready,            //   ..
    output  reg [SGL_CH_ADDR_WIDTH-1                           : 0] sgl_alloc_num_sgl,          //   ..
    output  reg                                                     sgl_alloc_dst_src_n,        //   ..
    output  reg [NUM_SGL_PREPARE_BLOCKS-1                      : 0] sgl_alloc_channel,          //   ..
    input       [NUM_DMA_CHANNELS-1                            : 0] sgl_alloc_src_full,         // SRC Allocate SGL FIFO Levels
    input       [NUM_DMA_CHANNELS-1                            : 0] sgl_alloc_src_aready,       //   ..
    input       [NUM_DMA_CHANNELS-1                            : 0] sgl_alloc_src_empty,        //   ..
    input       [NUM_DMA_CHANNELS-1                            : 0] sgl_alloc_dst_full,         // DST Allocate SGL FIFO Levels
    input       [NUM_DMA_CHANNELS-1                            : 0] sgl_alloc_dst_aready,       //   ..
    input       [NUM_DMA_CHANNELS-1                            : 0] sgl_alloc_dst_empty,        //   ..
                                                               
    // Direct SGL Write Interface                              
    output  reg                                                     sgl_wr_valid,               // Direct SGL Write Interface.  User's may use these ports to directly provide SGL to DMA Channels instead of having the DMA Channels fetch SGL from AXI or PCIe memory under control of their DMA Registers.
    input                                                           sgl_wr_ready,               //   This interface is primarily intended to facilitate AXI FIFO DMA applications.  The availability of user DMA Channel source FIFO data (or DMA Channel destination FIFO space) is communicated 
    output  reg [SGL_ELEMENT_WIDTH-1                           : 0] sgl_wr_data,                //   to the DMA Channels by providing the associated SGL elements using this interface.  The DMA Channel executes SGL provided on this interface in the same manner as SGL fetched from memory.
    output  reg                                                     sgl_wr_dst_src_n,           //   A SGL (i_sgl_wr_data) is written into the Destination(i_sgl_wr_dst_src_n==1)/Source(i_sgl_wr_dst_src_n==0) SGL FIFO of DMA Channel[i_sgl_src_wr_channel] when i_sgl_src_wr_valid==i_sgl_src_wr_ready==1.
    output  reg [NUM_SGL_PREPARE_BLOCKS-1:0]                        sgl_wr_channel              //   A given DMA Channel must get all of it Source SGL from the same source and must get all of its Destination SGL from the same source (either Direct SGL Write interface or fetch from memory).
    
  );
       
// State Parameters
parameter HW_SGL_START                  = 4'b0001;
parameter WAIT_FOR_SGL_AVAILABLE        = 4'b0010;
parameter ALLOCATE_SGL_SPACE            = 4'b0100;
parameter UPDATE_SGL_ELEMENT            = 4'b1000;                 
                                        
// DMA Channel Number Parameters        
parameter CHANNEL_ZERO                  = 2'b00; 
parameter CHANNEL_ONE                   = 2'b01; 
parameter CHANNEL_TWO                   = 2'b10; 
parameter CHANNEL_THREE                 = 2'b11; 
                                        
// Time out parameters                  
parameter TIMER0_MAX_COUNT              = 65535; //2^16-1
parameter TIMER1_MAX_COUNT              = 65535; //2^16-1
                                        
// DMA SGL Interface Parameters         
parameter NUM_SGL_ELEMENTS              = 3'b001;


// Register Declarations 
reg    [NUM_SGL_PREPARE_BLOCKS-1:0]     CurrentChannel_r;
reg    [NUM_SGL_PREPARE_BLOCKS-1:0]     NextChannel_r;
reg    [3:0]                            CurrentState_r;
reg    [3:0]                            NextState_r;
                                        
reg                                     timer_0_count_en_r;
reg    [15:0]                           timer_0_count_r;
reg                                     timer_1_count_en_r;
reg    [15:0]                           timer_1_count_r;

//-------------------------------------------------------------------------------------------------------     
//SGL Element Declaration - 128 bits
//-------------------------------------------------------------------------------------------------------     
//     |-----------------|--------------|-------------|--------------|-----------------|        
//     |   [ 127: 112]   |  [ 111: 96]  |  [ 95: 88]  |  [ 87: 64]   |     [ 63:  0]   |        
//     |-----------------|--------------|-------------|--------------|-----------------|        
//     |     user_id     |  user_handle |    flags    |  byte_count  | src_dst_address |        
//     |-----------------|--------------|-------------|--------------|-----------------|   
//-------------------------------------------------------------------------------------------------------     
wire   [63                         : 0]     src_dst_address;
wire   [23                         : 0]     byte_count;
wire   [7                          : 0]     flags;
wire   [15                         : 0]     user_handle;
wire   [15                         : 0]     user_id;
wire   [NUM_DMA_CHANNELS * 112 - 1 :0] sgal_data_chn_base;

reg    [NUM_DMA_CHANNELS-1:0]                                sgl_available_ff;
reg    [NUM_DMA_CHANNELS-1:0]                                sgl_available_ff2;
reg    [(NUM_DMA_CHANNELS*(BIT64_ADDR_EN*32 + 112))-1:0]     sgl_data_ff;
reg    [(NUM_DMA_CHANNELS*(BIT64_ADDR_EN*32 + 112))-1:0]     sgl_data_ff2;


//-------------------------------------------------------------------------
// Synchronizing SGL Prepare input interface
//-------------------------------------------------------------------------
always @(posedge aclk or negedge nRESET)
begin
  if(nRESET == 1'b0)
  begin
    sgl_available_ff  <= {NUM_DMA_CHANNELS {1'b0}};
    sgl_available_ff2 <= {NUM_DMA_CHANNELS {1'b0}};
    sgl_data_ff       <= {(NUM_DMA_CHANNELS*(BIT64_ADDR_EN*32 + 112)) {1'b0}};
    sgl_data_ff2      <= {(NUM_DMA_CHANNELS*(BIT64_ADDR_EN*32 + 112)) {1'b0}};
  end
  else
  begin
    sgl_available_ff  <= sgl_available;
    sgl_available_ff2 <= sgl_available_ff;  
    sgl_data_ff       <= sgl_data;
    sgl_data_ff2      <= sgl_data_ff;
  end  
end  

//-------------------------------------------------------------------------
//State Machine for HW SGL submission block 
//-------------------------------------------------------------------------
//    HW_SGL_START                  = 4'b0001;
//    WAIT_FOR_SGL_AVAILABLE        = 4'b0010;
//    ALLOCATE_SGL_SPACE            = 4'b0100;
//    UPDATE_SGL_ELEMENT            = 4'b1000

// HW_SGL_START:  
//                This is the default state of the state machine after reset.
//                State change from HW_SGL_START to WAIT_FOR_SGL_AVAILABLE will happen with nRESET signal de-assertion.

// WAIT_FOR_SGL_AVAILABLE:
//                The SGL submission logic polls for the SGL available status from SGL preparation logic of all the channels in a round robin fashion. 
//                Check the source/destination cache availability at DMA side depending the channel number 
//                State change from WAIT_FOR_SGL_AVAILABLE to ALLOCATE_SGL_SPACE will happen once sgl_alloc_src_aready/sgl_alloc_dst_aready for the particular channel is asserted   
//               
// ALLOCATE_SGL_SPACE:
//                In the SGL allocation phase, the SGL submission logic requests the DMA�s SGL interface to reserve the DMA�s shared memory mapped interface 
//                for a particular AXI4-Stream channel by asserting sgl_alloc_valid signal along with the other SGL Interface signals. 
//                State change from ALLOCATE_SGL_SPACE to UPDATE_SGL_ELEMENT will happen once acknowledgement from DMA comes in the form of sgl_alloc_ready signal assertion
//                SGL submission logic intimates the HW SGL preparation logic about resource allocation with a SGL done status 
//                State change from ALLOCATE_SGL_SPACE to WAIT_FOR_SGL_AVAILABLE will happen if time out happens before the acknowledgement from DMA
//               
// UPDATE_SGL_ELEMENT:
//                The SGL preparation logic submits SGL data to the SGL submission logic upon assertion of SGL done from the submission block. 
//                The padding of additional fields in the SGL element is performed by the SGL padding logic in the submission block.
//                The SGL submission logic requests the DMA�s SGL interface for SGL element update through sgl_wr_valid signal assertion along with the other write interface signals
//                State change from UPDATE_SGL_ELEMENT to WAIT_FOR_SGL_AVAILABLE will happen once sgl_wr_ready signal is asserted   

//-------------------------------------------------------------------------
// Updating Current DMA Channel 
//-------------------------------------------------------------------------

always @(posedge aclk or negedge nRESET)
begin
  if(nRESET == 1'b0) 
  begin
    CurrentChannel_r <= {NUM_SGL_PREPARE_BLOCKS {1'b0}};
    NextChannel_r    <= {NUM_SGL_PREPARE_BLOCKS {1'b0}};
  end
  // Update the channel number in WAIT_FOR_SGL_AVAILABLE state continuously
  else if (((CurrentState_r == WAIT_FOR_SGL_AVAILABLE) && (NextState_r == WAIT_FOR_SGL_AVAILABLE)) || ((CurrentState_r == UPDATE_SGL_ELEMENT) && (NextState_r == HW_SGL_START)))
  begin
    if ( sgl_dma_ch_reset[NextChannel_r] == 1'b0 && sgl_dma_ch_en[NextChannel_r] == 1'b1 && ( ((NextChannel_r[0] == 1'b0) && (sgl_alloc_dst_full[NextChannel_r] == 1'b0)) || ((NextChannel_r[0] == 1'b1) && (sgl_alloc_src_full[NextChannel_r] == 1'b0)))) 
    begin 
      CurrentChannel_r <= NextChannel_r;
    end
    else
    begin
      CurrentChannel_r <= CurrentChannel_r;
    end
     // Update next channel
     NextChannel_r <= NextChannel_r + 1'b1;
  end
  else
  begin
    CurrentChannel_r <= CurrentChannel_r;
  end  
end  

//-------------------------------------------------------------------------
// Updating Current State 
//-------------------------------------------------------------------------
always @(posedge aclk or negedge nRESET)
begin
  if(nRESET == 1'b0)
  begin
    CurrentState_r <= HW_SGL_START;
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
    HW_SGL_START:
    begin 
      if(nRESET == 1'b0) begin
        NextState_r = HW_SGL_START;
      end
      else begin
        NextState_r = WAIT_FOR_SGL_AVAILABLE;
      end    
    end //End of HW_SGL_START
    
    WAIT_FOR_SGL_AVAILABLE:
    begin
      // Wait for sgl_available signal assertion from any of the channels
      if ((sgl_available_ff2[CurrentChannel_r] == 1'b1) && ( sgl_dma_ch_reset[CurrentChannel_r] == 1'b0) && (sgl_dma_ch_en[CurrentChannel_r] == 1'b1 ) )
      begin
        // Check for destination cache availablity at DMA side for all even numbered channels
        if ((CurrentChannel_r[0] == 1'b0) && (sgl_alloc_dst_full[CurrentChannel_r] == 1'b0))
        begin
          NextState_r = ALLOCATE_SGL_SPACE;
        end
        // Check for source cache availablity at DMA side for all odd numbered channels
        else if ((CurrentChannel_r[0] == 1'b1) && (sgl_alloc_src_full[CurrentChannel_r] == 1'b0))
        begin
          NextState_r = ALLOCATE_SGL_SPACE;
        end
        else
        begin
          NextState_r = CurrentState_r;
        end    
      end
      else
      begin
        NextState_r = CurrentState_r;
      end    
    end //End of WAIT_FOR_SGL_AVAILABLE
    
    ALLOCATE_SGL_SPACE: 
    begin
      if (sgl_dma_ch_reset[CurrentChannel_r] == 1'b1)
      begin
        NextState_r = WAIT_FOR_SGL_AVAILABLE;
      end
      // wait for allocation ready acknowledgement from DMA
      else if (sgl_alloc_ready == 1'b1)
      begin
        NextState_r = UPDATE_SGL_ELEMENT;
      end
      // 
      else if (timer_0_count_r == TIMER0_MAX_COUNT) 
      begin
        NextState_r = WAIT_FOR_SGL_AVAILABLE;
      end
      else
      begin
        NextState_r = CurrentState_r;
      end      
    end // End of ALLOCATE_SGL_SPACE   
    
    UPDATE_SGL_ELEMENT:
    begin
      if (sgl_dma_ch_reset[CurrentChannel_r] == 1'b1)
      begin
        NextState_r = WAIT_FOR_SGL_AVAILABLE;
      end
     else if (sgl_available_ff2[CurrentChannel_r] == 1'b0)
      begin
        NextState_r = HW_SGL_START;
      end
      else if (timer_1_count_r == TIMER1_MAX_COUNT) 
      begin
        NextState_r = UPDATE_SGL_ELEMENT;
      end
      else
      begin
        NextState_r = CurrentState_r;
      end      
    end //End of UPDATE_SGL_ELEMENT     
       
    default: begin
      NextState_r = HW_SGL_START;
    end 
  endcase
end // End of always


//-------------------------------------------------------------------------  
// DMA SGL Allocate Interface driving logic
//-------------------------------------------------------------------------                                                 
always @(posedge aclk or negedge nRESET)
begin
  if(nRESET == 1'b0)                                                                                             
  begin                                                                                                          
    sgl_alloc_valid        <= 1'b0;                                                                              
    // This value is hardcoded to '1'                                                                             
    sgl_alloc_num_sgl      <= NUM_SGL_ELEMENTS;                                                                  
    sgl_alloc_dst_src_n    <= 1'b0;
    sgl_alloc_channel      <= 2'b00;
  end
  else
  begin
    // Drive DMA sgl allocation interface and wait for allocatoin ready acknowledgement from DMA
    if ( (CurrentState_r == WAIT_FOR_SGL_AVAILABLE) && (NextState_r == ALLOCATE_SGL_SPACE) )
    begin
      sgl_alloc_valid      <= 1'b1;
      // Even numbered Channels are S2C channels ==> Destination  = 1 ==> sgl_alloc_dst_src_n = 1
      // Odd numbered Channels are C2S channels  ==> Source       = 1 ==> sgl_alloc_dst_src_n = 0
      sgl_alloc_dst_src_n  <= ~CurrentChannel_r[0]; 
      sgl_alloc_channel    <= CurrentChannel_r;
    end
    else if ((sgl_alloc_ready == 1'b1) || (sgl_dma_ch_reset[CurrentChannel_r] == 1'b1))
    begin
      // de-assert valid with ready
      sgl_alloc_valid      <= 1'b0;
      sgl_alloc_dst_src_n  <= 1'b0;
      sgl_alloc_channel    <= 2'b00;
    end    
  end  
end  
   

//-------------------------------------------------------------------------------------------------------  
// DMA SGL Write Interface driving logic
//-------------------------------------------------------------------------------------------------------     
// SGL ELEMENT - 128 bits
//     |-----------------|--------------|-------------|--------------|-----------------|        
//     |   [ 127: 112]   |  [ 111: 96]  |  [ 95: 88]  |  [ 87: 64]   |     [ 63:  0]   |        
//     |-----------------|--------------|-------------|--------------|-----------------|        
//     |     user_id     |  user_handle |    flags    |  byte_count  | src_dst_address |        
//     |-----------------|--------------|-------------|--------------|-----------------|   
//-------------------------------------------------------------------------------------------------------    
   assign src_dst_address  = ( CurrentChannel_r == 2'h3 ) ? sgl_data_ff2[447 : 384] : 
                             ( CurrentChannel_r == 2'h2 ) ? sgl_data_ff2[335 : 272] :                    
                             ( CurrentChannel_r == 2'h1 ) ? sgl_data_ff2[223 : 160] : sgl_data_ff2[111 : 48]; 
   assign byte_count       = ( CurrentChannel_r == 2'h3 ) ? sgl_data_ff2[359 : 336] : 
                             ( CurrentChannel_r == 2'h2 ) ? sgl_data_ff2[247 : 224] :                    
                             ( CurrentChannel_r == 2'h1 ) ? sgl_data_ff2[135 : 112] : sgl_data_ff2[23 : 0]; 
   assign flags            = ( CurrentChannel_r == 2'h3 ) ? sgl_data_ff2[367 : 360] : 
                             ( CurrentChannel_r == 2'h2 ) ? sgl_data_ff2[255 : 248] :                    
                             ( CurrentChannel_r == 2'h1 ) ? sgl_data_ff2[143 : 136] : sgl_data_ff2[31 : 24]; 
   assign user_id          = ( CurrentChannel_r == 2'h3 ) ? sgl_data_ff2[383 : 368] : 
                             ( CurrentChannel_r == 2'h2 ) ? sgl_data_ff2[271 : 256] :                    
                             ( CurrentChannel_r == 2'h1 ) ? sgl_data_ff2[159 : 144] : sgl_data_ff2[47 : 32]; 
   assign user_handle      = 16'h00; 
   
//  assign src_dst_address  = CurrentChannel_r[0] ? sgl_data_ff2[223 : 160] : sgl_data_ff2[111 : 48];                    
//  assign byte_count       = CurrentChannel_r[0] ? sgl_data_ff2[135 : 112] : sgl_data_ff2[23 : 0];      
//  assign flags            = CurrentChannel_r[0] ? sgl_data_ff2[143 :136]  : sgl_data_ff2[31 : 24];           
//  assign user_handle      = 16'h00;    
//  assign user_id          = CurrentChannel_r[0] ? sgl_data_ff2[159 :144]  : sgl_data_ff2[47 : 32];         
          
always @(posedge aclk or negedge nRESET)
begin
  if(nRESET == 1'b0)
  begin
    sgl_wr_valid           <= 1'b0;
    sgl_wr_data            <= 128'h0000_0000_0000_0000_0000_0000_0000_0000;
    sgl_wr_dst_src_n       <= 1'b0;
    sgl_wr_channel         <= 2'b00;
  end
  else
  begin
    if ( (CurrentState_r == ALLOCATE_SGL_SPACE) && (NextState_r == UPDATE_SGL_ELEMENT) )
    begin
      sgl_wr_valid         <= 1'b1;
      sgl_wr_data          <= {user_id,user_handle,flags,byte_count,src_dst_address};
      // Even numbered Channels are S2C channels ==> Destination  = 1 ==> sgl_wr_dst_src_n = 1
      // Odd numbered Channels are C2S channels  ==> Source       = 1 ==> sgl_wr_dst_src_n = 0
      sgl_wr_dst_src_n     <= ~CurrentChannel_r[0]; 
      sgl_wr_channel       <= CurrentChannel_r;
    end
    else if ((sgl_wr_ready == 1'b1) || (sgl_dma_ch_reset[CurrentChannel_r] == 1'b1))
    begin
      // de-assert valid with ready
      sgl_wr_valid           <= 1'b0;
      sgl_wr_data            <= 128'h0000_0000_0000_0000_0000_0000_0000_0000;
      sgl_wr_dst_src_n       <= 1'b0;
      sgl_wr_channel         <= 2'b00;
    end    
  end  
end  

//-------------------------------------------------------------------------  
// Timeout counters control logic
//-------------------------------------------------------------------------                                                 
always @(posedge aclk or negedge nRESET)
begin
  if(nRESET == 1'b0)
  begin
    timer_0_count_en_r   <= 1'b0;                                                                                   
    timer_1_count_en_r   <= 1'b0;                                                                                   
  end                                                                                                               
  else                                                                                                              
  begin                                                                                                             
    // Enable timer0 during ALLOCATE_SGL_SPACE state
    if ( (CurrentState_r == WAIT_FOR_SGL_AVAILABLE) && (NextState_r == ALLOCATE_SGL_SPACE) )
    begin
      timer_0_count_en_r      <= 1'b1;
    end
    // Disable timer0 during UPDATE_SGL_ELEMENT state i.e. after sgl_alloc_ready signal assertion 
    else if ( (CurrentState_r == ALLOCATE_SGL_SPACE) && (NextState_r == UPDATE_SGL_ELEMENT) || (sgl_dma_ch_reset[CurrentChannel_r] == 1'b1))  
    begin
      timer_0_count_en_r      <= 1'b0;
    end  
    
    // Enable timer1 during UPDATE_SGL_ELEMENT state i.e. after sgl_alloc_ready signal assertion
    if ( (CurrentState_r == ALLOCATE_SGL_SPACE) && (NextState_r == UPDATE_SGL_ELEMENT) )
    begin
      timer_1_count_en_r      <= 1'b1;
    end
    // Disable timer1 after UPDATE_SGL_ELEMENT state i.e. with sgl_done signal assertion
    else if ( (CurrentState_r == UPDATE_SGL_ELEMENT) && (NextState_r == WAIT_FOR_SGL_AVAILABLE) || (sgl_dma_ch_reset[CurrentChannel_r] == 1'b1))  
    begin
      timer_1_count_en_r      <= 1'b0;
    end  
  end  
end  

//-------------------------------------------------------------------------  
// Timeout counters 
//-------------------------------------------------------------------------                                                 
always @(posedge aclk or negedge nRESET)
begin
  if(nRESET == 1'b0)
  begin
    timer_0_count_r   <= 16'h0000;
    timer_1_count_r   <= 16'h0000;
  end
  else
  begin
    if (timer_0_count_en_r == 1'b1)
    begin
      timer_0_count_r   <= timer_0_count_r + 1'b1;
    end
    else
    begin
      timer_0_count_r   <= 16'h0000;
    end
    
    if (timer_1_count_en_r == 1'b1)
    begin
      timer_1_count_r   <= timer_1_count_r + 1'b1;
    end
    else
    begin
      timer_1_count_r   <= 16'h0000;
    end
  
  end  
end  

//-------------------------------------------------------------------------  
// SGL Preparation block interface driving logic
//-------------------------------------------------------------------------                                                 
always @(posedge aclk or negedge nRESET)
begin
  if(nRESET == 1'b0)
  begin
    sgl_done     <= 4'h0;
    sgl_error    <= 4'h0;
  end
  else
  begin
    // Send done after writing the SGL element in the DMA
    if ( ( (sgl_wr_valid == 1'b1) && (sgl_wr_ready == 1'b1 )) && (sgl_dma_ch_reset[CurrentChannel_r] == 1'b0))
    begin
      sgl_done[CurrentChannel_r]   <= 1'b1;
    end
    else if (sgl_available_ff2[CurrentChannel_r] == 1'b0)
    begin
      sgl_done[CurrentChannel_r]   <= 1'b0;
    end
    else
    begin
      sgl_done[CurrentChannel_r]   <= sgl_done[CurrentChannel_r];
    end
    
    // Generating ERROR pulse with TIMER1 expiry
    if ( (CurrentState_r == UPDATE_SGL_ELEMENT) && (timer_1_count_r == TIMER1_MAX_COUNT) )
    begin
      sgl_error[CurrentChannel_r]  <= 1'b1;
    end
    else
    begin
      sgl_error[CurrentChannel_r]  <= 1'b0;
    end

  end  
end  



endmodule


//   END OF FILE 



