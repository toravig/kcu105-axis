//
///////////////////////////////////////////////////////////////////////////////////////////
// Copyright © 2010-2013, Xilinx, Inc.
// This file contains confidential and proprietary information of Xilinx, Inc. and is
// protected under U.S. and international copyright and other intellectual property laws.
///////////////////////////////////////////////////////////////////////////////////////////
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
///////////////////////////////////////////////////////////////////////////////////////////
//
//
// Definition of a program memory for KCPSM6 including generic parameters for the 
// convenient selection of device family, program memory size and the ability to include 
// the JTAG Loader hardware for rapid software development.
//
// This file is primarily for use during code development and it is recommended that the 
// appropriate simplified program memory definition be used in a final production design. 
//
//
//    Generic                  Values             Comments
//    Parameter                Supported
//  
//    C_FAMILY                 "S6"               Spartan-6 device
//                             "V6"               Virtex-6 device
//                             "7S"               7-Series device 
//                                                  (Artix-7, Kintex-7, Virtex-7 or Zynq)
//
//    C_RAM_SIZE_KWORDS        1, 2 or 4          Size of program memory in K-instructions
//
//    C_JTAG_LOADER_ENABLE     0 or 1             Set to '1' to include JTAG Loader
//
// Notes
//
// If your design contains MULTIPLE KCPSM6 instances then only one should have the 
// JTAG Loader enabled at a time (i.e. make sure that C_JTAG_LOADER_ENABLE is only set to 
// '1' on one instance of the program memory). Advanced users may be interested to know 
// that it is possible to connect JTAG Loader to multiple memories and then to use the 
// JTAG Loader utility to specify which memory contents are to be modified. However, 
// this scheme does require some effort to set up and the additional connectivity of the 
// multiple BRAMs can impact the placement, routing and performance of the complete 
// design. Please contact the author at Xilinx for more detailed information. 
//
// Regardless of the size of program memory specified by C_RAM_SIZE_KWORDS, the complete 
// 12-bit address bus is connected to KCPSM6. This enables the generic to be modified 
// without requiring changes to the fundamental hardware definition. However, when the 
// program memory is 1K then only the lower 10-bits of the address are actually used and 
// the valid address range is 000 to 3FF hex. Likewise, for a 2K program only the lower 
// 11-bits of the address are actually used and the valid address range is 000 to 7FF hex.
//
// Programs are stored in Block Memory (BRAM) and the number of BRAM used depends on the 
// size of the program and the device family. 
//
// In a Spartan-6 device a BRAM is capable of holding 1K instructions. Hence a 2K program 
// will require 2 BRAMs to be used and a 4K program will require 4 BRAMs to be used. It 
// should be noted that a 4K program is not such a natural fit in a Spartan-6 device and 
// the implementation also requires a small amount of logic resulting in slightly lower 
// performance. A Spartan-6 BRAM can also be split into two 9k-bit memories suggesting 
// that a program containing up to 512 instructions could be implemented. However, there 
// is a silicon errata which makes this unsuitable and therefore it is not supported by 
// this file.
//
// In a Virtex-6 or any 7-Series device a BRAM is capable of holding 2K instructions so 
// obviously a 2K program requires only a single BRAM. Each BRAM can also be divided into 
// 2 smaller memories supporting programs of 1K in half of a 36k-bit BRAM (generally 
// reported as being an 18k-bit BRAM). For a program of 4K instructions, 2 BRAMs are used.
//
//
// Program defined by 'S:\group_space\releases\ultra_lp_demo_1\2014.1\kcu105__sysmon_voltage_fix_4\ultra_lp_demo_1\kcu105\hardware\sources\hdl\control_plane\pico_gen\pmbus_to_bram_program.psm'.
//
// Generated by KCPSM6 Assembler: 07 Jan 2014 - 13:37:11. 
//
// Assembler used ROM_form template: ROM_form_JTAGLoader_14March13.v
//
//
`timescale 1ps/1ps
module pmbus_to_bram_program (address, instruction, enable, rdl, clk);
//
parameter integer C_JTAG_LOADER_ENABLE = 1;                        
parameter         C_FAMILY = "S6";                        
parameter integer C_RAM_SIZE_KWORDS = 1;                        
//
input         clk;        
input  [11:0] address;        
input         enable;        
output [17:0] instruction;        
output        rdl;
//
//
wire [15:0] address_a;
wire        pipe_a11;
wire [35:0] data_in_a;
wire [35:0] data_out_a;
wire [35:0] data_out_a_l;
wire [35:0] data_out_a_h;
wire [35:0] data_out_a_ll;
wire [35:0] data_out_a_lh;
wire [35:0] data_out_a_hl;
wire [35:0] data_out_a_hh;
wire [15:0] address_b;
wire [35:0] data_in_b;
wire [35:0] data_in_b_l;
wire [35:0] data_in_b_ll;
wire [35:0] data_in_b_hl;
wire [35:0] data_out_b;
wire [35:0] data_out_b_l;
wire [35:0] data_out_b_ll;
wire [35:0] data_out_b_hl;
wire [35:0] data_in_b_h;
wire [35:0] data_in_b_lh;
wire [35:0] data_in_b_hh;
wire [35:0] data_out_b_h;
wire [35:0] data_out_b_lh;
wire [35:0] data_out_b_hh;
wire        enable_b;
wire        clk_b;
wire [7:0]  we_b;
wire [3:0]  we_b_l;
wire [3:0]  we_b_h;
//
wire [11:0] jtag_addr;
wire        jtag_we;
wire        jtag_clk;
wire [17:0] jtag_din;
wire [17:0] jtag_dout;
wire [17:0] jtag_dout_1;
wire [0:0]  jtag_en;
//
wire [0:0]  picoblaze_reset;
wire [0:0]  rdl_bus;
//
parameter integer BRAM_ADDRESS_WIDTH = addr_width_calc(C_RAM_SIZE_KWORDS);
//
//
function integer addr_width_calc;
  input integer size_in_k;
    if (size_in_k == 1) begin addr_width_calc = 10; end
      else if (size_in_k == 2) begin addr_width_calc = 11; end
      else if (size_in_k == 4) begin addr_width_calc = 12; end
      else begin
        if (C_RAM_SIZE_KWORDS != 1 && C_RAM_SIZE_KWORDS != 2 && C_RAM_SIZE_KWORDS != 4) begin
          //#0;
          $display("Invalid BlockRAM size. Please set to 1, 2 or 4 K words..\n");
          $finish;
        end
    end
endfunction
//
//
generate
  if (C_RAM_SIZE_KWORDS == 1) begin : ram_1k_generate 
    //
    if (C_FAMILY == "S6") begin: s6 
      //
      assign address_a[13:0] = {address[9:0], 4'b0000};
      assign instruction = {data_out_a[33:32], data_out_a[15:0]};
      assign data_in_a = {34'b0000000000000000000000000000000000, address[11:10]};
      assign jtag_dout = {data_out_b[33:32], data_out_b[15:0]};
      //
      if (C_JTAG_LOADER_ENABLE == 0) begin : no_loader
        assign data_in_b = {2'b00, data_out_b[33:32], 16'b0000000000000000, data_out_b[15:0]};
        assign address_b[13:0] = 14'b00000000000000;
        assign we_b[3:0] = 4'b0000;
        assign enable_b = 1'b0;
        assign rdl = 1'b0;
        assign clk_b = 1'b0;
      end // no_loader;
      //
      if (C_JTAG_LOADER_ENABLE == 1) begin : loader
        assign data_in_b = {2'b00, jtag_din[17:16], 16'b0000000000000000, jtag_din[15:0]};
        assign address_b[13:0] = {jtag_addr[9:0], 4'b0000};
        assign we_b[3:0] = {jtag_we, jtag_we, jtag_we, jtag_we};
        assign enable_b = jtag_en[0];
        assign rdl = rdl_bus[0];
        assign clk_b = jtag_clk;
      end // loader;
      // 
      RAMB16BWER #(.DATA_WIDTH_A        (18),
                   .DOA_REG             (0),
                   .EN_RSTRAM_A         ("FALSE"),
                   .INIT_A              (9'b000000000),
                   .RST_PRIORITY_A      ("CE"),
                   .SRVAL_A             (9'b000000000),
                   .WRITE_MODE_A        ("WRITE_FIRST"),
                   .DATA_WIDTH_B        (18),
                   .DOB_REG             (0),
                   .EN_RSTRAM_B         ("FALSE"),
                   .INIT_B              (9'b000000000),
                   .RST_PRIORITY_B      ("CE"),
                   .SRVAL_B             (9'b000000000),
                   .WRITE_MODE_B        ("WRITE_FIRST"),
                   .RSTTYPE             ("SYNC"),
                   .INIT_FILE           ("NONE"),
                   .SIM_COLLISION_CHECK ("ALL"),
                   .SIM_DEVICE          ("SPARTAN6"),
                   .INIT_00             (256'h11001000D007D006D005D004D009D0081000B001020520052005200520052005),
                   .INIT_01             (256'h18061900F035D101D0001300120011801000B012D343D242D141D04013001200),
                   .INIT_02             (256'h039E03BE0224020960279401025A020F020914640205029C1D001C001B801A00),
                   .INIT_03             (256'hF0321034F03610060328F0321014F03610020328F0321010F0361001031C02BC),
                   .INIT_04             (256'h0328F0321024F0361082033EF0321020F03610810328F032101CF03610800328),
                   .INIT_05             (256'h02EE0333F032102CF03610180333F0321028F03610100328F0321030F0361083),
                   .INIT_06             (256'hF03610120349F0371004F0331015F03610110349F0371019F0331011F0361010),
                   .INIT_07             (256'hF0331021F03610130349F0371002F033101DF03610140349F0371007F0331035),
                   .INIT_08             (256'hF0371007F0331029F03610160349F0371002F0331025F03610150349F0371002),
                   .INIT_09             (256'h1014016DF0341012F0331011F03210100349F0371002F033102DF03610170349),
                   .INIT_0A             (256'h101DF032101C016DF0341036F0331035F0321034016DF0341016F0331015F032),
                   .INIT_0B             (256'h1026F0331025F0321024016DF0341022F0331021F0321020016DF034101EF033),
                   .INIT_0C             (256'h016DF034102EF033102DF032102C016DF034102AF0331029F0321028016DF034),
                   .INIT_0D             (256'h60E1CAB0BB353A400AB0029C9C05DB01DA0002A51D0018061900202F016400D3),
                   .INIT_0E             (256'h014C1A0AF00010DBF001101001481A0AF00010B9F0011010FA3503BEE1155000),
                   .INIT_0F             (256'hF00010C3F001100E01991A0AF0001033F001100F01541A0AF00010ACF001100F),
                   .INIT_10             (256'hF001100C01501A0AF00010CEF001100D015C1A0AF00010AEF001100D01581A0A),
                   .INIT_11             (256'h103DF001100C01601A0AF000103DF001100CFA3503BE500001601A0AF00010F5),
                   .INIT_12             (256'h100E01581A0AF00010AEF001100D015C1A0AF00010F5F001100C01501A0AF000),
                   .INIT_13             (256'h1A0AF000108FF001101001541A0AF000101EF001100F01991A0AF0001067F001),
                   .INIT_14             (256'h500001DC1B021C40500001DC1B021C24500001481A0AF00010D7F001100F014C),
                   .INIT_15             (256'h500001DC1B021C5E500001DC1B021C26500001DC1B021C25500001DC1B021C44),
                   .INIT_16             (256'hBF34BE33BD325000029C9A0FDB1002A51C001D0018031900500001DC1B021C5F),
                   .INIT_17             (256'h15410D200E30027B06A007B002A508E0190004A005B002A508D0190050000172),
                   .INIT_18             (256'h0BA01C001D002A2029100800027B06D007E0082009301A00027B060007101489),
                   .INIT_19             (256'h01B51B021C8B500001DC1B021C21500001B51B011C205000029C08F019000A90),
                   .INIT_1A             (256'h01DC1B021C39500001B51B021C39500001DC1B021C38500001B51B021C385000),
                   .INIT_1B             (256'h05C061D80246023201F8450605A0021D02051E001300500001B51B021C8C5000),
                   .INIT_1C             (256'h1301E53001F8022A024961D80246023201F8450705A0021D61D80246023201F8),
                   .INIT_1D             (256'h021D02051E0013005000D301130102245000C5E00224E5300230024961CBC3B0),
                   .INIT_1E             (256'h13010246023201F8A53061D80246023201F805C061D80246023201F8450605A0),
                   .INIT_1F             (256'h4E077E03E201D1C04108C50001E010805000D50102240246023205E061EBC3B0),
                   .INIT_20             (256'h5F015000025ADF202F0070FF10015000DF205F021F015000E1F9400E4E062202),
                   .INIT_21             (256'h025A020F021A5000DF205F025000DF202F0070FF100250002211D0019004DF20),
                   .INIT_22             (256'h500002090256020F025A02155000021A0256020F025A02155000020902560215),
                   .INIT_23             (256'h0252020F025A021A22339000440E022B021A223802156237C5401480222B021A),
                   .INIT_24             (256'h9001100B5000624A9401023C14085000D501023C5000020902524500D0029004),
                   .INIT_25             (256'h110012002276107C110012002276107C110012002276107C110012005000624F),
                   .INIT_26             (256'h118912092276104811E8120122761012117A12002276106A11181200227610FA),
                   .INIT_27             (256'h4608470E12001300181050006276B200B100900122761010115E125F22761068),
                   .INIT_28             (256'h100B3507400A400A400A00505000627E9801400841084208430823500240E283),
                   .INIT_29             (256'hDB05DA04D909D80822969001450044061000D000629210014408450E2296D080),
                   .INIT_2A             (256'hB004DA8050009D039C029B019A00B001B021D909D8085000B001B031DD07DC06),
                   .INIT_2B             (256'h02B4180019101A40500062B8D001900EB014D881D982DA805000980C990D02B8),
                   .INIT_2C             (256'h02B4180119471A4802B4180F19001A4602B41800190A1A4202B418F019001A41),
                   .INIT_2D             (256'h02B4180119011A4B02B4180119471A4A02B4180F19001A4702B4180119011A49),
                   .INIT_2E             (256'h19181A405000026A02B418F019201A4102B4180F19001A7902B4180119011A4F),
                   .INIT_2F             (256'h19001A4902B4180119001A4802B4180019001A4602B418F019001A4102B41812),
                   .INIT_30             (256'h19001A4F02B418FF19001A4B02B4180119001A4A02B4180019001A4702B418FF),
                   .INIT_31             (256'h035B035402AE1A005000026A02B418F019201A4102B4180019001A7902B418FF),
                   .INIT_32             (256'h0B301C001D00B8321900037702AEBA365000029C0A200B301C001D0018021900),
                   .INIT_33             (256'h02AEBA365000029C0A200B301C001D00B8321900036502AEBA365000029C0A20),
                   .INIT_34             (256'h0C200D30B8331900038002AEBA365000029C0A200B301C001D00B8321900036E),
                   .INIT_35             (256'h027B16FE177D048005905000635690014808490E100604805000029C0A000B10),
                   .INIT_36             (256'h04800590500033003200D180027B16D01707048005905000B301B210B1A69066),
                   .INIT_37             (256'h500033003200D180027B16B8170B04800590500033003200D180027B16701717),
                   .INIT_38             (256'hB83219005000027BB63717000420053033003200D180027B16E8170304800590),
                   .INIT_39             (256'h180419005000029C1A071B071C001D00B83219005000029C1AB01B041C001D00),
                   .INIT_3A             (256'hF300D20033034208430E4208430E03C002B0DD43DC42DB41DA403BFC1A0002A5),
                   .INIT_3B             (256'h03C41D005000029C9D0B9C0A9B099A0818051900B012DC421C0023B6B00223B3),
                   .INIT_3C             (256'h022490000246023205D090000246023245061574021D0205500003EA03DD1D04),
                   .INIT_3D             (256'h1575021D02055000022402300D50024990000246023245071574021D02055000),
                   .INIT_3E             (256'h0246023245071575021D02055000022490000246023205D09000024602324506),
                   .INIT_3F             (256'h00000000000000000000000000000000000000005000022402300D5002499000),
                   .INITP_00            (256'h88A222888A222888A88A2288A2288A2288A2288AAADA8A000A802AA00AAA2AAA),
                   .INITP_01            (256'h88888888888888AED022A02AA222888A222888A222888A222888A222888A2228),
                   .INITP_02            (256'h0208020A028A00A0A0A0A0A0A0A0A222222222222222222222222A8888888888),
                   .INITP_03            (256'h4C408A8D6A3A8EA4A0829AAD6ABA92EA3A928282828282828282828001580080),
                   .INITP_04            (256'h502D5808080808080808080B4B622A90AAB6AB0AAAAAAAAAAA8A02C22A0282D6),
                   .INITP_05            (256'h080808080A808080808080808080808080B0AA82A802AAAAAA95DD5C454B5557),
                   .INITP_06            (256'h9480252009480255802D50A000A280028A000A280028A000A8A8080808080808),
                   .INITP_07            (256'h00000A8BA4AAE8E92AA2E92ABA3A4AA88A000A2B51542A820A000A000A005200))
       kcpsm6_rom( .ADDRA               (address_a[13:0]),
                   .ENA                 (enable),
                   .CLKA                (clk),
                   .DOA                 (data_out_a[31:0]),
                   .DOPA                (data_out_a[35:32]), 
                   .DIA                 (data_in_a[31:0]),
                   .DIPA                (data_in_a[35:32]), 
                   .WEA                 (4'b0000),
                   .REGCEA              (1'b0),
                   .RSTA                (1'b0),
                   .ADDRB               (address_b[13:0]),
                   .ENB                 (enable_b),
                   .CLKB                (clk_b),
                   .DOB                 (data_out_b[31:0]),
                   .DOPB                (data_out_b[35:32]), 
                   .DIB                 (data_in_b[31:0]),
                   .DIPB                (data_in_b[35:32]), 
                   .WEB                 (we_b[3:0]),
                   .REGCEB              (1'b0),
                   .RSTB                (1'b0));
    end // s6;
    // 
    //
    if (C_FAMILY == "V6") begin: v6 
      //
      assign address_a[13:0] = {address[9:0], 4'b1111};
      assign instruction = data_out_a[17:0];
      assign data_in_a[17:0] = {16'b0000000000000000, address[11:10]};
      assign jtag_dout = data_out_b[17:0];
      //
      if (C_JTAG_LOADER_ENABLE == 0) begin : no_loader
        assign data_in_b[17:0] = data_out_b[17:0];
        assign address_b[13:0] = 14'b11111111111111;
        assign we_b[3:0] = 4'b0000;
        assign enable_b = 1'b0;
        assign rdl = 1'b0;
        assign clk_b = 1'b0;
      end // no_loader;
      //
      if (C_JTAG_LOADER_ENABLE == 1) begin : loader
        assign data_in_b[17:0] = jtag_din[17:0];
        assign address_b[13:0] = {jtag_addr[9:0], 4'b1111};
        assign we_b[3:0] = {jtag_we, jtag_we, jtag_we, jtag_we};
        assign enable_b = jtag_en[0];
        assign rdl = rdl_bus[0];
        assign clk_b = jtag_clk;
      end // loader;
      // 
      RAMB18E1 #(.READ_WIDTH_A              (18),
                 .WRITE_WIDTH_A             (18),
                 .DOA_REG                   (0),
                 .INIT_A                    (18'b000000000000000000),
                 .RSTREG_PRIORITY_A         ("REGCE"),
                 .SRVAL_A                   (18'b000000000000000000),
                 .WRITE_MODE_A              ("WRITE_FIRST"),
                 .READ_WIDTH_B              (18),
                 .WRITE_WIDTH_B             (18),
                 .DOB_REG                   (0),
                 .INIT_B                    (18'b000000000000000000),
                 .RSTREG_PRIORITY_B         ("REGCE"),
                 .SRVAL_B                   (18'b000000000000000000),
                 .WRITE_MODE_B              ("WRITE_FIRST"),
                 .INIT_FILE                 ("NONE"),
                 .SIM_COLLISION_CHECK       ("ALL"),
                 .RAM_MODE                  ("TDP"),
                 .RDADDR_COLLISION_HWCONFIG ("DELAYED_WRITE"),
                 .SIM_DEVICE                ("VIRTEX6"),
                 .INIT_00                   (256'h11001000D007D006D005D004D009D0081000B001020520052005200520052005),
                 .INIT_01                   (256'h18061900F035D101D0001300120011801000B012D343D242D141D04013001200),
                 .INIT_02                   (256'h039E03BE0224020960279401025A020F020914640205029C1D001C001B801A00),
                 .INIT_03                   (256'hF0321034F03610060328F0321014F03610020328F0321010F0361001031C02BC),
                 .INIT_04                   (256'h0328F0321024F0361082033EF0321020F03610810328F032101CF03610800328),
                 .INIT_05                   (256'h02EE0333F032102CF03610180333F0321028F03610100328F0321030F0361083),
                 .INIT_06                   (256'hF03610120349F0371004F0331015F03610110349F0371019F0331011F0361010),
                 .INIT_07                   (256'hF0331021F03610130349F0371002F033101DF03610140349F0371007F0331035),
                 .INIT_08                   (256'hF0371007F0331029F03610160349F0371002F0331025F03610150349F0371002),
                 .INIT_09                   (256'h1014016DF0341012F0331011F03210100349F0371002F033102DF03610170349),
                 .INIT_0A                   (256'h101DF032101C016DF0341036F0331035F0321034016DF0341016F0331015F032),
                 .INIT_0B                   (256'h1026F0331025F0321024016DF0341022F0331021F0321020016DF034101EF033),
                 .INIT_0C                   (256'h016DF034102EF033102DF032102C016DF034102AF0331029F0321028016DF034),
                 .INIT_0D                   (256'h60E1CAB0BB353A400AB0029C9C05DB01DA0002A51D0018061900202F016400D3),
                 .INIT_0E                   (256'h014C1A0AF00010DBF001101001481A0AF00010B9F0011010FA3503BEE1155000),
                 .INIT_0F                   (256'hF00010C3F001100E01991A0AF0001033F001100F01541A0AF00010ACF001100F),
                 .INIT_10                   (256'hF001100C01501A0AF00010CEF001100D015C1A0AF00010AEF001100D01581A0A),
                 .INIT_11                   (256'h103DF001100C01601A0AF000103DF001100CFA3503BE500001601A0AF00010F5),
                 .INIT_12                   (256'h100E01581A0AF00010AEF001100D015C1A0AF00010F5F001100C01501A0AF000),
                 .INIT_13                   (256'h1A0AF000108FF001101001541A0AF000101EF001100F01991A0AF0001067F001),
                 .INIT_14                   (256'h500001DC1B021C40500001DC1B021C24500001481A0AF00010D7F001100F014C),
                 .INIT_15                   (256'h500001DC1B021C5E500001DC1B021C26500001DC1B021C25500001DC1B021C44),
                 .INIT_16                   (256'hBF34BE33BD325000029C9A0FDB1002A51C001D0018031900500001DC1B021C5F),
                 .INIT_17                   (256'h15410D200E30027B06A007B002A508E0190004A005B002A508D0190050000172),
                 .INIT_18                   (256'h0BA01C001D002A2029100800027B06D007E0082009301A00027B060007101489),
                 .INIT_19                   (256'h01B51B021C8B500001DC1B021C21500001B51B011C205000029C08F019000A90),
                 .INIT_1A                   (256'h01DC1B021C39500001B51B021C39500001DC1B021C38500001B51B021C385000),
                 .INIT_1B                   (256'h05C061D80246023201F8450605A0021D02051E001300500001B51B021C8C5000),
                 .INIT_1C                   (256'h1301E53001F8022A024961D80246023201F8450705A0021D61D80246023201F8),
                 .INIT_1D                   (256'h021D02051E0013005000D301130102245000C5E00224E5300230024961CBC3B0),
                 .INIT_1E                   (256'h13010246023201F8A53061D80246023201F805C061D80246023201F8450605A0),
                 .INIT_1F                   (256'h4E077E03E201D1C04108C50001E010805000D50102240246023205E061EBC3B0),
                 .INIT_20                   (256'h5F015000025ADF202F0070FF10015000DF205F021F015000E1F9400E4E062202),
                 .INIT_21                   (256'h025A020F021A5000DF205F025000DF202F0070FF100250002211D0019004DF20),
                 .INIT_22                   (256'h500002090256020F025A02155000021A0256020F025A02155000020902560215),
                 .INIT_23                   (256'h0252020F025A021A22339000440E022B021A223802156237C5401480222B021A),
                 .INIT_24                   (256'h9001100B5000624A9401023C14085000D501023C5000020902524500D0029004),
                 .INIT_25                   (256'h110012002276107C110012002276107C110012002276107C110012005000624F),
                 .INIT_26                   (256'h118912092276104811E8120122761012117A12002276106A11181200227610FA),
                 .INIT_27                   (256'h4608470E12001300181050006276B200B100900122761010115E125F22761068),
                 .INIT_28                   (256'h100B3507400A400A400A00505000627E9801400841084208430823500240E283),
                 .INIT_29                   (256'hDB05DA04D909D80822969001450044061000D000629210014408450E2296D080),
                 .INIT_2A                   (256'hB004DA8050009D039C029B019A00B001B021D909D8085000B001B031DD07DC06),
                 .INIT_2B                   (256'h02B4180019101A40500062B8D001900EB014D881D982DA805000980C990D02B8),
                 .INIT_2C                   (256'h02B4180119471A4802B4180F19001A4602B41800190A1A4202B418F019001A41),
                 .INIT_2D                   (256'h02B4180119011A4B02B4180119471A4A02B4180F19001A4702B4180119011A49),
                 .INIT_2E                   (256'h19181A405000026A02B418F019201A4102B4180F19001A7902B4180119011A4F),
                 .INIT_2F                   (256'h19001A4902B4180119001A4802B4180019001A4602B418F019001A4102B41812),
                 .INIT_30                   (256'h19001A4F02B418FF19001A4B02B4180119001A4A02B4180019001A4702B418FF),
                 .INIT_31                   (256'h035B035402AE1A005000026A02B418F019201A4102B4180019001A7902B418FF),
                 .INIT_32                   (256'h0B301C001D00B8321900037702AEBA365000029C0A200B301C001D0018021900),
                 .INIT_33                   (256'h02AEBA365000029C0A200B301C001D00B8321900036502AEBA365000029C0A20),
                 .INIT_34                   (256'h0C200D30B8331900038002AEBA365000029C0A200B301C001D00B8321900036E),
                 .INIT_35                   (256'h027B16FE177D048005905000635690014808490E100604805000029C0A000B10),
                 .INIT_36                   (256'h04800590500033003200D180027B16D01707048005905000B301B210B1A69066),
                 .INIT_37                   (256'h500033003200D180027B16B8170B04800590500033003200D180027B16701717),
                 .INIT_38                   (256'hB83219005000027BB63717000420053033003200D180027B16E8170304800590),
                 .INIT_39                   (256'h180419005000029C1A071B071C001D00B83219005000029C1AB01B041C001D00),
                 .INIT_3A                   (256'hF300D20033034208430E4208430E03C002B0DD43DC42DB41DA403BFC1A0002A5),
                 .INIT_3B                   (256'h03C41D005000029C9D0B9C0A9B099A0818051900B012DC421C0023B6B00223B3),
                 .INIT_3C                   (256'h022490000246023205D090000246023245061574021D0205500003EA03DD1D04),
                 .INIT_3D                   (256'h1575021D02055000022402300D50024990000246023245071574021D02055000),
                 .INIT_3E                   (256'h0246023245071575021D02055000022490000246023205D09000024602324506),
                 .INIT_3F                   (256'h00000000000000000000000000000000000000005000022402300D5002499000),
                 .INITP_00                  (256'h88A222888A222888A88A2288A2288A2288A2288AAADA8A000A802AA00AAA2AAA),
                 .INITP_01                  (256'h88888888888888AED022A02AA222888A222888A222888A222888A222888A2228),
                 .INITP_02                  (256'h0208020A028A00A0A0A0A0A0A0A0A222222222222222222222222A8888888888),
                 .INITP_03                  (256'h4C408A8D6A3A8EA4A0829AAD6ABA92EA3A928282828282828282828001580080),
                 .INITP_04                  (256'h502D5808080808080808080B4B622A90AAB6AB0AAAAAAAAAAA8A02C22A0282D6),
                 .INITP_05                  (256'h080808080A808080808080808080808080B0AA82A802AAAAAA95DD5C454B5557),
                 .INITP_06                  (256'h9480252009480255802D50A000A280028A000A280028A000A8A8080808080808),
                 .INITP_07                  (256'h00000A8BA4AAE8E92AA2E92ABA3A4AA88A000A2B51542A820A000A000A005200))
     kcpsm6_rom( .ADDRARDADDR               (address_a[13:0]),
                 .ENARDEN                   (enable),
                 .CLKARDCLK                 (clk),
                 .DOADO                     (data_out_a[15:0]),
                 .DOPADOP                   (data_out_a[17:16]), 
                 .DIADI                     (data_in_a[15:0]),
                 .DIPADIP                   (data_in_a[17:16]), 
                 .WEA                       (2'b00),
                 .REGCEAREGCE               (1'b0),
                 .RSTRAMARSTRAM             (1'b0),
                 .RSTREGARSTREG             (1'b0),
                 .ADDRBWRADDR               (address_b[13:0]),
                 .ENBWREN                   (enable_b),
                 .CLKBWRCLK                 (clk_b),
                 .DOBDO                     (data_out_b[15:0]),
                 .DOPBDOP                   (data_out_b[17:16]), 
                 .DIBDI                     (data_in_b[15:0]),
                 .DIPBDIP                   (data_in_b[17:16]), 
                 .WEBWE                     (we_b[3:0]),
                 .REGCEB                    (1'b0),
                 .RSTRAMB                   (1'b0),
                 .RSTREGB                   (1'b0));
    end // v6;  
    // 
    //
    if (C_FAMILY == "7S") begin: akv7 
      //
      assign address_a[13:0] = {address[9:0], 4'b1111};
      assign instruction = data_out_a[17:0];
      assign data_in_a[17:0] = {16'b0000000000000000, address[11:10]};
      assign jtag_dout = data_out_b[17:0];
      //
      if (C_JTAG_LOADER_ENABLE == 0) begin : no_loader
        assign data_in_b[17:0] = data_out_b[17:0];
        assign address_b[13:0] = 14'b11111111111111;
        assign we_b[3:0] = 4'b0000;
        assign enable_b = 1'b0;
        assign rdl = 1'b0;
        assign clk_b = 1'b0;
      end // no_loader;
      //
      if (C_JTAG_LOADER_ENABLE == 1) begin : loader
        assign data_in_b[17:0] = jtag_din[17:0];
        assign address_b[13:0] = {jtag_addr[9:0], 4'b1111};
        assign we_b[3:0] = {jtag_we, jtag_we, jtag_we, jtag_we};
        assign enable_b = jtag_en[0];
        assign rdl = rdl_bus[0];
        assign clk_b = jtag_clk;
      end // loader;
      // 
      RAMB18E1 #(.READ_WIDTH_A              (18),
                 .WRITE_WIDTH_A             (18),
                 .DOA_REG                   (0),
                 .INIT_A                    (18'b000000000000000000),
                 .RSTREG_PRIORITY_A         ("REGCE"),
                 .SRVAL_A                   (18'b000000000000000000),
                 .WRITE_MODE_A              ("WRITE_FIRST"),
                 .READ_WIDTH_B              (18),
                 .WRITE_WIDTH_B             (18),
                 .DOB_REG                   (0),
                 .INIT_B                    (18'b000000000000000000),
                 .RSTREG_PRIORITY_B         ("REGCE"),
                 .SRVAL_B                   (18'b000000000000000000),
                 .WRITE_MODE_B              ("WRITE_FIRST"),
                 .INIT_FILE                 ("NONE"),
                 .SIM_COLLISION_CHECK       ("ALL"),
                 .RAM_MODE                  ("TDP"),
                 .RDADDR_COLLISION_HWCONFIG ("DELAYED_WRITE"),
                 .SIM_DEVICE                ("7SERIES"),
                 .INIT_00                   (256'h11001000D007D006D005D004D009D0081000B001020520052005200520052005),
                 .INIT_01                   (256'h18061900F035D101D0001300120011801000B012D343D242D141D04013001200),
                 .INIT_02                   (256'h039E03BE0224020960279401025A020F020914640205029C1D001C001B801A00),
                 .INIT_03                   (256'hF0321034F03610060328F0321014F03610020328F0321010F0361001031C02BC),
                 .INIT_04                   (256'h0328F0321024F0361082033EF0321020F03610810328F032101CF03610800328),
                 .INIT_05                   (256'h02EE0333F032102CF03610180333F0321028F03610100328F0321030F0361083),
                 .INIT_06                   (256'hF03610120349F0371004F0331015F03610110349F0371019F0331011F0361010),
                 .INIT_07                   (256'hF0331021F03610130349F0371002F033101DF03610140349F0371007F0331035),
                 .INIT_08                   (256'hF0371007F0331029F03610160349F0371002F0331025F03610150349F0371002),
                 .INIT_09                   (256'h1014016DF0341012F0331011F03210100349F0371002F033102DF03610170349),
                 .INIT_0A                   (256'h101DF032101C016DF0341036F0331035F0321034016DF0341016F0331015F032),
                 .INIT_0B                   (256'h1026F0331025F0321024016DF0341022F0331021F0321020016DF034101EF033),
                 .INIT_0C                   (256'h016DF034102EF033102DF032102C016DF034102AF0331029F0321028016DF034),
                 .INIT_0D                   (256'h60E1CAB0BB353A400AB0029C9C05DB01DA0002A51D0018061900202F016400D3),
                 .INIT_0E                   (256'h014C1A0AF00010DBF001101001481A0AF00010B9F0011010FA3503BEE1155000),
                 .INIT_0F                   (256'hF00010C3F001100E01991A0AF0001033F001100F01541A0AF00010ACF001100F),
                 .INIT_10                   (256'hF001100C01501A0AF00010CEF001100D015C1A0AF00010AEF001100D01581A0A),
                 .INIT_11                   (256'h103DF001100C01601A0AF000103DF001100CFA3503BE500001601A0AF00010F5),
                 .INIT_12                   (256'h100E01581A0AF00010AEF001100D015C1A0AF00010F5F001100C01501A0AF000),
                 .INIT_13                   (256'h1A0AF000108FF001101001541A0AF000101EF001100F01991A0AF0001067F001),
                 .INIT_14                   (256'h500001DC1B021C40500001DC1B021C24500001481A0AF00010D7F001100F014C),
                 .INIT_15                   (256'h500001DC1B021C5E500001DC1B021C26500001DC1B021C25500001DC1B021C44),
                 .INIT_16                   (256'hBF34BE33BD325000029C9A0FDB1002A51C001D0018031900500001DC1B021C5F),
                 .INIT_17                   (256'h15410D200E30027B06A007B002A508E0190004A005B002A508D0190050000172),
                 .INIT_18                   (256'h0BA01C001D002A2029100800027B06D007E0082009301A00027B060007101489),
                 .INIT_19                   (256'h01B51B021C8B500001DC1B021C21500001B51B011C205000029C08F019000A90),
                 .INIT_1A                   (256'h01DC1B021C39500001B51B021C39500001DC1B021C38500001B51B021C385000),
                 .INIT_1B                   (256'h05C061D80246023201F8450605A0021D02051E001300500001B51B021C8C5000),
                 .INIT_1C                   (256'h1301E53001F8022A024961D80246023201F8450705A0021D61D80246023201F8),
                 .INIT_1D                   (256'h021D02051E0013005000D301130102245000C5E00224E5300230024961CBC3B0),
                 .INIT_1E                   (256'h13010246023201F8A53061D80246023201F805C061D80246023201F8450605A0),
                 .INIT_1F                   (256'h4E077E03E201D1C04108C50001E010805000D50102240246023205E061EBC3B0),
                 .INIT_20                   (256'h5F015000025ADF202F0070FF10015000DF205F021F015000E1F9400E4E062202),
                 .INIT_21                   (256'h025A020F021A5000DF205F025000DF202F0070FF100250002211D0019004DF20),
                 .INIT_22                   (256'h500002090256020F025A02155000021A0256020F025A02155000020902560215),
                 .INIT_23                   (256'h0252020F025A021A22339000440E022B021A223802156237C5401480222B021A),
                 .INIT_24                   (256'h9001100B5000624A9401023C14085000D501023C5000020902524500D0029004),
                 .INIT_25                   (256'h110012002276107C110012002276107C110012002276107C110012005000624F),
                 .INIT_26                   (256'h118912092276104811E8120122761012117A12002276106A11181200227610FA),
                 .INIT_27                   (256'h4608470E12001300181050006276B200B100900122761010115E125F22761068),
                 .INIT_28                   (256'h100B3507400A400A400A00505000627E9801400841084208430823500240E283),
                 .INIT_29                   (256'hDB05DA04D909D80822969001450044061000D000629210014408450E2296D080),
                 .INIT_2A                   (256'hB004DA8050009D039C029B019A00B001B021D909D8085000B001B031DD07DC06),
                 .INIT_2B                   (256'h02B4180019101A40500062B8D001900EB014D881D982DA805000980C990D02B8),
                 .INIT_2C                   (256'h02B4180119471A4802B4180F19001A4602B41800190A1A4202B418F019001A41),
                 .INIT_2D                   (256'h02B4180119011A4B02B4180119471A4A02B4180F19001A4702B4180119011A49),
                 .INIT_2E                   (256'h19181A405000026A02B418F019201A4102B4180F19001A7902B4180119011A4F),
                 .INIT_2F                   (256'h19001A4902B4180119001A4802B4180019001A4602B418F019001A4102B41812),
                 .INIT_30                   (256'h19001A4F02B418FF19001A4B02B4180119001A4A02B4180019001A4702B418FF),
                 .INIT_31                   (256'h035B035402AE1A005000026A02B418F019201A4102B4180019001A7902B418FF),
                 .INIT_32                   (256'h0B301C001D00B8321900037702AEBA365000029C0A200B301C001D0018021900),
                 .INIT_33                   (256'h02AEBA365000029C0A200B301C001D00B8321900036502AEBA365000029C0A20),
                 .INIT_34                   (256'h0C200D30B8331900038002AEBA365000029C0A200B301C001D00B8321900036E),
                 .INIT_35                   (256'h027B16FE177D048005905000635690014808490E100604805000029C0A000B10),
                 .INIT_36                   (256'h04800590500033003200D180027B16D01707048005905000B301B210B1A69066),
                 .INIT_37                   (256'h500033003200D180027B16B8170B04800590500033003200D180027B16701717),
                 .INIT_38                   (256'hB83219005000027BB63717000420053033003200D180027B16E8170304800590),
                 .INIT_39                   (256'h180419005000029C1A071B071C001D00B83219005000029C1AB01B041C001D00),
                 .INIT_3A                   (256'hF300D20033034208430E4208430E03C002B0DD43DC42DB41DA403BFC1A0002A5),
                 .INIT_3B                   (256'h03C41D005000029C9D0B9C0A9B099A0818051900B012DC421C0023B6B00223B3),
                 .INIT_3C                   (256'h022490000246023205D090000246023245061574021D0205500003EA03DD1D04),
                 .INIT_3D                   (256'h1575021D02055000022402300D50024990000246023245071574021D02055000),
                 .INIT_3E                   (256'h0246023245071575021D02055000022490000246023205D09000024602324506),
                 .INIT_3F                   (256'h00000000000000000000000000000000000000005000022402300D5002499000),
                 .INITP_00                  (256'h88A222888A222888A88A2288A2288A2288A2288AAADA8A000A802AA00AAA2AAA),
                 .INITP_01                  (256'h88888888888888AED022A02AA222888A222888A222888A222888A222888A2228),
                 .INITP_02                  (256'h0208020A028A00A0A0A0A0A0A0A0A222222222222222222222222A8888888888),
                 .INITP_03                  (256'h4C408A8D6A3A8EA4A0829AAD6ABA92EA3A928282828282828282828001580080),
                 .INITP_04                  (256'h502D5808080808080808080B4B622A90AAB6AB0AAAAAAAAAAA8A02C22A0282D6),
                 .INITP_05                  (256'h080808080A808080808080808080808080B0AA82A802AAAAAA95DD5C454B5557),
                 .INITP_06                  (256'h9480252009480255802D50A000A280028A000A280028A000A8A8080808080808),
                 .INITP_07                  (256'h00000A8BA4AAE8E92AA2E92ABA3A4AA88A000A2B51542A820A000A000A005200))
     kcpsm6_rom( .ADDRARDADDR               (address_a[13:0]),
                 .ENARDEN                   (enable),
                 .CLKARDCLK                 (clk),
                 .DOADO                     (data_out_a[15:0]),
                 .DOPADOP                   (data_out_a[17:16]), 
                 .DIADI                     (data_in_a[15:0]),
                 .DIPADIP                   (data_in_a[17:16]), 
                 .WEA                       (2'b00),
                 .REGCEAREGCE               (1'b0),
                 .RSTRAMARSTRAM             (1'b0),
                 .RSTREGARSTREG             (1'b0),
                 .ADDRBWRADDR               (address_b[13:0]),
                 .ENBWREN                   (enable_b),
                 .CLKBWRCLK                 (clk_b),
                 .DOBDO                     (data_out_b[15:0]),
                 .DOPBDOP                   (data_out_b[17:16]), 
                 .DIBDI                     (data_in_b[15:0]),
                 .DIPBDIP                   (data_in_b[17:16]), 
                 .WEBWE                     (we_b[3:0]),
                 .REGCEB                    (1'b0),
                 .RSTRAMB                   (1'b0),
                 .RSTREGB                   (1'b0));
    end // akv7;  
    // 
  end // ram_1k_generate;
endgenerate
//  
generate
  if (C_RAM_SIZE_KWORDS == 2) begin : ram_2k_generate 
    //
    if (C_FAMILY == "S6") begin: s6 
      //
      assign address_a[13:0] = {address[10:0], 3'b000};
      assign instruction = {data_out_a_h[32], data_out_a_h[7:0], data_out_a_l[32], data_out_a_l[7:0]};
      assign data_in_a = {35'b00000000000000000000000000000000000, address[11]};
      assign jtag_dout = {data_out_b_h[32], data_out_b_h[7:0], data_out_b_l[32], data_out_b_l[7:0]};
      //
      if (C_JTAG_LOADER_ENABLE == 0) begin : no_loader
        assign data_in_b_l = {3'b000, data_out_b_l[32], 24'b000000000000000000000000, data_out_b_l[7:0]};
        assign data_in_b_h = {3'b000, data_out_b_h[32], 24'b000000000000000000000000, data_out_b_h[7:0]};
        assign address_b[13:0] = 14'b00000000000000;
        assign we_b[3:0] = 4'b0000;
        assign enable_b = 1'b0;
        assign rdl = 1'b0;
        assign clk_b = 1'b0;
      end // no_loader;
      //
      if (C_JTAG_LOADER_ENABLE == 1) begin : loader
        assign data_in_b_h = {3'b000, jtag_din[17], 24'b000000000000000000000000, jtag_din[16:9]};
        assign data_in_b_l = {3'b000, jtag_din[8],  24'b000000000000000000000000, jtag_din[7:0]};
        assign address_b[13:0] = {jtag_addr[10:0], 3'b000};
        assign we_b[3:0] = {jtag_we, jtag_we, jtag_we, jtag_we};
        assign enable_b = jtag_en[0];
        assign rdl = rdl_bus[0];
        assign clk_b = jtag_clk;
      end // loader;
      // 
      RAMB16BWER #(.DATA_WIDTH_A        (9),
                   .DOA_REG             (0),
                   .EN_RSTRAM_A         ("FALSE"),
                   .INIT_A              (9'b000000000),
                   .RST_PRIORITY_A      ("CE"),
                   .SRVAL_A             (9'b000000000),
                   .WRITE_MODE_A        ("WRITE_FIRST"),
                   .DATA_WIDTH_B        (9),
                   .DOB_REG             (0),
                   .EN_RSTRAM_B         ("FALSE"),
                   .INIT_B              (9'b000000000),
                   .RST_PRIORITY_B      ("CE"),
                   .SRVAL_B             (9'b000000000),
                   .WRITE_MODE_B        ("WRITE_FIRST"),
                   .RSTTYPE             ("SYNC"),
                   .INIT_FILE           ("NONE"),
                   .SIM_COLLISION_CHECK ("ALL"),
                   .SIM_DEVICE          ("SPARTAN6"),
                   .INIT_00             (256'h0600350100000080001243424140000000000706050409080001050505050505),
                   .INIT_01             (256'h32343606283214360228321036011CBC9EBE240927015A0F0964059C00008000),
                   .INIT_02             (256'hEE33322C36183332283610283230368328322436823E3220368128321C368028),
                   .INIT_03             (256'h33213613493702331D3614493707333536124937043315361149371933113610),
                   .INIT_04             (256'h146D341233113210493702332D36174937073329361649370233253615493702),
                   .INIT_05             (256'h26332532246D3422332132206D341E331D321C6D3436333532346D3416331532),
                   .INIT_06             (256'hE1B03540B09C050100A50006002F64D36D342E332D322C6D342A332932286D34),
                   .INIT_07             (256'h00C3010E990A0033010F540A00AC010F4C0A00DB0110480A00B9011035BE1500),
                   .INIT_08             (256'h3D010C600A003D010C35BE00600A00F5010C500A00CE010D5C0A00AE010D580A),
                   .INIT_09             (256'h0A008F0110540A001E010F990A0067010E580A00AE010D5C0A00F5010C500A00),
                   .INIT_0A             (256'h00DC025E00DC022600DC022500DC024400DC024000DC022400480A00D7010F4C),
                   .INIT_0B             (256'h4120307BA0B0A5E000A0B0A5D0000072343332009C0F10A50000030000DC025F),
                   .INIT_0C             (256'hB5028B00DC022100B50120009CF00090A000002010007BD0E02030007B001089),
                   .INIT_0D             (256'hC0D84632F806A01D05000000B5028C00DC023900B5023900DC023800B5023800),
                   .INIT_0E             (256'h1D0500000001012400E024303049CBB00130F82A49D84632F807A01DD84632F8),
                   .INIT_0F             (256'h070301C00800E0800001244632E0EBB0014632F830D84632F8C0D84632F806A0),
                   .INIT_10             (256'h5A0F1A002002002000FF02001101042001005A2000FF010020020100F90E0602),
                   .INIT_11             (256'h520F5A1A33000E2B1A38153740802B1A0009560F5A15001A560F5A1500095615),
                   .INIT_12             (256'h0000767C0000767C0000767C0000004F010B004A013C0800013C000952000204),
                   .INIT_13             (256'h080E000010007600000176105E5F766889097648E80176127A00766A180076FA),
                   .INIT_14             (256'h050409089601000600009201080E96800B070A0A0A50007E0108080808504083),
                   .INIT_15             (256'hB400104000B8010E14818280000C0DB804800003020100012109080001310706),
                   .INIT_16             (256'hB401014BB401474AB40F0047B4010149B4014748B40F0046B4000A42B4F00041),
                   .INIT_17             (256'h0049B4010048B4000046B4F00041B4121840006AB4F02041B40F0079B401014F),
                   .INIT_18             (256'h5B54AE00006AB4F02041B4000079B4FF004FB4FF004BB401004AB4000047B4FF),
                   .INIT_19             (256'hAE36009C20300000320065AE36009C20300000320077AE36009C203000000200),
                   .INIT_1A             (256'h7BFE7D8090005601080E0680009C00102030330080AE36009C2030000032006E),
                   .INIT_1B             (256'h000000807BB80B8090000000807B70178090000000807BD0078090000110A666),
                   .INIT_1C             (256'h0400009C070700003200009CB00400003200007B370020300000807BE8038090),
                   .INIT_1D             (256'hC400009C0B0A09080500124200B602B3000003080E080EC0B043424140FC00A5),
                   .INIT_1E             (256'h751D05002430504900463207741D050024004632D000463206741D0500EADD04),
                   .INIT_1F             (256'h00000000000000000000002430504900463207751D050024004632D000463206),
                   .INIT_20             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_21             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_22             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_23             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_24             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_25             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_26             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_27             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_28             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_29             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_2A             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_2B             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_2C             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_2D             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_2E             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_2F             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_30             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_31             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_32             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_33             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_34             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_35             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_36             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_37             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_38             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_39             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_3A             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_3B             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_3C             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_3D             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_3E             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_3F             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INITP_00            (256'h08208206212A8102040810204081020408102040421084210842C00A552A8000),
                   .INITP_01            (256'h1E479CE71653E4E9CE2CCCCCCCC2A8A2C4A5A256666666410410410410282082),
                   .INITP_02            (256'h888882222222222220221442A204402C5088888888880084000800000D8198E8),
                   .INITP_03            (256'h00043011821808C7CA45AB54454545A552A954AA2A41582B0560AC15C0888888),
                   .INITP_04            (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INITP_05            (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INITP_06            (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INITP_07            (256'h0000000000000000000000000000000000000000000000000000000000000000))
     kcpsm6_rom_l( .ADDRA               (address_a[13:0]),
                   .ENA                 (enable),
                   .CLKA                (clk),
                   .DOA                 (data_out_a_l[31:0]),
                   .DOPA                (data_out_a_l[35:32]), 
                   .DIA                 (data_in_a[31:0]),
                   .DIPA                (data_in_a[35:32]), 
                   .WEA                 (4'b0000),
                   .REGCEA              (1'b0),
                   .RSTA                (1'b0),
                   .ADDRB               (address_b[13:0]),
                   .ENB                 (enable_b),
                   .CLKB                (clk_b),
                   .DOB                 (data_out_b_l[31:0]),
                   .DOPB                (data_out_b_l[35:32]), 
                   .DIB                 (data_in_b_l[31:0]),
                   .DIPB                (data_in_b_l[35:32]), 
                   .WEB                 (we_b[3:0]),
                   .REGCEB              (1'b0),
                   .RSTB                (1'b0));
      // 
      RAMB16BWER #(.DATA_WIDTH_A        (9),
                   .DOA_REG             (0),
                   .EN_RSTRAM_A         ("FALSE"),
                   .INIT_A              (9'b000000000),
                   .RST_PRIORITY_A      ("CE"),
                   .SRVAL_A             (9'b000000000),
                   .WRITE_MODE_A        ("WRITE_FIRST"),
                   .DATA_WIDTH_B        (9),
                   .DOB_REG             (0),
                   .EN_RSTRAM_B         ("FALSE"),
                   .INIT_B              (9'b000000000),
                   .RST_PRIORITY_B      ("CE"),
                   .SRVAL_B             (9'b000000000),
                   .WRITE_MODE_B        ("WRITE_FIRST"),
                   .RSTTYPE             ("SYNC"),
                   .INIT_FILE           ("NONE"),
                   .SIM_COLLISION_CHECK ("ALL"),
                   .SIM_DEVICE          ("SPARTAN6"),
                   .INIT_00             (256'h0C0C786868090908085869696868090908086868686868680858011010101010),
                   .INIT_01             (256'h7808780801780878080178087808010101010101B0CA0101010A01010E0E0D0D),
                   .INIT_02             (256'h0101780878080178087808017808780801780878080178087808017808780801),
                   .INIT_03             (256'h7808780801780878087808017808780878080178087808780801780878087808),
                   .INIT_04             (256'h0800780878087808017808780878080178087808780801780878087808017808),
                   .INIT_05             (256'h0878087808007808780878080078087808780800780878087808007808780878),
                   .INIT_06             (256'hB0E55D1D05014E6D6D010E0C0C10000000780878087808007808780878080078),
                   .INIT_07             (256'h78087808000D78087808000D78087808000D78087808000D780878087D01F028),
                   .INIT_08             (256'h087808000D780878087D0128000D78087808000D78087808000D78087808000D),
                   .INIT_09             (256'h0D78087808000D78087808000D78087808000D78087808000D78087808000D78),
                   .INIT_0A             (256'h28000D0E28000D0E28000D0E28000D0E28000D0E28000D0E28000D7808780800),
                   .INIT_0B             (256'h0A060701030301040C020201040C28005F5F5E28014D6D010E0E0C0C28000D0E),
                   .INIT_0C             (256'h000D0E28000D0E28000D0E2801040C05050E0E95948401030304040D0103030A),
                   .INIT_0D             (256'h02B0010100A20201010F0928000D0E28000D0E28000D0E28000D0E28000D0E28),
                   .INIT_0E             (256'h01010F092869090128E201720101B0E18972000101B0010100A20201B0010100),
                   .INIT_0F             (256'hA73FF168A0620008286A01010102B0E18901010052B001010002B0010100A202),
                   .INIT_10             (256'h010101286F2F286F173808289168486F2F28016F173808286F2F0F28F0A0A711),
                   .INIT_11             (256'h0101010111C8A201011101B1620A110128010101010128010101010128010101),
                   .INIT_12             (256'h080911080809110808091108080928B1C80828B1CA010A286A01280101A26848),
                   .INIT_13             (256'hA3A309090C28B1D9D8C811080809110808091108080911080809110808091108),
                   .INIT_14             (256'h6D6D6C6C11C8A2A288E8B188A2A29168881AA0A0A00028B1CCA0A0A1A19181F1),
                   .INIT_15             (256'h010C0C0D28B16848586C6C6D284C4C01586D284E4E4D4D58586C6C2858586E6E),
                   .INIT_16             (256'h010C0C0D010C0C0D010C0C0D010C0C0D010C0C0D010C0C0D010C0C0D010C0C0D),
                   .INIT_17             (256'h0C0D010C0C0D010C0C0D010C0C0D010C0C0D2801010C0C0D010C0C0D010C0C0D),
                   .INIT_18             (256'h0101010D2801010C0C0D010C0C0D010C0C0D010C0C0D010C0C0D010C0C0D010C),
                   .INIT_19             (256'h015D280105050E0E5C0C01015D280105050E0E5C0C01015D280105050E0E0C0C),
                   .INIT_1A             (256'h010B0B020228B1C8A4A408022801050506065C0C01015D280105050E0E5C0C01),
                   .INIT_1B             (256'h28999968010B0B020228999968010B0B020228999968010B0B020228D9D9D8C8),
                   .INIT_1C             (256'h0C0C28010D0D0E0E5C0C28010D0D0E0E5C0C28015B0B0202999968010B0B0202),
                   .INIT_1D             (256'h010E28014E4E4D4D0C0C586E0E115891F9E919A1A1A1A101016E6E6D6D1D0D01),
                   .INIT_1E             (256'h0A01012801010601C80101A20A01012801C8010102C80101A20A01012801010E),
                   .INIT_1F             (256'h000000000000000000002801010601C80101A20A01012801C8010102C80101A2),
                   .INIT_20             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_21             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_22             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_23             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_24             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_25             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_26             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_27             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_28             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_29             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_2A             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_2B             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_2C             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_2D             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_2E             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_2F             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_30             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_31             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_32             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_33             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_34             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_35             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_36             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_37             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_38             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_39             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_3A             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_3B             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_3C             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_3D             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_3E             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_3F             (256'h0000000000000000000000000000004800000000000000000000000000000000),
                   .INITP_00            (256'hAAAAAAAF85C7D5AB56AD5AB56AD5AB56AD5AB56AEB5AD6B5AD6BFBB0387C3F7F),
                   .INITP_01            (256'h20BA77BCC9BE7F9F799999999998020812131B0CCCCCCCD555555555557AAAAA),
                   .INITP_02            (256'h22223888888888888CF9E1FFF8A203010622222222233578FDF3FFFFFB197199),
                   .INITP_03            (256'h003BCFEE7DE7F73EB03700793030301088442210860C0D81B03606C0EE222222),
                   .INITP_04            (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INITP_05            (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INITP_06            (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INITP_07            (256'h0001000000000000000000000000000000000000000000000000000000000000))
     kcpsm6_rom_h( .ADDRA               (address_a[13:0]),
                   .ENA                 (enable),
                   .CLKA                (clk),
                   .DOA                 (data_out_a_h[31:0]),
                   .DOPA                (data_out_a_h[35:32]), 
                   .DIA                 (data_in_a[31:0]),
                   .DIPA                (data_in_a[35:32]), 
                   .WEA                 (4'b0000),
                   .REGCEA              (1'b0),
                   .RSTA                (1'b0),
                   .ADDRB               (address_b[13:0]),
                   .ENB                 (enable_b),
                   .CLKB                (clk_b),
                   .DOB                 (data_out_b_h[31:0]),
                   .DOPB                (data_out_b_h[35:32]), 
                   .DIB                 (data_in_b_h[31:0]),
                   .DIPB                (data_in_b_h[35:32]), 
                   .WEB                 (we_b[3:0]),
                   .REGCEB              (1'b0),
                   .RSTB                (1'b0));
    end // s6;
    // 
    // 
    if (C_FAMILY == "V6") begin: v6 
      //
      assign address_a = {1'b1, address[10:0], 4'b1111};
      assign instruction = {data_out_a[33:32], data_out_a[15:0]};
      assign data_in_a = {35'b00000000000000000000000000000000000, address[11]};
      assign jtag_dout = {data_out_b[33:32], data_out_b[15:0]};
      //
      if (C_JTAG_LOADER_ENABLE == 0) begin : no_loader
        assign data_in_b = {2'b00, data_out_b[33:32], 16'b0000000000000000, data_out_b[15:0]};
        assign address_b = 16'b1111111111111111;
        assign we_b = 8'b00000000;
        assign enable_b = 1'b0;
        assign rdl = 1'b0;
        assign clk_b = 1'b0;
      end // no_loader;
      //
      if (C_JTAG_LOADER_ENABLE == 1) begin : loader
        assign data_in_b = {2'b00, jtag_din[17:16], 16'b0000000000000000, jtag_din[15:0]};
        assign address_b = {1'b1, jtag_addr[10:0], 4'b1111};
        assign we_b = {jtag_we, jtag_we, jtag_we, jtag_we, jtag_we, jtag_we, jtag_we, jtag_we};
        assign enable_b = jtag_en[0];
        assign rdl = rdl_bus[0];
        assign clk_b = jtag_clk;
      end // loader;
      // 
      RAMB36E1 #(.READ_WIDTH_A              (18),
                 .WRITE_WIDTH_A             (18),
                 .DOA_REG                   (0),
                 .INIT_A                    (36'h000000000),
                 .RSTREG_PRIORITY_A         ("REGCE"),
                 .SRVAL_A                   (36'h000000000),
                 .WRITE_MODE_A              ("WRITE_FIRST"),
                 .READ_WIDTH_B              (18),
                 .WRITE_WIDTH_B             (18),
                 .DOB_REG                   (0),
                 .INIT_B                    (36'h000000000),
                 .RSTREG_PRIORITY_B         ("REGCE"),
                 .SRVAL_B                   (36'h000000000),
                 .WRITE_MODE_B              ("WRITE_FIRST"),
                 .INIT_FILE                 ("NONE"),
                 .SIM_COLLISION_CHECK       ("ALL"),
                 .RAM_MODE                  ("TDP"),
                 .RDADDR_COLLISION_HWCONFIG ("DELAYED_WRITE"),
                 .EN_ECC_READ               ("FALSE"),
                 .EN_ECC_WRITE              ("FALSE"),
                 .RAM_EXTENSION_A           ("NONE"),
                 .RAM_EXTENSION_B           ("NONE"),
                 .SIM_DEVICE                ("VIRTEX6"),
                 .INIT_00                   (256'h11001000D007D006D005D004D009D0081000B001020520052005200520052005),
                 .INIT_01                   (256'h18061900F035D101D0001300120011801000B012D343D242D141D04013001200),
                 .INIT_02                   (256'h039E03BE0224020960279401025A020F020914640205029C1D001C001B801A00),
                 .INIT_03                   (256'hF0321034F03610060328F0321014F03610020328F0321010F0361001031C02BC),
                 .INIT_04                   (256'h0328F0321024F0361082033EF0321020F03610810328F032101CF03610800328),
                 .INIT_05                   (256'h02EE0333F032102CF03610180333F0321028F03610100328F0321030F0361083),
                 .INIT_06                   (256'hF03610120349F0371004F0331015F03610110349F0371019F0331011F0361010),
                 .INIT_07                   (256'hF0331021F03610130349F0371002F033101DF03610140349F0371007F0331035),
                 .INIT_08                   (256'hF0371007F0331029F03610160349F0371002F0331025F03610150349F0371002),
                 .INIT_09                   (256'h1014016DF0341012F0331011F03210100349F0371002F033102DF03610170349),
                 .INIT_0A                   (256'h101DF032101C016DF0341036F0331035F0321034016DF0341016F0331015F032),
                 .INIT_0B                   (256'h1026F0331025F0321024016DF0341022F0331021F0321020016DF034101EF033),
                 .INIT_0C                   (256'h016DF034102EF033102DF032102C016DF034102AF0331029F0321028016DF034),
                 .INIT_0D                   (256'h60E1CAB0BB353A400AB0029C9C05DB01DA0002A51D0018061900202F016400D3),
                 .INIT_0E                   (256'h014C1A0AF00010DBF001101001481A0AF00010B9F0011010FA3503BEE1155000),
                 .INIT_0F                   (256'hF00010C3F001100E01991A0AF0001033F001100F01541A0AF00010ACF001100F),
                 .INIT_10                   (256'hF001100C01501A0AF00010CEF001100D015C1A0AF00010AEF001100D01581A0A),
                 .INIT_11                   (256'h103DF001100C01601A0AF000103DF001100CFA3503BE500001601A0AF00010F5),
                 .INIT_12                   (256'h100E01581A0AF00010AEF001100D015C1A0AF00010F5F001100C01501A0AF000),
                 .INIT_13                   (256'h1A0AF000108FF001101001541A0AF000101EF001100F01991A0AF0001067F001),
                 .INIT_14                   (256'h500001DC1B021C40500001DC1B021C24500001481A0AF00010D7F001100F014C),
                 .INIT_15                   (256'h500001DC1B021C5E500001DC1B021C26500001DC1B021C25500001DC1B021C44),
                 .INIT_16                   (256'hBF34BE33BD325000029C9A0FDB1002A51C001D0018031900500001DC1B021C5F),
                 .INIT_17                   (256'h15410D200E30027B06A007B002A508E0190004A005B002A508D0190050000172),
                 .INIT_18                   (256'h0BA01C001D002A2029100800027B06D007E0082009301A00027B060007101489),
                 .INIT_19                   (256'h01B51B021C8B500001DC1B021C21500001B51B011C205000029C08F019000A90),
                 .INIT_1A                   (256'h01DC1B021C39500001B51B021C39500001DC1B021C38500001B51B021C385000),
                 .INIT_1B                   (256'h05C061D80246023201F8450605A0021D02051E001300500001B51B021C8C5000),
                 .INIT_1C                   (256'h1301E53001F8022A024961D80246023201F8450705A0021D61D80246023201F8),
                 .INIT_1D                   (256'h021D02051E0013005000D301130102245000C5E00224E5300230024961CBC3B0),
                 .INIT_1E                   (256'h13010246023201F8A53061D80246023201F805C061D80246023201F8450605A0),
                 .INIT_1F                   (256'h4E077E03E201D1C04108C50001E010805000D50102240246023205E061EBC3B0),
                 .INIT_20                   (256'h5F015000025ADF202F0070FF10015000DF205F021F015000E1F9400E4E062202),
                 .INIT_21                   (256'h025A020F021A5000DF205F025000DF202F0070FF100250002211D0019004DF20),
                 .INIT_22                   (256'h500002090256020F025A02155000021A0256020F025A02155000020902560215),
                 .INIT_23                   (256'h0252020F025A021A22339000440E022B021A223802156237C5401480222B021A),
                 .INIT_24                   (256'h9001100B5000624A9401023C14085000D501023C5000020902524500D0029004),
                 .INIT_25                   (256'h110012002276107C110012002276107C110012002276107C110012005000624F),
                 .INIT_26                   (256'h118912092276104811E8120122761012117A12002276106A11181200227610FA),
                 .INIT_27                   (256'h4608470E12001300181050006276B200B100900122761010115E125F22761068),
                 .INIT_28                   (256'h100B3507400A400A400A00505000627E9801400841084208430823500240E283),
                 .INIT_29                   (256'hDB05DA04D909D80822969001450044061000D000629210014408450E2296D080),
                 .INIT_2A                   (256'hB004DA8050009D039C029B019A00B001B021D909D8085000B001B031DD07DC06),
                 .INIT_2B                   (256'h02B4180019101A40500062B8D001900EB014D881D982DA805000980C990D02B8),
                 .INIT_2C                   (256'h02B4180119471A4802B4180F19001A4602B41800190A1A4202B418F019001A41),
                 .INIT_2D                   (256'h02B4180119011A4B02B4180119471A4A02B4180F19001A4702B4180119011A49),
                 .INIT_2E                   (256'h19181A405000026A02B418F019201A4102B4180F19001A7902B4180119011A4F),
                 .INIT_2F                   (256'h19001A4902B4180119001A4802B4180019001A4602B418F019001A4102B41812),
                 .INIT_30                   (256'h19001A4F02B418FF19001A4B02B4180119001A4A02B4180019001A4702B418FF),
                 .INIT_31                   (256'h035B035402AE1A005000026A02B418F019201A4102B4180019001A7902B418FF),
                 .INIT_32                   (256'h0B301C001D00B8321900037702AEBA365000029C0A200B301C001D0018021900),
                 .INIT_33                   (256'h02AEBA365000029C0A200B301C001D00B8321900036502AEBA365000029C0A20),
                 .INIT_34                   (256'h0C200D30B8331900038002AEBA365000029C0A200B301C001D00B8321900036E),
                 .INIT_35                   (256'h027B16FE177D048005905000635690014808490E100604805000029C0A000B10),
                 .INIT_36                   (256'h04800590500033003200D180027B16D01707048005905000B301B210B1A69066),
                 .INIT_37                   (256'h500033003200D180027B16B8170B04800590500033003200D180027B16701717),
                 .INIT_38                   (256'hB83219005000027BB63717000420053033003200D180027B16E8170304800590),
                 .INIT_39                   (256'h180419005000029C1A071B071C001D00B83219005000029C1AB01B041C001D00),
                 .INIT_3A                   (256'hF300D20033034208430E4208430E03C002B0DD43DC42DB41DA403BFC1A0002A5),
                 .INIT_3B                   (256'h03C41D005000029C9D0B9C0A9B099A0818051900B012DC421C0023B6B00223B3),
                 .INIT_3C                   (256'h022490000246023205D090000246023245061574021D0205500003EA03DD1D04),
                 .INIT_3D                   (256'h1575021D02055000022402300D50024990000246023245071574021D02055000),
                 .INIT_3E                   (256'h0246023245071575021D02055000022490000246023205D09000024602324506),
                 .INIT_3F                   (256'h00000000000000000000000000000000000000005000022402300D5002499000),
                 .INIT_40                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_41                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_42                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_43                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_44                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_45                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_46                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_47                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_48                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_49                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_50                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_51                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_52                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_53                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_54                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_55                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_56                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_57                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_58                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_59                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_60                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_61                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_62                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_63                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_64                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_65                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_66                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_67                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_68                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_69                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_70                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_71                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_72                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_73                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_74                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_75                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_76                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_77                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_78                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_79                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7F                   (256'h0000000000000000000000000000000000000000000000000000000000009000),
                 .INITP_00                  (256'h88A222888A222888A88A2288A2288A2288A2288AAADA8A000A802AA00AAA2AAA),
                 .INITP_01                  (256'h88888888888888AED022A02AA222888A222888A222888A222888A222888A2228),
                 .INITP_02                  (256'h0208020A028A00A0A0A0A0A0A0A0A222222222222222222222222A8888888888),
                 .INITP_03                  (256'h4C408A8D6A3A8EA4A0829AAD6ABA92EA3A928282828282828282828001580080),
                 .INITP_04                  (256'h502D5808080808080808080B4B622A90AAB6AB0AAAAAAAAAAA8A02C22A0282D6),
                 .INITP_05                  (256'h080808080A808080808080808080808080B0AA82A802AAAAAA95DD5C454B5557),
                 .INITP_06                  (256'h9480252009480255802D50A000A280028A000A280028A000A8A8080808080808),
                 .INITP_07                  (256'h00000A8BA4AAE8E92AA2E92ABA3A4AA88A000A2B51542A820A000A000A005200),
                 .INITP_08                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_09                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0A                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0B                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0C                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0D                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0E                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0F                  (256'h0000000200000000000000000000000000000000000000000000000000000000))
     kcpsm6_rom( .ADDRARDADDR               (address_a),
                 .ENARDEN                   (enable),
                 .CLKARDCLK                 (clk),
                 .DOADO                     (data_out_a[31:0]),
                 .DOPADOP                   (data_out_a[35:32]), 
                 .DIADI                     (data_in_a[31:0]),
                 .DIPADIP                   (data_in_a[35:32]), 
                 .WEA                       (4'b0000),
                 .REGCEAREGCE               (1'b0),
                 .RSTRAMARSTRAM             (1'b0),
                 .RSTREGARSTREG             (1'b0),
                 .ADDRBWRADDR               (address_b),
                 .ENBWREN                   (enable_b),
                 .CLKBWRCLK                 (clk_b),
                 .DOBDO                     (data_out_b[31:0]),
                 .DOPBDOP                   (data_out_b[35:32]), 
                 .DIBDI                     (data_in_b[31:0]),
                 .DIPBDIP                   (data_in_b[35:32]), 
                 .WEBWE                     (we_b),
                 .REGCEB                    (1'b0),
                 .RSTRAMB                   (1'b0),
                 .RSTREGB                   (1'b0),
                 .CASCADEINA                (1'b0),
                 .CASCADEINB                (1'b0),
                 .CASCADEOUTA               (),
                 .CASCADEOUTB               (),
                 .DBITERR                   (),
                 .ECCPARITY                 (),
                 .RDADDRECC                 (),
                 .SBITERR                   (),
                 .INJECTDBITERR             (1'b0),       
                 .INJECTSBITERR             (1'b0));   
    end // v6;  
    // 
    // 
    if (C_FAMILY == "7S") begin: akv7 
      //
      assign address_a = {1'b1, address[10:0], 4'b1111};
      assign instruction = {data_out_a[33:32], data_out_a[15:0]};
      assign data_in_a = {35'b00000000000000000000000000000000000, address[11]};
      assign jtag_dout = {data_out_b[33:32], data_out_b[15:0]};
      //
      if (C_JTAG_LOADER_ENABLE == 0) begin : no_loader
        assign data_in_b = {2'b00, data_out_b[33:32], 16'b0000000000000000, data_out_b[15:0]};
        assign address_b = 16'b1111111111111111;
        assign we_b = 8'b00000000;
        assign enable_b = 1'b0;
        assign rdl = 1'b0;
        assign clk_b = 1'b0;
      end // no_loader;
      //
      if (C_JTAG_LOADER_ENABLE == 1) begin : loader
        assign data_in_b = {2'b00, jtag_din[17:16], 16'b0000000000000000, jtag_din[15:0]};
        assign address_b = {1'b1, jtag_addr[10:0], 4'b1111};
        assign we_b = {jtag_we, jtag_we, jtag_we, jtag_we, jtag_we, jtag_we, jtag_we, jtag_we};
        assign enable_b = jtag_en[0];
        assign rdl = rdl_bus[0];
        assign clk_b = jtag_clk;
      end // loader;
      // 
      RAMB36E1 #(.READ_WIDTH_A              (18),
                 .WRITE_WIDTH_A             (18),
                 .DOA_REG                   (0),
                 .INIT_A                    (36'h000000000),
                 .RSTREG_PRIORITY_A         ("REGCE"),
                 .SRVAL_A                   (36'h000000000),
                 .WRITE_MODE_A              ("WRITE_FIRST"),
                 .READ_WIDTH_B              (18),
                 .WRITE_WIDTH_B             (18),
                 .DOB_REG                   (0),
                 .INIT_B                    (36'h000000000),
                 .RSTREG_PRIORITY_B         ("REGCE"),
                 .SRVAL_B                   (36'h000000000),
                 .WRITE_MODE_B              ("WRITE_FIRST"),
                 .INIT_FILE                 ("NONE"),
                 .SIM_COLLISION_CHECK       ("ALL"),
                 .RAM_MODE                  ("TDP"),
                 .RDADDR_COLLISION_HWCONFIG ("DELAYED_WRITE"),
                 .EN_ECC_READ               ("FALSE"),
                 .EN_ECC_WRITE              ("FALSE"),
                 .RAM_EXTENSION_A           ("NONE"),
                 .RAM_EXTENSION_B           ("NONE"),
                 .SIM_DEVICE                ("7SERIES"),
                 .INIT_00                   (256'h11001000D007D006D005D004D009D0081000B001020520052005200520052005),
                 .INIT_01                   (256'h18061900F035D101D0001300120011801000B012D343D242D141D04013001200),
                 .INIT_02                   (256'h039E03BE0224020960279401025A020F020914640205029C1D001C001B801A00),
                 .INIT_03                   (256'hF0321034F03610060328F0321014F03610020328F0321010F0361001031C02BC),
                 .INIT_04                   (256'h0328F0321024F0361082033EF0321020F03610810328F032101CF03610800328),
                 .INIT_05                   (256'h02EE0333F032102CF03610180333F0321028F03610100328F0321030F0361083),
                 .INIT_06                   (256'hF03610120349F0371004F0331015F03610110349F0371019F0331011F0361010),
                 .INIT_07                   (256'hF0331021F03610130349F0371002F033101DF03610140349F0371007F0331035),
                 .INIT_08                   (256'hF0371007F0331029F03610160349F0371002F0331025F03610150349F0371002),
                 .INIT_09                   (256'h1014016DF0341012F0331011F03210100349F0371002F033102DF03610170349),
                 .INIT_0A                   (256'h101DF032101C016DF0341036F0331035F0321034016DF0341016F0331015F032),
                 .INIT_0B                   (256'h1026F0331025F0321024016DF0341022F0331021F0321020016DF034101EF033),
                 .INIT_0C                   (256'h016DF034102EF033102DF032102C016DF034102AF0331029F0321028016DF034),
                 .INIT_0D                   (256'h60E1CAB0BB353A400AB0029C9C05DB01DA0002A51D0018061900202F016400D3),
                 .INIT_0E                   (256'h014C1A0AF00010DBF001101001481A0AF00010B9F0011010FA3503BEE1155000),
                 .INIT_0F                   (256'hF00010C3F001100E01991A0AF0001033F001100F01541A0AF00010ACF001100F),
                 .INIT_10                   (256'hF001100C01501A0AF00010CEF001100D015C1A0AF00010AEF001100D01581A0A),
                 .INIT_11                   (256'h103DF001100C01601A0AF000103DF001100CFA3503BE500001601A0AF00010F5),
                 .INIT_12                   (256'h100E01581A0AF00010AEF001100D015C1A0AF00010F5F001100C01501A0AF000),
                 .INIT_13                   (256'h1A0AF000108FF001101001541A0AF000101EF001100F01991A0AF0001067F001),
                 .INIT_14                   (256'h500001DC1B021C40500001DC1B021C24500001481A0AF00010D7F001100F014C),
                 .INIT_15                   (256'h500001DC1B021C5E500001DC1B021C26500001DC1B021C25500001DC1B021C44),
                 .INIT_16                   (256'hBF34BE33BD325000029C9A0FDB1002A51C001D0018031900500001DC1B021C5F),
                 .INIT_17                   (256'h15410D200E30027B06A007B002A508E0190004A005B002A508D0190050000172),
                 .INIT_18                   (256'h0BA01C001D002A2029100800027B06D007E0082009301A00027B060007101489),
                 .INIT_19                   (256'h01B51B021C8B500001DC1B021C21500001B51B011C205000029C08F019000A90),
                 .INIT_1A                   (256'h01DC1B021C39500001B51B021C39500001DC1B021C38500001B51B021C385000),
                 .INIT_1B                   (256'h05C061D80246023201F8450605A0021D02051E001300500001B51B021C8C5000),
                 .INIT_1C                   (256'h1301E53001F8022A024961D80246023201F8450705A0021D61D80246023201F8),
                 .INIT_1D                   (256'h021D02051E0013005000D301130102245000C5E00224E5300230024961CBC3B0),
                 .INIT_1E                   (256'h13010246023201F8A53061D80246023201F805C061D80246023201F8450605A0),
                 .INIT_1F                   (256'h4E077E03E201D1C04108C50001E010805000D50102240246023205E061EBC3B0),
                 .INIT_20                   (256'h5F015000025ADF202F0070FF10015000DF205F021F015000E1F9400E4E062202),
                 .INIT_21                   (256'h025A020F021A5000DF205F025000DF202F0070FF100250002211D0019004DF20),
                 .INIT_22                   (256'h500002090256020F025A02155000021A0256020F025A02155000020902560215),
                 .INIT_23                   (256'h0252020F025A021A22339000440E022B021A223802156237C5401480222B021A),
                 .INIT_24                   (256'h9001100B5000624A9401023C14085000D501023C5000020902524500D0029004),
                 .INIT_25                   (256'h110012002276107C110012002276107C110012002276107C110012005000624F),
                 .INIT_26                   (256'h118912092276104811E8120122761012117A12002276106A11181200227610FA),
                 .INIT_27                   (256'h4608470E12001300181050006276B200B100900122761010115E125F22761068),
                 .INIT_28                   (256'h100B3507400A400A400A00505000627E9801400841084208430823500240E283),
                 .INIT_29                   (256'hDB05DA04D909D80822969001450044061000D000629210014408450E2296D080),
                 .INIT_2A                   (256'hB004DA8050009D039C029B019A00B001B021D909D8085000B001B031DD07DC06),
                 .INIT_2B                   (256'h02B4180019101A40500062B8D001900EB014D881D982DA805000980C990D02B8),
                 .INIT_2C                   (256'h02B4180119471A4802B4180F19001A4602B41800190A1A4202B418F019001A41),
                 .INIT_2D                   (256'h02B4180119011A4B02B4180119471A4A02B4180F19001A4702B4180119011A49),
                 .INIT_2E                   (256'h19181A405000026A02B418F019201A4102B4180F19001A7902B4180119011A4F),
                 .INIT_2F                   (256'h19001A4902B4180119001A4802B4180019001A4602B418F019001A4102B41812),
                 .INIT_30                   (256'h19001A4F02B418FF19001A4B02B4180119001A4A02B4180019001A4702B418FF),
                 .INIT_31                   (256'h035B035402AE1A005000026A02B418F019201A4102B4180019001A7902B418FF),
                 .INIT_32                   (256'h0B301C001D00B8321900037702AEBA365000029C0A200B301C001D0018021900),
                 .INIT_33                   (256'h02AEBA365000029C0A200B301C001D00B8321900036502AEBA365000029C0A20),
                 .INIT_34                   (256'h0C200D30B8331900038002AEBA365000029C0A200B301C001D00B8321900036E),
                 .INIT_35                   (256'h027B16FE177D048005905000635690014808490E100604805000029C0A000B10),
                 .INIT_36                   (256'h04800590500033003200D180027B16D01707048005905000B301B210B1A69066),
                 .INIT_37                   (256'h500033003200D180027B16B8170B04800590500033003200D180027B16701717),
                 .INIT_38                   (256'hB83219005000027BB63717000420053033003200D180027B16E8170304800590),
                 .INIT_39                   (256'h180419005000029C1A071B071C001D00B83219005000029C1AB01B041C001D00),
                 .INIT_3A                   (256'hF300D20033034208430E4208430E03C002B0DD43DC42DB41DA403BFC1A0002A5),
                 .INIT_3B                   (256'h03C41D005000029C9D0B9C0A9B099A0818051900B012DC421C0023B6B00223B3),
                 .INIT_3C                   (256'h022490000246023205D090000246023245061574021D0205500003EA03DD1D04),
                 .INIT_3D                   (256'h1575021D02055000022402300D50024990000246023245071574021D02055000),
                 .INIT_3E                   (256'h0246023245071575021D02055000022490000246023205D09000024602324506),
                 .INIT_3F                   (256'h00000000000000000000000000000000000000005000022402300D5002499000),
                 .INIT_40                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_41                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_42                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_43                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_44                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_45                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_46                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_47                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_48                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_49                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_50                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_51                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_52                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_53                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_54                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_55                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_56                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_57                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_58                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_59                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_60                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_61                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_62                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_63                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_64                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_65                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_66                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_67                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_68                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_69                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_70                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_71                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_72                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_73                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_74                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_75                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_76                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_77                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_78                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_79                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7F                   (256'h0000000000000000000000000000000000000000000000000000000000009000),
                 .INITP_00                  (256'h88A222888A222888A88A2288A2288A2288A2288AAADA8A000A802AA00AAA2AAA),
                 .INITP_01                  (256'h88888888888888AED022A02AA222888A222888A222888A222888A222888A2228),
                 .INITP_02                  (256'h0208020A028A00A0A0A0A0A0A0A0A222222222222222222222222A8888888888),
                 .INITP_03                  (256'h4C408A8D6A3A8EA4A0829AAD6ABA92EA3A928282828282828282828001580080),
                 .INITP_04                  (256'h502D5808080808080808080B4B622A90AAB6AB0AAAAAAAAAAA8A02C22A0282D6),
                 .INITP_05                  (256'h080808080A808080808080808080808080B0AA82A802AAAAAA95DD5C454B5557),
                 .INITP_06                  (256'h9480252009480255802D50A000A280028A000A280028A000A8A8080808080808),
                 .INITP_07                  (256'h00000A8BA4AAE8E92AA2E92ABA3A4AA88A000A2B51542A820A000A000A005200),
                 .INITP_08                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_09                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0A                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0B                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0C                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0D                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0E                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0F                  (256'h0000000200000000000000000000000000000000000000000000000000000000))
     kcpsm6_rom( .ADDRARDADDR               (address_a),
                 .ENARDEN                   (enable),
                 .CLKARDCLK                 (clk),
                 .DOADO                     (data_out_a[31:0]),
                 .DOPADOP                   (data_out_a[35:32]), 
                 .DIADI                     (data_in_a[31:0]),
                 .DIPADIP                   (data_in_a[35:32]), 
                 .WEA                       (4'b0000),
                 .REGCEAREGCE               (1'b0),
                 .RSTRAMARSTRAM             (1'b0),
                 .RSTREGARSTREG             (1'b0),
                 .ADDRBWRADDR               (address_b),
                 .ENBWREN                   (enable_b),
                 .CLKBWRCLK                 (clk_b),
                 .DOBDO                     (data_out_b[31:0]),
                 .DOPBDOP                   (data_out_b[35:32]), 
                 .DIBDI                     (data_in_b[31:0]),
                 .DIPBDIP                   (data_in_b[35:32]), 
                 .WEBWE                     (we_b),
                 .REGCEB                    (1'b0),
                 .RSTRAMB                   (1'b0),
                 .RSTREGB                   (1'b0),
                 .CASCADEINA                (1'b0),
                 .CASCADEINB                (1'b0),
                 .CASCADEOUTA               (),
                 .CASCADEOUTB               (),
                 .DBITERR                   (),
                 .ECCPARITY                 (),
                 .RDADDRECC                 (),
                 .SBITERR                   (),
                 .INJECTDBITERR             (1'b0),       
                 .INJECTSBITERR             (1'b0));   
    end // akv7;  
    // 
  end // ram_2k_generate;
endgenerate              
//
generate
  if (C_RAM_SIZE_KWORDS == 4) begin : ram_4k_generate 
    if (C_FAMILY == "S6") begin: s6 
      //
      assign address_a[13:0] = {address[10:0], 3'b000};
      assign data_in_a = 36'b000000000000000000000000000000000000;
      //
      FD s6_a11_flop ( .D      (address[11]),
                       .Q      (pipe_a11),
                       .C      (clk));
      //
      LUT6_2 # (       .INIT   (64'hFF00F0F0CCCCAAAA))
       s6_4k_mux0_lut( .I0     (data_out_a_ll[0]),
                       .I1     (data_out_a_hl[0]),
                       .I2     (data_out_a_ll[1]),
                       .I3     (data_out_a_hl[1]),
                       .I4     (pipe_a11),
                       .I5     (1'b1),
                       .O5     (instruction[0]),
                       .O6     (instruction[1]));
      //
      LUT6_2 # (       .INIT   (64'hFF00F0F0CCCCAAAA))
       s6_4k_mux2_lut( .I0     (data_out_a_ll[2]),
                       .I1     (data_out_a_hl[2]),
                       .I2     (data_out_a_ll[3]),
                       .I3     (data_out_a_hl[3]),
                       .I4     (pipe_a11),
                       .I5     (1'b1),
                       .O5     (instruction[2]),
                       .O6     (instruction[3]));
      //
      LUT6_2 # (       .INIT   (64'hFF00F0F0CCCCAAAA))
       s6_4k_mux4_lut( .I0     (data_out_a_ll[4]),
                       .I1     (data_out_a_hl[4]),
                       .I2     (data_out_a_ll[5]),
                       .I3     (data_out_a_hl[5]),
                       .I4     (pipe_a11),
                       .I5     (1'b1),
                       .O5     (instruction[4]),
                       .O6     (instruction[5]));
      //
      LUT6_2 # (       .INIT   (64'hFF00F0F0CCCCAAAA))
       s6_4k_mux6_lut( .I0     (data_out_a_ll[6]),
                       .I1     (data_out_a_hl[6]),
                       .I2     (data_out_a_ll[7]),
                       .I3     (data_out_a_hl[7]),
                       .I4     (pipe_a11),
                       .I5     (1'b1),
                       .O5     (instruction[6]),
                       .O6     (instruction[7]));
      //
      LUT6_2 # (       .INIT   (64'hFF00F0F0CCCCAAAA))
       s6_4k_mux8_lut( .I0     (data_out_a_ll[32]),
                       .I1     (data_out_a_hl[32]),
                       .I2     (data_out_a_lh[0]),
                       .I3     (data_out_a_hh[0]),
                       .I4     (pipe_a11),
                       .I5     (1'b1),
                       .O5     (instruction[8]),
                       .O6     (instruction[9]));
      //
      LUT6_2 # (       .INIT   (64'hFF00F0F0CCCCAAAA))
      s6_4k_mux10_lut( .I0     (data_out_a_lh[1]),
                       .I1     (data_out_a_hh[1]),
                       .I2     (data_out_a_lh[2]),
                       .I3     (data_out_a_hh[2]),
                       .I4     (pipe_a11),
                       .I5     (1'b1),
                       .O5     (instruction[10]),
                       .O6     (instruction[11]));
      //
      LUT6_2 # (       .INIT   (64'hFF00F0F0CCCCAAAA))
      s6_4k_mux12_lut( .I0     (data_out_a_lh[3]),
                       .I1     (data_out_a_hh[3]),
                       .I2     (data_out_a_lh[4]),
                       .I3     (data_out_a_hh[4]),
                       .I4     (pipe_a11),
                       .I5     (1'b1),
                       .O5     (instruction[12]),
                       .O6     (instruction[13]));
      //
      LUT6_2 # (       .INIT   (64'hFF00F0F0CCCCAAAA))
      s6_4k_mux14_lut( .I0     (data_out_a_lh[5]),
                       .I1     (data_out_a_hh[5]),
                       .I2     (data_out_a_lh[6]),
                       .I3     (data_out_a_hh[6]),
                       .I4     (pipe_a11),
                       .I5     (1'b1),
                       .O5     (instruction[14]),
                       .O6     (instruction[15]));
      //
      LUT6_2 # (       .INIT   (64'hFF00F0F0CCCCAAAA))
      s6_4k_mux16_lut( .I0     (data_out_a_lh[7]),
                       .I1     (data_out_a_hh[7]),
                       .I2     (data_out_a_lh[32]),
                       .I3     (data_out_a_hh[32]),
                       .I4     (pipe_a11),
                       .I5     (1'b1),
                       .O5     (instruction[16]),
                       .O6     (instruction[17]));
      //
      if (C_JTAG_LOADER_ENABLE == 0) begin : no_loader
        assign data_in_b_ll = {3'b000, data_out_b_ll[32], 24'b000000000000000000000000, data_out_b_ll[7:0]};
        assign data_in_b_lh = {3'b000, data_out_b_lh[32], 24'b000000000000000000000000, data_out_b_lh[7:0]};
        assign data_in_b_hl = {3'b000, data_out_b_hl[32], 24'b000000000000000000000000, data_out_b_hl[7:0]};
        assign data_in_b_hh = {3'b000, data_out_b_hh[32], 24'b000000000000000000000000, data_out_b_hh[7:0]};
        assign address_b[13:0] = 14'b00000000000000;
        assign we_b_l[3:0] = 4'b0000;
        assign we_b_h[3:0] = 4'b0000;
        assign enable_b = 1'b0;
        assign rdl = 1'b0;
        assign clk_b = 1'b0;
        assign jtag_dout = {data_out_b_h[32], data_out_b_h[7:0], data_out_b_l[32], data_out_b_l[7:0]};
      end // no_loader;
      //
      if (C_JTAG_LOADER_ENABLE == 1) begin : loader
        assign data_in_b_lh = {3'b000, jtag_din[17], 24'b000000000000000000000000, jtag_din[16:9]};
        assign data_in_b_ll = {3'b000, jtag_din[8],  24'b000000000000000000000000, jtag_din[7:0]};
        assign data_in_b_hh = {3'b000, jtag_din[17], 24'b000000000000000000000000, jtag_din[16:9]};
        assign data_in_b_hl = {3'b000, jtag_din[8],  24'b000000000000000000000000, jtag_din[7:0]};
        assign address_b[13:0] = {jtag_addr[10:0], 3'b000};
        //
        LUT6_2 # (         .INIT   (64'h8000000020000000))
        s6_4k_jtag_we_lut( .I0     (jtag_we),
                           .I1     (jtag_addr[11]),
                           .I2     (1'b1),
                           .I3     (1'b1),
                           .I4     (1'b1),
                           .I5     (1'b1),
                           .O5     (jtag_we_l),
                           .O6     (jtag_we_h));
        //
        assign we_b_l[3:0] = {jtag_we_l, jtag_we_l, jtag_we_l, jtag_we_l};
        assign we_b_h[3:0] = {jtag_we_h, jtag_we_h, jtag_we_h, jtag_we_h};
        //
        assign enable_b = jtag_en[0];
        assign rdl = rdl_bus[0];
        assign clk_b = jtag_clk;
        //
        LUT6_2 # (            .INIT   (64'hFF00F0F0CCCCAAAA))
         s6_4k_jtag_mux0_lut( .I0     (data_out_b_ll[0]),
                              .I1     (data_out_b_hl[0]),
                              .I2     (data_out_b_ll[1]),
                              .I3     (data_out_b_hl[1]),
                              .I4     (jtag_addr[11]),
                              .I5     (1'b1),
                              .O5     (jtag_dout[0]),
                              .O6     (jtag_dout[1]));
        //
        LUT6_2 # (            .INIT   (64'hFF00F0F0CCCCAAAA))
         s6_4k_jtag_mux2_lut( .I0     (data_out_b_ll[2]),
                              .I1     (data_out_b_hl[2]),
                              .I2     (data_out_b_ll[3]),
                              .I3     (data_out_b_hl[3]),
                              .I4     (jtag_addr[11]),
                              .I5     (1'b1),
                              .O5     (jtag_dout[2]),
                              .O6     (jtag_dout[3]));
        //
        LUT6_2 # (            .INIT   (64'hFF00F0F0CCCCAAAA))
         s6_4k_jtag_mux4_lut( .I0     (data_out_b_ll[4]),
                              .I1     (data_out_b_hl[4]),
                              .I2     (data_out_b_ll[5]),
                              .I3     (data_out_b_hl[5]),
                              .I4     (jtag_addr[11]),
                              .I5     (1'b1),
                              .O5     (jtag_dout[4]),
                              .O6     (jtag_dout[5]));
        //
        LUT6_2 # (            .INIT   (64'hFF00F0F0CCCCAAAA))
         s6_4k_jtag_mux6_lut( .I0     (data_out_b_ll[6]),
                              .I1     (data_out_b_hl[6]),
                              .I2     (data_out_b_ll[7]),
                              .I3     (data_out_b_hl[7]),
                              .I4     (jtag_addr[11]),
                              .I5     (1'b1),
                              .O5     (jtag_dout[6]),
                              .O6     (jtag_dout[7]));
        //
        LUT6_2 # (            .INIT   (64'hFF00F0F0CCCCAAAA))
         s6_4k_jtag_mux8_lut( .I0     (data_out_b_ll[32]),
                              .I1     (data_out_b_hl[32]),
                              .I2     (data_out_b_lh[0]),
                              .I3     (data_out_b_hh[0]),
                              .I4     (jtag_addr[11]),
                              .I5     (1'b1),
                              .O5     (jtag_dout[8]),
                              .O6     (jtag_dout[9]));
        //
        LUT6_2 # (            .INIT   (64'hFF00F0F0CCCCAAAA))
        s6_4k_jtag_mux10_lut( .I0     (data_out_b_lh[1]),
                              .I1     (data_out_b_hh[1]),
                              .I2     (data_out_b_lh[2]),
                              .I3     (data_out_b_hh[2]),
                              .I4     (jtag_addr[11]),
                              .I5     (1'b1),
                              .O5     (jtag_dout[10]),
                              .O6     (jtag_dout[11]));
        //
        LUT6_2 # (            .INIT   (64'hFF00F0F0CCCCAAAA))
        s6_4k_jtag_mux12_lut( .I0     (data_out_b_lh[3]),
                              .I1     (data_out_b_hh[3]),
                              .I2     (data_out_b_lh[4]),
                              .I3     (data_out_b_hh[4]),
                              .I4     (jtag_addr[11]),
                              .I5     (1'b1),
                              .O5     (jtag_dout[12]),
                              .O6     (jtag_dout[13]));
        //
        LUT6_2 # (            .INIT   (64'hFF00F0F0CCCCAAAA))
        s6_4k_jtag_mux14_lut( .I0     (data_out_b_lh[5]),
                              .I1     (data_out_b_hh[5]),
                              .I2     (data_out_b_lh[6]),
                              .I3     (data_out_b_hh[6]),
                              .I4     (jtag_addr[11]),
                              .I5     (1'b1),
                              .O5     (jtag_dout[14]),
                              .O6     (jtag_dout[15]));
        //
        LUT6_2 # (            .INIT   (64'hFF00F0F0CCCCAAAA))
        s6_4k_jtag_mux16_lut( .I0     (data_out_b_lh[7]),
                              .I1     (data_out_b_hh[7]),
                              .I2     (data_out_b_lh[32]),
                              .I3     (data_out_b_hh[32]),
                              .I4     (jtag_addr[11]),
                              .I5     (1'b1),
                              .O5     (jtag_dout[16]),
                              .O6     (jtag_dout[17]));
        //
      end // loader;
      // 
      RAMB16BWER #(.DATA_WIDTH_A        (9),
                   .DOA_REG             (0),
                   .EN_RSTRAM_A         ("FALSE"),
                   .INIT_A              (9'b000000000),
                   .RST_PRIORITY_A      ("CE"),
                   .SRVAL_A             (9'b000000000),
                   .WRITE_MODE_A        ("WRITE_FIRST"),
                   .DATA_WIDTH_B        (9),
                   .DOB_REG             (0),
                   .EN_RSTRAM_B         ("FALSE"),
                   .INIT_B              (9'b000000000),
                   .RST_PRIORITY_B      ("CE"),
                   .SRVAL_B             (9'b000000000),
                   .WRITE_MODE_B        ("WRITE_FIRST"),
                   .RSTTYPE             ("SYNC"),
                   .INIT_FILE           ("NONE"),
                   .SIM_COLLISION_CHECK ("ALL"),
                   .SIM_DEVICE          ("SPARTAN6"),
                   .INIT_00             (256'h0600350100000080001243424140000000000706050409080001050505050505),
                   .INIT_01             (256'h32343606283214360228321036011CBC9EBE240927015A0F0964059C00008000),
                   .INIT_02             (256'hEE33322C36183332283610283230368328322436823E3220368128321C368028),
                   .INIT_03             (256'h33213613493702331D3614493707333536124937043315361149371933113610),
                   .INIT_04             (256'h146D341233113210493702332D36174937073329361649370233253615493702),
                   .INIT_05             (256'h26332532246D3422332132206D341E331D321C6D3436333532346D3416331532),
                   .INIT_06             (256'hE1B03540B09C050100A50006002F64D36D342E332D322C6D342A332932286D34),
                   .INIT_07             (256'h00C3010E990A0033010F540A00AC010F4C0A00DB0110480A00B9011035BE1500),
                   .INIT_08             (256'h3D010C600A003D010C35BE00600A00F5010C500A00CE010D5C0A00AE010D580A),
                   .INIT_09             (256'h0A008F0110540A001E010F990A0067010E580A00AE010D5C0A00F5010C500A00),
                   .INIT_0A             (256'h00DC025E00DC022600DC022500DC024400DC024000DC022400480A00D7010F4C),
                   .INIT_0B             (256'h4120307BA0B0A5E000A0B0A5D0000072343332009C0F10A50000030000DC025F),
                   .INIT_0C             (256'hB5028B00DC022100B50120009CF00090A000002010007BD0E02030007B001089),
                   .INIT_0D             (256'hC0D84632F806A01D05000000B5028C00DC023900B5023900DC023800B5023800),
                   .INIT_0E             (256'h1D0500000001012400E024303049CBB00130F82A49D84632F807A01DD84632F8),
                   .INIT_0F             (256'h070301C00800E0800001244632E0EBB0014632F830D84632F8C0D84632F806A0),
                   .INIT_10             (256'h5A0F1A002002002000FF02001101042001005A2000FF010020020100F90E0602),
                   .INIT_11             (256'h520F5A1A33000E2B1A38153740802B1A0009560F5A15001A560F5A1500095615),
                   .INIT_12             (256'h0000767C0000767C0000767C0000004F010B004A013C0800013C000952000204),
                   .INIT_13             (256'h080E000010007600000176105E5F766889097648E80176127A00766A180076FA),
                   .INIT_14             (256'h050409089601000600009201080E96800B070A0A0A50007E0108080808504083),
                   .INIT_15             (256'hB400104000B8010E14818280000C0DB804800003020100012109080001310706),
                   .INIT_16             (256'hB401014BB401474AB40F0047B4010149B4014748B40F0046B4000A42B4F00041),
                   .INIT_17             (256'h0049B4010048B4000046B4F00041B4121840006AB4F02041B40F0079B401014F),
                   .INIT_18             (256'h5B54AE00006AB4F02041B4000079B4FF004FB4FF004BB401004AB4000047B4FF),
                   .INIT_19             (256'hAE36009C20300000320065AE36009C20300000320077AE36009C203000000200),
                   .INIT_1A             (256'h7BFE7D8090005601080E0680009C00102030330080AE36009C2030000032006E),
                   .INIT_1B             (256'h000000807BB80B8090000000807B70178090000000807BD0078090000110A666),
                   .INIT_1C             (256'h0400009C070700003200009CB00400003200007B370020300000807BE8038090),
                   .INIT_1D             (256'hC400009C0B0A09080500124200B602B3000003080E080EC0B043424140FC00A5),
                   .INIT_1E             (256'h751D05002430504900463207741D050024004632D000463206741D0500EADD04),
                   .INIT_1F             (256'h00000000000000000000002430504900463207751D050024004632D000463206),
                   .INIT_20             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_21             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_22             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_23             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_24             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_25             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_26             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_27             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_28             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_29             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_2A             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_2B             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_2C             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_2D             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_2E             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_2F             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_30             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_31             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_32             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_33             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_34             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_35             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_36             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_37             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_38             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_39             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_3A             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_3B             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_3C             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_3D             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_3E             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_3F             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INITP_00            (256'h08208206212A8102040810204081020408102040421084210842C00A552A8000),
                   .INITP_01            (256'h1E479CE71653E4E9CE2CCCCCCCC2A8A2C4A5A256666666410410410410282082),
                   .INITP_02            (256'h888882222222222220221442A204402C5088888888880084000800000D8198E8),
                   .INITP_03            (256'h00043011821808C7CA45AB54454545A552A954AA2A41582B0560AC15C0888888),
                   .INITP_04            (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INITP_05            (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INITP_06            (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INITP_07            (256'h0000000000000000000000000000000000000000000000000000000000000000))
    kcpsm6_rom_ll( .ADDRA               (address_a[13:0]),
                   .ENA                 (enable),
                   .CLKA                (clk),
                   .DOA                 (data_out_a_ll[31:0]),
                   .DOPA                (data_out_a_ll[35:32]), 
                   .DIA                 (data_in_a[31:0]),
                   .DIPA                (data_in_a[35:32]), 
                   .WEA                 (4'b0000),
                   .REGCEA              (1'b0),
                   .RSTA                (1'b0),
                   .ADDRB               (address_b[13:0]),
                   .ENB                 (enable_b),
                   .CLKB                (clk_b),
                   .DOB                 (data_out_b_ll[31:0]),
                   .DOPB                (data_out_b_ll[35:32]), 
                   .DIB                 (data_in_b_ll[31:0]),
                   .DIPB                (data_in_b_ll[35:32]), 
                   .WEB                 (we_b_l[3:0]),
                   .REGCEB              (1'b0),
                   .RSTB                (1'b0));
      // 
      RAMB16BWER #(.DATA_WIDTH_A        (9),
                   .DOA_REG             (0),
                   .EN_RSTRAM_A         ("FALSE"),
                   .INIT_A              (9'b000000000),
                   .RST_PRIORITY_A      ("CE"),
                   .SRVAL_A             (9'b000000000),
                   .WRITE_MODE_A        ("WRITE_FIRST"),
                   .DATA_WIDTH_B        (9),
                   .DOB_REG             (0),
                   .EN_RSTRAM_B         ("FALSE"),
                   .INIT_B              (9'b000000000),
                   .RST_PRIORITY_B      ("CE"),
                   .SRVAL_B             (9'b000000000),
                   .WRITE_MODE_B        ("WRITE_FIRST"),
                   .RSTTYPE             ("SYNC"),
                   .INIT_FILE           ("NONE"),
                   .SIM_COLLISION_CHECK ("ALL"),
                   .SIM_DEVICE          ("SPARTAN6"),
                   .INIT_00             (256'h0C0C786868090908085869696868090908086868686868680858011010101010),
                   .INIT_01             (256'h7808780801780878080178087808010101010101B0CA0101010A01010E0E0D0D),
                   .INIT_02             (256'h0101780878080178087808017808780801780878080178087808017808780801),
                   .INIT_03             (256'h7808780801780878087808017808780878080178087808780801780878087808),
                   .INIT_04             (256'h0800780878087808017808780878080178087808780801780878087808017808),
                   .INIT_05             (256'h0878087808007808780878080078087808780800780878087808007808780878),
                   .INIT_06             (256'hB0E55D1D05014E6D6D010E0C0C10000000780878087808007808780878080078),
                   .INIT_07             (256'h78087808000D78087808000D78087808000D78087808000D780878087D01F028),
                   .INIT_08             (256'h087808000D780878087D0128000D78087808000D78087808000D78087808000D),
                   .INIT_09             (256'h0D78087808000D78087808000D78087808000D78087808000D78087808000D78),
                   .INIT_0A             (256'h28000D0E28000D0E28000D0E28000D0E28000D0E28000D0E28000D7808780800),
                   .INIT_0B             (256'h0A060701030301040C020201040C28005F5F5E28014D6D010E0E0C0C28000D0E),
                   .INIT_0C             (256'h000D0E28000D0E28000D0E2801040C05050E0E95948401030304040D0103030A),
                   .INIT_0D             (256'h02B0010100A20201010F0928000D0E28000D0E28000D0E28000D0E28000D0E28),
                   .INIT_0E             (256'h01010F092869090128E201720101B0E18972000101B0010100A20201B0010100),
                   .INIT_0F             (256'hA73FF168A0620008286A01010102B0E18901010052B001010002B0010100A202),
                   .INIT_10             (256'h010101286F2F286F173808289168486F2F28016F173808286F2F0F28F0A0A711),
                   .INIT_11             (256'h0101010111C8A201011101B1620A110128010101010128010101010128010101),
                   .INIT_12             (256'h080911080809110808091108080928B1C80828B1CA010A286A01280101A26848),
                   .INIT_13             (256'hA3A309090C28B1D9D8C811080809110808091108080911080809110808091108),
                   .INIT_14             (256'h6D6D6C6C11C8A2A288E8B188A2A29168881AA0A0A00028B1CCA0A0A1A19181F1),
                   .INIT_15             (256'h010C0C0D28B16848586C6C6D284C4C01586D284E4E4D4D58586C6C2858586E6E),
                   .INIT_16             (256'h010C0C0D010C0C0D010C0C0D010C0C0D010C0C0D010C0C0D010C0C0D010C0C0D),
                   .INIT_17             (256'h0C0D010C0C0D010C0C0D010C0C0D010C0C0D2801010C0C0D010C0C0D010C0C0D),
                   .INIT_18             (256'h0101010D2801010C0C0D010C0C0D010C0C0D010C0C0D010C0C0D010C0C0D010C),
                   .INIT_19             (256'h015D280105050E0E5C0C01015D280105050E0E5C0C01015D280105050E0E0C0C),
                   .INIT_1A             (256'h010B0B020228B1C8A4A408022801050506065C0C01015D280105050E0E5C0C01),
                   .INIT_1B             (256'h28999968010B0B020228999968010B0B020228999968010B0B020228D9D9D8C8),
                   .INIT_1C             (256'h0C0C28010D0D0E0E5C0C28010D0D0E0E5C0C28015B0B0202999968010B0B0202),
                   .INIT_1D             (256'h010E28014E4E4D4D0C0C586E0E115891F9E919A1A1A1A101016E6E6D6D1D0D01),
                   .INIT_1E             (256'h0A01012801010601C80101A20A01012801C8010102C80101A20A01012801010E),
                   .INIT_1F             (256'h000000000000000000002801010601C80101A20A01012801C8010102C80101A2),
                   .INIT_20             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_21             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_22             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_23             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_24             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_25             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_26             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_27             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_28             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_29             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_2A             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_2B             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_2C             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_2D             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_2E             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_2F             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_30             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_31             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_32             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_33             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_34             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_35             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_36             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_37             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_38             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_39             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_3A             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_3B             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_3C             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_3D             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_3E             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_3F             (256'h0000000000000000000000000000004800000000000000000000000000000000),
                   .INITP_00            (256'hAAAAAAAF85C7D5AB56AD5AB56AD5AB56AD5AB56AEB5AD6B5AD6BFBB0387C3F7F),
                   .INITP_01            (256'h20BA77BCC9BE7F9F799999999998020812131B0CCCCCCCD555555555557AAAAA),
                   .INITP_02            (256'h22223888888888888CF9E1FFF8A203010622222222233578FDF3FFFFFB197199),
                   .INITP_03            (256'h003BCFEE7DE7F73EB03700793030301088442210860C0D81B03606C0EE222222),
                   .INITP_04            (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INITP_05            (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INITP_06            (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INITP_07            (256'h0001000000000000000000000000000000000000000000000000000000000000))
    kcpsm6_rom_lh( .ADDRA               (address_a[13:0]),
                   .ENA                 (enable),
                   .CLKA                (clk),
                   .DOA                 (data_out_a_lh[31:0]),
                   .DOPA                (data_out_a_lh[35:32]), 
                   .DIA                 (data_in_a[31:0]),
                   .DIPA                (data_in_a[35:32]), 
                   .WEA                 (4'b0000),
                   .REGCEA              (1'b0),
                   .RSTA                (1'b0),
                   .ADDRB               (address_b[13:0]),
                   .ENB                 (enable_b),
                   .CLKB                (clk_b),
                   .DOB                 (data_out_b_lh[31:0]),
                   .DOPB                (data_out_b_lh[35:32]), 
                   .DIB                 (data_in_b_lh[31:0]),
                   .DIPB                (data_in_b_lh[35:32]), 
                   .WEB                 (we_b_l[3:0]),
                   .REGCEB              (1'b0),
                   .RSTB                (1'b0));
      // 
      RAMB16BWER #(.DATA_WIDTH_A        (9),
                   .DOA_REG             (0),
                   .EN_RSTRAM_A         ("FALSE"),
                   .INIT_A              (9'b000000000),
                   .RST_PRIORITY_A      ("CE"),
                   .SRVAL_A             (9'b000000000),
                   .WRITE_MODE_A        ("WRITE_FIRST"),
                   .DATA_WIDTH_B        (9),
                   .DOB_REG             (0),
                   .EN_RSTRAM_B         ("FALSE"),
                   .INIT_B              (9'b000000000),
                   .RST_PRIORITY_B      ("CE"),
                   .SRVAL_B             (9'b000000000),
                   .WRITE_MODE_B        ("WRITE_FIRST"),
                   .RSTTYPE             ("SYNC"),
                   .INIT_FILE           ("NONE"),
                   .SIM_COLLISION_CHECK ("ALL"),
                   .SIM_DEVICE          ("SPARTAN6"),
                   .INIT_00             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_01             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_02             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_03             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_04             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_05             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_06             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_07             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_08             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_09             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_0A             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_0B             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_0C             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_0D             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_0E             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_0F             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_10             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_11             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_12             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_13             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_14             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_15             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_16             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_17             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_18             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_19             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_1A             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_1B             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_1C             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_1D             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_1E             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_1F             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_20             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_21             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_22             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_23             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_24             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_25             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_26             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_27             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_28             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_29             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_2A             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_2B             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_2C             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_2D             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_2E             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_2F             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_30             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_31             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_32             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_33             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_34             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_35             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_36             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_37             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_38             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_39             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_3A             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_3B             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_3C             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_3D             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_3E             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_3F             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INITP_00            (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INITP_01            (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INITP_02            (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INITP_03            (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INITP_04            (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INITP_05            (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INITP_06            (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INITP_07            (256'h0000000000000000000000000000000000000000000000000000000000000000))
    kcpsm6_rom_hl( .ADDRA               (address_a[13:0]),
                   .ENA                 (enable),
                   .CLKA                (clk),
                   .DOA                 (data_out_a_hl[31:0]),
                   .DOPA                (data_out_a_hl[35:32]), 
                   .DIA                 (data_in_a[31:0]),
                   .DIPA                (data_in_a[35:32]), 
                   .WEA                 (4'b0000),
                   .REGCEA              (1'b0),
                   .RSTA                (1'b0),
                   .ADDRB               (address_b[13:0]),
                   .ENB                 (enable_b),
                   .CLKB                (clk_b),
                   .DOB                 (data_out_b_hl[31:0]),
                   .DOPB                (data_out_b_hl[35:32]), 
                   .DIB                 (data_in_b_hl[31:0]),
                   .DIPB                (data_in_b_hl[35:32]), 
                   .WEB                 (we_b_h[3:0]),
                   .REGCEB              (1'b0),
                   .RSTB                (1'b0));
      // 
      RAMB16BWER #(.DATA_WIDTH_A        (9),
                   .DOA_REG             (0),
                   .EN_RSTRAM_A         ("FALSE"),
                   .INIT_A              (9'b000000000),
                   .RST_PRIORITY_A      ("CE"),
                   .SRVAL_A             (9'b000000000),
                   .WRITE_MODE_A        ("WRITE_FIRST"),
                   .DATA_WIDTH_B        (9),
                   .DOB_REG             (0),
                   .EN_RSTRAM_B         ("FALSE"),
                   .INIT_B              (9'b000000000),
                   .RST_PRIORITY_B      ("CE"),
                   .SRVAL_B             (9'b000000000),
                   .WRITE_MODE_B        ("WRITE_FIRST"),
                   .RSTTYPE             ("SYNC"),
                   .INIT_FILE           ("NONE"),
                   .SIM_COLLISION_CHECK ("ALL"),
                   .SIM_DEVICE          ("SPARTAN6"),
                   .INIT_00             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_01             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_02             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_03             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_04             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_05             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_06             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_07             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_08             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_09             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_0A             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_0B             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_0C             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_0D             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_0E             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_0F             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_10             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_11             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_12             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_13             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_14             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_15             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_16             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_17             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_18             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_19             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_1A             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_1B             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_1C             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_1D             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_1E             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_1F             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_20             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_21             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_22             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_23             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_24             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_25             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_26             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_27             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_28             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_29             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_2A             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_2B             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_2C             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_2D             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_2E             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_2F             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_30             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_31             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_32             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_33             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_34             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_35             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_36             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_37             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_38             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_39             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_3A             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_3B             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_3C             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_3D             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_3E             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INIT_3F             (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INITP_00            (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INITP_01            (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INITP_02            (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INITP_03            (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INITP_04            (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INITP_05            (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INITP_06            (256'h0000000000000000000000000000000000000000000000000000000000000000),
                   .INITP_07            (256'h0000000000000000000000000000000000000000000000000000000000000000))
    kcpsm6_rom_hh( .ADDRA               (address_a[13:0]),
                   .ENA                 (enable),
                   .CLKA                (clk),
                   .DOA                 (data_out_a_hh[31:0]),
                   .DOPA                (data_out_a_hh[35:32]), 
                   .DIA                 (data_in_a[31:0]),
                   .DIPA                (data_in_a[35:32]), 
                   .WEA                 (4'b0000),
                   .REGCEA              (1'b0),
                   .RSTA                (1'b0),
                   .ADDRB               (address_b[13:0]),
                   .ENB                 (enable_b),
                   .CLKB                (clk_b),
                   .DOB                 (data_out_b_hh[31:0]),
                   .DOPB                (data_out_b_hh[35:32]), 
                   .DIB                 (data_in_b_hh[31:0]),
                   .DIPB                (data_in_b_hh[35:32]), 
                   .WEB                 (we_b_h[3:0]),
                   .REGCEB              (1'b0),
                   .RSTB                (1'b0));
      //
    end // s6;
    //
    //
    if (C_FAMILY == "V6") begin: v6 
      //
      assign address_a = {1'b1, address[11:0], 3'b111};
      assign instruction = {data_out_a_h[32], data_out_a_h[7:0], data_out_a_l[32], data_out_a_l[7:0]};
      assign data_in_a = 36'b00000000000000000000000000000000000;
      assign jtag_dout = {data_out_b_h[32], data_out_b_h[7:0], data_out_b_l[32], data_out_b_l[7:0]};
      //
      if (C_JTAG_LOADER_ENABLE == 0) begin : no_loader
        assign data_in_b_l = {3'b000, data_out_b_l[32], 24'b000000000000000000000000, data_out_b_l[7:0]};
        assign data_in_b_h = {3'b000, data_out_b_h[32], 24'b000000000000000000000000, data_out_b_h[7:0]};
        assign address_b = 16'b1111111111111111;
        assign we_b = 8'b00000000;
        assign enable_b = 1'b0;
        assign rdl = 1'b0;
        assign clk_b = 1'b0;
      end // no_loader;
      //
      if (C_JTAG_LOADER_ENABLE == 1) begin : loader
        assign data_in_b_h = {3'b000, jtag_din[17], 24'b000000000000000000000000, jtag_din[16:9]};
        assign data_in_b_l = {3'b000, jtag_din[8],  24'b000000000000000000000000, jtag_din[7:0]};
        assign address_b = {1'b1, jtag_addr[11:0], 3'b111};
        assign we_b = {jtag_we, jtag_we, jtag_we, jtag_we, jtag_we, jtag_we, jtag_we, jtag_we};
        assign enable_b = jtag_en[0];
        assign rdl = rdl_bus[0];
        assign clk_b = jtag_clk;
      end // loader;
      // 
      RAMB36E1 #(.READ_WIDTH_A              (9),
                 .WRITE_WIDTH_A             (9),
                 .DOA_REG                   (0),
                 .INIT_A                    (36'h000000000),
                 .RSTREG_PRIORITY_A         ("REGCE"),
                 .SRVAL_A                   (36'h000000000),
                 .WRITE_MODE_A              ("WRITE_FIRST"),
                 .READ_WIDTH_B              (9),
                 .WRITE_WIDTH_B             (9),
                 .DOB_REG                   (0),
                 .INIT_B                    (36'h000000000),
                 .RSTREG_PRIORITY_B         ("REGCE"),
                 .SRVAL_B                   (36'h000000000),
                 .WRITE_MODE_B              ("WRITE_FIRST"),
                 .INIT_FILE                 ("NONE"),
                 .SIM_COLLISION_CHECK       ("ALL"),
                 .RAM_MODE                  ("TDP"),
                 .RDADDR_COLLISION_HWCONFIG ("DELAYED_WRITE"),
                 .EN_ECC_READ               ("FALSE"),
                 .EN_ECC_WRITE              ("FALSE"),
                 .RAM_EXTENSION_A           ("NONE"),
                 .RAM_EXTENSION_B           ("NONE"),
                 .SIM_DEVICE                ("VIRTEX6"),
                 .INIT_00                   (256'h0600350100000080001243424140000000000706050409080001050505050505),
                 .INIT_01                   (256'h32343606283214360228321036011CBC9EBE240927015A0F0964059C00008000),
                 .INIT_02                   (256'hEE33322C36183332283610283230368328322436823E3220368128321C368028),
                 .INIT_03                   (256'h33213613493702331D3614493707333536124937043315361149371933113610),
                 .INIT_04                   (256'h146D341233113210493702332D36174937073329361649370233253615493702),
                 .INIT_05                   (256'h26332532246D3422332132206D341E331D321C6D3436333532346D3416331532),
                 .INIT_06                   (256'hE1B03540B09C050100A50006002F64D36D342E332D322C6D342A332932286D34),
                 .INIT_07                   (256'h00C3010E990A0033010F540A00AC010F4C0A00DB0110480A00B9011035BE1500),
                 .INIT_08                   (256'h3D010C600A003D010C35BE00600A00F5010C500A00CE010D5C0A00AE010D580A),
                 .INIT_09                   (256'h0A008F0110540A001E010F990A0067010E580A00AE010D5C0A00F5010C500A00),
                 .INIT_0A                   (256'h00DC025E00DC022600DC022500DC024400DC024000DC022400480A00D7010F4C),
                 .INIT_0B                   (256'h4120307BA0B0A5E000A0B0A5D0000072343332009C0F10A50000030000DC025F),
                 .INIT_0C                   (256'hB5028B00DC022100B50120009CF00090A000002010007BD0E02030007B001089),
                 .INIT_0D                   (256'hC0D84632F806A01D05000000B5028C00DC023900B5023900DC023800B5023800),
                 .INIT_0E                   (256'h1D0500000001012400E024303049CBB00130F82A49D84632F807A01DD84632F8),
                 .INIT_0F                   (256'h070301C00800E0800001244632E0EBB0014632F830D84632F8C0D84632F806A0),
                 .INIT_10                   (256'h5A0F1A002002002000FF02001101042001005A2000FF010020020100F90E0602),
                 .INIT_11                   (256'h520F5A1A33000E2B1A38153740802B1A0009560F5A15001A560F5A1500095615),
                 .INIT_12                   (256'h0000767C0000767C0000767C0000004F010B004A013C0800013C000952000204),
                 .INIT_13                   (256'h080E000010007600000176105E5F766889097648E80176127A00766A180076FA),
                 .INIT_14                   (256'h050409089601000600009201080E96800B070A0A0A50007E0108080808504083),
                 .INIT_15                   (256'hB400104000B8010E14818280000C0DB804800003020100012109080001310706),
                 .INIT_16                   (256'hB401014BB401474AB40F0047B4010149B4014748B40F0046B4000A42B4F00041),
                 .INIT_17                   (256'h0049B4010048B4000046B4F00041B4121840006AB4F02041B40F0079B401014F),
                 .INIT_18                   (256'h5B54AE00006AB4F02041B4000079B4FF004FB4FF004BB401004AB4000047B4FF),
                 .INIT_19                   (256'hAE36009C20300000320065AE36009C20300000320077AE36009C203000000200),
                 .INIT_1A                   (256'h7BFE7D8090005601080E0680009C00102030330080AE36009C2030000032006E),
                 .INIT_1B                   (256'h000000807BB80B8090000000807B70178090000000807BD0078090000110A666),
                 .INIT_1C                   (256'h0400009C070700003200009CB00400003200007B370020300000807BE8038090),
                 .INIT_1D                   (256'hC400009C0B0A09080500124200B602B3000003080E080EC0B043424140FC00A5),
                 .INIT_1E                   (256'h751D05002430504900463207741D050024004632D000463206741D0500EADD04),
                 .INIT_1F                   (256'h00000000000000000000002430504900463207751D050024004632D000463206),
                 .INIT_20                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_21                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_22                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_23                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_24                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_25                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_26                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_27                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_28                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_29                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_30                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_31                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_32                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_33                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_34                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_35                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_36                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_37                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_38                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_39                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_40                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_41                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_42                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_43                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_44                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_45                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_46                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_47                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_48                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_49                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_50                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_51                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_52                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_53                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_54                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_55                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_56                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_57                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_58                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_59                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_60                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_61                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_62                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_63                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_64                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_65                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_66                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_67                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_68                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_69                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_70                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_71                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_72                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_73                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_74                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_75                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_76                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_77                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_78                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_79                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_00                  (256'h08208206212A8102040810204081020408102040421084210842C00A552A8000),
                 .INITP_01                  (256'h1E479CE71653E4E9CE2CCCCCCCC2A8A2C4A5A256666666410410410410282082),
                 .INITP_02                  (256'h888882222222222220221442A204402C5088888888880084000800000D8198E8),
                 .INITP_03                  (256'h00043011821808C7CA45AB54454545A552A954AA2A41582B0560AC15C0888888),
                 .INITP_04                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_05                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_06                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_07                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_08                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_09                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0A                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0B                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0C                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0D                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0E                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0F                  (256'h0000000000000000000000000000000000000000000000000000000000000000))
   kcpsm6_rom_l( .ADDRARDADDR               (address_a),
                 .ENARDEN                   (enable),
                 .CLKARDCLK                 (clk),
                 .DOADO                     (data_out_a_l[31:0]),
                 .DOPADOP                   (data_out_a_l[35:32]), 
                 .DIADI                     (data_in_a[31:0]),
                 .DIPADIP                   (data_in_a[35:32]), 
                 .WEA                       (4'b0000),
                 .REGCEAREGCE               (1'b0),
                 .RSTRAMARSTRAM             (1'b0),
                 .RSTREGARSTREG             (1'b0),
                 .ADDRBWRADDR               (address_b),
                 .ENBWREN                   (enable_b),
                 .CLKBWRCLK                 (clk_b),
                 .DOBDO                     (data_out_b_l[31:0]),
                 .DOPBDOP                   (data_out_b_l[35:32]), 
                 .DIBDI                     (data_in_b_l[31:0]),
                 .DIPBDIP                   (data_in_b_l[35:32]), 
                 .WEBWE                     (we_b),
                 .REGCEB                    (1'b0),
                 .RSTRAMB                   (1'b0),
                 .RSTREGB                   (1'b0),
                 .CASCADEINA                (1'b0),
                 .CASCADEINB                (1'b0),
                 .CASCADEOUTA               (),
                 .CASCADEOUTB               (),
                 .DBITERR                   (),
                 .ECCPARITY                 (),
                 .RDADDRECC                 (),
                 .SBITERR                   (),
                 .INJECTDBITERR             (1'b0),      
                 .INJECTSBITERR             (1'b0));   
      //
      RAMB36E1 #(.READ_WIDTH_A              (9),
                 .WRITE_WIDTH_A             (9),
                 .DOA_REG                   (0),
                 .INIT_A                    (36'h000000000),
                 .RSTREG_PRIORITY_A         ("REGCE"),
                 .SRVAL_A                   (36'h000000000),
                 .WRITE_MODE_A              ("WRITE_FIRST"),
                 .READ_WIDTH_B              (9),
                 .WRITE_WIDTH_B             (9),
                 .DOB_REG                   (0),
                 .INIT_B                    (36'h000000000),
                 .RSTREG_PRIORITY_B         ("REGCE"),
                 .SRVAL_B                   (36'h000000000),
                 .WRITE_MODE_B              ("WRITE_FIRST"),
                 .INIT_FILE                 ("NONE"),
                 .SIM_COLLISION_CHECK       ("ALL"),
                 .RAM_MODE                  ("TDP"),
                 .RDADDR_COLLISION_HWCONFIG ("DELAYED_WRITE"),
                 .EN_ECC_READ               ("FALSE"),
                 .EN_ECC_WRITE              ("FALSE"),
                 .RAM_EXTENSION_A           ("NONE"),
                 .RAM_EXTENSION_B           ("NONE"),
                 .SIM_DEVICE                ("VIRTEX6"),
                 .INIT_00                   (256'h0C0C786868090908085869696868090908086868686868680858011010101010),
                 .INIT_01                   (256'h7808780801780878080178087808010101010101B0CA0101010A01010E0E0D0D),
                 .INIT_02                   (256'h0101780878080178087808017808780801780878080178087808017808780801),
                 .INIT_03                   (256'h7808780801780878087808017808780878080178087808780801780878087808),
                 .INIT_04                   (256'h0800780878087808017808780878080178087808780801780878087808017808),
                 .INIT_05                   (256'h0878087808007808780878080078087808780800780878087808007808780878),
                 .INIT_06                   (256'hB0E55D1D05014E6D6D010E0C0C10000000780878087808007808780878080078),
                 .INIT_07                   (256'h78087808000D78087808000D78087808000D78087808000D780878087D01F028),
                 .INIT_08                   (256'h087808000D780878087D0128000D78087808000D78087808000D78087808000D),
                 .INIT_09                   (256'h0D78087808000D78087808000D78087808000D78087808000D78087808000D78),
                 .INIT_0A                   (256'h28000D0E28000D0E28000D0E28000D0E28000D0E28000D0E28000D7808780800),
                 .INIT_0B                   (256'h0A060701030301040C020201040C28005F5F5E28014D6D010E0E0C0C28000D0E),
                 .INIT_0C                   (256'h000D0E28000D0E28000D0E2801040C05050E0E95948401030304040D0103030A),
                 .INIT_0D                   (256'h02B0010100A20201010F0928000D0E28000D0E28000D0E28000D0E28000D0E28),
                 .INIT_0E                   (256'h01010F092869090128E201720101B0E18972000101B0010100A20201B0010100),
                 .INIT_0F                   (256'hA73FF168A0620008286A01010102B0E18901010052B001010002B0010100A202),
                 .INIT_10                   (256'h010101286F2F286F173808289168486F2F28016F173808286F2F0F28F0A0A711),
                 .INIT_11                   (256'h0101010111C8A201011101B1620A110128010101010128010101010128010101),
                 .INIT_12                   (256'h080911080809110808091108080928B1C80828B1CA010A286A01280101A26848),
                 .INIT_13                   (256'hA3A309090C28B1D9D8C811080809110808091108080911080809110808091108),
                 .INIT_14                   (256'h6D6D6C6C11C8A2A288E8B188A2A29168881AA0A0A00028B1CCA0A0A1A19181F1),
                 .INIT_15                   (256'h010C0C0D28B16848586C6C6D284C4C01586D284E4E4D4D58586C6C2858586E6E),
                 .INIT_16                   (256'h010C0C0D010C0C0D010C0C0D010C0C0D010C0C0D010C0C0D010C0C0D010C0C0D),
                 .INIT_17                   (256'h0C0D010C0C0D010C0C0D010C0C0D010C0C0D2801010C0C0D010C0C0D010C0C0D),
                 .INIT_18                   (256'h0101010D2801010C0C0D010C0C0D010C0C0D010C0C0D010C0C0D010C0C0D010C),
                 .INIT_19                   (256'h015D280105050E0E5C0C01015D280105050E0E5C0C01015D280105050E0E0C0C),
                 .INIT_1A                   (256'h010B0B020228B1C8A4A408022801050506065C0C01015D280105050E0E5C0C01),
                 .INIT_1B                   (256'h28999968010B0B020228999968010B0B020228999968010B0B020228D9D9D8C8),
                 .INIT_1C                   (256'h0C0C28010D0D0E0E5C0C28010D0D0E0E5C0C28015B0B0202999968010B0B0202),
                 .INIT_1D                   (256'h010E28014E4E4D4D0C0C586E0E115891F9E919A1A1A1A101016E6E6D6D1D0D01),
                 .INIT_1E                   (256'h0A01012801010601C80101A20A01012801C8010102C80101A20A01012801010E),
                 .INIT_1F                   (256'h000000000000000000002801010601C80101A20A01012801C8010102C80101A2),
                 .INIT_20                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_21                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_22                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_23                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_24                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_25                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_26                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_27                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_28                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_29                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_30                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_31                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_32                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_33                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_34                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_35                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_36                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_37                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_38                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_39                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3F                   (256'h0000000000000000000000000000004800000000000000000000000000000000),
                 .INIT_40                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_41                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_42                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_43                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_44                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_45                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_46                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_47                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_48                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_49                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_50                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_51                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_52                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_53                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_54                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_55                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_56                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_57                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_58                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_59                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_60                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_61                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_62                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_63                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_64                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_65                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_66                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_67                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_68                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_69                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_70                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_71                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_72                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_73                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_74                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_75                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_76                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_77                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_78                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_79                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_00                  (256'hAAAAAAAF85C7D5AB56AD5AB56AD5AB56AD5AB56AEB5AD6B5AD6BFBB0387C3F7F),
                 .INITP_01                  (256'h20BA77BCC9BE7F9F799999999998020812131B0CCCCCCCD555555555557AAAAA),
                 .INITP_02                  (256'h22223888888888888CF9E1FFF8A203010622222222233578FDF3FFFFFB197199),
                 .INITP_03                  (256'h003BCFEE7DE7F73EB03700793030301088442210860C0D81B03606C0EE222222),
                 .INITP_04                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_05                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_06                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_07                  (256'h0001000000000000000000000000000000000000000000000000000000000000),
                 .INITP_08                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_09                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0A                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0B                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0C                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0D                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0E                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0F                  (256'h0000000000000000000000000000000000000000000000000000000000000000))
   kcpsm6_rom_h( .ADDRARDADDR               (address_a),
                 .ENARDEN                   (enable),
                 .CLKARDCLK                 (clk),
                 .DOADO                     (data_out_a_h[31:0]),
                 .DOPADOP                   (data_out_a_h[35:32]), 
                 .DIADI                     (data_in_a[31:0]),
                 .DIPADIP                   (data_in_a[35:32]), 
                 .WEA                       (4'b0000),
                 .REGCEAREGCE               (1'b0),
                 .RSTRAMARSTRAM             (1'b0),
                 .RSTREGARSTREG             (1'b0),
                 .ADDRBWRADDR               (address_b),
                 .ENBWREN                   (enable_b),
                 .CLKBWRCLK                 (clk_b),
                 .DOBDO                     (data_out_b_h[31:0]),
                 .DOPBDOP                   (data_out_b_h[35:32]), 
                 .DIBDI                     (data_in_b_h[31:0]),
                 .DIPBDIP                   (data_in_b_h[35:32]), 
                 .WEBWE                     (we_b),
                 .REGCEB                    (1'b0),
                 .RSTRAMB                   (1'b0),
                 .RSTREGB                   (1'b0),
                 .CASCADEINA                (1'b0),
                 .CASCADEINB                (1'b0),
                 .CASCADEOUTA               (),
                 .CASCADEOUTB               (),
                 .DBITERR                   (),
                 .ECCPARITY                 (),
                 .RDADDRECC                 (),
                 .SBITERR                   (),
                 .INJECTDBITERR             (1'b0),      
                 .INJECTSBITERR             (1'b0));  
    end // v6;  
    //
    //
    if (C_FAMILY == "7S") begin: akv7 
      //
      assign address_a = {1'b1, address[11:0], 3'b111};
      assign instruction = {data_out_a_h[32], data_out_a_h[7:0], data_out_a_l[32], data_out_a_l[7:0]};
      assign data_in_a = 36'b00000000000000000000000000000000000;
      assign jtag_dout = {data_out_b_h[32], data_out_b_h[7:0], data_out_b_l[32], data_out_b_l[7:0]};
      //
      if (C_JTAG_LOADER_ENABLE == 0) begin : no_loader
        assign data_in_b_l = {3'b000, data_out_b_l[32], 24'b000000000000000000000000, data_out_b_l[7:0]};
        assign data_in_b_h = {3'b000, data_out_b_h[32], 24'b000000000000000000000000, data_out_b_h[7:0]};
        assign address_b = 16'b1111111111111111;
        assign we_b = 8'b00000000;
        assign enable_b = 1'b0;
        assign rdl = 1'b0;
        assign clk_b = 1'b0;
      end // no_loader;
      //
      if (C_JTAG_LOADER_ENABLE == 1) begin : loader
        assign data_in_b_h = {3'b000, jtag_din[17], 24'b000000000000000000000000, jtag_din[16:9]};
        assign data_in_b_l = {3'b000, jtag_din[8],  24'b000000000000000000000000, jtag_din[7:0]};
        assign address_b = {1'b1, jtag_addr[11:0], 3'b111};
        assign we_b = {jtag_we, jtag_we, jtag_we, jtag_we, jtag_we, jtag_we, jtag_we, jtag_we};
        assign enable_b = jtag_en[0];
        assign rdl = rdl_bus[0];
        assign clk_b = jtag_clk;
      end // loader;
      // 
      RAMB36E1 #(.READ_WIDTH_A              (9),
                 .WRITE_WIDTH_A             (9),
                 .DOA_REG                   (0),
                 .INIT_A                    (36'h000000000),
                 .RSTREG_PRIORITY_A         ("REGCE"),
                 .SRVAL_A                   (36'h000000000),
                 .WRITE_MODE_A              ("WRITE_FIRST"),
                 .READ_WIDTH_B              (9),
                 .WRITE_WIDTH_B             (9),
                 .DOB_REG                   (0),
                 .INIT_B                    (36'h000000000),
                 .RSTREG_PRIORITY_B         ("REGCE"),
                 .SRVAL_B                   (36'h000000000),
                 .WRITE_MODE_B              ("WRITE_FIRST"),
                 .INIT_FILE                 ("NONE"),
                 .SIM_COLLISION_CHECK       ("ALL"),
                 .RAM_MODE                  ("TDP"),
                 .RDADDR_COLLISION_HWCONFIG ("DELAYED_WRITE"),
                 .EN_ECC_READ               ("FALSE"),
                 .EN_ECC_WRITE              ("FALSE"),
                 .RAM_EXTENSION_A           ("NONE"),
                 .RAM_EXTENSION_B           ("NONE"),
                 .SIM_DEVICE                ("7SERIES"),
                 .INIT_00                   (256'h0600350100000080001243424140000000000706050409080001050505050505),
                 .INIT_01                   (256'h32343606283214360228321036011CBC9EBE240927015A0F0964059C00008000),
                 .INIT_02                   (256'hEE33322C36183332283610283230368328322436823E3220368128321C368028),
                 .INIT_03                   (256'h33213613493702331D3614493707333536124937043315361149371933113610),
                 .INIT_04                   (256'h146D341233113210493702332D36174937073329361649370233253615493702),
                 .INIT_05                   (256'h26332532246D3422332132206D341E331D321C6D3436333532346D3416331532),
                 .INIT_06                   (256'hE1B03540B09C050100A50006002F64D36D342E332D322C6D342A332932286D34),
                 .INIT_07                   (256'h00C3010E990A0033010F540A00AC010F4C0A00DB0110480A00B9011035BE1500),
                 .INIT_08                   (256'h3D010C600A003D010C35BE00600A00F5010C500A00CE010D5C0A00AE010D580A),
                 .INIT_09                   (256'h0A008F0110540A001E010F990A0067010E580A00AE010D5C0A00F5010C500A00),
                 .INIT_0A                   (256'h00DC025E00DC022600DC022500DC024400DC024000DC022400480A00D7010F4C),
                 .INIT_0B                   (256'h4120307BA0B0A5E000A0B0A5D0000072343332009C0F10A50000030000DC025F),
                 .INIT_0C                   (256'hB5028B00DC022100B50120009CF00090A000002010007BD0E02030007B001089),
                 .INIT_0D                   (256'hC0D84632F806A01D05000000B5028C00DC023900B5023900DC023800B5023800),
                 .INIT_0E                   (256'h1D0500000001012400E024303049CBB00130F82A49D84632F807A01DD84632F8),
                 .INIT_0F                   (256'h070301C00800E0800001244632E0EBB0014632F830D84632F8C0D84632F806A0),
                 .INIT_10                   (256'h5A0F1A002002002000FF02001101042001005A2000FF010020020100F90E0602),
                 .INIT_11                   (256'h520F5A1A33000E2B1A38153740802B1A0009560F5A15001A560F5A1500095615),
                 .INIT_12                   (256'h0000767C0000767C0000767C0000004F010B004A013C0800013C000952000204),
                 .INIT_13                   (256'h080E000010007600000176105E5F766889097648E80176127A00766A180076FA),
                 .INIT_14                   (256'h050409089601000600009201080E96800B070A0A0A50007E0108080808504083),
                 .INIT_15                   (256'hB400104000B8010E14818280000C0DB804800003020100012109080001310706),
                 .INIT_16                   (256'hB401014BB401474AB40F0047B4010149B4014748B40F0046B4000A42B4F00041),
                 .INIT_17                   (256'h0049B4010048B4000046B4F00041B4121840006AB4F02041B40F0079B401014F),
                 .INIT_18                   (256'h5B54AE00006AB4F02041B4000079B4FF004FB4FF004BB401004AB4000047B4FF),
                 .INIT_19                   (256'hAE36009C20300000320065AE36009C20300000320077AE36009C203000000200),
                 .INIT_1A                   (256'h7BFE7D8090005601080E0680009C00102030330080AE36009C2030000032006E),
                 .INIT_1B                   (256'h000000807BB80B8090000000807B70178090000000807BD0078090000110A666),
                 .INIT_1C                   (256'h0400009C070700003200009CB00400003200007B370020300000807BE8038090),
                 .INIT_1D                   (256'hC400009C0B0A09080500124200B602B3000003080E080EC0B043424140FC00A5),
                 .INIT_1E                   (256'h751D05002430504900463207741D050024004632D000463206741D0500EADD04),
                 .INIT_1F                   (256'h00000000000000000000002430504900463207751D050024004632D000463206),
                 .INIT_20                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_21                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_22                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_23                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_24                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_25                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_26                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_27                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_28                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_29                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_30                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_31                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_32                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_33                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_34                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_35                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_36                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_37                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_38                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_39                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_40                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_41                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_42                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_43                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_44                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_45                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_46                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_47                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_48                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_49                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_50                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_51                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_52                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_53                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_54                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_55                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_56                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_57                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_58                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_59                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_60                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_61                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_62                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_63                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_64                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_65                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_66                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_67                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_68                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_69                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_70                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_71                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_72                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_73                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_74                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_75                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_76                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_77                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_78                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_79                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_00                  (256'h08208206212A8102040810204081020408102040421084210842C00A552A8000),
                 .INITP_01                  (256'h1E479CE71653E4E9CE2CCCCCCCC2A8A2C4A5A256666666410410410410282082),
                 .INITP_02                  (256'h888882222222222220221442A204402C5088888888880084000800000D8198E8),
                 .INITP_03                  (256'h00043011821808C7CA45AB54454545A552A954AA2A41582B0560AC15C0888888),
                 .INITP_04                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_05                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_06                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_07                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_08                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_09                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0A                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0B                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0C                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0D                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0E                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0F                  (256'h0000000000000000000000000000000000000000000000000000000000000000))
   kcpsm6_rom_l( .ADDRARDADDR               (address_a),
                 .ENARDEN                   (enable),
                 .CLKARDCLK                 (clk),
                 .DOADO                     (data_out_a_l[31:0]),
                 .DOPADOP                   (data_out_a_l[35:32]), 
                 .DIADI                     (data_in_a[31:0]),
                 .DIPADIP                   (data_in_a[35:32]), 
                 .WEA                       (4'b0000),
                 .REGCEAREGCE               (1'b0),
                 .RSTRAMARSTRAM             (1'b0),
                 .RSTREGARSTREG             (1'b0),
                 .ADDRBWRADDR               (address_b),
                 .ENBWREN                   (enable_b),
                 .CLKBWRCLK                 (clk_b),
                 .DOBDO                     (data_out_b_l[31:0]),
                 .DOPBDOP                   (data_out_b_l[35:32]), 
                 .DIBDI                     (data_in_b_l[31:0]),
                 .DIPBDIP                   (data_in_b_l[35:32]), 
                 .WEBWE                     (we_b),
                 .REGCEB                    (1'b0),
                 .RSTRAMB                   (1'b0),
                 .RSTREGB                   (1'b0),
                 .CASCADEINA                (1'b0),
                 .CASCADEINB                (1'b0),
                 .CASCADEOUTA               (),
                 .CASCADEOUTB               (),
                 .DBITERR                   (),
                 .ECCPARITY                 (),
                 .RDADDRECC                 (),
                 .SBITERR                   (),
                 .INJECTDBITERR             (1'b0),      
                 .INJECTSBITERR             (1'b0));   
      //
      RAMB36E1 #(.READ_WIDTH_A              (9),
                 .WRITE_WIDTH_A             (9),
                 .DOA_REG                   (0),
                 .INIT_A                    (36'h000000000),
                 .RSTREG_PRIORITY_A         ("REGCE"),
                 .SRVAL_A                   (36'h000000000),
                 .WRITE_MODE_A              ("WRITE_FIRST"),
                 .READ_WIDTH_B              (9),
                 .WRITE_WIDTH_B             (9),
                 .DOB_REG                   (0),
                 .INIT_B                    (36'h000000000),
                 .RSTREG_PRIORITY_B         ("REGCE"),
                 .SRVAL_B                   (36'h000000000),
                 .WRITE_MODE_B              ("WRITE_FIRST"),
                 .INIT_FILE                 ("NONE"),
                 .SIM_COLLISION_CHECK       ("ALL"),
                 .RAM_MODE                  ("TDP"),
                 .RDADDR_COLLISION_HWCONFIG ("DELAYED_WRITE"),
                 .EN_ECC_READ               ("FALSE"),
                 .EN_ECC_WRITE              ("FALSE"),
                 .RAM_EXTENSION_A           ("NONE"),
                 .RAM_EXTENSION_B           ("NONE"),
                 .SIM_DEVICE                ("7SERIES"),
                 .INIT_00                   (256'h0C0C786868090908085869696868090908086868686868680858011010101010),
                 .INIT_01                   (256'h7808780801780878080178087808010101010101B0CA0101010A01010E0E0D0D),
                 .INIT_02                   (256'h0101780878080178087808017808780801780878080178087808017808780801),
                 .INIT_03                   (256'h7808780801780878087808017808780878080178087808780801780878087808),
                 .INIT_04                   (256'h0800780878087808017808780878080178087808780801780878087808017808),
                 .INIT_05                   (256'h0878087808007808780878080078087808780800780878087808007808780878),
                 .INIT_06                   (256'hB0E55D1D05014E6D6D010E0C0C10000000780878087808007808780878080078),
                 .INIT_07                   (256'h78087808000D78087808000D78087808000D78087808000D780878087D01F028),
                 .INIT_08                   (256'h087808000D780878087D0128000D78087808000D78087808000D78087808000D),
                 .INIT_09                   (256'h0D78087808000D78087808000D78087808000D78087808000D78087808000D78),
                 .INIT_0A                   (256'h28000D0E28000D0E28000D0E28000D0E28000D0E28000D0E28000D7808780800),
                 .INIT_0B                   (256'h0A060701030301040C020201040C28005F5F5E28014D6D010E0E0C0C28000D0E),
                 .INIT_0C                   (256'h000D0E28000D0E28000D0E2801040C05050E0E95948401030304040D0103030A),
                 .INIT_0D                   (256'h02B0010100A20201010F0928000D0E28000D0E28000D0E28000D0E28000D0E28),
                 .INIT_0E                   (256'h01010F092869090128E201720101B0E18972000101B0010100A20201B0010100),
                 .INIT_0F                   (256'hA73FF168A0620008286A01010102B0E18901010052B001010002B0010100A202),
                 .INIT_10                   (256'h010101286F2F286F173808289168486F2F28016F173808286F2F0F28F0A0A711),
                 .INIT_11                   (256'h0101010111C8A201011101B1620A110128010101010128010101010128010101),
                 .INIT_12                   (256'h080911080809110808091108080928B1C80828B1CA010A286A01280101A26848),
                 .INIT_13                   (256'hA3A309090C28B1D9D8C811080809110808091108080911080809110808091108),
                 .INIT_14                   (256'h6D6D6C6C11C8A2A288E8B188A2A29168881AA0A0A00028B1CCA0A0A1A19181F1),
                 .INIT_15                   (256'h010C0C0D28B16848586C6C6D284C4C01586D284E4E4D4D58586C6C2858586E6E),
                 .INIT_16                   (256'h010C0C0D010C0C0D010C0C0D010C0C0D010C0C0D010C0C0D010C0C0D010C0C0D),
                 .INIT_17                   (256'h0C0D010C0C0D010C0C0D010C0C0D010C0C0D2801010C0C0D010C0C0D010C0C0D),
                 .INIT_18                   (256'h0101010D2801010C0C0D010C0C0D010C0C0D010C0C0D010C0C0D010C0C0D010C),
                 .INIT_19                   (256'h015D280105050E0E5C0C01015D280105050E0E5C0C01015D280105050E0E0C0C),
                 .INIT_1A                   (256'h010B0B020228B1C8A4A408022801050506065C0C01015D280105050E0E5C0C01),
                 .INIT_1B                   (256'h28999968010B0B020228999968010B0B020228999968010B0B020228D9D9D8C8),
                 .INIT_1C                   (256'h0C0C28010D0D0E0E5C0C28010D0D0E0E5C0C28015B0B0202999968010B0B0202),
                 .INIT_1D                   (256'h010E28014E4E4D4D0C0C586E0E115891F9E919A1A1A1A101016E6E6D6D1D0D01),
                 .INIT_1E                   (256'h0A01012801010601C80101A20A01012801C8010102C80101A20A01012801010E),
                 .INIT_1F                   (256'h000000000000000000002801010601C80101A20A01012801C8010102C80101A2),
                 .INIT_20                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_21                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_22                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_23                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_24                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_25                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_26                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_27                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_28                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_29                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_2F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_30                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_31                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_32                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_33                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_34                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_35                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_36                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_37                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_38                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_39                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_3F                   (256'h0000000000000000000000000000004800000000000000000000000000000000),
                 .INIT_40                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_41                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_42                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_43                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_44                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_45                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_46                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_47                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_48                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_49                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_4F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_50                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_51                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_52                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_53                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_54                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_55                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_56                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_57                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_58                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_59                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_5F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_60                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_61                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_62                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_63                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_64                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_65                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_66                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_67                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_68                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_69                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_6F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_70                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_71                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_72                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_73                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_74                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_75                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_76                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_77                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_78                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_79                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7A                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7B                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7C                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7D                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7E                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INIT_7F                   (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_00                  (256'hAAAAAAAF85C7D5AB56AD5AB56AD5AB56AD5AB56AEB5AD6B5AD6BFBB0387C3F7F),
                 .INITP_01                  (256'h20BA77BCC9BE7F9F799999999998020812131B0CCCCCCCD555555555557AAAAA),
                 .INITP_02                  (256'h22223888888888888CF9E1FFF8A203010622222222233578FDF3FFFFFB197199),
                 .INITP_03                  (256'h003BCFEE7DE7F73EB03700793030301088442210860C0D81B03606C0EE222222),
                 .INITP_04                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_05                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_06                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_07                  (256'h0001000000000000000000000000000000000000000000000000000000000000),
                 .INITP_08                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_09                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0A                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0B                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0C                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0D                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0E                  (256'h0000000000000000000000000000000000000000000000000000000000000000),
                 .INITP_0F                  (256'h0000000000000000000000000000000000000000000000000000000000000000))
   kcpsm6_rom_h( .ADDRARDADDR               (address_a),
                 .ENARDEN                   (enable),
                 .CLKARDCLK                 (clk),
                 .DOADO                     (data_out_a_h[31:0]),
                 .DOPADOP                   (data_out_a_h[35:32]), 
                 .DIADI                     (data_in_a[31:0]),
                 .DIPADIP                   (data_in_a[35:32]), 
                 .WEA                       (4'b0000),
                 .REGCEAREGCE               (1'b0),
                 .RSTRAMARSTRAM             (1'b0),
                 .RSTREGARSTREG             (1'b0),
                 .ADDRBWRADDR               (address_b),
                 .ENBWREN                   (enable_b),
                 .CLKBWRCLK                 (clk_b),
                 .DOBDO                     (data_out_b_h[31:0]),
                 .DOPBDOP                   (data_out_b_h[35:32]), 
                 .DIBDI                     (data_in_b_h[31:0]),
                 .DIPBDIP                   (data_in_b_h[35:32]), 
                 .WEBWE                     (we_b),
                 .REGCEB                    (1'b0),
                 .RSTRAMB                   (1'b0),
                 .RSTREGB                   (1'b0),
                 .CASCADEINA                (1'b0),
                 .CASCADEINB                (1'b0),
                 .CASCADEOUTA               (),
                 .CASCADEOUTB               (),
                 .DBITERR                   (),
                 .ECCPARITY                 (),
                 .RDADDRECC                 (),
                 .SBITERR                   (),
                 .INJECTDBITERR             (1'b0),      
                 .INJECTSBITERR             (1'b0));  
    end // akv7;  
    //
  end // ram_4k_generate;
endgenerate      
//
// JTAG Loader 
//
generate
  if (C_JTAG_LOADER_ENABLE == 1) begin: instantiate_loader
    jtag_loader_6  #(  .C_FAMILY              (C_FAMILY),
                       .C_NUM_PICOBLAZE       (1),
                       .C_JTAG_LOADER_ENABLE  (C_JTAG_LOADER_ENABLE),        
                       .C_BRAM_MAX_ADDR_WIDTH (BRAM_ADDRESS_WIDTH),        
                       .C_ADDR_WIDTH_0        (BRAM_ADDRESS_WIDTH))
    jtag_loader_6_inst(.picoblaze_reset       (rdl_bus),
                       .jtag_en               (jtag_en),
                       .jtag_din              (jtag_din),
                       .jtag_addr             (jtag_addr[BRAM_ADDRESS_WIDTH-1 : 0]),
                       .jtag_clk              (jtag_clk),
                       .jtag_we               (jtag_we),
                       .jtag_dout_0           (jtag_dout),
                       .jtag_dout_1           (jtag_dout),  // ports 1-7 are not used
                       .jtag_dout_2           (jtag_dout),  // in a 1 device debug 
                       .jtag_dout_3           (jtag_dout),  // session.  However, Synplify
                       .jtag_dout_4           (jtag_dout),  // etc require all ports are
                       .jtag_dout_5           (jtag_dout),  // connected
                       .jtag_dout_6           (jtag_dout),
                       .jtag_dout_7           (jtag_dout));  
    
  end //instantiate_loader
endgenerate 
//
//
endmodule
//
//
//
//
///////////////////////////////////////////////////////////////////////////////////////////
//
// JTAG Loader 
//
///////////////////////////////////////////////////////////////////////////////////////////
//
//
// JTAG Loader 6 - Version 6.00
//
// Kris Chaplin - 4th February 2010
// Nick Sawyer  - 3rd March 2011 - Initial conversion to Verilog
// Ken Chapman  - 16th August 2011 - Revised coding style
//
`timescale 1ps/1ps
module jtag_loader_6 (picoblaze_reset, jtag_en, jtag_din, jtag_addr, jtag_clk, jtag_we, jtag_dout_0, jtag_dout_1, jtag_dout_2, jtag_dout_3, jtag_dout_4, jtag_dout_5, jtag_dout_6, jtag_dout_7);
//
parameter integer C_JTAG_LOADER_ENABLE = 1;
parameter         C_FAMILY = "V6";
parameter integer C_NUM_PICOBLAZE = 1;
parameter integer C_BRAM_MAX_ADDR_WIDTH = 10;
parameter integer C_PICOBLAZE_INSTRUCTION_DATA_WIDTH = 18;
parameter integer C_JTAG_CHAIN = 2;
parameter [4:0]   C_ADDR_WIDTH_0 = 10;
parameter [4:0]   C_ADDR_WIDTH_1 = 10;
parameter [4:0]   C_ADDR_WIDTH_2 = 10;
parameter [4:0]   C_ADDR_WIDTH_3 = 10;
parameter [4:0]   C_ADDR_WIDTH_4 = 10;
parameter [4:0]   C_ADDR_WIDTH_5 = 10;
parameter [4:0]   C_ADDR_WIDTH_6 = 10;
parameter [4:0]   C_ADDR_WIDTH_7 = 10;
//
output [C_NUM_PICOBLAZE-1:0]                    picoblaze_reset;
output [C_NUM_PICOBLAZE-1:0]                    jtag_en;
output [C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1:0] jtag_din;
output [C_BRAM_MAX_ADDR_WIDTH-1:0]              jtag_addr;
output                                          jtag_clk ;
output                                          jtag_we;  
input  [C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1:0] jtag_dout_0;
input  [C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1:0] jtag_dout_1;
input  [C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1:0] jtag_dout_2;
input  [C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1:0] jtag_dout_3;
input  [C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1:0] jtag_dout_4;
input  [C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1:0] jtag_dout_5;
input  [C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1:0] jtag_dout_6;
input  [C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1:0] jtag_dout_7;
//
//
wire   [2:0]                                    num_picoblaze;        
wire   [4:0]                                    picoblaze_instruction_data_width; 
//
wire                                            drck;
wire                                            shift_clk;
wire                                            shift_din;
wire                                            shift_dout;
wire                                            shift;
wire                                            capture;
//
reg                                             control_reg_ce;
reg    [C_NUM_PICOBLAZE-1:0]                    bram_ce;
wire   [C_NUM_PICOBLAZE-1:0]                    bus_zero;
wire   [C_NUM_PICOBLAZE-1:0]                    jtag_en_int;
wire   [7:0]                                    jtag_en_expanded;
reg    [C_BRAM_MAX_ADDR_WIDTH-1:0]              jtag_addr_int;
reg    [C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1:0] jtag_din_int;
wire   [C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1:0] control_din;
wire   [C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1:0] control_dout;
reg    [7:0]                                    control_dout_int;
wire   [C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1:0] bram_dout_int;
reg                                             jtag_we_int;
wire                                            jtag_clk_int;
wire                                            bram_ce_valid;
reg                                             din_load;
//                                                
wire   [C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1:0] jtag_dout_0_masked;
wire   [C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1:0] jtag_dout_1_masked;
wire   [C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1:0] jtag_dout_2_masked;
wire   [C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1:0] jtag_dout_3_masked;
wire   [C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1:0] jtag_dout_4_masked;
wire   [C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1:0] jtag_dout_5_masked;
wire   [C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1:0] jtag_dout_6_masked;
wire   [C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1:0] jtag_dout_7_masked;
reg    [C_NUM_PICOBLAZE-1:0]                    picoblaze_reset_int;
//
initial picoblaze_reset_int = 0;
//
genvar i;
//
generate
  for (i = 0; i <= C_NUM_PICOBLAZE-1; i = i+1)
    begin : npzero_loop
      assign bus_zero[i] = 1'b0;
    end
