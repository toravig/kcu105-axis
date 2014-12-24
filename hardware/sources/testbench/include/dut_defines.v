/*******************************************************************************
** © Copyright 2009 - 2010 Xilinx, Inc. All rights reserved.
** This file contains confidential and proprietary information of Xilinx, Inc. and 
** is protected under U.S. and international copyright and other intellectual property laws.
*******************************************************************************
**   ____  ____ 
**  /   /\/   / 
** /___/  \  /   Vendor: Xilinx 
** \   \   \/    
**  \   \        
**  /   /          
** /___/   /\     
** \   \  /  \   Virtex-6 PCIe-10GDMA-DDR3-XAUI Targeted Reference Design
**  \___\/\___\ 
** 
**  Device: xc6vlx240t
**  Version: 1.2
**  Reference: UG372
**     
*******************************************************************************
**
**  Disclaimer: 
**
**    This disclaimer is not a license and does not grant any rights to the materials 
**              distributed herewith. Except as otherwise provided in a valid license issued to you 
**              by Xilinx, and to the maximum extent permitted by applicable law: 
**              (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND WITH ALL FAULTS, 
**              AND XILINX HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, 
**              INCLUDING BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-INFRINGEMENT, OR 
**              FITNESS FOR ANY PARTICULAR PURPOSE; and (2) Xilinx shall not be liable (whether in contract 
**              or tort, including negligence, or under any other theory of liability) for any loss or damage 
**              of any kind or nature related to, arising under or in connection with these materials, 
**              including for any direct, or any indirect, special, incidental, or consequential loss 
**              or damage (including loss of data, profits, goodwill, or any type of loss or damage suffered 
**              as a result of any action brought by a third party) even if such damage or loss was 
**              reasonably foreseeable or Xilinx had been advised of the possibility of the same.


**  Critical Applications:
**
**    Xilinx products are not designed or intended to be fail-safe, or for use in any application 
**    requiring fail-safe performance, such as life-support or safety devices or systems, 
**    Class III medical devices, nuclear facilities, applications related to the deployment of airbags,
**    or any other applications that could lead to death, personal injury, or severe property or 
**    environmental damage (individually and collectively, "Critical Applications"). Customer assumes 
**    the sole risk and liability of any use of Xilinx products in Critical Applications, subject only 
**    to applicable laws and regulations governing limitations on product liability.

**  THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS PART OF THIS FILE AT ALL TIMES.

*******************************************************************************/
// This file defines the parameters for DUT.
// Change to these parameters impacts the testbench behavior hence avoid
// changing them if you are unsure of its implications.
//-------------------------------------------------------------------------

`define NUM_DMA_CHANNEL 2

//Macro Definitions used in the ENV
`define SRC_Q_PTR_LO 32'h0000_0000
`define SRC_Q_PTR_HI 32'h0000_0004
`define SRC_Q_SIZE   32'h0000_0008
`define SRC_Q_LIMIT  32'h0000_000C

`define DST_Q_PTR_LO 32'h0000_0010
`define DST_Q_PTR_HI 32'h0000_0014
`define DST_Q_SIZE   32'h0000_0018
`define DST_Q_LIMIT  32'h0000_001C

`define STAS_Q_PTR_LO 32'h0000_0020
`define STAS_Q_PTR_HI 32'h0000_0024
`define STAS_Q_SIZE   32'h0000_0028
`define STAS_Q_LIMIT  32'h0000_002C

`define STAD_Q_PTR_LO 32'h0000_0030
`define STAD_Q_PTR_HI 32'h0000_0034
`define STAD_Q_SIZE   32'h0000_0038
`define STAD_Q_LIMIT  32'h0000_003C

`define SRC_Q_NEXT  32'h0000_0040
`define DST_Q_NEXT  32'h0000_0044
`define STAS_Q_NEXT 32'h0000_0048
`define STAD_Q_NEXT 32'h0000_004C

`define SCRATCH_PAD0 32'h0000_0050
`define SCRATCH_PAD1 32'h0000_0054
`define SCRATCH_PAD2 32'h0000_0058
`define SCRATCH_PAD3 32'h0000_005C

`define PCIE_INTR_CTRL 32'h0000_0060
`define PCIE_INTR_STS  32'h0000_0064
`define AXI_INTR_CTRL  32'h0000_0068
`define AXI_INTR_STS   32'h0000_006C

`define PCIE_INTR_ASSERT 32'h0000_0070
`define AXI_INTR_ASSERT  32'h0000_0074

`define DMA_CONTROL 32'h0000_0078
`define DMA_STATUS  32'h0000_007C

  //- GENCHK Regs
`define ENABLE_GEN_REG    32'h0000_0000
`define ENABLE_CHK_REG    32'h0000_0004
`define PKT_SIZE_REG      32'h0000_0008
`define CHK_STS_REG       32'h0000_000C
`define CNT_WRAP_REG      32'h0000_0010  
`define AXI_BA_REG        32'h0000_0014  
`define AXI_HA_REG        32'h0000_0018  
//`define SCRATCH_REG   32'h0000_0018
 
