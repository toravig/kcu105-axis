//- This file includes additional tasks required for PCIe Reference Designs
//for Kintex UltraScale using NWL AXI-PCIe Bridge & Expresso DMA

//- Bridge Initialization & Ingress Translation setup task
task InitBridge;

  reg [2:0] bar_index;

  begin
    $display("[%t] Starting Bridge Initialization ...\n", $realtime);
    bar_index = 3'd0;
    //- Read BREG_CAP
    TSK_TX_BAR_READ(bar_index, `BREG_CAP , DEFAULT_TAG, DEFAULT_TC);
    TSK_WAIT_FOR_READ_DATA;
    $display("[%t] BREG Cap = %0x\n", $realtime, P_READ_DATA);
    //- Setup up Bridge SRC BASE LO/HI Addresses to BAR[1:0] + 0x8000
    DEFAULT_TAG = DEFAULT_TAG + 1'b1;
    TSK_TX_BAR_WRITE(bar_index, `BREG_SRC_LO , DEFAULT_TAG, DEFAULT_TC, (BAR_INIT_P_BAR[0][31:0] + 32'h8000));
    TSK_TX_CLK_EAT(10);
    DEFAULT_TAG = DEFAULT_TAG + 1'b1;
    TSK_TX_BAR_WRITE(bar_index, `BREG_SRC_HI , DEFAULT_TAG, DEFAULT_TC, BAR_INIT_P_BAR[1][31:0]);
    TSK_TX_CLK_EAT(10);
    DEFAULT_TAG = DEFAULT_TAG + 1'b1;
    TSK_TX_BAR_READ(bar_index, `BREG_SRC_LO , DEFAULT_TAG, DEFAULT_TC);
    TSK_WAIT_FOR_READ_DATA;
    $display("[%t] BREG SRC LO = %0x\n", $realtime, P_READ_DATA);
    DEFAULT_TAG = DEFAULT_TAG + 1'b1;
    TSK_TX_BAR_READ(bar_index, `BREG_SRC_HI , DEFAULT_TAG, DEFAULT_TC);
    TSK_WAIT_FOR_READ_DATA;
    $display("[%t] BREG SRC HI = %0x\n", $realtime, P_READ_DATA);

    SetupIngressTran(0, 2, 0, `PVTMON_REG_AXI_ADDR, 4);
    SetupIngressTran(1, 4, 0, `BRAM0_AXI_ADDR, 0);

    //- Lock Bridge
    DEFAULT_TAG = DEFAULT_TAG + 1'b1;
    TSK_TX_BAR_WRITE(bar_index, `BREG_CTRL , DEFAULT_TAG, DEFAULT_TC, 32'h0004_0001);
    TSK_TX_CLK_EAT(10);
  
  end
endtask 

task SetupIngressTran;
  input [3:0]   num_ing_tran;
  input [2:0]   bar_i;
  input [31:0]  bar_offset;
  input [31:0]  axi_addr;
  input [4:0]   ing_size;

  reg [2:0]   bar_index;
  reg [31:0]  r_data;

  begin
    bar_index = 3'd0;
    //- Read Ingress Cap
    TSK_TX_BAR_READ(bar_index, (`INGRESS_CAP + (32'h20 * num_ing_tran)) , DEFAULT_TAG, DEFAULT_TC);
    TSK_WAIT_FOR_READ_DATA;
    $display("[%t] INGRESS CAP-%0d = %0x\n", $realtime, num_ing_tran, P_READ_DATA);
    DEFAULT_TAG = DEFAULT_TAG + 1'b1;
    TSK_TX_BAR_READ(bar_index, (`INGRESS_CTRL + (32'h20 * num_ing_tran)) , DEFAULT_TAG, DEFAULT_TC);
    TSK_WAIT_FOR_READ_DATA;
    r_data = P_READ_DATA;
    //- Enable translation and set aperture size
    r_data = r_data | (ing_size << 16) | 32'h01;
    TSK_TX_BAR_WRITE(bar_index, (`INGRESS_CTRL + (32'h20 * num_ing_tran)) , DEFAULT_TAG, DEFAULT_TC, r_data);
    TSK_TX_CLK_EAT(10);
    DEFAULT_TAG = DEFAULT_TAG + 1'b1;
    TSK_TX_BAR_READ(bar_index, (`INGRESS_CTRL + (32'h20 * num_ing_tran)) , DEFAULT_TAG, DEFAULT_TC);
    TSK_WAIT_FOR_READ_DATA;
    $display("[%t] INGRESS CTRL-%0d = %0x\n", $realtime, num_ing_tran, P_READ_DATA);
    DEFAULT_TAG = DEFAULT_TAG + 1'b1;
    TSK_TX_BAR_WRITE(bar_index, (`INGRESS_SRC_LO + (32'h20 * num_ing_tran)) , DEFAULT_TAG, DEFAULT_TC, (BAR_INIT_P_BAR[bar_i][31:0] + bar_offset));
    TSK_TX_CLK_EAT(10);
    DEFAULT_TAG = DEFAULT_TAG + 1'b1;
    TSK_TX_BAR_WRITE(bar_index, (`INGRESS_SRC_HI + (32'h20 * num_ing_tran)) , DEFAULT_TAG, DEFAULT_TC, (BAR_INIT_P_BAR[bar_i+1][31:0]));
    TSK_TX_CLK_EAT(10);
    DEFAULT_TAG = DEFAULT_TAG + 1'b1;
    TSK_TX_BAR_READ(bar_index, (`INGRESS_SRC_LO + (32'h20 * num_ing_tran)) , DEFAULT_TAG, DEFAULT_TC);
    TSK_WAIT_FOR_READ_DATA;
    $display("[%t] INGRESS SRC LO-%0d = %0x\n", $realtime, num_ing_tran, P_READ_DATA);
    TSK_TX_BAR_READ(bar_index, (`INGRESS_SRC_HI + (32'h20 * num_ing_tran)) , DEFAULT_TAG, DEFAULT_TC);
    TSK_WAIT_FOR_READ_DATA;
    $display("[%t] INGRESS SRC HI-%0d = %0x\n", $realtime, num_ing_tran, P_READ_DATA);
    DEFAULT_TAG = DEFAULT_TAG + 1'b1;
    TSK_TX_BAR_WRITE(bar_index, (`INGRESS_DST_LO + (32'h20 * num_ing_tran)) , DEFAULT_TAG, DEFAULT_TC, axi_addr);
    TSK_TX_CLK_EAT(10);
    DEFAULT_TAG = DEFAULT_TAG + 1'b1;
    TSK_TX_BAR_WRITE(bar_index, (`INGRESS_DST_HI + (32'h20 * num_ing_tran)) , DEFAULT_TAG, DEFAULT_TC, 32'd0);
    TSK_TX_CLK_EAT(10);
    DEFAULT_TAG = DEFAULT_TAG + 1'b1;
    TSK_TX_BAR_READ(bar_index, (`INGRESS_DST_LO + (32'h20 * num_ing_tran)) , DEFAULT_TAG, DEFAULT_TC);
    TSK_WAIT_FOR_READ_DATA;
    $display("[%t] INGRESS DST LO-%0d = %0x\n", $realtime, num_ing_tran, P_READ_DATA);
    TSK_TX_BAR_READ(bar_index, (`INGRESS_DST_HI + (32'h20 * num_ing_tran)) , DEFAULT_TAG, DEFAULT_TC);
    TSK_WAIT_FOR_READ_DATA;
    $display("[%t] INGRESS DST HI-%0d = %0x\n", $realtime, num_ing_tran, P_READ_DATA);
  
  end
endtask  

task ReadUserReg;
  input [2:0]   bar_index;
  input [31:0]  offset;  
  input [31:0]  w_data;

  reg [31:0]    r_data;

  begin
    bar_index = 2;
    TSK_TX_BAR_WRITE(bar_index, 32'h04 , DEFAULT_TAG, DEFAULT_TC, w_data);
    TSK_TX_CLK_EAT(10);
    DEFAULT_TAG = DEFAULT_TAG + 1'b1;
    TSK_TX_BAR_READ(bar_index, 32'h04 , DEFAULT_TAG, DEFAULT_TC);
    TSK_WAIT_FOR_READ_DATA;
    if (P_READ_DATA == w_data)
      $display("[%t] Data written and read back match! (Data = %0x, Address = %0x)\n", $realtime, w_data, ({BAR_INIT_P_BAR[bar_index+1][31:0], BAR_INIT_P_BAR[bar_index][31:0]} + offset));
    else
      $display("[%t] Data written (%0x) and read (%0x) do not match\n", $realtime, w_data, P_READ_DATA);
  end
endtask  
