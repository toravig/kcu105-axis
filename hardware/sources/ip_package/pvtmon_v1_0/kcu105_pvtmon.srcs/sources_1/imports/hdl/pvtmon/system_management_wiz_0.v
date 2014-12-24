
// file: system_management_wiz_0.v
// (c) Copyright 2013 - 2013 Xilinx, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
`timescale 1ns / 1 ps

(* CORE_GENERATION_INFO = "system_management_wiz_0,system_management_wiz_v1_0,{component_name=system_management_wiz_0,enable_axi=false,enable_axi4stream=false,dclk_frequency=50,enable_busy=true,enable_convst=false,enable_convstclk=false,enable_dclk=true,enable_drp=true,enable_eoc=true,enable_eos=true,enable_vbram_alaram=false,enable_vccddro_alaram=false,enable_Vccint_Alaram=false,enable_Vccaux_alaram=false,enable_vccpaux_alaram=false,enable_vccpint_alaram=false,ot_alaram=false,user_temp_alaram=false,timing_mode=continuous,channel_averaging=16,sequencer_mode=on,startup_channel_selection=contineous_sequence}" *)


module system_management_wiz_0
          (
          daddr_in,            // Address bus for the dynamic reconfiguration port
          dclk_in,             // Clock input for the dynamic reconfiguration port
          den_in,              // Enable Signal for the dynamic reconfiguration port
          di_in,               // Input data bus for the dynamic reconfiguration port
          dwe_in,              // Write Enable for the dynamic reconfiguration port
          reset_in,            // Reset signal for the System Monitor control logic
          vauxp0,              // Auxiliary channel 0
          vauxn0,
          vauxp2,              // Auxiliary channel 2
          vauxn2,
          vauxp8,              // Auxiliary channel 8
          vauxn8,
          vp,
          vn,
          busy_out,            // ADC Busy signal
          channel_out,         // Channel Selection Outputs
          do_out,              // Output data bus for dynamic reconfiguration port
          drdy_out,            // Data ready signal for the dynamic reconfiguration port
          eoc_out,             // End of Conversion Signal
          eos_out,             // End of Sequence Signal
          muxaddr_out,
          alarm_out);

          input [7:0] daddr_in;
          input dclk_in;
          input den_in;
          input [15:0] di_in;
          input dwe_in;
          input reset_in;
          input vauxp0;
          input vauxn0;
          input vauxp2;
          input vauxn2;
          input vauxp8;
          input vauxn8;
          input vp; 
          input vn; 
          output busy_out;
          output [5:0] channel_out;
          output [15:0] do_out;
          output drdy_out;
          output eoc_out;
          output eos_out;
          output alarm_out;
          output [4:0] muxaddr_out;

          wire FLOAT_VCCAUX;
          wire FLOAT_VCCINT;
          wire FLOAT_TEMP;
          wire GND_BIT;
    wire [2:0] GND_BUS3;
          assign GND_BIT = 0;
          wire [15:0] aux_channel_p;
          wire [15:0] aux_channel_n;
          wire [15:0]  alm_int;
          assign alarm_out = alm_int[7];

          IBUF_ANALOG ibuf_an_vauxp0
          (.I(vauxp0),
           .O(aux_channel_p[0]));  

          IBUF_ANALOG ibuf_an_vauxn0
          (.I(vauxn0),
           .O(aux_channel_n[0]));  

          IBUF_ANALOG ibuf_an_vauxp2
          (.I(vauxp2),
           .O(aux_channel_p[2]));  

          IBUF_ANALOG ibuf_an_vauxn2
          (.I(vauxn2),
           .O(aux_channel_n[2]));  

          IBUF_ANALOG ibuf_an_vauxp8
          (.I(vauxp8),
           .O(aux_channel_p[8]));  

          IBUF_ANALOG ibuf_an_vauxn8
          (.I(vauxn8),
           .O(aux_channel_n[8]));  


SYSMONE1 #(
        .INIT_40(16'h1812), // config reg 0
        .INIT_41(16'h21FF), // config reg 1
        .INIT_42(16'h0A00), // config reg 2
        .INIT_43(16'h000F), // config reg 3
        .INIT_45(16'h5890), // Analog Bus Register
        .INIT_46(16'h000F), // Sequencer Channel selection (Vuser1-4)
        .INIT_47(16'h000F), // Sequencer Average selection (Vuser1-4)
        .INIT_48(16'h4F01), // Sequencer channel selection
        .INIT_49(16'h0105), // Sequencer channel selection
        .INIT_4A(16'h4F00), // Sequencer Average selection
        .INIT_4B(16'h0105), // Sequencer Average selection
        .INIT_4C(16'h0000), // Sequencer Bipolar selection
        .INIT_4D(16'h0000), // Sequencer Bipolar selection
        .INIT_4E(16'h0800), // Sequencer Acq time selection
        .INIT_4F(16'h0105), // Sequencer Acq time selection
        .INIT_50(16'hB5ED), // Temp alarm trigger
        .INIT_51(16'h4E81), // Vccint upper alarm limit
        .INIT_52(16'hA147), // Vccaux upper alarm limit
        .INIT_53(16'hCA33),  // Temp alarm OT upper
        .INIT_54(16'hA93A), // Temp alarm reset
        .INIT_55(16'h4963), // Vccint lower alarm limit
        .INIT_56(16'h9555), // Vccaux lower alarm limit
        .INIT_57(16'hAE4E),  // Temp alarm OT reset
        .INIT_58(16'h4E81), // VBRAM upper alarm limit
        .INIT_5C(16'h4963), //  VBRAM lower alarm limit
        .INIT_60(16'h9A74), // Vuser1 upper alarm limit
        .INIT_61(16'h4D39), // Vuser2 upper alarm limit
        .INIT_62(16'h9A74), // Vuser3 upper alarm limit
        .INIT_63(16'h9A74), // Vuser4 upper alarm limit
        .INIT_68(16'h98BF), // Vuser1 lower alarm limit
        .INIT_69(16'h4C5E), // Vuser2 lower alarm limit
        .INIT_6A(16'h98BF), // Vuser3 lower alarm limit
        .INIT_6B(16'h98BF), // Vuser4 lower alarm limit
        .SYSMON_VUSER0_BANK(47),
        .SYSMON_VUSER0_MONITOR("VCCO"),
        .SYSMON_VUSER1_BANK(64),
        .SYSMON_VUSER1_MONITOR("VCCO_BOT"),
        .SYSMON_VUSER2_BANK(44),
        .SYSMON_VUSER2_MONITOR("VCCO"),
        .SYSMON_VUSER3_BANK(48),
        .SYSMON_VUSER3_MONITOR("VCCAUX"),
        .SIM_MONITOR_FILE("/group/paeg/sweathar/releases/ultra_lp_demo_1/2013.4/kcu105__sysmon_fulldesign/ultra_lp_demo_1/kcu105/hardware/sources/ip_catalog/system_management_wiz/system_management_wiz_0/simulation/functional/design.txt")
)

inst (
        .CONVST(GND_BIT),
        .CONVSTCLK(GND_BIT),
        .DADDR(daddr_in[7:0]),
        .DCLK(dclk_in),
        .DEN(den_in),
        .DI(di_in[15:0]),
        .DWE(dwe_in),
        .RESET(reset_in),
        .VAUXN(aux_channel_n[15:0]),
        .VAUXP(aux_channel_p[15:0]),
        .ALM(alm_int),
        .BUSY(busy_out),
        .CHANNEL(channel_out[5:0]),
        .DO(do_out[15:0]),
        .DRDY(drdy_out),
        .EOC(eoc_out),
        .EOS(eos_out),
        .JTAGBUSY(),
        .JTAGLOCKED(),
        .JTAGMODIFIED(),
        .OT(),
        .I2C_SCLK(1'b0),
        .I2C_SDA(1'b0),
        .I2C_SCLK_TS(),
        .I2C_SDA_TS(),
        .MUXADDR(muxaddr_out),
        .VP(vp),
        .VN(vn)
          );

endmodule