`define CFG_DMA_REG_BAR 3'b000  

`define SLAVE_START_ADDR  32'h43C0_0000

`define BRIDGE_BAR  32'h43C1_0000
`define ECAM_BAR    32'h43C0_0000  
`define DREG_BAR    32'h43C0_1000  
`define AXI_BAR     32'h44A0_0000
//`define BAR2	    32'h0000_0000
//`define BAR2_OFFSET 32'h0000_0000

// This address can be either Gen-Chk address or DDR4 address
//`define FIXED_FPGA_OFFSET 32'h44000000
`define FIXED_FPGA_OFFSET 32'hC0000000
//`define INDEX 1 
//`define REGION_OFFSET 32'h0000_0020 

`define TRAN_INGRESS_CAPABILITIES_OFFSET 32'h0000_0800
`define TRAN_INGRESS_STATUS_OFFSET       32'h0000_0804 
`define TRAN_INGRESS_CONTROL_OFFSET      32'h0000_0808 
`define TRAN_INGRESS_SRC_BASE_LO_OFFSET  32'h0000_0810 
`define TRAN_INGRESS_SRC_BASE_HI_OFFSET  32'h0000_0814 
`define TRAN_INGRESS_DST_BASE_LO_OFFSET  32'h0000_0818 
`define TRAN_INGRESS_DST_BASE_HI_OFFSET  32'h0000_081C 
`define TRAN_INGRESS_SIZE                32'h0004_0000 

`define E_BREG_CAPABILITIES_OFFSET 32'h0000_0200
`define E_BREG_STATUS_OFFSET       32'h0000_0204 
`define E_BREG_CONTROL_OFFSET      32'h0000_0208 
`define E_BREG_SRC_BASE_LO_OFFSET  32'h0000_0210 
`define E_BREG_SRC_BASE_HI_OFFSET  32'h0000_0214 
`define E_BREG_SIZE                32'h0000_0000

`define E_ECAM_CAPABILITIES_OFFSET 32'h0000_0220
`define E_ECAM_STATUS_OFFSET       32'h0000_0224 
`define E_ECAM_CONTROL_OFFSET      32'h0000_0228 
`define E_ECAM_SRC_BASE_LO_OFFSET  32'h0000_0230 
`define E_ECAM_SRC_BASE_HI_OFFSET  32'h0000_0234 
//`define E_ECAM_SIZE                32'h0000_0000

`define E_DREG_CAPABILITIES_OFFSET 32'h0000_0280
`define E_DREG_STATUS_OFFSET       32'h0000_0284 
`define E_DREG_CONTROL_OFFSET      32'h0000_0288 
`define E_DREG_SRC_BASE_LO_OFFSET  32'h0000_0290 
`define E_DREG_SRC_BASE_HI_OFFSET  32'h0000_0294 

 // CH0_C2S_BD_COUNT defines the number of descriptors set up in C2S
 // direction for APP-0. It has an upper bound of 25.
 `define CH0_C2S_BD_COUNT 5'd2    
 
 // CH1_C2S_BD_COUNT defines the number of descriptors set up in C2S
 // direction for APP-1. It has an upper bound of 25.
 `define  CH1_C2S_BD_COUNT 5'd6  
 
 `define  CH2_C2S_BD_COUNT 5'd10  
 `define  CH3_C2S_BD_COUNT 5'd10  

  // Span count is applicable only when packet_spanning test is selected
  // This defines the number of descriptor over which a packet spans
 `define SPAN_COUNT 4'h2          

 // Descriptor base-limits
 `define TXDESC0_SRC_BASE  32'h0000_0800  //address of first descriptor in the descriptor chain for channel 0 in S2C direction
 `define TXDESC0_SRC_LIMIT 32'h0000_09FF

 `define TXDESC0_DST_BASE  32'h0000_0A00  //address of first descriptor in the descriptor chain for channel 1 in S2C direction.
 `define TXDESC0_DST_LIMIT 32'h0000_0BFF 

 `define TXDESC0_STAS_BASE  32'h0000_0C00  //address of first descriptor in the descriptor chain for channel 1 in S2C direction.
 `define TXDESC0_STAS_LIMIT 32'h0000_0DFF 

 `define TXDESC0_STAD_BASE  32'h0000_0E00  //address of first descriptor in the descriptor chain for channel 1 in S2C direction.
 `define TXDESC0_STAD_LIMIT 32'h0000_0FFF 
  

`define RXDESC0_SRC_BASE  32'h0000_0040  //address of first descriptor in the descriptor chain for channel 0 in C2S direction. 
`define RXDESC0_SRC_LIMIT 32'h0000_01FF 

`define RXDESC0_DST_BASE  32'h0000_0200  //address of first descriptor in the descriptor chain for channel 1 in C2S direction.
`define RXDESC0_DST_LIMIT 32'h0000_03FF 

