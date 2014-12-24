//- AXILITE control modules for AXI-MM GEN/CHK

`timescale 1ns/1ps

module user_axilite_control #(
  parameter C_S_AXI_BUF_BASEADDR  = 32'h4000_0000,
  parameter C_S_AXI_BUF_HIGHADDR  = 32'h40FF_FFFF,
  //- AXI4 Lite Address Space
  parameter C_S_AXI_BASEADDR    = 32'h0000_0000,
  parameter C_S_AXI_HIGHADDR    = 32'h0000_0FFF,
  parameter C_NUM_ADDRESS_RANGES  = 1,
  parameter C_S_AXI_MIN_SIZE = 32'h0000_0FFF,
  parameter C_TOTAL_NUM_CE = 1
) (
  input                 s_axi_aclk,
  input                 s_axi_areset_n,
  input [31:0]          s_axi_awaddr,
  input                 s_axi_awvalid,
  output                s_axi_awready,
  input [31:0]          s_axi_wdata,
  input [3:0]           s_axi_wstrb,
  input                 s_axi_wvalid,
  output                s_axi_wready,
  output [1:0]          s_axi_bresp,
  output                s_axi_bvalid,
  input                 s_axi_bready,
  input [31:0]          s_axi_araddr,
  input                 s_axi_arvalid,
  output                s_axi_arready,
  output [31:0]         s_axi_rdata,
  output                s_axi_rvalid,
  output [1:0]          s_axi_rresp,
  input                 s_axi_rready,

    //- PCIe Performance Monitor Interface
  input [31:0]          tx_pcie_bc,
  input [31:0]          rx_pcie_bc,
 // input [31:0]          tx_pcie_pc,
 // input [31:0]          rx_pcie_pc,

  input [11:0]          init_fc_cpld,
  input [7:0]           init_fc_cplh,
  input [11:0]          init_fc_npd,
  input [7:0]           init_fc_nph,
  input [11:0]          init_fc_pd,
  input [7:0]           init_fc_ph,

  output [31:0]         clk_period,
  output [1:0]          scaling_factor,
  output [47:0]         mac_id_0,
  output [47:0]         mac_id_1,
  input  [7:0]          phy_0_status,
  input  [7:0]          phy_1_status,
  input                 ddr4_calib_done
);

  wire                                  Bus2IP_Clk;
  wire                                  Bus2IP_Resetn;
  wire [31:0]                           Bus2IP_Addr;
  wire                                  Bus2IP_RNW;
  wire [3:0]                            Bus2IP_BE;
  wire [C_NUM_ADDRESS_RANGES-1:0]       Bus2IP_CS;
  wire [C_TOTAL_NUM_CE-1:0]             Bus2IP_RdCE;
  wire [C_TOTAL_NUM_CE-1:0]             Bus2IP_WrCE;
  wire [31:0]                           Bus2IP_Data;
  wire [31:0]                           IP2Bus_Data;
  wire                                  IP2Bus_WrAck;
  wire                                  IP2Bus_RdAck;
  wire                                  IP2Bus_Error; 

//- Temporary fix for IPF wrapper issue
//- rready=rvalid=1 and if arrvalid=1 at the same time, this read request is
//ignored
  wire lite_arready_out;

  assign s_axi_arready = s_axi_rvalid ? 1'b0 : lite_arready_out;
  /*
   *    Instantiation of AXI Lite IPIF Slave which converts the AXI Lite
   *    interface to IPIF
   */
   
  axi_lite_ipif #(
    .C_S_AXI_DATA_WIDTH     (32),
    .C_S_AXI_ADDR_WIDTH     (32),
    .C_S_AXI_MIN_SIZE       (C_S_AXI_MIN_SIZE   ),
    .C_DPHASE_TIMEOUT       (32),
    .C_NUM_ADDRESS_RANGES   (C_NUM_ADDRESS_RANGES),
    .C_TOTAL_NUM_CE         (C_TOTAL_NUM_CE     ),
    .C_ARD_ADDR_RANGE_ARRAY ({C_S_AXI_BASEADDR,C_S_AXI_HIGHADDR}),
    .C_ARD_NUM_CE_ARRAY     ({8'd1})
//    .C_FAMILY               ("kintex8")
  ) axi_lite_ipif_inst (
    .S_AXI_ACLK             (s_axi_aclk          ),
    .S_AXI_ARESETN          (s_axi_areset_n     ),
    .S_AXI_AWADDR           (s_axi_awaddr       ),
    .S_AXI_AWVALID          (s_axi_awvalid      ),
    .S_AXI_AWREADY          (s_axi_awready      ),
    .S_AXI_WDATA            (s_axi_wdata        ),
    .S_AXI_WSTRB            (s_axi_wstrb        ),
    .S_AXI_WVALID           (s_axi_wvalid       ),
    .S_AXI_WREADY           (s_axi_wready       ),
    .S_AXI_BRESP            (s_axi_bresp        ),
    .S_AXI_BVALID           (s_axi_bvalid       ),
    .S_AXI_BREADY           (s_axi_bready       ),
    .S_AXI_ARADDR           (s_axi_araddr       ),
    .S_AXI_ARVALID          (s_axi_arvalid      ),
    .S_AXI_ARREADY          (lite_arready_out   ),  //s_axi_arready      ),
    .S_AXI_RDATA            (s_axi_rdata        ),
    .S_AXI_RRESP            (s_axi_rresp        ),
    .S_AXI_RVALID           (s_axi_rvalid       ),
    .S_AXI_RREADY           (s_axi_rready       ),
    .Bus2IP_Clk             (Bus2IP_Clk         ),
    .Bus2IP_Resetn          (Bus2IP_Resetn      ),
    .Bus2IP_Addr            (Bus2IP_Addr        ),
    .Bus2IP_RNW             (Bus2IP_RNW         ),
    .Bus2IP_BE              (Bus2IP_BE          ),
    .Bus2IP_CS              (Bus2IP_CS          ),
    .Bus2IP_RdCE            (Bus2IP_RdCE        ),
    .Bus2IP_WrCE            (Bus2IP_WrCE        ),
    .Bus2IP_Data            (Bus2IP_Data        ),
    .IP2Bus_Data            (IP2Bus_Data        ),
    .IP2Bus_WrAck           (IP2Bus_WrAck       ),
    .IP2Bus_RdAck           (IP2Bus_RdAck       ),
    .IP2Bus_Error           (IP2Bus_Error       )
  );

  /*  
   * Register Logic tied to the IPIC interface
   */
  registers_common #(
    .C_S_AXI_BASEADDR   (C_S_AXI_BASEADDR ),
    .C_S_AXI_HIGHADDR   (C_S_AXI_HIGHADDR )
  ) reg_common_i (
    .Bus2IP_Addr            (Bus2IP_Addr        ),
    .Bus2IP_RNW             (Bus2IP_RNW         ),
    .Bus2IP_CS              (Bus2IP_CS          ),
    .Bus2IP_Data            (Bus2IP_Data        ),
    .IP2Bus_Data            (IP2Bus_Data        ),
    .IP2Bus_WrAck           (IP2Bus_WrAck       ),
    .IP2Bus_RdAck           (IP2Bus_RdAck       ),
    .IP2Bus_Error           (IP2Bus_Error       ), 

    .tx_pcie_bc             (tx_pcie_bc         ),   
    .rx_pcie_bc             (rx_pcie_bc         ),   
    .tx_pcie_pc             (tx_pcie_pc         ),   
    .rx_pcie_pc             (rx_pcie_pc         ),   
    .init_fc_cpld           (init_fc_cpld       ),
    .init_fc_cplh           (init_fc_cpld       ),
    .init_fc_npd            (init_fc_npd        ),
    .init_fc_nph            (init_fc_nph        ),
    .init_fc_pd             (init_fc_pd         ),
    .init_fc_ph             (init_fc_ph         ),
    .ddr4_calib_done        (ddr4_calib_done    ),
    .clk_period_reg         (clk_period         ),
    .scaling_factor         (scaling_factor     ),
    .mac_id_0               (mac_id_0           ),
    .mac_id_1               (mac_id_1           ),
    .phy_0_status           (phy_0_status       ),
    .phy_1_status           (phy_1_status       ),
    .axi_baseaddr           (C_S_AXI_BUF_BASEADDR),
    .axi_highaddr           (C_S_AXI_BUF_HIGHADDR),
    .clk                    (s_axi_aclk         ),
    .rst_n                  (s_axi_areset_n     )
  ); 


endmodule
