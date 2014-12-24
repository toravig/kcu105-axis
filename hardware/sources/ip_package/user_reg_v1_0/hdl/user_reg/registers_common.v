//- Register module for AXI-MM GEN/CHK

`timescale 1ns/1ps

module registers_common #(
  parameter [31:0]  C_S_AXI_BASEADDR      = 32'h0000_0000,
  parameter [31:0]  C_S_AXI_HIGHADDR      = 32'h0000_FFFF
) (
  input [31:0]        Bus2IP_Addr,
  input               Bus2IP_RNW,
  input               Bus2IP_CS,
  input [31:0]        Bus2IP_Data,
  output reg [31:0]   IP2Bus_Data,
  output reg          IP2Bus_WrAck,
  output reg          IP2Bus_RdAck,
  output              IP2Bus_Error,
   
  input               clk,
  input               rst_n,

  input [31:0]          tx_pcie_bc,
  input [31:0]          rx_pcie_bc,
  input [31:0]          tx_pcie_pc,
  input [31:0]          rx_pcie_pc,

  input [11:0]          init_fc_cpld,
  input [7:0]           init_fc_cplh,
  input [11:0]          init_fc_npd,
  input [7:0]           init_fc_nph,
  input [11:0]          init_fc_pd,
  input [7:0]           init_fc_ph,
  input [31:0]          axi_baseaddr,
  input [31:0]          axi_highaddr,
  input                 ddr4_calib_done,

  output reg [31:0]     clk_period_reg,
  output reg [1:0]      scaling_factor,
  output reg [47:0]     mac_id_0,          
  output reg [47:0]     mac_id_1,
  input  [7:0]          phy_0_status,
  input  [7:0]          phy_1_status
);

  //- Address offset definitions
  localparam [15:0]
      //- Design Info
    DESIGN_VERSION = (C_S_AXI_BASEADDR + 16'h0000),
    DESIGN_STATUS  = (C_S_AXI_BASEADDR + 16'h0004), 
    SCALE_FACTOR   = (C_S_AXI_BASEADDR + 16'h0008),
    SCRATCHPAD     = (C_S_AXI_BASEADDR + 16'h0010),
    CLK_PERIOD     = (C_S_AXI_BASEADDR + 16'h0014),
    
    //- PCIe Performance Monitor
    TX_PCIE_BC  = (C_S_AXI_BASEADDR + 16'h0100),
    RX_PCIE_BC  = (C_S_AXI_BASEADDR + 16'h0104),
    TX_PCIE_PC  = (C_S_AXI_BASEADDR + 16'h0108),
    RX_PCIE_PC  = (C_S_AXI_BASEADDR + 16'h010C),
    INIT_FC_CPLD= (C_S_AXI_BASEADDR + 16'h0110),
    INIT_FC_CPLH= (C_S_AXI_BASEADDR + 16'h0114),
    INIT_FC_NPD = (C_S_AXI_BASEADDR + 16'h0118),
    INIT_FC_NPH = (C_S_AXI_BASEADDR + 16'h011C),
    INIT_FC_PD  = (C_S_AXI_BASEADDR + 16'h0120),
    INIT_FC_PH  = (C_S_AXI_BASEADDR + 16'h0124),
      //- Advertize AXI Buffer address
    AXI_BASEADDR = (C_S_AXI_BASEADDR + 16'h0200),
    AXI_HIGHADDR = (C_S_AXI_BASEADDR + 16'h0204),
      //- MAC address
    MAC_0_ID_LOW   = (C_S_AXI_BASEADDR + 16'h0404),
    MAC_0_ID_HIGH  = (C_S_AXI_BASEADDR + 16'h0408),
    MAC_1_ID_LOW   = (C_S_AXI_BASEADDR + 16'h0410),
    MAC_1_ID_HIGH  = (C_S_AXI_BASEADDR + 16'h0414),
    PHY_STATUS     = (C_S_AXI_BASEADDR + 16'h0418);
      
  reg [31:0] scratchpad_reg;

  assign IP2Bus_Error  = 1'b0;
  /*
  * On the assertion of CS, RNW port is checked for read or a write
  * transaction.    
  * In case of a write transaction, the relevant register is written to and
  * WrAck generated.
  * In case of reads, the read data along with RdAck is generated.
  */
  always @(posedge clk)
    if (rst_n == 1'b0)
    begin
      IP2Bus_Data   <= 32'd0;
      IP2Bus_WrAck  <= 1'b0;
      IP2Bus_RdAck  <= 1'b0;
      scaling_factor  <= 2'b10;
      scratchpad_reg  <= 32'hDEADDEAF;
      clk_period_reg  <= 32'h0EE6B280;
      mac_id_0        <= 48'hAABBCCDDEEFF;
      mac_id_1        <= 48'hFFEEDDCCBBAA;
    end
    else
    begin
      //- Write transaction
      if (Bus2IP_CS & ~Bus2IP_RNW)
      begin
        if (Bus2IP_Addr[11:8] == 'h0)
        case (Bus2IP_Addr[7:0])
          SCALE_FACTOR[7:0]   : scaling_factor  <= Bus2IP_Data[1:0];
          SCRATCHPAD[7:0]     : scratchpad_reg  <= Bus2IP_Data;
          CLK_PERIOD[7:0]     : clk_period_reg  <= Bus2IP_Data;
        endcase
        else if (Bus2IP_Addr[11:8] == 'h4)
        case (Bus2IP_Addr[7:0])
          MAC_0_ID_LOW[7:0]   : mac_id_0[31:0]  <= Bus2IP_Data;
          MAC_0_ID_HIGH[7:0]  : mac_id_0[47:32] <= Bus2IP_Data[15:0];
          MAC_1_ID_LOW[7:0]   : mac_id_1[31:0]  <= Bus2IP_Data;
          MAC_1_ID_HIGH[7:0]  : mac_id_1[47:32] <= Bus2IP_Data[15:0];          
        endcase
//        else if (Bus2IP_Addr[11:8] == 'h2)
//        case (Bus2IP_Addr[7:0])
//        endcase
        IP2Bus_WrAck  <= 1'b1;
        IP2Bus_Data   <= 32'd0;
        IP2Bus_RdAck  <= 1'b0;
      end
      else if (Bus2IP_CS & Bus2IP_RNW)    //- Read transaction
      begin
        if (Bus2IP_Addr[11:8] == 'h0)
        case (Bus2IP_Addr[7:0])
          DESIGN_VERSION[7:0]   : IP2Bus_Data <= {24'd0, 4'd1, 4'd0};
          DESIGN_STATUS[7:0]    : IP2Bus_Data <= {31'd0, ddr4_calib_done};
          SCALE_FACTOR[7:0]     : IP2Bus_Data <= {30'd0, scaling_factor};
          SCRATCHPAD[7:0]       : IP2Bus_Data <= scratchpad_reg;
          CLK_PERIOD[7:0]       : IP2Bus_Data <= clk_period_reg;
        endcase  
        else if (Bus2IP_Addr[11:8] == 'h1)
        case (Bus2IP_Addr[7:0])
          TX_PCIE_BC[7:0]       : IP2Bus_Data <= tx_pcie_bc;  
          RX_PCIE_BC[7:0]       : IP2Bus_Data <= rx_pcie_bc;  
          TX_PCIE_PC[7:0]       : IP2Bus_Data <= tx_pcie_pc;  
          RX_PCIE_PC[7:0]       : IP2Bus_Data <= rx_pcie_pc;  
          INIT_FC_CPLD[7:0]     : IP2Bus_Data <= {20'd0, init_fc_cpld};
          INIT_FC_CPLH[7:0]     : IP2Bus_Data <= {24'd0, init_fc_cplh};
          INIT_FC_NPD[7:0]      : IP2Bus_Data <= {20'd0, init_fc_npd};
          INIT_FC_NPH[7:0]      : IP2Bus_Data <= {24'd0, init_fc_nph};
          INIT_FC_PH[7:0]       : IP2Bus_Data <= {24'd0, init_fc_ph};
          INIT_FC_PD[7:0]       : IP2Bus_Data <= {20'd0, init_fc_pd};
        endcase
        else if (Bus2IP_Addr[11:8] == 'h2)
        case (Bus2IP_Addr[7:0])
          AXI_BASEADDR[7:0]     : IP2Bus_Data <= axi_baseaddr;
          AXI_HIGHADDR[7:0]     : IP2Bus_Data <= axi_highaddr;
        endcase
        else if (Bus2IP_Addr[11:8] == 'h4)
        case (Bus2IP_Addr[7:0])
          MAC_0_ID_LOW[7:0]     : IP2Bus_Data <= mac_id_0[31:0];
          MAC_0_ID_HIGH[7:0]    : IP2Bus_Data <= {16'd0, mac_id_0[47:32]};
          MAC_1_ID_LOW[7:0]     : IP2Bus_Data <= mac_id_1[31:0];
          MAC_1_ID_HIGH[7:0]    : IP2Bus_Data <= {16'd0, mac_id_1[47:32]};
          PHY_STATUS[7:0]       : IP2Bus_Data <= {16'd0, phy_1_status, phy_0_status};
        endcase
        IP2Bus_RdAck  <= 1'b1;
        IP2Bus_WrAck  <= 1'b0;
      end  
      else begin
        IP2Bus_Data   <= 32'd0;
        IP2Bus_WrAck  <= 1'b0;
        IP2Bus_RdAck  <= 1'b0;
      end
    end

endmodule