`define RXDESC0_STAS_BASE  32'h0000_0400  //address of first descriptor in the descriptor chain for channel 0 in C2S direction. 
`define RXDESC0_STAS_LIMIT 32'h0000_05FF 

`define RXDESC0_STAD_BASE  32'h0000_0600  //address of first descriptor in the descriptor chain for channel 1 in C2S direction.
`define RXDESC0_STAD_LIMIT 32'h0000_07FF 

//`define RXDESC2_BASE  32'h0000_0C00  //address of first descriptor in the descriptor chain for channel 1 in C2S direction.
//`define RXDESC2_LIMIT 32'h0000_0DFF 
//
//`define RXDESC3_BASE  32'h0000_0E00  //address of first descriptor in the descriptor chain for channel 1 in C2S direction.
//`define RXDESC3_LIMIT 32'h0000_0FFF 

// Buffer base-limits
 `define TXBUF0_BASE  32'h0001_0000
 `define TXBUF0_LIMIT 32'h0001_FFFF

// `define TXBUF1_BASE  32'h0002_0000
// `define TXBUF1_LIMIT 32'h0002_FFFF
//
// `define TXBUF2_BASE  32'h0003_0000
// `define TXBUF2_LIMIT 32'h0003_FFFF
//
// `define TXBUF3_BASE  32'h0004_0000
// `define TXBUF3_LIMIT 32'h0004_FFFF

 `define RXBUF0_BASE  32'h0002_0000
 `define RXBUF0_LIMIT 32'h0002_FFFF

// `define RXBUF1_BASE  32'h0006_0000
// `define RXBUF1_LIMIT 32'h0006_FFFF
//
// `define RXBUF2_BASE  32'h0007_0000
// `define RXBUF2_LIMIT 32'h0007_FFFF
//
// `define RXBUF3_BASE  32'h0008_0000
// `define RXBUF3_LIMIT 32'h0008_FFFF
 
 // Base addresses for channel in both directions
 `define CH0_S2C_REG_BASE 32'h0000_0000
 `define CH1_S2C_REG_BASE 32'h0000_0100
 `define CH2_S2C_REG_BASE 32'h0000_0200
 `define CH3_S2C_REG_BASE 32'h0000_0300
 `define CH0_C2S_REG_BASE 32'h0000_2000
 `define CH1_C2S_REG_BASE 32'h0000_2100
 `define CH2_C2S_REG_BASE 32'h0000_2200
 `define CH3_C2S_REG_BASE 32'h0000_2300

// Maximum BD supported
 `define MAX_BD 'd2
 
 // Read completion boundary for root port
 `define RP_RCB 'd64 
 
 // max payload for channels 
 `define MAX_BUFFER_LENGTH_CHNL0 'd64

 // This has to be a multiple of 128 bytes (DUT_MPS)
 `define MAX_BUFFER_LENGTH_CHNL1 'd64
 `define MAX_BUFFER_LENGTH_CHNL2 'd512  //'d128
 `define MAX_BUFFER_LENGTH_CHNL3 'd256  //64

 // max payload size in bytes
 `define DUT_MPS  12'd128
 `define DUT_MRRS 12'd128
 
 // DMA offset address maped to BAR0
 `define DMA_OFFSET_ADRS 32'hff00_0000
 
 // DMA Engine Control
 `define DMA_ENGN_CTRL 32'h0000_0004

 `define DMA_REG_NEXT_DESC_PTR 32'h0000_0008 
 `define DMA_CNTRL_REG 32'h0000_0004
 `define DMA_REG_SW_DESC_PTR 32'h0000_000C
 `define DMA_REG_CMPLT_DESC_PTR 32'h0000_0010


 // MSI related definitions
 // address reserved for MSI
 `define MSI_MAR_LOW_ADRS 32'h000F_FFF0
 //-- Data in MSI packet
 `define MSI_MDR_DATA 32'h0000_DEAD

 // DMA common register block
 `define DMA_COMMON_REG_BASE 32'h0000_4000
 `define DMA_COMMON_CNTRL_STS_OFFSET 0

 // -- BAR
 `define DUT_BADDR_LOWER 32'hff00_0000
 `define BFM_BADDR_LOWER 32'h0000_0000

 `define DUT_BAR2_LOWER 32'hfa00_0000
 `define DUT_BAR2_UPPER 32'h0000_0000  

`define USER_REG_AXI_ADDR   32'h44A0_0000

`define BREG_CAP            32'h0000_8200
`define BREG_CTRL           32'h0000_8208
`define BREG_SRC_LO         32'h0000_8210
`define BREG_SRC_HI         32'h0000_8214

`define INGRESS_CAP         32'h0000_8800
`define INGRESS_CTRL        32'h0000_8808
`define INGRESS_SRC_LO      32'h0000_8810
`define INGRESS_SRC_HI      32'h0000_8814
`define INGRESS_DST_LO      32'h0000_8818
`define INGRESS_DST_HI      32'h0000_881C
