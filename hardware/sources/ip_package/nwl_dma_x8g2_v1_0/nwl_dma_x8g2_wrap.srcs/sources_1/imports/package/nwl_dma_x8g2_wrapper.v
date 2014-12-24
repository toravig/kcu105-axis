
`timescale 1ps / 1ps

module nwl_dma_x8g2_wrapper #(

    // PCI Express Interface Parameters
    parameter   NUM_LANES                           = 8,                        // Number of PCI Express Lanes
    parameter   DMA_CHANNEL_WIDTH                   = 2,                        // Number of DMA Channels == 2^DMA_CHANNEL_WIDTH
    
    parameter   NUM_DMA_CHANNELS                    = (1<<DMA_CHANNEL_WIDTH),   //   ..
    parameter   SGLF_CH_ADDR_WIDTH                  = 3,                        // Source and Destination SGL FIFOs are 2^SGLF_CH_ADDR_WIDTH SGL elements per channel
    parameter   SGL_WIDTH                           = 128,                      // Data Width of SGL Elements
    parameter   P_DATA_WIDTH                        = 128,                      // PCI Express Core Data Width
    // AXI Slave Interface Parameters
    parameter   S_ID_WIDTH                          = 4,                        // AXI Master Port Widths
    parameter   S_ADDR_WIDTH                        = 32,                       //   ..
    parameter   S_LEN_WIDTH                         = 4,                        //   ..
    parameter   S_DATA_WIDTH                        = 128,                      //   ..

    // AXI Master Interface Parameters
    parameter   M_ID_WIDTH                          = 4,                        // AXI Master Port Widths
    parameter   M_ADDR_WIDTH                        = 32,                       //   ..
    parameter   M_LEN_WIDTH                         = 4,                        //   ..
    parameter   M_DATA_WIDTH                        = 128                      //   ..
    
)(

    input                                        user_clk,
    input                                        user_reset,
    input                                        user_lnk_up,

    output                                       s_axis_rq_tlast,
    output    [P_DATA_WIDTH-1:0]                 s_axis_rq_tdata,
    output    [59:0]                             s_axis_rq_tuser,
    output    [(P_DATA_WIDTH/32)-1:0]            s_axis_rq_tkeep,
    output                                       s_axis_rq_tvalid,
    input     [3:0]                              s_axis_rq_tready,
    
    input    [P_DATA_WIDTH-1:0]                  m_axis_rc_tdata,
    input    [74:0]                              m_axis_rc_tuser,
    input                                        m_axis_rc_tlast,
    input    [(P_DATA_WIDTH/32)-1:0]             m_axis_rc_tkeep,
    input                                        m_axis_rc_tvalid,
    output   [21:0]                              m_axis_rc_tready,
    
    input    [P_DATA_WIDTH-1:0]                  m_axis_cq_tdata,
    input    [84:0]                              m_axis_cq_tuser,
    input                                        m_axis_cq_tlast,
    input    [(P_DATA_WIDTH/32)-1:0]             m_axis_cq_tkeep,
    input                                        m_axis_cq_tvalid,
    output   [21:0]                              m_axis_cq_tready,
    
    output   [P_DATA_WIDTH-1:0]                  s_axis_cc_tdata,
    output   [32:0]                              s_axis_cc_tuser,
    output                                       s_axis_cc_tlast,
    output   [(P_DATA_WIDTH/32)-1:0]             s_axis_cc_tkeep,
    output                                       s_axis_cc_tvalid,
    input    [3:0]                               s_axis_cc_tready,
    
    // AXI Interrupt Interface (clk clock domain)
    //output                                       int_dma,                    // Local CPU Interrupt Request - DMA
    
    output  [NUM_DMA_CHANNELS-1:0]              sgl_dma_ch_en,
    output  [NUM_DMA_CHANNELS-1:0]              sgl_dma_ch_reset,

    // Direct SGL Write Allocate Interface (clk clock domain)
    input                                       sgl_alloc_valid,            
    output                                      sgl_alloc_ready,            //
    input   [SGLF_CH_ADDR_WIDTH-1:0]            sgl_alloc_num_sgl,          //
    input                                       sgl_alloc_dst_src_n,
    input   [DMA_CHANNEL_WIDTH-1:0]             sgl_alloc_channel,          //
    output  [NUM_DMA_CHANNELS-1:0]              sgl_alloc_src_full,         //
    output  [NUM_DMA_CHANNELS-1:0]              sgl_alloc_src_aready,       //
    output  [NUM_DMA_CHANNELS-1:0]              sgl_alloc_src_empty,        //
    output  [NUM_DMA_CHANNELS-1:0]              sgl_alloc_dst_full,         //
    output  [NUM_DMA_CHANNELS-1:0]              sgl_alloc_dst_aready,       //
    output  [NUM_DMA_CHANNELS-1:0]              sgl_alloc_dst_empty,
    // Direct SGL Write Interface (clk clock domain)
    input                                       sgl_wr_valid,               //
    output                                      sgl_wr_ready,               //
    input   [SGL_WIDTH-1:0]                     sgl_wr_data,                //
    input                                       sgl_wr_dst_src_n,           //
    input   [DMA_CHANNEL_WIDTH-1:0]             sgl_wr_channel,             //

    // AXI Master Interface (clk clock domain)
    output                                      m_awvalid,                  // Write Address Channel
    input                                       m_awready,                  //
    output  [M_ID_WIDTH-1:0]                    m_awid,                     //
    output  [M_ADDR_WIDTH-1:0]                  m_awaddr,                   //
    output  [M_LEN_WIDTH-1:0]                   m_awlen,                    //
    output  [2:0]                               m_awsize,                   //
    output  [1:0]                               m_awburst,                  //
    output  [2:0]                               m_awprot,                   //
    output  [3:0]                               m_awcache,                  //
    output  [47:0]                              m_awuser,                   // Write Address Channel - non-standard AXI ports

    output                                      m_wvalid,                   // Write Data Channel
    input                                       m_wready,                   //
    output  [M_ID_WIDTH-1:0]                    m_wid,                      //
    output  [M_DATA_WIDTH-1:0]                  m_wdata,                    //
    output  [(M_DATA_WIDTH/8)-1:0]              m_wstrb,                    //
    output                                      m_wlast,                    //

    input                                       m_bvalid,                   // Write Response Channel
    output                                      m_bready,                   //
    input   [M_ID_WIDTH-1:0]                    m_bid,                      //
    input   [1:0]                               m_bresp,                    //

    output                                      m_arvalid,                  // Read Address Channel
    input                                       m_arready,                  //
    output  [M_ID_WIDTH-1:0]                    m_arid,                     //
    output  [M_ADDR_WIDTH-1:0]                  m_araddr,                   //
    output  [M_LEN_WIDTH-1:0]                   m_arlen,                    //
    output  [2:0]                               m_arsize,                   //
    output  [1:0]                               m_arburst,                  //
    output  [2:0]                               m_arprot,                   //
    output  [3:0]                               m_arcache,                  //
    output  [47:0]                              m_aruser,                 // Read Address Channel - non-standard AXI ports

    input                                       m_rvalid,                   // Read Data Channel
    output                                      m_rready,                   //
    input   [M_ID_WIDTH-1:0]                    m_rid,                      //
    input   [M_DATA_WIDTH-1:0]                  m_rdata,                    //
    input   [1:0]                               m_rresp,                    //
    input                                       m_rlast,                    //

    // AXI Slave Interface (clk clock domain)
    input                                       s_awvalid,                  // Write Address Channel
    output                                      s_awready,                  //
    input   [S_ID_WIDTH-1:0]                    s_awid,                     //
    input   [S_ADDR_WIDTH-1:0]                  s_awaddr,                   //
    input   [S_LEN_WIDTH-1:0]                   s_awlen,                    //
    input   [2:0]                               s_awsize,                   //
    input   [1:0]                               s_awburst,                  //
    input   [2:0]                               s_awprot,                   //

    input                                       s_wvalid,                   // Write Data Channel
    output                                      s_wready,                   //
    input   [S_ID_WIDTH-1:0]                    s_wid,                      //
    input   [S_DATA_WIDTH-1:0]                  s_wdata,                    //
    input   [(S_DATA_WIDTH/8)-1:0]              s_wstrb,                    //
    input                                       s_wlast,                    //

    output                                      s_bvalid,                   // Write Response Channel
    input                                       s_bready,                   //
    output  [S_ID_WIDTH-1:0]                    s_bid,                      //
    output  [1:0]                               s_bresp,                    //

    input                                       s_arvalid,                  // Read Address Channel
    output                                      s_arready,                  //
    input   [S_ID_WIDTH-1:0]                    s_arid,                     //
    input   [S_ADDR_WIDTH-1:0]                  s_araddr,                   //
    input   [S_LEN_WIDTH-1:0]                   s_arlen,                    //
    input   [2:0]                               s_arsize,                   //
    input   [1:0]                               s_arburst,                  //
    input   [2:0]                               s_arprot,                   //

    output                                      s_rvalid,                   // Read Data Channel
    input                                       s_rready,                   //
    output  [S_ID_WIDTH-1:0]                    s_rid,                      //
    output  [S_DATA_WIDTH-1:0]                  s_rdata,                    //
    output  [1:0]                               s_rresp,                    //
    output                                      s_rlast,                    //
  
  /*
    input   [7:0]                               fc_ph,
    input   [11:0]                              fc_pd,
    input   [7:0]                               fc_nph,
    input   [11:0]                              fc_npd,
    input   [11:0]                              fc_cpld,
    input   [7:0]                               fc_cplh,
    input   [2:0]                               fc_sel,
*/
    output                                      cfg_err_cor,
    output                                      cfg_err_uncor,
    input   [2:0]                               cfg_max_payload,
    input   [2:0]                               cfg_max_read_req,
    input   [15:0]                              cfg_function_status,
    output                                      pcie_cq_np_req,
    input   [3:0]                               cfg_flr_in_process,
    input   [7:0]                               cfg_vf_flr_in_process,
    output  [3:0]                               cfg_flr_done,
    output  [7:0]                               cfg_vf_flr_done,
    output  [15:0]                              cfg_vend_id,
    output  [15:0]                              cfg_subsys_vend_id,
    output  [15:0]                              cfg_dev_id,
    output  [15:0]                              cfg_subsys_id,
    output  [7:0]                               cfg_rev_id,

    input   [31:0]                              cfg_mgmt_read_data,
    input                                       cfg_mgmt_read_write_done,
    output  [18:0]                              cfg_mgmt_addr,
    output                                      cfg_mgmt_write,
    output  [31:0]                              cfg_mgmt_write_data,
    output  [3:0]                               cfg_mgmt_byte_enable,
    output                                      cfg_mgmt_read,
    output                                      cfg_mgmt_type1_cfg_reg_access,

    output   [3:0]                               cfg_interrupt_int,
    input                                        cfg_interrupt_sent,
    output   [31:0]                              cfg_interrupt_msi_int,
    input                                        cfg_interrupt_msi_sent,
    input    [3:0]                               cfg_interrupt_msi_enable,
    input    [3:0]                               cfg_interrupt_msix_enable,
    input    [3:0]                               cfg_interrupt_msix_mask
    
);

    // -------------------------------------------------
    // !! Do not modify any of the parameters below   !!
    // !! Only the default configuration is supported !!
    // -------------------------------------------------

    // Controlling Parameters for Expresso DMA RAM Sizes
    parameter   P_MAX_PAYLOAD_ADDR_WIDTH            = 9;    // Maximum PCI Express Payload Size Supported == 2^P_MAX_PAYLOAD_ADDR_WIDTH bytes.  Must be 9, 8, or 7.  PCIe Core must not advertise > than this amount.
    parameter   DMA_PCIE_M_R_BADDR_WIDTH            = 13;   // PCIe Master Read Reorder Queue == 2^DMA_PCIE_M_R_BADDR_WIDTH bytes
    parameter   DMA_PCIE_S_W_BADDR_WIDTH            = 11;   // PCIe Slave Write Data FIFO     == 2^DMA_PCIE_S_W_BADDR_WIDTH bytes
    parameter   DMA_AXI_M_R_BADDR_WIDTH             = 12;   // AXI  Master Read Reorder Queue == 2^DMA_AXI_M_R_BADDR_WIDTH  bytes
    parameter   DMA_AXI_S_W_BADDR_WIDTH             = 10;   // AXI  Slave  Write FIFO         == 2^DMA_AXI_S_W_BADDR_WIDTH  bytes

    parameter   FDBK_BITS                           = 8;                        // Number of Equalization Feedback bits per lane == 8 (Figure of Merit)
    parameter   NUM_F_VF                            = 1;                        // Single Function
    parameter   P_REMAIN_WIDTH                      = ((P_DATA_WIDTH >= 256) ? 5 :      // Address bits required to address all bytes of P_DATA_WIDTH
                                                      ((P_DATA_WIDTH >= 128) ? 4 :
                                                      ((P_DATA_WIDTH >=  64) ? 3 : 2)));

    // DMA Channel Parameters
    

    // Interrupt Parameters
    parameter   INTERRUPT_VECTOR_BITS               = ((DMA_CHANNEL_WIDTH>5) ?  DMA_CHANNEL_WIDTH : 5); // Number of Interrupt Vectors == 2^INTERRUPT_VECTOR_BITS.  Minimum 1 vector per DMA Channel.  Min 4 vectors per Function.  Minimum value == 5 (32 vectors).

    // Translation Parameters
    parameter   NUM_EGRESS_TRAN                     = 2;                        // Number of Egress  Address Translations supported == NUM_EGRESS_TRAN 
    parameter   NUM_INGRESS_TRAN                    = 2;                        // Number of Ingress Address Translations supported == NUM_INGRESS_TRAN

    // AXI Slave Interface Parameters
    //parameter   S_ID_WIDTH                          = 16;                       // AXI Slave Port Widths
    //parameter   S_ADDR_WIDTH                        = 64;                       //   ..
    //parameter   S_LEN_WIDTH                         = 4;                        //   ..
    //parameter   S_DATA_WIDTH                        = 256;                      //   ..

    // AXI Master Outstanding Transacton Limits
    parameter   M_RD_WIDTH                          = 4;                        // Maximum number of outstanding read requests supported by AXI Master Read Reorder Queue == 2^M_RD_WIDTH.
    parameter   M_RQ_TAG_WIDTH                      = M_RD_WIDTH;               //   AXI Reorder Queue reads may be subsequently fragmented by the AXI Master to comply with AXI Max Read Request Size Limits.

    // AXI Slave Outstanding Transacton Limits
    parameter   S_WR_WIDTH                          = 4;                        // Maximum number of outstanding AXI Slave write requests  == 2^S_WR_WIDTH
    parameter   S_RD_WIDTH                          = 4;                        // Maximum number of outstanding AXI Slave read  requests  == 2^S_RD_WIDTH

    // PCI Express Outstanding Transacton Limits
    parameter   P_WR_WIDTH                          = 4;                        // Maximum number of outstanding PCIe slave write requests == 2^P_WR_WIDTH
    parameter   P_RD_WIDTH                          = M_RD_WIDTH;               // Maximum number of outstanding PCIe slave read requests  == 2^P_RD_WIDTH

    // DMA Outstanding Transacton Limits
    parameter   SGL_RD_WIDTH                        = 4;                                                     // Limit outstanding DMA SGL  read transactions to 2^SGL_RD_WIDTH
    parameter   DMA_RD_WIDTH                        = ((M_RD_WIDTH > S_RD_WIDTH) ? M_RD_WIDTH : S_RD_WIDTH); // Limit outstanding DMA Data read transactions to 2^DMA_RD_WIDTH

    parameter   P_RQ_TAG_WIDTH                      = S_RD_WIDTH;               // Maximum number of outstanding read requests supported by PCIe Master Read Reorder Queue == 2^P_RQ_TAG_WIDTH.

    // Interconnect Data Width is the widest of all interfaces
    parameter   X_DATA_WIDTH                        = ((M_DATA_WIDTH > S_DATA_WIDTH) ? M_DATA_WIDTH : S_DATA_WIDTH);
    parameter   I_DATA_WIDTH                        = ((X_DATA_WIDTH > P_DATA_WIDTH) ? X_DATA_WIDTH : P_DATA_WIDTH);
    parameter   I_REMAIN_WIDTH                      = ((I_DATA_WIDTH >= 256) ? 5 :          // Address bits required to address all bytes of I_DATA_WIDTH
                                                      ((I_DATA_WIDTH >= 128) ? 4 :
                                                      ((I_DATA_WIDTH >=  64) ? 3 : 2)));
    
    parameter   P_EODCNT_WIDTH                      = ((I_DATA_WIDTH > P_DATA_WIDTH) ? (I_REMAIN_WIDTH - P_REMAIN_WIDTH) : 1);

    // DMA Channel External RAM Port Size - Derived from other parameters
    parameter   DMA_SGL_SRC_ADDR_WIDTH              = SGLF_CH_ADDR_WIDTH + DMA_CHANNEL_WIDTH;
    parameter   DMA_SGL_SRC_DATA_WIDTH              = SGL_WIDTH;

    parameter   DMA_SGL_DST_ADDR_WIDTH              = SGLF_CH_ADDR_WIDTH + DMA_CHANNEL_WIDTH;
    parameter   DMA_SGL_DST_DATA_WIDTH              = SGL_WIDTH;

    parameter   DMA_SGL_STA_ADDR_WIDTH              = SGLF_CH_ADDR_WIDTH + DMA_CHANNEL_WIDTH;
    parameter   DMA_SGL_STA_DATA_WIDTH              = (1  +               
                                                       1  +
                                                       1  +
                                                       27 +
                                                       16 +
                                                       16 +               
                                                       16);

    // Bridge External RAM Port Sizes - Derived from other parameters
    parameter   DMA_PCIE_M_R_ADDR_WIDTH             = DMA_PCIE_M_R_BADDR_WIDTH - I_REMAIN_WIDTH;
    parameter   DMA_PCIE_M_R_DATA_WIDTH             = I_DATA_WIDTH;

    parameter   DMA_PCIE_S_W_ADDR_WIDTH             = DMA_PCIE_S_W_BADDR_WIDTH - I_REMAIN_WIDTH;
    parameter   DMA_PCIE_S_W_DATA_WIDTH             = 3 + I_DATA_WIDTH + 1;

    parameter   DMA_AXI_M_R_ADDR_WIDTH              = DMA_AXI_M_R_BADDR_WIDTH - I_REMAIN_WIDTH;
    parameter   DMA_AXI_M_R_DATA_WIDTH              = I_DATA_WIDTH;

    parameter   DMA_AXI_MSG_ADDR_WIDTH              = 7;
    parameter   DMA_AXI_MSG_DATA_WIDTH              = (M_ADDR_WIDTH + 32 + 16 + 8 + 8 + 2 + 1 + 3);

    parameter   DMA_AXI_S_W_ADDR_WIDTH              = DMA_AXI_S_W_BADDR_WIDTH - I_REMAIN_WIDTH;
    parameter   DMA_AXI_S_W_DATA_WIDTH              = 1 + I_DATA_WIDTH;

    parameter   DMA_PCIE_TX_W_ADDR_WIDTH            = ((P_MAX_PAYLOAD_ADDR_WIDTH + 1) - I_REMAIN_WIDTH);   // PCIe Master Tx TLP FIFO == 2^DMA_PCIE_TX_W_BADDR_WIDTH bytes - must hold a minimum of 2*Max Payload Size Supported bytes
    parameter   DMA_PCIE_TX_W_DATA_WIDTH_I_EQ_32    = (1 + P_RQ_TAG_WIDTH +                                   1 + 1 + 1 + I_DATA_WIDTH);
    parameter   DMA_PCIE_TX_W_DATA_WIDTH_I_EQ_P     = (1 + P_RQ_TAG_WIDTH + I_REMAIN_WIDTH +                  1 + 1 + 1 + I_DATA_WIDTH);
    parameter   DMA_PCIE_TX_W_DATA_WIDTH_I_NE_P     = (1 + P_RQ_TAG_WIDTH + I_REMAIN_WIDTH + P_EODCNT_WIDTH + 1 + 1 + 1 + I_DATA_WIDTH);
    parameter   DMA_PCIE_TX_W_DATA_WIDTH            = ((I_DATA_WIDTH == 32          ) ? DMA_PCIE_TX_W_DATA_WIDTH_I_EQ_32 :
                                                      ((I_DATA_WIDTH == P_DATA_WIDTH) ? DMA_PCIE_TX_W_DATA_WIDTH_I_EQ_P  : DMA_PCIE_TX_W_DATA_WIDTH_I_NE_P));
    parameter   DMA_CH_REG_ADDR_WIDTH               = DMA_CHANNEL_WIDTH;
    parameter   DMA_CH_REG_DATA_WIDTH               = 512/2;
    parameter   DMA_MSIX_TAB_ADDR_WIDTH             = INTERRUPT_VECTOR_BITS - 2;    // MSI-X Table Entries are 128-bit; 4 table entries fit per 512-bit REG_DATA_WIDTH; minimum DMA_MSIX_TAB_ADDR_WIDTH is 1 (8 table entries);
    parameter   DMA_MSIX_TAB_DATA_WIDTH             = 512;


// ----------------
// -- Parameters --
// ----------------

// -------------------------------------------------
// !! Do not modify any of the parameters below   !!
// !! Only the default configuration is supported !!
// -------------------------------------------------
localparam  MSIX_CAP_TABLE_BIR              = 0;                        // MSI-X Table located in BAR0.
localparam  MSIX_CAP_TABLE_OFFSET           = (32'h10000 >> 3);         // MSI-X Table located at byte address offset 0x10000
localparam  MSIX_CAP_PBA_BIR                = 0;                        // MSI-X PBA   located in BAR0.
localparam  MSIX_CAP_PBA_OFFSET             = (32'h18000 >> 3);         // MSI-X PBA   located at byte address offset 0x18000
localparam  NUM_INTERRUPT_VECTORS           = (1<<INTERRUPT_VECTOR_BITS);

wire                           p_is_rp_ep_n;
wire    [15:0]                 p_set_interrupt;
wire   [4:0]                   security_internal;          // Security Level for Internal Egress Address Translations {DMA Registers, MSI-X PBA, MSI-X Table, ECAM, Bridge Regs}
wire   [NUM_EGRESS_TRAN-1:0]   security_egress;            // Security level for Egress  Address Translation[i] == security_egress [i]
wire   [NUM_INGRESS_TRAN-1:0]  security_ingress;           // Security level for Ingress Address Translation[i] == security_ingress[i]
wire   [NUM_DMA_CHANNELS-1:0]  security_dma;               // Security level for                 DMA Channel[i] == security_dma    [i]
wire   [1:0]                   int_msi;                    // Local CPU Interrupt Request - MSI
wire                           int_legacy;                 // Local CPU Interrupt Request - Legacy PCIe INT[A,B,C,D]
wire                           int_misc;                   // Local CPU Interrupt Request - Miscellaneous
reg                            d_rst;
reg                            p_rst;
wire                           p_reset_n;
wire                           p_rst_n;
reg    [3:0]                   cfg_flr_done_reg0;
reg    [7:0]                   cfg_vf_flr_done_reg0;
reg    [3:0]                   cfg_flr_done_reg1;
reg    [7:0]                   cfg_vf_flr_done_reg1;
wire    [11:0]                              fc_cpld;
wire    [7:0]                              fc_cplh;
wire                           m_axis_cq_tready_i;
wire                           m_axis_rc_tready_i;

assign security_internal  = {5{1'b0}};
assign security_egress    = {NUM_EGRESS_TRAN{1'b0}}; 
assign security_ingress   = {NUM_INGRESS_TRAN{1'b0}};
assign security_dma       = {NUM_DMA_CHANNELS{1'b0}};

assign m_axis_cq_tready   = {22{m_axis_cq_tready_i}};
assign m_axis_rc_tready   = {22{m_axis_rc_tready_i}};

// The following outputs are needed from the Xilinx Hard Core CSR module.
//   Tie off until the Xilinx CSR module is available.
assign p_is_rp_ep_n    = 1'b0;  // Set to Endpoint
assign p_set_interrupt = 16'h0; // Set to no interrupts requested

assign p_clk = user_clk;

assign p_reset_n = p_is_rp_ep_n ? ~user_reset : // For Root Port applications PCIe Clock domain should be reset by user_reset_out
                                   user_lnk_up;     // For Endpoint  applications PCIe Clock domain should be reset by user_lnk_up

// Register active high reset since Xilinx flops reset high.  This should allow place & route to recognize that the reset inversion (to comply with the
//   core's active low reset flops) is unnecessary and remove it resulting in a direct register connection between reset source flop and destination flops.
always @(posedge p_clk or negedge p_reset_n)
begin
    if (p_reset_n == 1'b0)
    begin
        d_rst <= 1'b1;
        p_rst <= 1'b1;
    end
    else
    begin
        d_rst <= 1'b0;
        p_rst <= d_rst;
    end
end
assign p_rst_n = ~p_rst;

always @(posedge user_clk)
  begin
   if (user_reset) begin
      cfg_flr_done_reg0       <= 4'b0;
      cfg_vf_flr_done_reg0    <= 8'b0;
      cfg_flr_done_reg1       <= 4'b0;
      cfg_vf_flr_done_reg1    <= 8'b0;
    end
   else begin
      cfg_flr_done_reg0       <= cfg_flr_in_process;
      cfg_vf_flr_done_reg0    <= cfg_vf_flr_in_process;
      cfg_flr_done_reg1       <= cfg_flr_done_reg0;
      cfg_vf_flr_done_reg1    <= cfg_vf_flr_done_reg0;
    end
  end


assign cfg_flr_done[0] = ~cfg_flr_done_reg1[0] && cfg_flr_done_reg0[0];
assign cfg_flr_done[1] = ~cfg_flr_done_reg1[1] && cfg_flr_done_reg0[1];
assign cfg_flr_done[2] = ~cfg_flr_done_reg1[2] && cfg_flr_done_reg0[2];
assign cfg_flr_done[3] = ~cfg_flr_done_reg1[3] && cfg_flr_done_reg0[3];

assign cfg_vf_flr_done[0] = ~cfg_vf_flr_done_reg1[0] && cfg_vf_flr_done_reg0[0]; 
assign cfg_vf_flr_done[1] = ~cfg_vf_flr_done_reg1[1] && cfg_vf_flr_done_reg0[1]; 
assign cfg_vf_flr_done[2] = ~cfg_vf_flr_done_reg1[2] && cfg_vf_flr_done_reg0[2];
assign cfg_vf_flr_done[3] = ~cfg_vf_flr_done_reg1[3] && cfg_vf_flr_done_reg0[3];
assign cfg_vf_flr_done[4] = ~cfg_vf_flr_done_reg1[4] && cfg_vf_flr_done_reg0[4]; 
assign cfg_vf_flr_done[5] = ~cfg_vf_flr_done_reg1[5] && cfg_vf_flr_done_reg0[5];
assign cfg_vf_flr_done[6] = ~cfg_vf_flr_done_reg1[6] && cfg_vf_flr_done_reg0[6]; 
assign cfg_vf_flr_done[7] = ~cfg_vf_flr_done_reg1[7] && cfg_vf_flr_done_reg0[7];

  assign  cfg_vend_id        = 16'h10EE;   
  assign  cfg_subsys_vend_id = 16'h10EE;                                  
  assign  cfg_dev_id         = 16'h8082;   
  assign  cfg_subsys_id      = 16'h8082;                                
  assign  cfg_rev_id         = 8'h00; 
 
 assign fc_cplh = 8'd64;
 assign fc_cpld = 12'd496;
 
mc_dma2 #(

    .MSIX_CAP_TABLE_OFFSET          (MSIX_CAP_TABLE_OFFSET          ),
    .MSIX_CAP_PBA_OFFSET            (MSIX_CAP_PBA_OFFSET            ),
    .P_DATA_WIDTH                   (P_DATA_WIDTH                   ),
    .P_MAX_PAYLOAD_ADDR_WIDTH       (P_MAX_PAYLOAD_ADDR_WIDTH       ),

    .DMA_CHANNEL_WIDTH              (DMA_CHANNEL_WIDTH              ),
    .SGLF_CH_ADDR_WIDTH             (SGLF_CH_ADDR_WIDTH             ),
    .SGL_WIDTH                      (SGL_WIDTH                      ),

    .INTERRUPT_VECTOR_BITS          (INTERRUPT_VECTOR_BITS          ),

    .NUM_EGRESS_TRAN                (NUM_EGRESS_TRAN                ),
    .NUM_INGRESS_TRAN               (NUM_INGRESS_TRAN               ),

    .M_ID_WIDTH                     (M_ID_WIDTH                     ),
    .M_ADDR_WIDTH                   (64), //M_ADDR_WIDTH                   ),
    .M_LEN_WIDTH                    (M_LEN_WIDTH                    ),
    .M_DATA_WIDTH                   (M_DATA_WIDTH                   ),

    .S_ID_WIDTH                     (S_ID_WIDTH                     ),
    .S_ADDR_WIDTH                   (64), //S_ADDR_WIDTH                   ),
    .S_LEN_WIDTH                    (S_LEN_WIDTH                    ),
    .S_DATA_WIDTH                   (S_DATA_WIDTH                   )

) mc_dma (

    // -----------------------------------
    // AXI Clock Domain (clk clock domain)

    .clk                            (user_clk                       ),
    .rst_n                          (user_lnk_up                    ),

    // DMA Channel Enable and Reset Status for resetting the user's design (clk clcok domain)
    
    .sgl_dma_ch_en                  (sgl_dma_ch_en), 
    .sgl_dma_ch_reset               (sgl_dma_ch_reset), 

    .sgl_alloc_valid                (sgl_alloc_valid),
    .sgl_alloc_ready                (sgl_alloc_ready), 
    .sgl_alloc_num_sgl              (sgl_alloc_num_sgl),
    .sgl_alloc_dst_src_n            (sgl_alloc_dst_src_n),
    .sgl_alloc_channel              (sgl_alloc_channel),
    .sgl_alloc_src_full             (sgl_alloc_src_full),
    .sgl_alloc_src_aready           (sgl_alloc_src_aready),
    .sgl_alloc_src_empty            (sgl_alloc_src_empty),
    .sgl_alloc_dst_full             (sgl_alloc_dst_full),
    .sgl_alloc_dst_aready           (sgl_alloc_dst_aready),
    .sgl_alloc_dst_empty            (sgl_alloc_dst_empty),

    .sgl_wr_valid                   (sgl_wr_valid),
    .sgl_wr_ready                   (sgl_wr_ready),
    .sgl_wr_data                    (sgl_wr_data),
    .sgl_wr_dst_src_n               (sgl_wr_dst_src_n),
    .sgl_wr_channel                 (sgl_wr_channel),

    .security_internal              (security_internal              ),
    .security_egress                (security_egress                ),
    .security_ingress               (security_ingress               ),
    .security_dma                   (security_dma                   ),

    .int_msi                        (int_msi                        ),
    .int_legacy                     (int_legacy                     ),
    .int_misc                       (int_misc                       ),
    .int_dma                        (int_dma                        ),

    .m_awvalid                      (m_awvalid                      ),
    .m_awready                      (m_awready                      ),
    .m_awid                         (m_awid                         ),
    .m_awaddr                       (m_awaddr                       ),
    .m_awlen                        (m_awlen                        ),
    .m_awsize                       (m_awsize                       ),
    .m_awburst                      (m_awburst                      ),
    .m_awprot                       (m_awprot                       ),
    .m_awcache                      (m_awcache                      ),
    .m_awuser                       (m_awuser                       ),

    .m_wvalid                       (m_wvalid                       ),
    .m_wready                       (m_wready                       ),
    .m_wid                          (m_wid                          ),
    .m_wdata                        (m_wdata                        ),
    .m_wstrb                        (m_wstrb                        ),
    .m_wlast                        (m_wlast                        ),

    .m_bvalid                       (m_bvalid                       ),
    .m_bready                       (m_bready                       ),
    .m_bid                          (m_bid                          ),
    .m_bresp                        (m_bresp                        ),

    .m_arvalid                      (m_arvalid                      ),
    .m_arready                      (m_arready                      ),
    .m_arid                         (m_arid                         ),
    .m_araddr                       (m_araddr                       ),
    .m_arlen                        (m_arlen                        ),
    .m_arsize                       (m_arsize                       ),
    .m_arburst                      (m_arburst                      ),
    .m_arprot                       (m_arprot                       ),
    .m_arcache                      (m_arcache                      ),
    .m_aruser                       (m_aruser                       ),

    .m_rvalid                       (m_rvalid                       ),
    .m_rready                       (m_rready                       ),
    .m_rid                          (m_rid                          ),
    .m_rdata                        (m_rdata                        ),
    .m_rresp                        (m_rresp                        ),
    .m_rlast                        (m_rlast                        ),

    .s_awvalid                      (s_awvalid                      ),
    .s_awready                      (s_awready                      ),
    .s_awid                         (s_awid                         ),
    .s_awaddr                       ({32'd0,s_awaddr}               ),
    .s_awlen                        (s_awlen                        ),
    .s_awsize                       (s_awsize                       ),
    .s_awburst                      (s_awburst                      ),
    .s_awprot                       (s_awprot                       ),

    .s_wvalid                       (s_wvalid                       ),
    .s_wready                       (s_wready                       ),
    .s_wid                          (s_wid                          ),
    .s_wdata                        (s_wdata                        ),
    .s_wstrb                        (s_wstrb                        ),
    .s_wlast                        (s_wlast                        ),

    .s_bvalid                       (s_bvalid                       ),
    .s_bready                       (s_bready                       ),
    .s_bid                          (s_bid                          ),
    .s_bresp                        (s_bresp                        ),

    .s_arvalid                      (s_arvalid                      ),
    .s_arready                      (s_arready                      ),
    .s_arid                         (s_arid                         ),
    .s_araddr                       ({32'd0,s_araddr}               ),
    .s_arlen                        (s_arlen                        ),
    .s_arsize                       (s_arsize                       ),
    .s_arburst                      (s_arburst                      ),
    .s_arprot                       (s_arprot                       ),

    .s_rvalid                       (s_rvalid                       ),
    .s_rready                       (s_rready                       ),
    .s_rid                          (s_rid                          ),
    .s_rdata                        (s_rdata                        ),
    .s_rresp                        (s_rresp                        ),
    .s_rlast                        (s_rlast                        ),

    // ---------------------------------------------
    // PCI Express Clock Domain (p_clk clock domain)
    // ---------------------------------------------
    // Xilinx Hard Core - Clock and Reset
    .p_clk                          (p_clk                          ),
    .p_rst_n                        (p_rst_n                        ),
    .user_lnk_up                    (user_lnk_up                    ),

    // Xilinx Hard Core - CSR Interface Ports
    .p_is_rp_ep_n                   (p_is_rp_ep_n                   ),
    .p_set_interrupt                (p_set_interrupt                ),

    .s_axis_rq_tlast                (s_axis_rq_tlast                ),
    .s_axis_rq_tdata                (s_axis_rq_tdata                ),
    .s_axis_rq_tuser                (s_axis_rq_tuser                ),
    .s_axis_rq_tkeep                (s_axis_rq_tkeep                ),
    .s_axis_rq_tready               (s_axis_rq_tready               ),
    .s_axis_rq_tvalid               (s_axis_rq_tvalid               ),

    .m_axis_rc_tdata                (m_axis_rc_tdata                ),
    .m_axis_rc_tuser                (m_axis_rc_tuser                ),
    .m_axis_rc_tlast                (m_axis_rc_tlast                ),
    .m_axis_rc_tkeep                (m_axis_rc_tkeep                ),
    .m_axis_rc_tvalid               (m_axis_rc_tvalid               ),
    .m_axis_rc_tready               (m_axis_rc_tready_i             ),

    .m_axis_cq_tdata                (m_axis_cq_tdata                ),
    .m_axis_cq_tuser                (m_axis_cq_tuser                ),
    .m_axis_cq_tlast                (m_axis_cq_tlast                ),
    .m_axis_cq_tkeep                (m_axis_cq_tkeep                ),
    .m_axis_cq_tvalid               (m_axis_cq_tvalid               ),
    .m_axis_cq_tready               (m_axis_cq_tready_i             ),
    .pcie_cq_np_req                 (pcie_cq_np_req                 ),

    .s_axis_cc_tdata                (s_axis_cc_tdata                ),
    .s_axis_cc_tuser                (s_axis_cc_tuser                ),
    .s_axis_cc_tlast                (s_axis_cc_tlast                ),
    .s_axis_cc_tkeep                (s_axis_cc_tkeep                ),
    .s_axis_cc_tvalid               (s_axis_cc_tvalid               ),
    .s_axis_cc_tready               (s_axis_cc_tready               ),

    // Xilinx Hard Core - Flow Control Ports - Need initial CH & CD credits for Read Request Metering
    .fc_cpld                        (fc_cpld                        ),
    .fc_cplh                        (fc_cplh                        ),
    .fc_sel                         (                               ),

    // Xilinx Hard Core - Configuration
    .cfg_max_payload                (cfg_max_payload                ),
    .cfg_max_read_req               (cfg_max_read_req               ),
    .cfg_function_status            (cfg_function_status            ),

    .cfg_err_cor                    (cfg_err_cor                    ),
    .cfg_err_uncor                  (cfg_err_uncor                  ),

    .cfg_mgmt_addr                  (cfg_mgmt_addr                  ),                
    .cfg_mgmt_write                 (cfg_mgmt_write                 ),
    .cfg_mgmt_write_data            (cfg_mgmt_write_data            ),
    .cfg_mgmt_byte_enable           (cfg_mgmt_byte_enable           ),
    .cfg_mgmt_read                  (cfg_mgmt_read                  ),
    .cfg_mgmt_read_data             (cfg_mgmt_read_data             ),
    .cfg_mgmt_read_write_done       (cfg_mgmt_read_write_done       ),
    .cfg_mgmt_type1_cfg_reg_access  (cfg_mgmt_type1_cfg_reg_access  ),

    // Xilinx Hard Core - Interrupt Generation Interface
    .cfg_interrupt_int              (cfg_interrupt_int              ),
    .cfg_interrupt_sent             (cfg_interrupt_sent             ),
    .cfg_interrupt_msi_int          (cfg_interrupt_msi_int          ),
    .cfg_interrupt_msi_sent         (cfg_interrupt_msi_sent         ),
    .cfg_interrupt_msienable        (cfg_interrupt_msi_enable       ),
    .cfg_interrupt_msixenable       (cfg_interrupt_msix_enable      ),
    .cfg_interrupt_msixfm           (cfg_interrupt_msix_mask        ),

    .cfg_sec_bus_num                (8'h1                           )
);

endmodule