endgenerate
//
generate
  //
  if (C_JTAG_LOADER_ENABLE == 1)
    begin : jtag_loader_gen
      //
      // Insert BSCAN primitive for target device architecture.
      //
      if (C_FAMILY == "S6")
        begin : BSCAN_SPARTAN6_gen
          BSCAN_SPARTAN6 # (.JTAG_CHAIN (C_JTAG_CHAIN))
          BSCAN_BLOCK_inst (.CAPTURE    (capture),
                            .DRCK       (drck),
                            .RESET      (),
                            .RUNTEST    (),
                            .SEL        (bram_ce_valid),
                            .SHIFT      (shift),
                            .TCK        (),
                            .TDI        (shift_din),
                            .TMS        (),
                            .UPDATE     (jtag_clk_int),
                            .TDO        (shift_dout)); 
            
        end 
      //
      if (C_FAMILY == "V6")
        begin : BSCAN_VIRTEX6_gen
          BSCAN_VIRTEX6 # ( .JTAG_CHAIN   (C_JTAG_CHAIN),
                            .DISABLE_JTAG ("FALSE"))
          BSCAN_BLOCK_inst (.CAPTURE      (capture),
                            .DRCK         (drck),
                            .RESET        (),
                            .RUNTEST      (),
                            .SEL          (bram_ce_valid),
                            .SHIFT        (shift),
                            .TCK          (),
                            .TDI          (shift_din),
                            .TMS          (),
                            .UPDATE       (jtag_clk_int),
                            .TDO          (shift_dout));
        end 
      //
      if (C_FAMILY == "7S")
        begin : BSCAN_7SERIES_gen
          BSCANE2 # (       .JTAG_CHAIN   (C_JTAG_CHAIN),
                            .DISABLE_JTAG ("FALSE"))
          BSCAN_BLOCK_inst (.CAPTURE      (capture),
                            .DRCK         (drck),
                            .RESET        (),
                            .RUNTEST      (),
                            .SEL          (bram_ce_valid),
                            .SHIFT        (shift),
                            .TCK          (),
                            .TDI          (shift_din),
                            .TMS          (),
                            .UPDATE       (jtag_clk_int),
                            .TDO          (shift_dout));
        end 
      //
      // Insert clock buffer to ensure reliable shift operations.
      //
      BUFG upload_clock (.I (drck), .O (shift_clk));
      //        
      //
      // Shift Register 
      //
      always @ (posedge shift_clk) begin
        if (shift == 1'b1) begin
          control_reg_ce <= shift_din;
        end
      end
      // 
      always @ (posedge shift_clk) begin
        if (shift == 1'b1) begin
          bram_ce[0] <= control_reg_ce;
        end
      end 
      //
      for (i = 0; i <= C_NUM_PICOBLAZE-2; i = i+1)
      begin : loop0 
        if (C_NUM_PICOBLAZE > 1) begin
          always @ (posedge shift_clk) begin
            if (shift == 1'b1) begin
              bram_ce[i+1] <= bram_ce[i];
            end
          end
        end 
      end
      // 
      always @ (posedge shift_clk) begin
        if (shift == 1'b1) begin
          jtag_we_int <= bram_ce[C_NUM_PICOBLAZE-1];
        end
      end
      // 
      always @ (posedge shift_clk) begin 
        if (shift == 1'b1) begin
          jtag_addr_int[0] <= jtag_we_int;
        end
      end
      //
      for (i = 0; i <= C_BRAM_MAX_ADDR_WIDTH-2; i = i+1)
      begin : loop1
        always @ (posedge shift_clk) begin
          if (shift == 1'b1) begin
            jtag_addr_int[i+1] <= jtag_addr_int[i];
          end
        end 
      end
      // 
      always @ (posedge shift_clk) begin 
        if (din_load == 1'b1) begin
          jtag_din_int[0] <= bram_dout_int[0];
        end
        else if (shift == 1'b1) begin
          jtag_din_int[0] <= jtag_addr_int[C_BRAM_MAX_ADDR_WIDTH-1];
        end
      end       
      //
      for (i = 0; i <= C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-2; i = i+1)
      begin : loop2
        always @ (posedge shift_clk) begin
          if (din_load == 1'b1) begin
            jtag_din_int[i+1] <= bram_dout_int[i+1];
          end
          if (shift == 1'b1) begin
            jtag_din_int[i+1] <= jtag_din_int[i];
          end
        end 
      end
      //
      assign shift_dout = jtag_din_int[C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1];
      //
      //
      always @ (bram_ce or din_load or capture or bus_zero or control_reg_ce) begin
        if ( bram_ce == bus_zero ) begin
          din_load <= capture & control_reg_ce;
        end else begin
          din_load <= capture;
        end
      end
      //
      //
      // Control Registers 
      //
      assign num_picoblaze = C_NUM_PICOBLAZE-3'h1;
      assign picoblaze_instruction_data_width = C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-5'h01;
      //
      always @ (posedge jtag_clk_int) begin
        if (bram_ce_valid == 1'b1 && jtag_we_int == 1'b0 && control_reg_ce == 1'b1) begin
          case (jtag_addr_int[3:0]) 
            0 : // 0 = version - returns (7:4) illustrating number of PB
                // and [3:0] picoblaze instruction data width
                control_dout_int <= {num_picoblaze, picoblaze_instruction_data_width};
            1 : // 1 = PicoBlaze 0 reset / status
                if (C_NUM_PICOBLAZE >= 1) begin 
                  control_dout_int <= {picoblaze_reset_int[0], 2'b00, C_ADDR_WIDTH_0-5'h01};
                end else begin
                  control_dout_int <= 8'h00;
                end
            2 : // 2 = PicoBlaze 1 reset / status
                if (C_NUM_PICOBLAZE >= 2) begin 
                  control_dout_int <= {picoblaze_reset_int[1], 2'b00, C_ADDR_WIDTH_1-5'h01};
                end else begin
                  control_dout_int <= 8'h00;
                end
            3 : // 3 = PicoBlaze 2 reset / status
                if (C_NUM_PICOBLAZE >= 3) begin 
                  control_dout_int <= {picoblaze_reset_int[2], 2'b00, C_ADDR_WIDTH_2-5'h01};
                end else begin
                  control_dout_int <= 8'h00;
                end
            4 : // 4 = PicoBlaze 3 reset / status
                if (C_NUM_PICOBLAZE >= 4) begin 
                  control_dout_int <= {picoblaze_reset_int[3], 2'b00, C_ADDR_WIDTH_3-5'h01};
                end else begin
                  control_dout_int <= 8'h00;
                end
            5:  // 5 = PicoBlaze 4 reset / status
                if (C_NUM_PICOBLAZE >= 5) begin 
                  control_dout_int <= {picoblaze_reset_int[4], 2'b00, C_ADDR_WIDTH_4-5'h01};
                end else begin
                  control_dout_int <= 8'h00;
                end
            6 : // 6 = PicoBlaze 5 reset / status
                if (C_NUM_PICOBLAZE >= 6) begin 
                  control_dout_int <= {picoblaze_reset_int[5], 2'b00, C_ADDR_WIDTH_5-5'h01};
                end else begin
                  control_dout_int <= 8'h00;
                end
            7 : // 7 = PicoBlaze 6 reset / status
                if (C_NUM_PICOBLAZE >= 7) begin 
                  control_dout_int <= {picoblaze_reset_int[6], 2'b00, C_ADDR_WIDTH_6-5'h01};
                end else begin
                  control_dout_int <= 8'h00;
                end
            8 : // 8 = PicoBlaze 7 reset / status
                if (C_NUM_PICOBLAZE >= 8) begin 
                  control_dout_int <= {picoblaze_reset_int[7], 2'b00, C_ADDR_WIDTH_7-5'h01};
                end else begin
                  control_dout_int <= 8'h00;
                end
            15 : control_dout_int <= C_BRAM_MAX_ADDR_WIDTH -1;
            default : control_dout_int <= 8'h00;
            //
          endcase
        end else begin
          control_dout_int <= 8'h00;
        end
      end 
      //
      assign control_dout[C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1:C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-8] = control_dout_int;
      //
      always @ (posedge jtag_clk_int) begin
        if (bram_ce_valid == 1'b1 && jtag_we_int == 1'b1 && control_reg_ce == 1'b1) begin
          picoblaze_reset_int[C_NUM_PICOBLAZE-1:0] <= control_din[C_NUM_PICOBLAZE-1:0];
        end
      end     
      //
      //
      // Assignments 
      //
      if (C_PICOBLAZE_INSTRUCTION_DATA_WIDTH > 8) begin
        assign control_dout[C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-9:0] = 10'h000;
      end
      //
      // Qualify the blockram CS signal with bscan select output
      assign jtag_en_int = (bram_ce_valid) ? bram_ce : bus_zero;
      //
      assign jtag_en_expanded[C_NUM_PICOBLAZE-1:0] = jtag_en_int; 
      //
      for (i = 7; i >= C_NUM_PICOBLAZE; i = i-1)
        begin : loop4 
          if (C_NUM_PICOBLAZE < 8) begin : jtag_en_expanded_gen
            assign jtag_en_expanded[i] = 1'b0;
          end
        end
      //
      assign bram_dout_int = control_dout | jtag_dout_0_masked | jtag_dout_1_masked | jtag_dout_2_masked | jtag_dout_3_masked | jtag_dout_4_masked | jtag_dout_5_masked | jtag_dout_6_masked | jtag_dout_7_masked;
      //
      assign control_din = jtag_din_int;
      //
      assign jtag_dout_0_masked = (jtag_en_expanded[0]) ? jtag_dout_0 : 18'h00000;
      assign jtag_dout_1_masked = (jtag_en_expanded[1]) ? jtag_dout_1 : 18'h00000;
      assign jtag_dout_2_masked = (jtag_en_expanded[2]) ? jtag_dout_2 : 18'h00000;
      assign jtag_dout_3_masked = (jtag_en_expanded[3]) ? jtag_dout_3 : 18'h00000;
      assign jtag_dout_4_masked = (jtag_en_expanded[4]) ? jtag_dout_4 : 18'h00000;
      assign jtag_dout_5_masked = (jtag_en_expanded[5]) ? jtag_dout_5 : 18'h00000;
      assign jtag_dout_6_masked = (jtag_en_expanded[6]) ? jtag_dout_6 : 18'h00000;
      assign jtag_dout_7_masked = (jtag_en_expanded[7]) ? jtag_dout_7 : 18'h00000;
      //       
      assign jtag_en = jtag_en_int;
      assign jtag_din = jtag_din_int;
      assign jtag_addr = jtag_addr_int;
      assign jtag_clk = jtag_clk_int;
      assign jtag_we = jtag_we_int;
      assign picoblaze_reset = picoblaze_reset_int;
      //
    end
endgenerate
   //
endmodule
//
///////////////////////////////////////////////////////////////////////////////////////////
//
//  END OF FILE pmbus_to_bram_program.v
//
///////////////////////////////////////////////////////////////////////////////////////////
//
