//
//////////////////////////////////////////////////////////////////////////////////////////-
// Copyright  2011, Xilinx, Inc.
// This file contains confidential and proprietary information of Xilinx, Inc. and is
// protected under U.S. and international copyright and other intellectual property laws.
//////////////////////////////////////////////////////////////////////////////////////////-
//
// Disclaimer:
// This disclaimer is not a license and does not grant any rights to the materials
// distributed herewith. Except as otherwise provided in a valid license issued to
// you by Xilinx, and to the maximum extent permitted by applicable law: (1) THESE
// MATERIALS ARE MADE AVAILABLE "AS IS" AND WITH ALL FAULTS, AND XILINX HEREBY
// DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY,
// INCLUDING BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-INFRINGEMENT,
// OR FITNESS FOR ANY PARTICULAR PURPOSE; and (2) Xilinx shall not be liable
// (whether in contract or tort, including negligence, or under any other theory
// of liability) for any loss or damage of any kind or nature related to, arising
// under or in connection with these materials, including for any direct, or any
// indirect, special, incidental, or consequential loss or damage (including loss
// of data, profits, goodwill, or any type of loss or damage suffered as a result
// of any action brought by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the possibility of the same.
//
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-safe, or for use in any
// application requiring fail-safe performance, such as life-support or safety
// devices or systems, Class III medical devices, nuclear facilities, applications
// related to the deployment of airbags, or any other applications that could lead
// to death, personal injury, or severe property or environmental damage
// (individually and collectively, "Critical Applications"). Customer assumes the
// sole risk and liability of any use of Xilinx products in Critical Applications,
// subject only to applicable laws and regulations governing limitations on product
// liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS PART OF THIS FILE AT ALL TIMES.
//
//////////////////////////////////////////////////////////////////////////////////////////-
//
//
//
//             _ ______ ____ ____ __ __ __
//             | |/ / ___| _ \/ ___|| \/ |/ /_
//             | ' / | | |_) \___ \| |\/| | '_ \
//             | . \ |___| __/ ___) | | | | (_) |
//             |_|\_\____|_| |____/|_| |_|\___/
// 
// 
// 
// KCPSM6 reference design on KC705 Board (www.xilinx.com).
// 
// XC7K325T-2FFG900 Device 
//
// Chris Kohn and Ken Chapman - Xilinx, Inc.
//
// March 9, 2011
//
//
//
// This reference design is to illustrate a way in which a KCPSM6 processor can implement 
// a bridge between a UART and a Block Memory (BRAM) within a device. With the UART 
// should be connected back to a PC (via the USB/UART device on the KC705 board) and 
// HyperTerminal or similar configured to 115200 baud, 1 stop bit, no parity, no handshake.
// Then simple text commands will enable memory locations within a BRAM to be read and 
// written. The memory is treated as 1K words of 32-bits so all data values are 8-digit
// hexadecimal.
//
// This design is set up to use the 200MHz differential clock source on the KC705 board. 
// The clock is then divided by 4 before being used by the bridge module containing KCPMS6.
// If a frequency applied to the bridge module is not 50MHz then the KCPSM6 program will 
// require some adjustments to maintain the same communication settings.
// 
// 
//////////////////////////////////////////////////////////////////////////////////////////-
//
`timescale 1ps / 1ps


module kcu105_power_test
   ( 
      input         clk50,
      //input         fan_tach,
      //output        fan_pwm,
      inout         pmbus_clk,
      inout         pmbus_data,
      input         pmbus_alert,
      output [15:0] pwr_demo_control,
      input   [7:0] pwr_demo_status,
      input         locked,
      input         vauxp0,
      input         vauxn0,
      input         vauxp2,
      input         vauxn2,
      input         vauxp8,
      input         vauxn8,
      input  [9:0]  rd_address,
      input         rd_en,
      output [31:0]  rd_data,
      output  [4:0] muxaddr_out          
      
    );

  parameter [3:0] MAJ_VER = 1;
  parameter [3:0] MIN_VER = 1;
  parameter [3:0] SIL_ID  = 1;
  parameter [3:0] DES_ID  = 1;
  parameter power_sink_modules = 256;
  
  //
  // wires used to connect UART to BRAM
  //
  
  wire         bram_we_a;
  wire [31:0]  bram_data_in_a;
  
  // Port-A is used only for reading, so tie we_a to zero
  assign bram_we_a = 1'b0;
  assign bram_data_in_a = 32'd0;
  
  //
  // wires used to connect CTRL to BRAM
  //
  
  wire        bram_we_b;
  wire        bram_en_b;
  wire  [9:0] bram_address_b;
  wire [31:0] bram_data_in_b;
  wire [31:0] bram_data_out_b;
  
  //
  // wires used to insert a BRAM
  //
  
  wire  [3:0] we_a;
  wire        en_a;
  wire [15:0] address_a;
  wire  [3:0] parity_a;
  //
  wire  [7:0] we_b;
  wire        en_b;
  wire [15:0] address_b;
  wire  [3:0] parity_b;
  
  //
  // wires for PMBus
  //
  
  wire  drive_pmbus_clk;
  wire  drive_pmbus_data;
  wire  pmbus_control;
  //
  // wires to connect power consuming modules
  //
  //type sink_link_type is array(power_sink_modules downto 0) of std_logic_vector(31 downto 0);
  //
  wire [31:0] sink_link [power_sink_modules:0]; 
  wire [power_sink_modules:0] sleep_sink;

  ////////////////////////////////////////////////////////////////////////////////////////-
  // Instantiate CTRL to BRAM bridge module containing KCPSM6
  ////////////////////////////////////////////////////////////////////////////////////////-
  //
  // This module should be clocked at 50MHz or the program adjusted accordingly.
  //

  pmbus_bram_bridge pmbus_bridge
    (       .bram_we        (bram_we_b),
            .bram_en        (bram_en_b), 
            .bram_address   (bram_address_b),
            .bram_data_in   (bram_data_in_b),
            .bram_data_out  (bram_data_out_b),
            .pmbus_clk_in   (pmbus_clk),
            .pmbus_clk_out  (drive_pmbus_clk),
            .pmbus_data_in  (pmbus_data),
            .pmbus_data_out (drive_pmbus_data),
            .pmbus_control  (pmbus_control),
            .pmbus_alert    (pmbus_alert),
            .control_sinks  (sink_link[0]),
            .monitor_sinks  (sink_link[power_sink_modules]),
            .sleep_sinks    (sleep_sink[0]),
            //.fan_tach         (fan_tach),
            //.fan_pwm          (fan_pwm),
            .pwr_demo_control (pwr_demo_control),
            .pwr_demo_status  (pwr_demo_status),
            .clk            (clk50),
            .locked         (locked),
            .vauxp0         (vauxp0     ),
            .vauxn0         (vauxn0     ),
            .vauxp2         (vauxp2     ),
            .vauxn2         (vauxn2     ),
            .vauxp8         (vauxp8     ),
            .vauxn8         (vauxn8     ),
            .muxaddr_out    (muxaddr_out)
     );
                        
                        
  //
  ////////////////////////////////////////////////////////////////////////////////////////-
  // Connections to PMBus
  ////////////////////////////////////////////////////////////////////////////////////////-
  //
  // The data and clock should be treated as open collector bidirectional wires which 
  // use a pull-up on the board to generate a High level.
  //
    assign pmbus_clk  = (drive_pmbus_clk == 0) ? 1'b0 : 'bz;
    assign pmbus_data = (drive_pmbus_data == 0) ? 1'b0 : 'bz;     

  //
  // Instantiate a BRAM configured to be 1K words of 32-bits
  //
  // In this test case only one port (A) is connected but obviously the other port is 
  // available for communication providing a further bridging opportunity. Currently 
  // unused ports are tied off or looped back.
  //
  // The port connected to the UART to BRAM bridge must used the same clock (50MHz).
  //
  // For test purposes the BRAM has been initialised with the following values..
  //     Address   Data
  //     000       16'b0, DES_VER, SIL_VER, MAJ_VER , MIN_VER 
  //     001       12345678 
  //     002       00000000
  //     to... 
  //     3FE       00000000 
  //     3FF       FEDCBA09 
  //

  assign address_a = {1'b0 , rd_address[9:0] , 5'b0};
  assign en_a = rd_en;
  assign we_a = {bram_we_a , bram_we_a , bram_we_a , bram_we_a};
   
  assign address_b = {1'b0 , bram_address_b[9:0] , 5'b0};
  assign en_b = bram_en_b;
  assign we_b = {bram_we_b , bram_we_b , bram_we_b , bram_we_b , bram_we_b , bram_we_b , bram_we_b , bram_we_b};

  localparam [255:0] INIT_00_VAL = {240'h0, DES_ID, SIL_ID, MAJ_VER, MIN_VER};

  RAMB36E1 #
                ( .READ_WIDTH_A ( 36),
                  .WRITE_WIDTH_A ( 36),
                  .DOA_REG ( 0),
                  .INIT_A ( 'b0),
                  .RSTREG_PRIORITY_A ( "REGCE"),
                  .SRVAL_A ( 'b0),
                  .WRITE_MODE_A ( "WRITE_FIRST"),
                  .READ_WIDTH_B ( 36),
                  .WRITE_WIDTH_B ( 36),
                  .DOB_REG ( 0),
                  .INIT_B ( 'b0),
                  .RSTREG_PRIORITY_B ( "REGCE"),
                  .SRVAL_B ( 'b0),
                  .WRITE_MODE_B ( "WRITE_FIRST"),
                  .INIT_FILE ( "NONE"),
                  .SIM_COLLISION_CHECK ( "ALL"),
                  .SIM_DEVICE ( "7SERIES"),
                  .RAM_MODE ( "TDP"),
                  .RDADDR_COLLISION_HWCONFIG ( "DELAYED_WRITE"),
                  .EN_ECC_READ ( "FALSE"),
                  .EN_ECC_WRITE ( "FALSE"),
                  .RAM_EXTENSION_A ( "NONE"),
                  .RAM_EXTENSION_B ( "NONE"),
                  .INIT_00  ( INIT_00_VAL),
                  .INIT_01  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_02  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_03  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_04  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_05  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_06  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_07  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_08  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_09  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_0A  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_0B  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_0C  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_0D  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_0E  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_0F  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_10  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_11  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_12  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_13  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_14  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_15  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_16  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_17  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_18  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_19  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_1A  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_1B  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_1C  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_1D  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_1E  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_1F  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_20  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_21  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_22  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_23  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_24  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_25  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_26  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_27  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_28  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_29  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_2A  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_2B  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_2C  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_2D  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_2E  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_2F  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_30  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_31  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_32  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_33  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_34  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_35  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_36  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_37  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_38  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_39  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_3A  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_3B  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_3C  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_3D  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_3E  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_3F  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_40  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_41  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_42  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_43  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_44  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_45  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_46  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_47  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_48  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_49  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_4A  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_4B  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_4C  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_4D  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_4E  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_4F  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_50  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_51  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_52  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_53  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_54  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_55  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_56  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_57  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_58  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_59  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_5A  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_5B  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_5C  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_5D  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_5E  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_5F  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_60  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_61  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_62  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_63  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_64  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_65  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_66  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_67  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_68  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_69  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_6A  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_6B  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_6C  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_6D  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_6E  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_6F  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_70  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_71  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_72  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_73  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_74  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_75  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_76  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_77  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_78  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_79  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_7A  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_7B  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_7C  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_7D  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_7E  ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INIT_7F  ( 256'hFEDCBA0900000000000000000000000000000000000000000000000000000000),
                  .INITP_00 ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INITP_01 ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INITP_02 ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INITP_03 ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INITP_04 ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INITP_05 ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INITP_06 ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INITP_07 ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INITP_08 ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INITP_09 ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INITP_0A ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INITP_0B ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INITP_0C ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INITP_0D ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INITP_0E ( 256'h0000000000000000000000000000000000000000000000000000000000000000),
                  .INITP_0F ( 256'h0000000000000000000000000000000000000000000000000000000000000000))
          target_bram_1K_x_32
            (   .ADDRARDADDR ( address_a),
                    .ENARDEN ( en_a),
                  .CLKARDCLK ( clk50),
                      .DOADO ( rd_data),
                    .DOPADOP ( parity_a), 
                      .DIADI ( bram_data_in_a),
                    .DIPADIP ( parity_a), 
                        .WEA ( we_a),
                .REGCEAREGCE ( 1'b0),
              .RSTRAMARSTRAM ( 1'b0),
              .RSTREGARSTREG ( 1'b0),
                .ADDRBWRADDR ( address_b),
                    .ENBWREN ( en_b),
                  .CLKBWRCLK ( clk50),
                      .DOBDO ( bram_data_out_b),
                    .DOPBDOP ( parity_b), 
                      .DIBDI ( bram_data_in_b),
                    .DIPBDIP ( parity_b), 
                      .WEBWE ( we_b),
                     .REGCEB ( 1'b0),
                    .RSTRAMB ( 1'b0),
                    .RSTREGB ( 1'b0),
                 .CASCADEINA ( 1'b0),
                 .CASCADEINB ( 1'b0),
              .INJECTDBITERR ( 1'b0),
              .INJECTSBITERR ( 1'b0));

endmodule
