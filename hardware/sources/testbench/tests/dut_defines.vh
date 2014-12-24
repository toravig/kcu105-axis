
`define PVTMON_REG_AXI_ADDR 32'h44A0_0000
`define USER_REG_AXI_ADDR   32'h44A0_1000
`define BRAM0_AXI_ADDR      32'hC000_0000
`define BRAM1_AXI_ADDR      32'hD000_0000

//- Bridge Specific Offsets

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

