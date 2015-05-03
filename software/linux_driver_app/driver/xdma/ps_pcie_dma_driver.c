/****************************************************************************
 ****************************************************************************/
/** Copyright (C) 2014-2015 Xilinx, Inc.  All rights reserved.
 ** Permission is hereby granted, free of charge, to any person obtaining
 ** a copy of this software and associated documentation files (the
 ** "Software"), to deal in the Software without restriction, including
 ** without limitation the rights to use, copy, modify, merge, publish,
 ** distribute, sublicense, and/or sell copies of the Software, and to
 ** permit persons to whom the Software is furnished to do so, subject to
 ** the following conditions:
 ** The above copyright notice and this permission notice shall be included
 ** in all copies or substantial portions of the Software.Use of the Software 
 ** is limited solely to applications: (a) running on a Xilinx device, or 
 ** (b) that interact with a Xilinx device through a bus or interconnect.  
 ** THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 ** EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 ** MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 ** NONINFRINGEMENT. IN NO EVENT SHALL XILINX BE LIABLE FOR ANY
 ** CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 ** TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 ** SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 ** Except as contained in this notice, the name of the Xilinx shall
 ** not be used in advertising or otherwise to promote the sale, use or other
 ** dealings in this Software without prior written authorization from Xilinx
 **/
/*****************************************************************************
*****************************************************************************/
#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/delay.h>
#include <linux/interrupt.h>
#include <linux/slab.h>
#include <linux/timer.h>
#include <linux/sched.h>
#include <linux/kthread.h>
#include <linux/cdev.h>
#include <asm/uaccess.h>
#include <linux/fs.h>
#include <linux/kdev_t.h>
#include <linux/version.h>
#include <linux/pci.h>

#include "ps_pcie_dma_driver.h"
#include "../include/xpmon_be.h"
#include "../include/xdebug.h"
#if defined(VIDEO_ACC_DESIGN)
#define NOBH 1
#else
#undef NOBH
#define WITHBH 1
#endif

#if defined (NOBH)
#define LOCK_DMA_CHANNEL(x) spin_lock(x)
#define UNLOCK_DMA_CHANNEL(x) spin_unlock(x)
#elif defined (WITHBH)
#define LOCK_DMA_CHANNEL(x) spin_lock_bh(x)
#define UNLOCK_DMA_CHANNEL(x) spin_unlock_bh(x)
#else
#define LOCK_DMA_CHANNEL(x) 
#define UNLOCK_DMA_CHANNEL(x) 
#endif

/*
 * Global Statastics 
 * Driver periodically polls statistics from Hw and preserves in below data structures
 * GUI Periodicaly polls these statstics from driver to show case it in GUI.
 */

TRNStatistics TStats[MAX_STATS];

int dstatsRead[PS_PCIE_NUM_DMA_CHANNELS], dstatsWrite[PS_PCIE_NUM_DMA_CHANNELS];
int dstatsNum[PS_PCIE_NUM_DMA_CHANNELS], sstatsRead[PS_PCIE_NUM_DMA_CHANNELS];
int sstatsWrite[PS_PCIE_NUM_DMA_CHANNELS], sstatsNum[PS_PCIE_NUM_DMA_CHANNELS];
int tstatsRead, tstatsWrite, tstatsNum;
unsigned long SWrate[PS_PCIE_NUM_DMA_CHANNELS];

struct timer_list stats_timer;
struct cdev * xdmaCdev=NULL;
int UserOpen=0;
u32 DriverState = UNINITIALIZED;
PowerMonitorVal pmval;

const char ps_pcie_driver_name[] = "PS_PCIE_XILINX_DMA_DRIVER";

#define XIo_In32(addr)      (readl((unsigned int *)(addr)))
#define XIo_Out32(addr, data) (writel((data), (unsigned int *)(addr)))
/*
 * Global linked list head pointer for DMA descriptor list
 * maintained by host driver. Each descriptor correspinds to each 
 * card is system that employs the DMA we are interested in.
 * The actual job of detecting the card is done by the higher layer (application specific)
 * driver that is above this DMA driver.
 */
static ps_pcie_dma_desc_t g_host_dma_desc = {0}; //TODO this has to go and we need to support multiple EPs

static DEFINE_SPINLOCK(DmaStatsLock);

static irqreturn_t ps_pcie_intr_handler(int irq, void *data);

static irqreturn_t ps_pcie_intr_handler_no_msix(int irq, void *data);


static int register_interrupt_handler(unsigned int irq_no, const char *hndlr_name,
		ps_pcie_dma_desc_t *ptr_dma_desc)
{

	int retval = XLNX_SUCCESS;


	/* Register interrupt handler if not already done */
	if(ptr_dma_desc->intr_hndlr_registered == false) 
	{
		int rc = request_irq(irq_no, ps_pcie_intr_handler_no_msix, IRQF_SHARED,
				hndlr_name, ptr_dma_desc);
		if (rc) {
			printk(KERN_ERR"\nUnable to request IRQ %p, error %d\n",
					ptr_dma_desc->device, rc);
			retval = XLNX_INTERRUPT_REG_FAIL;
		}
		else
		{
			ptr_dma_desc->intr_hndlr_registered = true;
			printk(KERN_ERR"\nIRQ Handler register success\n");
		}
	}

	return retval;
}
/*
 * Function returns device structure of PCIe device
 *
 *
 */
static inline struct device *nwl_pci_dev_to_dev(struct pci_dev *pdev)
{
	return &pdev->dev;
}

static int nwl_dma_is_chann_alloc_ep(ps_pcie_dma_desc_t * ptr_dma_desc, 
		unsigned int channel_id, direction_t dir)
{
	u8 __iomem *ptr_temp_chann_regs = ptr_dma_desc->dma_chann_reg_virt_base_addr + (channel_id * DMA_REG_TOT_BYTES);
	unsigned int offset = DMA_SRCQPTRLO_REG_OFFSET;
	unsigned int regval;
	int retval = XLNX_SUCCESS;

#ifdef HW_SGL_DESIGN
	return retval;
#endif

	if( dir == OUT) 
	{
		/* We want to send data to card, so ep will have configured destination Q for rhis channel */
		offset = DMA_DSTQPTRLO_REG_OFFSET;
	}

	printk(KERN_ERR"\nCheck if Channel is allocated in EP\n");

	regval = RD_DMA_REG(ptr_temp_chann_regs, offset);


	if(!(regval & DMA_QPTRLO_Q_ENABLE_BIT)) 
	{
		retval = XLNX_UNALLOCATED_IN_EP;
		ptr_dma_desc->channels[channel_id].chann_state = XLNX_DMA_CHANN_NOT_READY_EP;
	}

	printk(KERN_ERR"\nCheck if Channel is allocated in EP read loc %p, read %x returning %d\n", ptr_temp_chann_regs + offset, regval, retval);

	return retval;
}

/* InitBridge Function Initializes and configures Bridge in DMA.
 *
 *
 *
 */
static void InitBridge(u64 bar0_addr, u64 bar0_addr_p, u64 bar2_addr, u64 bar2_addr_p)
{
	u32 reg;

	/* Read breg_cap */		
	printk("\nData at BAR0 offset (0x8200) = %x\n", XIo_In32(bar0_addr + REG_BRDG_BASE  + REG_BRDG_E_BASE + OFFSET_BRDG_E_CAP ));

	/* Read breg_src_base and setup bridge translation */
	reg = XIo_In32(bar0_addr + REG_BRDG_BASE + REG_BRDG_E_BASE + OFFSET_BRDG_E_SRC_LO );
	printk("breg_src_base_lo = %0x\n", reg);

	/* program breg_src_base the same as what is accessible over PCIe */
	XIo_Out32((bar0_addr +REG_BRDG_BASE + REG_BRDG_E_BASE + OFFSET_BRDG_E_SRC_LO ),(u32)(bar0_addr_p +REG_BRDG_BASE ));
	reg = XIo_In32(bar0_addr + REG_BRDG_BASE + REG_BRDG_E_BASE + OFFSET_BRDG_E_SRC_LO);
	printk("breg_src_base_lo = %0x\n", reg);
	XIo_Out32((bar0_addr +REG_BRDG_BASE + REG_BRDG_E_BASE + OFFSET_BRDG_E_SRC_HI ),(u32)((bar0_addr_p +REG_BRDG_BASE ) >> 32));
	reg = XIo_In32(bar0_addr + REG_BRDG_BASE + REG_BRDG_E_BASE + OFFSET_BRDG_E_SRC_HI);
	printk("breg_src_base_hi = %0x\n", reg);
#if defined(PFORM_USCALE_NO_EP_PROCESSOR) || defined(DDR_DESIGN)
	/* Max Read and Write Request size on Master AXI-MM interface of DMA */
	XIo_Out32((bar0_addr + REG_BRDG_BASE + CFG_AXI_MASTER),MAX_RW_AXI_MM);
	/* Programming the FC credits;
	   Completion Header Credits=0x60; Completion Data=0x3E0 */
	XIo_Out32((bar0_addr + REG_BRDG_BASE + CFG_PCIE_CREDIT),FC_COMP_HEADER_DATA);
#endif
#ifdef HW_SGL_DESIGN
	/* Change AXI Read/Write request size
	   - 0x22 - 256B for Read & Wr */
	XIo_Out32((bar0_addr + REG_BRDG_BASE + CFG_AXI_MASTER),MAX_RW_AXI_MM);
#endif
	/* Currently setting up only one translation region - might need more as
	 * future DUTs require */
	/* Read ingress tran cap */
	printk("Ingress Tran cap (0x8800) = %x\n", XIo_In32(bar0_addr + REG_BRDG_BASE + REG_INGR_AXI_BASE ));
	/* enable translation */  
	reg = XIo_In32(bar0_addr +REG_BRDG_BASE + REG_INGR_AXI_BASE + OFFSET_INGR_AXI_CTRL );
	/* Programming an aperture size of 1M(80000) ,Ingress Enable(00001) */
	XIo_Out32((bar0_addr + REG_BRDG_BASE + REG_INGR_AXI_BASE + OFFSET_INGR_AXI_CTRL), (reg | 0x00080001));
	printk("tran_ingress_control = %x\n", XIo_In32(bar0_addr + REG_BRDG_BASE + REG_INGR_AXI_BASE + OFFSET_INGR_AXI_CTRL));
	/*- This translation maps BAR[2] hits to AXI address 0x44A00000
	  - Program src address to be BAR[2] */
	XIo_Out32((bar0_addr + REG_BRDG_BASE + REG_INGR_AXI_BASE + OFFSET_INGR_AXI_SRC_LO), (u32)bar2_addr_p);
	printk("tran_src_lo = %x\n", XIo_In32(bar0_addr + REG_BRDG_BASE + REG_INGR_AXI_BASE + OFFSET_INGR_AXI_SRC_LO));
	XIo_Out32((bar0_addr + REG_BRDG_BASE + REG_INGR_AXI_BASE + OFFSET_INGR_AXI_SRC_HI), (u32)((bar2_addr_p)>> 32));
	printk("tran_src_hi = %x\n", XIo_In32(bar0_addr + REG_BRDG_BASE + REG_INGR_AXI_BASE + OFFSET_INGR_AXI_SRC_HI));
	/*- Program DST address to be AXI domain address for user reg module */
	XIo_Out32((bar0_addr + REG_BRDG_BASE + REG_INGR_AXI_BASE + OFFSET_INGR_AXI_DST_LO),AXI_DOMAIN_ADDR);
	printk("tran_dst_lo = %x\n", XIo_In32(bar0_addr + REG_BRDG_BASE + REG_INGR_AXI_BASE + OFFSET_INGR_AXI_DST_LO));

	/* DST HI will already set to Zero by default */
	//  XIo_Out32((bar0_addr + REG_BRDG_BASE + REG_INGR_AXI_BASE + OFFSET_INGR_AXI_DST_HI),0x00000000);
	//  printk("tran_dst_hi = %x\n", XIo_In32(bar0_addr + REG_BRDG_BASE + REG_INGR_AXI_BASE + OFFSET_INGR_AXI_DST_HI));


#if defined(VIDEO_ACC_DESIGN)
	/* Adding DREG capability */
	//- Read dreg_cap		
	printk("\nData at BAR0 offset (0x8280) = %x\n", XIo_In32(bar0_addr + REG_BRDG_BASE  + REG_BRDG_E_BASE + OFFSET_BRDG_D_CAP ));

	/* Read dreg control register */ 
	reg = XIo_In32(bar0_addr + REG_BRDG_BASE + REG_BRDG_E_BASE + OFFSET_BRDG_D_CTRL );
	printk("\nData at BAR0 offset (0x8288) = %x\n", reg);

	reg |= 0x00000001;

	XIo_Out32(bar0_addr + REG_BRDG_BASE + REG_BRDG_E_BASE + OFFSET_BRDG_D_CTRL,reg );
	printk("\nData at BAR0 offset (0x8288) = %x\n", XIo_In32(bar0_addr + REG_BRDG_BASE  + REG_BRDG_E_BASE + OFFSET_BRDG_D_CTRL ));

	/* - Program src address to be BAR[2] */
	XIo_Out32((bar0_addr + REG_BRDG_BASE + REG_BRDG_E_BASE + OFFSET_BRDG_D_SRC_LO), 0x80000000);
	printk("\nData at BAR0 offset (0x8290) = %x\n", XIo_In32(bar0_addr + REG_BRDG_BASE  + REG_BRDG_E_BASE + OFFSET_BRDG_D_SRC_LO ));

	XIo_Out32((bar0_addr + REG_BRDG_BASE + 0x464), 1);
	reg = XIo_In32(bar0_addr + REG_BRDG_BASE +0x464);//  RD_DMA_REG(brdg_reg_base, EP_BRDG_REG_MSGF_MSK_OFFSET);
	printk(KERN_ERR"EP_BRDG_REG_MSGF_MSK_OFFSET = %x\n",reg);

	reg = XIo_In32(bar0_addr + DMA_AXI_INTR_CNTRL_REG_OFFSET );
	printk(KERN_ERR"AXI_INTERRUPT_CTRL register val = %x\n",reg);
	/* Enable AXI Interrupts */
	reg |= 0x01;
	XIo_Out32(bar0_addr + DMA_AXI_INTR_CNTRL_REG_OFFSET,reg);
	printk(KERN_ERR"AXI_INTERRUPT_CTRL register val = %x\n",reg);

	//  XIo_Out32((bar0_addr + DMA_AXI_INTR_ASSRT_REG_OFFSET), 0x8);
#endif

	reg = XIo_In32(bar0_addr + REG_BRDG_BASE + REG_BRDG_E_BASE + OFFSET_BRDG_E_CTRL );
	/* Enable bridge translation with 64K size */
	printk("Initial e_breg_control= %0x\n", reg);
	XIo_Out32((bar0_addr + REG_BRDG_BASE + REG_BRDG_E_BASE + OFFSET_BRDG_E_CTRL), 0x00040001);
	reg = XIo_In32(bar0_addr + REG_BRDG_BASE + REG_BRDG_E_BASE + OFFSET_BRDG_E_CTRL );
	printk("e_breg_control= %0x\n", reg);

#ifdef HW_SGL_DESIGN
	XIo_Out32((bar2_addr + USER_BASE + SCAL_FACTOR_REG), 0x1);
#endif
#if 1
	printk("Scaling factor %x",XIo_In32(bar2_addr + USER_BASE + SCAL_FACTOR_REG));
#ifdef DDR_DESIGN
	/* For x8 Gen3, MIG AXI User Clk is 300MHz */
	XIo_Out32((bar2_addr + USER_BASE + CLK_PERIOD_REG), CLK_250MHZ_PERIOD);            //250MHz clock
	XIo_Out32((bar2_addr + AXI_PERF_MON_BASE + SAMPLE_INTERVAL), CLK_300MHZ_PERIOD);   //300MHz clock
	/* For x4 Gen3, PCIe User clk is 125MHz and MIG AXI User Clk is 267MHz */
	//XIo_Out32((bar2_addr + USER_BASE + CLK_PERIOD_REG), CLK_125MHZ_PERIOD);            //125MHz clock
	//XIo_Out32((bar2_addr + AXI_PERF_MON_BASE + SAMPLE_INTERVAL), CLK_267MHZ_PERIOD);   //267MHz clock
#else
	XIo_Out32((bar2_addr + AXI_PERF_MON_BASE + SAMPLE_INTERVAL), CLK_250MHZ_PERIOD); // 250 MHz
#endif 

	XIo_Out32((bar2_addr + AXI_PERF_MON_BASE + SAMPLE_INTERVAL_CTRL), 0x2); // Load inteval timer reg value
	XIo_Out32((bar2_addr + AXI_PERF_MON_BASE + SAMPLE_INTERVAL_CTRL), 0x0); // clear load bit
	XIo_Out32((bar2_addr + AXI_PERF_MON_BASE + SAMPLE_INTERVAL_CTRL), 0x101); // enable + reset metric counter after read

#ifdef HW_SGL_DESIGN
#ifdef ETH_APP
	XIo_Out32((bar2_addr +  AXI_PERF_MON_BASE + METRIC_SEL_REG0), 0x52721232);//slotID1-databytecount + slotID0 databytecount
	//  {0,12}              + {1,12}     
#else
	XIo_Out32((bar2_addr +  AXI_PERF_MON_BASE + METRIC_SEL_REG0), 0x1232);//slotID1-databytecount + slotID0 databytecount
#endif
#endif

#ifdef PFORM_USCALE_NO_EP_PROCESSOR
#if defined(VIDEO_ACC_DESIGN)
	XIo_Out32((bar2_addr +  AXI_PERF_MON_BASE + METRIC_SEL_REG0), 0x22230203);
#else
	XIo_Out32((bar2_addr +  AXI_PERF_MON_BASE + METRIC_SEL_REG0), 0x0203);
#endif
#endif                             
	XIo_Out32((bar2_addr + AXI_PERF_MON_BASE + APM_CTRL_REG), 0x1);
#endif

}

static void poll_stats(unsigned long __opaque)
{
	unsigned long t1;
	struct pci_dev *pdev = (struct pci_dev *)__opaque;
	ps_pcie_dma_desc_t *lp = pci_get_drvdata(pdev);
	int offset = 0;
	unsigned long t2;
	u8 __iomem *base = lp->cntrl_func_virt_base_addr;
	/* Now, get the TRN statistics 
	 * Registers to be read for TRN stats 
	 * This counts all TLPs including header */

	t1 = RD_DMA_REG(base, USER_BASE + TX_UTIL_BC);
	t2 = RD_DMA_REG(base, USER_BASE + RX_UTIL_BC);

	TStats[tstatsWrite].LTX = 4*(t1>>2);

	TStats[tstatsWrite].LRX = 4*(t2>>2);


	TStats[tstatsWrite].scaling_factor = RD_DMA_REG(base, USER_BASE + SCAL_FACTOR_REG);



#if defined(VIDEO_ACC_DESIGN)
	TStats[tstatsWrite].RBC_APM0 = RD_DMA_REG(base,  AXI_PERF_MON_BASE + APM_METRIC_CNTR2);
	TStats[tstatsWrite].WBC_APM0 = RD_DMA_REG(base, AXI_PERF_MON_BASE + APM_METRIC_CNTR3 );

	log_normal(KERN_ERR"LTX = %d LRX = %d RBC_APM = %d WBC_APM = %d\n",TStats[tstatsWrite].LTX,\
			TStats[tstatsWrite].LRX, TStats[tstatsWrite].RBC_APM0, TStats[tstatsWrite].WBC_APM0);
#elif defined(ETH_APP)
	TStats[tstatsWrite].RBC_APM0 = RD_DMA_REG(base,  AXI_PERF_MON_BASE + APM_METRIC_CNTR0);
	TStats[tstatsWrite].WBC_APM0 = RD_DMA_REG(base, AXI_PERF_MON_BASE + APM_METRIC_CNTR1 );
	TStats[tstatsWrite].RBC_APM1 = RD_DMA_REG(base, AXI_PERF_MON_BASE + APM_METRIC_CNTR2 );
	TStats[tstatsWrite].WBC_APM1 = RD_DMA_REG(base, AXI_PERF_MON_BASE + APM_METRIC_CNTR3 );
	log_normal("## RBC0 %x WBC0 %x RBC1 %x wbc1 %x ## \n",TStats[tstatsWrite].RBC_APM0,TStats[tstatsWrite].WBC_APM0,TStats[tstatsWrite].RBC_APM1, TStats[tstatsWrite].WBC_APM1);
#else
	TStats[tstatsWrite].RBC_APM0 = RD_DMA_REG(base,  AXI_PERF_MON_BASE + APM_METRIC_CNTR0);
	TStats[tstatsWrite].WBC_APM0 = RD_DMA_REG(base, AXI_PERF_MON_BASE + APM_METRIC_CNTR1 );
#endif
	/* Check for DATA_VERIFY for Checker mode */
#ifndef DDR_DESIGN
#ifdef DATA_VERIFY
	int val=0;
	val = RD_DMA_REG(base,GEN_CHECK_OFFSET_START + CHK_STATUS);
	if(val)
		printk("##### DATA MISMATCH OCCURED %x ##### \n",RD_DMA_REG(base,GEN_CHECK_OFFSET_START + CHK_STATUS));
#endif
#endif		 
	tstatsWrite += 1;
	if(tstatsWrite >= MAX_STATS) tstatsWrite = 0;

	if(tstatsNum < MAX_STATS)
		tstatsNum += 1;
	/* else move the read pointer forward */
	else
	{
		tstatsRead += 1;
		if(tstatsRead >= MAX_STATS) tstatsRead = 0;
	}

	spin_lock(&DmaStatsLock);
	pmval.vcc = XIo_In32(base+ PVTMON_BASE +PVTMON_VCCINT);
	pmval.vccaux = XIo_In32(base+PVTMON_BASE+PVTMON_VCCAUX);
	pmval.vcc3v3 = XIo_In32(base+PVTMON_BASE+PVTMON_VCC3);
	pmval.vadj = XIo_In32(base+PVTMON_BASE+PVTMON_VADJ);
	pmval.vcc2v5 = XIo_In32(base+PVTMON_BASE+PVTMON_VCC2);
	pmval.vcc1v5 = XIo_In32(base+PVTMON_BASE+PVTMON_VCC1);
	pmval.mgt_avcc = XIo_In32(base+PVTMON_BASE+PVTMON_MGT_AVCC);
	pmval.mgt_avtt = XIo_In32(base+PVTMON_BASE+PVTMON_MGT_AVTT);
	pmval.vccaux_io = XIo_In32(base+PVTMON_BASE+PVTMON_VCCAUX_IO);
	pmval.vccbram = XIo_In32(base+PVTMON_BASE+PVTMON_VCCBRAM);
	pmval.mgt_vccaux = XIo_In32(base+PVTMON_BASE+PVTMON_MGT_VCCAUX);

	pmval.die_temp = (XIo_In32(base+PVTMON_BASE+PVTMON_TEMP));
#ifdef DEBUG_VERBOSE
	log_verbose(KERN_INFO "VCCINT=%x",pmval.vcc);
	log_verbose(KERN_INFO "VCCAUX=%x",pmval.vccaux);
	log_verbose(KERN_INFO "VCC3V3=%x",pmval.vcc3v3);
	log_verbose(KERN_INFO "MGT_AVCC=%x",pmval.mgt_avcc);
	log_verbose(KERN_INFO "MGT_AVTT=%x",pmval.mgt_avtt);
	log_verbose(KERN_INFO "VCCAUX_IO=%x",pmval.vccaux_io);
	log_verbose(KERN_INFO "VCCBRAM=%x",pmval.vccbram);
	log_verbose(KERN_INFO "DIE_TEMP=%x",pmval.die_temp);
#endif
	spin_unlock(&DmaStatsLock);

	/* Reschedule poll routine */
	offset = -3;
	stats_timer.expires = jiffies + HZ + offset;
	add_timer(&stats_timer);
}


static int ReadPCIState(void * pdev, PCIState * pcistate)
{
	int pos;
	u16 valw;
	u8 valb;
#ifdef USE_LATER
	int reg=0,linkUpCap=0;
#endif
	u64 base;
	base = (u64 )g_host_dma_desc.cntrl_func_virt_base_addr;


	/* Since probe has succeeded, indicates that link is up. */
	pcistate->LinkState = LINK_UP;
	pcistate->VendorId = PCI_VENDOR_XILINX;
#ifdef HW_SGL_DESIGN
#ifdef ETH_APP
	pcistate->DeviceId = NWL_DMA_HW_SGL_ETHER;
#else
	pcistate->DeviceId = NWL_DMA_HW_SGL_CNTRL;
#endif
#elif defined(VIDEO_ACC_DESIGN)
	pcistate->DeviceId = NWL_DMA_VAL_DEVID_VIDEO;
#else
	pcistate->DeviceId = NWL_DMA_VAL_DEVID;
#endif


	/* Read Interrupt setting - Legacy or MSI/MSI-X */
	pci_read_config_byte(pdev, PCI_INTERRUPT_PIN, &valb);
	if(!valb)
	{
		if(pci_find_capability(pdev, PCI_CAP_ID_MSIX))
			pcistate->IntMode = INT_MSIX;
		else if(pci_find_capability(pdev, PCI_CAP_ID_MSI))
			pcistate->IntMode = INT_MSI;
		else
			pcistate->IntMode = INT_NONE;
	}
	else if((valb >= 1) && (valb <= 4))
		pcistate->IntMode = INT_LEGACY;
	else
		pcistate->IntMode = INT_NONE;
	if((pos = pci_find_capability(pdev, PCI_CAP_ID_EXP)))
	{
		/* Read Link Status */
		pci_read_config_word(pdev, pos+PCI_EXP_LNKSTA, &valw);
		pcistate->LinkSpeed = (valw & 0x0003);
		pcistate->LinkWidth = (valw & 0x03f0) >> 4;
#ifdef USE_LATER
		reg=XIo_In32(base+PCIE_CAP_REG);
		linkUpCap= (reg>>4) & 0x1;
		pcistate->LinkUpCap = linkUpCap;
#endif
		/* Read MPS & MRRS */
		pci_read_config_word(pdev, pos+PCI_EXP_DEVCTL, &valw);
		pcistate->MPS = 128 << ((valw & PCI_EXP_DEVCTL_PAYLOAD) >> 5);
		pcistate->MRRS = 128 << ((valw & PCI_EXP_DEVCTL_READRQ) >> 12);
	}
	else
	{
		printk("Cannot find PCI Express Capabilities\n");
		pcistate->LinkSpeed = pcistate->LinkWidth = 0;
		pcistate->MPS = pcistate->MRRS = 0;
	}
	pcistate->InitFCCplD = XIo_In32(base+USER_BASE +MInitFCCplD)& 0x00000FFF;
	pcistate->InitFCCplH = XIo_In32(base+USER_BASE +MInitFCCplH)& 0x000000FF;
	pcistate->InitFCNPD  = XIo_In32(base+USER_BASE +MInitFCNPD) & 0x00000FFF;
	pcistate->InitFCNPH  = XIo_In32(base+USER_BASE +MInitFCNPH) & 0x000000FF;
	pcistate->InitFCPD   = XIo_In32(base+USER_BASE +MInitFCPD)  & 0x00000FFF;
	pcistate->InitFCPH   = XIo_In32(base+USER_BASE +MInitFCPH)  & 0x000000FF;
	pcistate->Version    = XIo_In32(base+USER_BASE );	

	return 0;
}


/* Character device file operations */
static int xdma_dev_open(struct inode * in, struct file * filp)
{
	/* Will restrict more than one file open 
	*/
	if(UserOpen)
	{
		printk("Device already in use\n");
		return -EBUSY;
	}


	spin_lock_bh(&DmaStatsLock);
	UserOpen++;                 /* To prevent more than one GUI */
	spin_unlock_bh(&DmaStatsLock);

	return 0;
}



static int xdma_dev_release(struct inode * in, struct file * filp)
{
	if(!UserOpen)
	{
		/* Should not come here */
		printk("Device not in use\n");
		return -EFAULT;
	}

	spin_lock_bh(&DmaStatsLock);
	UserOpen-- ;
	spin_unlock_bh(&DmaStatsLock);

	return 0;
}

#if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,36)
static int xdma_dev_ioctl(struct inode * in, struct file * filp,
		unsigned int cmd, unsigned long arg)
#else
static long xdma_dev_ioctl(struct file * filp,
		unsigned int cmd, unsigned long arg)
#endif
{
	int retval=0;
	EngState eng;
	TRNStatsArray tsa;
	TRNStatistics * ts;
	PCIState pcistate;
	ps_pcie_dma_chann_desc_t *chann_temp;
	LedStats lstats; 


	ps_pcie_dma_desc_t *ptr_dma_desc_temp = &g_host_dma_desc;
	PowerMonitorVal pmval_temp;

	int len, i;
#if defined(ETH_APP) || defined(DDR_DESIGN)
	int Status_Reg=0;

	u64 base= (u64)ptr_dma_desc_temp->cntrl_func_virt_base_addr;
#endif
	/* Check cmd type and value */
	if(_IOC_TYPE(cmd) != XPMON_MAGIC) return -ENOTTY;
	if(_IOC_NR(cmd) > XPMON_MAX_CMD) return -ENOTTY;

	/* Check read/write and corresponding argument */
	if(_IOC_DIR(cmd) & _IOC_READ)
		if(!access_ok(VERIFY_WRITE, (void *)arg, _IOC_SIZE(cmd)))
			return -EFAULT;
	if(_IOC_DIR(cmd) & _IOC_WRITE)
		if(!access_ok(VERIFY_READ, (void *)arg, _IOC_SIZE(cmd)))
			return -EFAULT;
	/* Looks ok, let us continue */
	switch(cmd)
	{
		case IGET_PCI_STATE:
			ReadPCIState(ptr_dma_desc_temp->device, &pcistate);
			if(copy_to_user((PCIState *)arg, &pcistate, sizeof(PCIState)))
			{
				printk("copy_to_user failed\n");
				retval = -EFAULT;
				break;
			}
			break;
		case IGET_LED_STATISTICS:
#ifdef ETH_APP
			Status_Reg = XIo_In32(base +USER_BASE + 0x418);

			lstats.Phy0 = Status_Reg & 0x1;  /* 0th bit 'on' of Status Register indicated Phy 0 link up */
			lstats.Phy1 = (Status_Reg >> 8) & 0x1;  /* 8th bit 'on' of Status Register indicated Phy 1 link up */
#endif
#ifdef DDR_DESIGN
			Status_Reg = XIo_In32(base + USER_BASE + 0x4);	
			lstats.DdrCalib0 = (Status_Reg) & 0x1;  /* 1st bit 'on' of Status Register indicated DDR3 Calibration done*/
#endif 
				if(copy_to_user((LedStats *)arg, &lstats, sizeof(LedStats)))
				{
					printk("copy_to_user failed\n");
					retval = -EFAULT;
					break;
				}
			break;

		case IGET_PMVAL:
			spin_lock_bh(&DmaStatsLock);
			memcpy(&pmval_temp,&pmval,sizeof(PowerMonitorVal));
			spin_unlock_bh(&DmaStatsLock);
			if(copy_to_user((PowerMonitorVal *)arg, &pmval_temp, sizeof(PowerMonitorVal)))
			{
				printk("PMVAL copy_to_user failed\n");
				retval = -EFAULT;
			}
			break;

		case IGET_ENG_STATE:
			if(copy_from_user(&eng, (EngState *)arg, sizeof(EngState)))
			{
				printk("\ncopy_from_user failed\n");
				retval = -EFAULT;
				break;
			}

			i = eng.Engine;

			chann_temp =  &(ptr_dma_desc_temp->channels[i]);
#ifdef USE_LATER
			/*Use below code to get Actual Error from SG element
			*/

			unsigned long flags;
			spin_lock_irqsave(&chann_temp->channel_lock, flags);
			eng.SrcErrors = chann_temp->src_sgl_err;
			eng.DstErrors = chann_temp->dst_sgl_err;
			eng.IntErrors  = chann_temp->internal_err;
			spin_unlock_irqrestore(&chann_temp->channel_lock, flags);
#endif  

			eng.SrcErrors = 0;
			eng.DstErrors = 0;
			eng.IntErrors  = 0;

			if(copy_to_user((EngState *)arg, &eng, sizeof(EngState)))
			{
				printk("copy_to_user failed\n");
				retval = -EFAULT;
				break;
			}
			break;
		case IGET_TRN_STATISTICS:
			if(copy_from_user(&tsa, (TRNStatsArray *)arg, sizeof(TRNStatsArray)))
			{
				printk("copy_from_user failed\n");
				retval = -1;
				break;
			}

			ts = tsa.trnptr;
			len = 0;
			for(i=0; i<tsa.Count; i++)
			{
				TRNStatistics from;

				if(!tstatsNum) break;

				spin_lock_bh(&DmaStatsLock);
				from = TStats[tstatsRead];
				tstatsNum -= 1;
				tstatsRead += 1;
				if(tstatsRead == MAX_STATS)
					tstatsRead = 0;
				spin_unlock_bh(&DmaStatsLock);

				if(copy_to_user(ts, &from, sizeof(TRNStatistics)))
				{
					printk("copy_to_user failed\n");
					retval = -EFAULT;
					break;
				}

				len++;
				ts++;
			}
			tsa.Count = len;
			if(copy_to_user((TRNStatsArray *)arg, &tsa, sizeof(TRNStatsArray)))
			{
				printk("copy_to_user failed\n");
				retval = -EFAULT;
				break;
			}
			break;


		default:
			printk("Invalid command %d\n", cmd);
			retval = -1;
			break;
	}

	return retval;
}





static int /*__devinit*/ nwl_dma_probe(struct pci_dev *pdev,
		const struct pci_device_id *ent)
{
	int err, pci_using_dac,i;
	ps_pcie_dma_desc_t *ptr_dma_desc_temp = NULL;
	dev_t xdmaDev;
	int chrRet;
	static struct file_operations xdmaDevFileOps;	

	err = pci_enable_device(pdev);
	if (err)
		return err;

	printk(KERN_ERR"\nPCIe device enabled\n");

	if (!dma_set_mask(nwl_pci_dev_to_dev(pdev), DMA_BIT_MASK(64)) &&
			!dma_set_coherent_mask(nwl_pci_dev_to_dev(pdev), DMA_BIT_MASK(64))) {
		pci_using_dac = 1;
		printk(KERN_ERR"\nPCIe 64bit access capable\n");

	} else {
		err = dma_set_mask(nwl_pci_dev_to_dev(pdev), DMA_BIT_MASK(32));
		if (err) {
			err = dma_set_coherent_mask(nwl_pci_dev_to_dev(pdev),
					DMA_BIT_MASK(32));
			printk(KERN_ERR"\nPCIe 32bit access capable\n");
			if (err) {
				dev_err(nwl_pci_dev_to_dev(pdev), "No usable DMA "
						"configuration, aborting\n");
				printk(KERN_ERR"\nError!!! No usable DMA configuration ..........\n");
				goto err_dma;
			}
		}
		pci_using_dac = 0;
	}

	printk(KERN_ERR"\nPCIe request regions \n");

	err = pci_request_regions(pdev, ps_pcie_driver_name);
	if (err) {
		dev_err(nwl_pci_dev_to_dev(pdev),
				"pci_request_regions failed 0x%x\n", err);
		printk(KERN_ERR"\nERROR!!!! PCIe request regions failed\n");
		goto err_pci_reg;
	}

	printk(KERN_ERR"\nPCIe NOT enable error reporting\n");

	//pci_enable_pcie_error_reporting(pdev); TODO support error reporting

	printk(KERN_ERR"\nPCIe set master\n");

	pci_set_master(pdev);

	/*
	 * Allocate a descriptor corresponding to discovered 
	 */
	ptr_dma_desc_temp = &g_host_dma_desc; //TODO this is temporary, dynamically alloc and support multiple EPs

	/* Initialize fields of the dma descriptor */
	ptr_dma_desc_temp->device = (void*)pdev;
	ptr_dma_desc_temp->irq_no = pdev->irq;
	ptr_dma_desc_temp->num_channels = PS_PCIE_NUM_DMA_CHANNELS;
	ptr_dma_desc_temp->num_channels_active = PS_PCIE_NUM_DMA_CHANNELS; //TODO, get from device tree
	ptr_dma_desc_temp->pform = HOST; //We are the host
	ptr_dma_desc_temp->num_channels_alloc = 0;

	spin_lock_init(&ptr_dma_desc_temp->dma_lock);

	spin_lock_init(&DmaStatsLock);

	ptr_dma_desc_temp->dma_reg_phy_base_addr = pci_resource_start(pdev, PS_PCIE_BRDG_DMA_CHANN_BAR);
	ptr_dma_desc_temp->dma_reg_virt_base_addr = ioremap_nocache(ptr_dma_desc_temp->dma_reg_phy_base_addr, 
			pci_resource_len(pdev, 0));
	if (!ptr_dma_desc_temp->dma_reg_virt_base_addr) 
	{

		printk(KERN_ERR"\nPCIe ioremap failed ERROR!!!!\n");
		err = -EIO;
		goto err_ioremap;
	}

	printk(KERN_ERR"\n DMA and Bridge Register Base Physical addr: %x, Virt address %p Length %d\n",(unsigned int)ptr_dma_desc_temp->dma_reg_phy_base_addr, 
			ptr_dma_desc_temp->dma_reg_virt_base_addr, (int)pci_resource_len(pdev, 0));

	/* Assign the channel register base address */
	ptr_dma_desc_temp->dma_chann_reg_virt_base_addr = ptr_dma_desc_temp->dma_reg_virt_base_addr /*+ 0x1000*/;


	ptr_dma_desc_temp->cntrl_func_phy_base_addr = pci_resource_start(pdev, PS_PCIE_CNTRL_FUNCT_INGRESS_TRANS_BAR);
	ptr_dma_desc_temp->cntrl_func_virt_base_addr = ioremap_nocache(ptr_dma_desc_temp->cntrl_func_phy_base_addr, 
			pci_resource_len(pdev, PS_PCIE_CNTRL_FUNCT_INGRESS_TRANS_BAR));
	if (!ptr_dma_desc_temp->cntrl_func_virt_base_addr) 
	{

		printk(KERN_ERR"\nPCIe ioremap failed ERROR!!!!\n");
		err = -EIO;
		goto err_ioremap_ingress_bar;
	}

	printk(KERN_ERR"\n User Registers BAR Physical addr: %x, Virt address %p Length %d\n",(unsigned int)ptr_dma_desc_temp->cntrl_func_phy_base_addr, 
			ptr_dma_desc_temp->cntrl_func_virt_base_addr, (int)pci_resource_len(pdev, PS_PCIE_CNTRL_FUNCT_INGRESS_TRANS_BAR));

	/* Initialize the bridge */
	InitBridge((u64) ptr_dma_desc_temp->dma_reg_virt_base_addr, 
			(u64) ptr_dma_desc_temp->dma_reg_phy_base_addr, 
			(u64) ptr_dma_desc_temp->cntrl_func_virt_base_addr, 
			(u64) ptr_dma_desc_temp->cntrl_func_phy_base_addr);

	pci_set_drvdata(pdev, ptr_dma_desc_temp);


#ifdef USE_MSIX
	{
		unsigned int i;

		for (i = 0; i < NUM_MSIX_VECS; i++)
			ptr_dma_desc_temp->entries[i].entry = i;

		err = pci_enable_msix(pdev, ptr_dma_desc_temp->entries, NUM_MSIX_VECS);
		if(err != XLNX_SUCCESS) 
		{
			printk(KERN_ERR"\nMSIx Vectors NOT acquired %d\n",err);
			printk(KERN_ERR"\n%x %x\n",ptr_dma_desc_temp->entries,/*pdev->msix_cap ,*/pdev->current_state);

			err = pci_enable_msi(pdev);
			if(err != XLNX_SUCCESS) 
			{
				err = register_interrupt_handler(pdev->irq, "PS PCIe DMA Device", ptr_dma_desc_temp);
				if(err != XLNX_SUCCESS) 
				{
					goto interrupt_registration_failed;
				}
				else
				{
					ptr_dma_desc_temp->intr_type = HW;
					printk(KERN_ERR"\nHW interrupt acquired %d\n",err);
				}
			}
			else
			{
				err = register_interrupt_handler(pdev->irq, "PS PCIe DMA Device", ptr_dma_desc_temp);
				if(err != XLNX_SUCCESS) 
				{
					goto interrupt_registration_failed;
				}
				else
				{
					ptr_dma_desc_temp->intr_type = MSI;
					printk(KERN_ERR"\nMSI Interrupt acquired %d\n",err);
				}
			}
		}
		else
		{
			int i;
			ptr_dma_desc_temp->intr_type = MSIX;
			printk(KERN_ERR"\nMSIx Vectors acquired %d\n",err);

			for(i = 0; i < NUM_MSIX_VECS; i++) 
			{
				sprintf(ptr_dma_desc_temp->channels[i].msix_hndlr_name, "PS PCIe DMA Chann %d Interrupt Handler",i);
				if(request_irq(ptr_dma_desc_temp->entries[i].vector,
							ps_pcie_intr_handler,
							0, 
							ptr_dma_desc_temp->channels[i].msix_hndlr_name, 
							&ptr_dma_desc_temp->channels[i]))
				{
					err = XLNX_MSIX_HNDLR_REG_FAIL;
					goto msix_hndlr_registration_failed;
				}
				else
				{
					(&ptr_dma_desc_temp->channels[i])->intr_hndlr_registered = true;
					printk(KERN_ERR"\nMSIx Interrupt handler registered\n");
				}
			}


		}
	}
#else
	err = register_interrupt_handler(pdev->irq, "PS PCIe DMA Device", ptr_dma_desc_temp);
	if(err != XLNX_SUCCESS) 
	{
		goto interrupt_registration_failed;
	}
#endif
	/* The following code is for registering as a character device driver.
	 * The GUI will use /dev/xdma_state file to read state & statistics.
	 * Incase of any failure, the driver will come up without device
	 * file support, but statistics will still be visible in the system log.
	 */
	/* First allocate a major/minor number. */
	chrRet = alloc_chrdev_region(&xdmaDev, 0, 1, "xdma_stats");
	if(chrRet < 0)
		printk(KERN_ERR "Error allocating char device region\n");
	else
	{
		/* Register our character device */
		xdmaCdev = cdev_alloc();
		if(IS_ERR(xdmaCdev))
		{
			printk(KERN_ERR "Alloc error registering device driver\n");
			unregister_chrdev_region(xdmaDev, 1);
			chrRet = -1;
		}
		else
		{
			xdmaDevFileOps.owner = THIS_MODULE;
			xdmaDevFileOps.open = xdma_dev_open;
			xdmaDevFileOps.release = xdma_dev_release;
#if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,36)
			xdmaDevFileOps.ioctl = xdma_dev_ioctl;
#else
			xdmaDevFileOps.unlocked_ioctl = xdma_dev_ioctl;
#endif
			xdmaCdev->owner = THIS_MODULE;
			xdmaCdev->ops = &xdmaDevFileOps;
			xdmaCdev->dev = xdmaDev;
			chrRet = cdev_add(xdmaCdev, xdmaDev, 1);
			if(chrRet < 0)
			{
				printk(KERN_ERR "Add error registering device driver\n");
				unregister_chrdev_region(xdmaDev, 1);
			}
		}
	}
	/* Initialise all stats pointers */
	for(i=0; i<PS_PCIE_NUM_DMA_CHANNELS; i++)
	{
		dstatsRead[i] = dstatsWrite[i] = dstatsNum[i] = 0;
		sstatsRead[i] = sstatsWrite[i] = sstatsNum[i] = 0;
		SWrate[i] = 0;
	}
	tstatsRead = tstatsWrite = tstatsNum = 0;

	/* Start stats polling routine */
	printk(KERN_INFO "probe: Starting stats poll routine \n");
	/* Now start timer */
	init_timer(&stats_timer);
	stats_timer.expires=jiffies + HZ;
	stats_timer.data=(unsigned long) pdev;
	stats_timer.function = poll_stats;
	add_timer(&stats_timer);
	printk(KERN_ERR"\nInitialized HOST side diver logic\n");

	//TODO free up resources for each label
interrupt_registration_failed:
msix_hndlr_registration_failed:
err_dma:
err_pci_reg:
err_ioremap:
err_ioremap_ingress_bar:
	return err;

}

static void /*__devexit*/ nwl_dma_remove(struct pci_dev *pdev)
{

	spin_lock_bh(&DmaStatsLock);
	del_timer_sync(&stats_timer);
	spin_unlock_bh(&DmaStatsLock);

	if(xdmaCdev != NULL)
	{
		cdev_del(xdmaCdev);
		unregister_chrdev_region(xdmaCdev->dev,1);
	}
#ifdef USE_MSIX
	if(g_host_dma_desc.intr_type == MSIX) 
	{
		printk(KERN_ERR"\nUnregister MSIX vectors\n");

		{
			int i;

			for(i = 0; i < NUM_MSIX_VECS; i++) 
			{
				/*
				   if(request_irq(ptr_dma_desc_temp->entries[i].vector,
				   ps_pcie_intr_handler,
				   0, 
				   ptr_dma_desc_temp->channels[i].msix_hndlr_name, 
				   &ptr_dma_desc_temp->channels[i]))
				   {
				   err = XLNX_MSIX_HNDLR_REG_FAIL;
				   goto msix_hndlr_registration_failed;
				   }
				   else
				   {
				   (&ptr_dma_desc_temp->channels[i])->intr_hndlr_registered = true;
				   printk(KERN_ERR"\nMSIx Interrupt handler registered\n");
				   }*/
				free_irq(g_host_dma_desc.entries[i].vector, &g_host_dma_desc.channels[i]);
			}


		}
		pci_disable_msix(pdev);
	}
	else
		if(g_host_dma_desc.intr_type == MSI) 
		{
			printk(KERN_ERR"\nUnregister MSI` interrupt handler\n");
			free_irq(pdev->irq, &g_host_dma_desc); //Todo need to change for multiple card support with linked list
			pci_disable_msi(pdev);
			g_host_dma_desc.intr_hndlr_registered = false;
		}
		else
			if(g_host_dma_desc.intr_type == HW) 
			{
				printk(KERN_ERR"\nUnregister Legacy interrupt handler\n");
				free_irq(pdev->irq, &g_host_dma_desc); //Todo need to change for multiple card support with linked list
				g_host_dma_desc.intr_hndlr_registered = false;
			}
#else
	if(g_host_dma_desc.intr_hndlr_registered == true) 
	{
		printk(KERN_ERR"\nUnregister Legacy interrupt handler\n");
		free_irq(pdev->irq, &g_host_dma_desc); //Todo need to change for multiple card support with linked list
		g_host_dma_desc.intr_hndlr_registered = false;
	}
#endif


	iounmap(g_host_dma_desc.cntrl_func_virt_base_addr); //Todo need to change for multiple card support with linked list
	iounmap(g_host_dma_desc.dma_reg_virt_base_addr); //Todo need to change for multiple card support with linked list
	pci_clear_master(pdev);
	pci_release_regions(pdev);
	pci_disable_device(pdev);
}

/* ixgbevf_pci_tbl - PCI Device ID Table
 *
 * Wildcard entries (PCI_ANY_ID) should come last
 * Last entry must be all 0s
 *
 * { Vendor ID, Device ID, SubVendor ID, SubDevice ID,
 *   Class, Class Mask, private data (not used) }
 */
static struct pci_device_id nwl_dma_pci_tbl[] = {
	{PCI_DEVICE(PCI_VENDOR_XILINX, NWL_DMA_VAL_DEVID)},
	{PCI_DEVICE(PCI_VENDOR_XILINX, NWL_DMA_VAL_DEVID_VIDEO)},
	{PCI_DEVICE(PCI_VENDOR_XILINX, NWL_DMA_x4G1_PFMON_DEVID)},
	{PCI_DEVICE(PCI_VENDOR_XILINX, NWL_DMA_HW_SGL_CNTRL)},
	{PCI_DEVICE(PCI_VENDOR_XILINX, NWL_DMA_HW_SGL_ETHER)},
	/* required last entry */
	{0, }
};
//MODULE_DEVICE_TABLE(pci, nwl_dma_pci_tbl);



static struct pci_driver nwl_dma_driver = {
	.name     = ps_pcie_driver_name,
	.id_table = nwl_dma_pci_tbl,
	.probe    = nwl_dma_probe,
	.remove   = /*__devexit_p*/(nwl_dma_remove),
#ifdef CONFIG_PM //TODO power management
	/* Power Management Hooks */
	.suspend  = NULL,//nwl_dma_suspend,
	.resume   = NULL,//ixgbevf_resume,
#endif
#ifndef USE_REBOOT_NOTIFIER //TODO Reboot notifier
	.shutdown = NULL,//ixgbevf_shutdown,
#endif
	.err_handler = NULL,//&ixgbevf_err_handler
};


/*int xilinx_ps_pcie_dma_driver_init()
  {
  return 0;
  }*/



/*
 * NWL DMA centric functions
 * These functions abstract the inner register & BD format of NWL DMA
 */
//TODO #warning "Make this funtion inline"
static /*inline*/ void ps_pcie_post_process_rx_qs(/*ps_pcie_dma_chann_desc_t*/struct work_struct *work/*ptr_chann_desc, enum dma_data_direction dr*/)

{
	ps_pcie_dma_chann_desc_t *ptr_chann_desc = (ps_pcie_dma_chann_desc_t *)container_of(work, ps_pcie_dma_chann_desc_t, intrh_work);
	ps_pcie_sta_desc_t *ptr_sta_desc = NULL;
	unsigned int dbg_flag = 1;
	unsigned short cntxt_hndl;
	unsigned short uid;
	unsigned int compl_bytes = 0;
	enum dma_data_direction dr;
	//unsigned long flags;

	u8 __iomem *ptr_chan_dma_reg_vbaddr = ptr_chann_desc->chan_dma_reg_vbaddr;

	if(ptr_chann_desc->dir == IN) 
	{
		dr = DMA_FROM_DEVICE;
	}
	else
	{
		dr = DMA_TO_DEVICE;
	}

	//spin_lock_irqsave(&ptr_chann_desc->channel_lock, flags);
	//LOCK_DMA_CHANNEL(&ptr_chann_desc->channel_lock);
	//spin_lock(&ptr_chann_desc->channel_lock);


	/* Go through the status q BD elements */
	ptr_sta_desc = &ptr_chann_desc->ptr_sta_q[ptr_chann_desc->idx_sta_q];

	//UNLOCK_DMA_CHANNEL(&ptr_chann_desc->channel_lock);
	while(ptr_sta_desc->completed ) 
	{
		data_q_cntxt_t *ptr_ctx = NULL;
		data_q_cntxt_t *ptr_postps_start_ctx = NULL;
		unsigned int tmp_bd_idx;
		unsigned int eop_bd_idx;
		unsigned int num_frags = 0;
		unsigned int offset = 0;
		void *data = NULL;
		func_ptr_dma_chann_cbk_noblock cbk;
	//	LOCK_DMA_CHANNEL(&ptr_chann_desc->channel_lock);
#ifdef DBG_PRNT
		printk(KERN_ERR"\nStatus Q BD element index %d\n",ptr_chann_desc->idx_sta_q);
#endif

		/* Check for errors */
		if(ptr_sta_desc->dst_err == 1) 
		{
			printk(KERN_ERR"\nDestination error detected\n");
			ptr_chann_desc->chann_state = XLNX_DMA_DST_ERROR;
			ptr_chann_desc->src_sgl_err++;
			break;
		}

		if(ptr_sta_desc->src_err == 1) 
		{
			printk(KERN_ERR"\nSource error detected\n");
			ptr_chann_desc->chann_state = XLNX_DMA_SRC_ERROR;
			ptr_chann_desc->dst_sgl_err++;
			break;
		}

		if(ptr_sta_desc->intrnl_error == 1) 
		{
			printk(KERN_ERR"\nInternal error detected\n");
			ptr_chann_desc->chann_state = XLNX_DMA_INTRNL_ERROR;
			ptr_chann_desc->internal_err++;
			break;
		}

		if(ptr_sta_desc->upper_sta_nz == 0) 
		{
			printk(KERN_ERR"\nERROR Upper fields have no data!!\n");
			ptr_chann_desc->chann_state = XLNX_DMA_USRDATA_ERROR;
			break;
		}
		else
		{
			cntxt_hndl = ptr_sta_desc->usr_handle;
			uid = ptr_sta_desc->usr_id;
			compl_bytes = ptr_sta_desc->compl_bytes;
		}

		ptr_ctx = &ptr_chann_desc->ptr_ctx[cntxt_hndl];
		ptr_postps_start_ctx = &ptr_chann_desc->ptr_ctx[ptr_chann_desc->idx_rxpostps_cntxt_q];
		tmp_bd_idx = /*ptr_ctx*/ptr_postps_start_ctx->sop_bd_idx;
		eop_bd_idx = ptr_ctx->eop_bd_idx;
#ifdef DBG_PRNT
		printk(KERN_ERR"\nUser handle %d, Uid %x, SOP BD-%d, EOP BD-%d Context Pointer %p",cntxt_hndl, uid, tmp_bd_idx, eop_bd_idx, ptr_ctx);
#endif
		//while(tmp_bd_idx != eop_bd_idx) 
		do
		{
			if(dr == DMA_TO_DEVICE) 
			{
				ps_pcie_src_bd_t *ptr_src_bd = &ptr_chann_desc->ptr_data_q.ptr_src_q[tmp_bd_idx];
				dma_addr_t paddr_buf = (dma_addr_t)ptr_src_bd->phy_src_addr;
				size_t sz = (size_t)ptr_src_bd->byte_count;
#ifdef DBG_PRNT	
				printk(KERN_ERR"\nBD %d Unmapping buffer PA %p Size %d\n", tmp_bd_idx,(void*)paddr_buf, sz);
#endif


				if(ptr_ctx->at == VIRT_ADDR) 
				{
					/* Unmap buffer */
					dma_unmap_single(ptr_chann_desc->ptr_dma_desc->dev, paddr_buf, sz, dr);
				}

				/* Zero out src bd element */
				memset(ptr_src_bd, 0, sizeof(ps_pcie_src_bd_t));
			}
			else
				if(dr == DMA_FROM_DEVICE) 
				{
					ps_pcie_dst_bd_t *ptr_dst_bd = &ptr_chann_desc->ptr_data_q.ptr_dst_q[tmp_bd_idx];
					dma_addr_t paddr_buf = (dma_addr_t)ptr_dst_bd->phy_dst_addr;
					size_t sz = (size_t)ptr_dst_bd->byte_count;
#ifdef DBG_PRNT	
					printk(KERN_ERR"\nBD %d Unmapping buffer PA %p Size %d\n", tmp_bd_idx,(void*)paddr_buf, sz);
#endif
					if(ptr_ctx->at == VIRT_ADDR)
					{
						/* Unmap buffer */
						dma_unmap_single(ptr_chann_desc->ptr_dma_desc->dev, paddr_buf, sz, dr);
					}

					/* Zero out dst bd element */
					memset(ptr_dst_bd, 0, sizeof(ps_pcie_dst_bd_t));
				}

			num_frags++; //Increment numbr of frags for this packet
#ifdef DBG_PRNT
			printk(KERN_ERR"\nFor this packet start BD %d end BD %d Num frags %d\n", tmp_bd_idx,eop_bd_idx, num_frags);
#endif
			if(tmp_bd_idx == eop_bd_idx) 
			{
				break; //We have post processed each fragment
			}

			/* Increment sop bd index */
			tmp_bd_idx++;
			if(tmp_bd_idx == ptr_chann_desc->data_q_sz) 
			{
				tmp_bd_idx = 0;
			}

		}while(1);

		/* Increment number of packet io done by channel */
		ptr_chann_desc->num_pkts_io++;
		/* Increment the number of BDs available for use */
		//ptr_chann_desc->num_free_bds += num_frags;
#if 1
		/* Fire callback if registered */
		if(ptr_postps_start_ctx->cbk) 
		{
#ifdef DBG_PRNT
			printk(KERN_ERR"\nCBK registered %d\n",ptr_chann_desc->num_pkts_io);
#endif
			cbk = ptr_postps_start_ctx->cbk;
			data = ptr_postps_start_ctx->data;
		}
		else
		{
#ifdef DBG_PRNT
			printk(KERN_ERR"\nCBK not registered\n");
#endif
		}
#endif

		/*
		 * Release the context element that correspond to the BD(s) that conatin the packet that was received
		 */
		do
		{
			bool done = false;
			data_q_cntxt_t *tmp_ptr_ctx = &ptr_chann_desc->ptr_ctx[ptr_chann_desc->idx_rxpostps_cntxt_q];
#ifdef DBG_PRNT	
			printk(KERN_ERR"\nZero context Q element data %x Q element frag src q index %d\n",tmp_ptr_ctx->data, tmp_ptr_ctx->sop_bd_idx);
#endif
			/* Zero out context element */
			memset(tmp_ptr_ctx, 0, sizeof(data_q_cntxt_t));
#ifdef DBG_PRNT
			printk(KERN_ERR"\nZero done\n");
#endif


			if(ptr_chann_desc->idx_rxpostps_cntxt_q == cntxt_hndl) 
			{
				done = true;
			}

			/* 
			 * Increment post processing context q index.
			 * This index should always give the next context elemnt at which post processing should start
			 */
			ptr_chann_desc->idx_rxpostps_cntxt_q++;
			if(ptr_chann_desc->idx_rxpostps_cntxt_q == ptr_chann_desc->sta_q_sz) 
			{
				ptr_chann_desc->idx_rxpostps_cntxt_q = 0;
			}

			if(done == true) 
			{
				break;
			}
		}while(1);


		/* Increment status q index */
		ptr_chann_desc->idx_sta_q++;
		if(ptr_chann_desc->idx_sta_q == ptr_chann_desc->sta_q_sz) 
		{
			ptr_chann_desc->idx_sta_q = 0;
		}

		/* Increment hardware status q index */
		ptr_chann_desc->idx_sta_q_hw++;
		if(ptr_chann_desc->idx_sta_q_hw == ptr_chann_desc->sta_q_sz) 
		{
			ptr_chann_desc->idx_sta_q_hw = 0;
		}

		dbg_flag = 0;

		//printk(KERN_ERR"\nPremature break, change check condition of this loop");
		//break;
		// 
		/* Zero out the status descriptor element */
		memset(ptr_sta_desc, 0, sizeof(ps_pcie_sta_desc_t));

		/* Get pointer to next status descriptor */
		ptr_sta_desc = &ptr_chann_desc->ptr_sta_q[ptr_chann_desc->idx_sta_q];
#ifdef DBG_PRNT
		printk(KERN_ERR"\nStatus Q next BD to check index %d\n",ptr_chann_desc->idx_sta_q);
#endif

		wmb();

		if(ptr_chann_desc->dir == OUT) 
		{
			offset = DMA_SSTAQLMT_REG_OFFSET;
		}
		else
		{
			offset = DMA_DSTAQLMT_REG_OFFSET;
		}
		/* Increment status Q limit to index next status Q BD to use */
		WR_DMA_REG(ptr_chan_dma_reg_vbaddr, offset, ptr_chann_desc->idx_sta_q_hw);
		wmb();
		/*
		 * We now have some BDs & context free
		 */
		if( ptr_chann_desc->chann_state == XLNX_DMA_CNTXTQ_SATURATED ||
				ptr_chann_desc->chann_state == XLNX_DMA_CHANN_SATURATED ) 
		{
			ptr_chann_desc->chann_state = XLNX_DMA_CHANN_NO_ERR;
		}


		LOCK_DMA_CHANNEL(&ptr_chann_desc->channel_lock);
		if(cbk != NULL /*&& ptr_chann_desc->chann_state != XLNX_DMA_CHANN_IO_QUIESCED*/) 
		{
			/* Fire callback */
			cbk(ptr_chann_desc, data, compl_bytes, uid, num_frags);
		}
		UNLOCK_DMA_CHANNEL(&ptr_chann_desc->channel_lock);

	}

	//LOCK_DMA_CHANNEL(&ptr_chann_desc->channel_lock);

	{
		unsigned int regval;
		unsigned int offset;

		if(ptr_chann_desc->ptr_dma_desc->pform == EP) 
		{
			offset = DMA_AXI_INTR_CNTRL_REG_OFFSET;
		}
		else
		{
			offset = DMA_PCIE_INTR_CNTRL_REG_OFFSET;
		}



		rmb();
		/* Enable interrupts for this channel */
		regval = RD_DMA_REG(ptr_chan_dma_reg_vbaddr, offset);
		regval |= DMA_INTCNTRL_ENABLINTR_BIT;
		WR_DMA_REG(ptr_chan_dma_reg_vbaddr, offset,regval);
	}
	//spin_unlock_irqrestore(&ptr_chann_desc->channel_lock, flags);
	//UNLOCK_DMA_CHANNEL(&ptr_chann_desc->channel_lock/*, flags*/);
	//spin_unlock(&ptr_chann_desc->channel_lock/*, flags*/);

}

static /*inline*/ void ps_pcie_post_process_tx_qs(/*ps_pcie_dma_chann_desc_t*/struct work_struct *work/*ptr_chann_desc, enum dma_data_direction dr*/)
{
	ps_pcie_dma_chann_desc_t *ptr_chann_desc = (ps_pcie_dma_chann_desc_t *)container_of(work, ps_pcie_dma_chann_desc_t, intrh_work);
	ps_pcie_sta_desc_t *ptr_sta_desc = NULL;
	unsigned int dbg_flag = 1;
	unsigned short cntxt_hndl;
	unsigned short uid;
	unsigned int compl_bytes = 0;
	enum dma_data_direction dr;
	func_ptr_dma_chann_cbk_noblock cbk_all=NULL;
	unsigned int num_frags_all = 0;
	void *data_all = NULL;
	//unsigned long flags;
	unsigned int regval;
	unsigned int offset;
	u8 __iomem *ptr_chan_dma_reg_vbaddr = ptr_chann_desc->chan_dma_reg_vbaddr;

	if(ptr_chann_desc->dir == IN) 
	{
		dr = DMA_FROM_DEVICE;
	}
	else
	{
		dr = DMA_TO_DEVICE;
	}

	//spin_lock_irqsave(&ptr_chann_desc->channel_lock, flags);
	//LOCK_DMA_CHANNEL(&ptr_chann_desc->channel_lock);
	//spin_lock(&ptr_chann_desc->channel_lock);

	/* Go through the status q BD elements */
	ptr_sta_desc = &ptr_chann_desc->ptr_sta_q[ptr_chann_desc->idx_sta_q];
	//UNLOCK_DMA_CHANNEL(&ptr_chann_desc->channel_lock);

	while(ptr_sta_desc->completed ) 
	{
		data_q_cntxt_t *ptr_ctx = NULL;
		unsigned int tmp_bd_idx;
		unsigned int eop_bd_idx;
		unsigned int num_frags = 0;
		unsigned int offset = 0;
		void *data = NULL;
		func_ptr_dma_chann_cbk_noblock cbk;

	//	LOCK_DMA_CHANNEL(&ptr_chann_desc->channel_lock);
#ifdef DBG_PRNT
		printk(KERN_ERR"\nStatus Q BD element index %d\n",ptr_chann_desc->idx_sta_q);
#endif

		/* Check for errors */
		if(ptr_sta_desc->dst_err == 1) 
		{
			printk(KERN_ERR"\nDestination error detected\n");
			ptr_chann_desc->chann_state = XLNX_DMA_DST_ERROR;
			ptr_chann_desc->src_sgl_err++;
			break;
		}

		if(ptr_sta_desc->src_err == 1) 
		{
			printk(KERN_ERR"\nSource error detected\n");
			ptr_chann_desc->chann_state = XLNX_DMA_SRC_ERROR;
			ptr_chann_desc->dst_sgl_err++;
			break;
		}

		if(ptr_sta_desc->intrnl_error == 1) 
		{
			printk(KERN_ERR"\nInternal error detected\n");
			ptr_chann_desc->chann_state = XLNX_DMA_INTRNL_ERROR;
			ptr_chann_desc->internal_err++;
			break;
		}

		if(ptr_sta_desc->upper_sta_nz == 0) 
		{
			printk(KERN_ERR"\nERROR Upper fields have no data!!\n");
			ptr_chann_desc->chann_state = XLNX_DMA_USRDATA_ERROR;
			break;
		}
		else
		{
			cntxt_hndl = ptr_sta_desc->usr_handle;
			uid = ptr_sta_desc->usr_id;
			compl_bytes = ptr_sta_desc->compl_bytes;
		}

		ptr_ctx = &ptr_chann_desc->ptr_ctx[cntxt_hndl];
		tmp_bd_idx = ptr_ctx->sop_bd_idx;
		eop_bd_idx = ptr_ctx->eop_bd_idx;
#ifdef DBG_PRNT
		printk(KERN_ERR"\nUser handle %d, Uid %x, SOP BD-%d, EOP BD-%d Context Pointer %p",cntxt_hndl, uid, tmp_bd_idx, eop_bd_idx, ptr_ctx);
#endif

		//while(tmp_bd_idx != eop_bd_idx) 
		do
		{
			if(dr == DMA_TO_DEVICE) 
			{
				ps_pcie_src_bd_t *ptr_src_bd = &ptr_chann_desc->ptr_data_q.ptr_src_q[tmp_bd_idx];
				dma_addr_t paddr_buf = (dma_addr_t)ptr_src_bd->phy_src_addr;
				size_t sz = (size_t)ptr_src_bd->byte_count;
#ifdef DBG_PRNT	
				printk(KERN_ERR"\nBD %d Unmapping buffer PA %p Size %d\n", tmp_bd_idx,(void*)paddr_buf, sz);
#endif


				if(ptr_ctx->at == VIRT_ADDR) 
				{
					/* Unmap buffer */
					dma_unmap_single(ptr_chann_desc->ptr_dma_desc->dev, paddr_buf, sz, dr);
				}

				/* Zero out src bd element */
				memset(ptr_src_bd, 0, sizeof(ps_pcie_src_bd_t));
			}
			else
				if(dr == DMA_FROM_DEVICE) 
				{
					ps_pcie_dst_bd_t *ptr_dst_bd = &ptr_chann_desc->ptr_data_q.ptr_dst_q[tmp_bd_idx];
					dma_addr_t paddr_buf = (dma_addr_t)ptr_dst_bd->phy_dst_addr;
					size_t sz = (size_t)ptr_dst_bd->byte_count;
#ifdef DBG_PRNT	
					printk(KERN_ERR"\nBD %d Unmapping buffer PA %p Size %d\n", tmp_bd_idx,(void*)paddr_buf, sz);
#endif

					if(ptr_ctx->at == VIRT_ADDR)
					{
						/* Unmap buffer */
						dma_unmap_single(ptr_chann_desc->ptr_dma_desc->dev, paddr_buf, sz, dr);
					}

					/* Zero out dst bd element */
					memset(ptr_dst_bd, 0, sizeof(ps_pcie_dst_bd_t));
				}

			num_frags++; //Increment numbr of frags for this packet
#ifdef DBG_PRNT
			printk(KERN_ERR"\nFor this packet start BD %d end BD %d Num frags %d\n", tmp_bd_idx,eop_bd_idx, num_frags);
#endif

			if(tmp_bd_idx == eop_bd_idx) 
			{
				break; //We have post processed each fragment
			}

			/* Increment sop bd index */
			tmp_bd_idx++;
			if(tmp_bd_idx == ptr_chann_desc->data_q_sz) 
			{
				tmp_bd_idx = 0;
			}

		}while(1);

		/* Increment number of packet io done by channel */
		ptr_chann_desc->num_pkts_io++;
		/* Increment the number of BDs available for use */
		//ptr_chann_desc->num_free_bds += num_frags;
#if 1
		/* Fire callback if registered */
		if(ptr_ctx->cbk) 
		{
#ifdef DBG_PRNT
			printk(KERN_ERR"\nCBK registered\n");
#endif
			cbk = ptr_ctx->cbk;
			data = ptr_ctx->data;
			cbk_all = ptr_ctx->cbk;
			data_all = ptr_ctx->data;

		}
		else
		{
			printk(KERN_ERR"\nCBK not registered\n");
		}
#endif
#ifdef DBG_PRNT
		//intk(KERN_ERR"\nZero out context data\n");
		printk(KERN_ERR"\nZero context Q element data %x Q element frag src q index %d\n",ptr_ctx->data, ptr_ctx->sop_bd_idx);
#endif
		/* Zero out context element */
		memset(ptr_ctx, 0, sizeof(data_q_cntxt_t));
#ifdef DBG_PRNT
		printk(KERN_ERR"\nZero done\n");
#endif


		/* Increment status q index */
		ptr_chann_desc->idx_sta_q++;
		if(ptr_chann_desc->idx_sta_q == ptr_chann_desc->sta_q_sz) 
		{
			ptr_chann_desc->idx_sta_q = 0;
		}

		/* Increment hardware status q index */
		ptr_chann_desc->idx_sta_q_hw++;
		if(ptr_chann_desc->idx_sta_q_hw == ptr_chann_desc->sta_q_sz) 
		{
			ptr_chann_desc->idx_sta_q_hw = 0;
		}

		dbg_flag = 0;

		//printk(KERN_ERR"\nPremature break, change check condition of this loop");
		//break;
		// 
		/* Zero out the status descriptor element */
		memset(ptr_sta_desc, 0, sizeof(ps_pcie_sta_desc_t));

		/* Get pointer to next status descriptor */
		ptr_sta_desc = &ptr_chann_desc->ptr_sta_q[ptr_chann_desc->idx_sta_q];
#ifdef DBG_PRNT
		printk(KERN_ERR"\nStatus Q next BD to check index %d\n",ptr_chann_desc->idx_sta_q);
#endif

		wmb();

		if(ptr_chann_desc->dir == OUT) 
		{
			offset = DMA_SSTAQLMT_REG_OFFSET;
		}
		else
		{
			offset = DMA_DSTAQLMT_REG_OFFSET;
		}

		/* Increment status Q limit to index next status Q BD to use */
		WR_DMA_REG(ptr_chan_dma_reg_vbaddr, offset, ptr_chann_desc->idx_sta_q_hw);

		wmb();

		/*
		 * We now have some BDs & context free
		 */
		if( ptr_chann_desc->chann_state == XLNX_DMA_CNTXTQ_SATURATED ||
				ptr_chann_desc->chann_state == XLNX_DMA_CHANN_SATURATED ) 
		{
			ptr_chann_desc->chann_state = XLNX_DMA_CHANN_NO_ERR;
		}

		LOCK_DMA_CHANNEL(&ptr_chann_desc->channel_lock);
		if(cbk != NULL /*&& ptr_chann_desc->chann_state != XLNX_DMA_CHANN_IO_QUIESCED*/) 
		{
			/* Fire callback */
			cbk(ptr_chann_desc, data, compl_bytes, uid, num_frags);
		}

		//break; //Temporary
		num_frags_all += num_frags;
		ptr_chann_desc->yield_weight--;
		UNLOCK_DMA_CHANNEL(&ptr_chann_desc->channel_lock);	
	}
#ifdef USE_LATER
	if(cbk_all != NULL /*&& ptr_chann_desc->chann_state != XLNX_DMA_CHANN_IO_QUIESCED*/) 
	{
		/* Fire callback */
		cbk_all(ptr_chann_desc, data_all, compl_bytes, uid, num_frags_all);
	}
#endif
	//LOCK_DMA_CHANNEL(&ptr_chann_desc->channel_lock);


	if(ptr_chann_desc->ptr_dma_desc->pform == EP) 
	{
		offset = DMA_AXI_INTR_CNTRL_REG_OFFSET;
	}
	else
	{
		offset = DMA_PCIE_INTR_CNTRL_REG_OFFSET;
	}



	rmb();
	/* Enable interrupts for this channel */
	regval = RD_DMA_REG(ptr_chan_dma_reg_vbaddr, offset);
	regval |= DMA_INTCNTRL_ENABLINTR_BIT;
	WR_DMA_REG(ptr_chan_dma_reg_vbaddr, offset,regval);


	//spin_unlock_irqrestore(&ptr_chann_desc->channel_lock, flags);
	//UNLOCK_DMA_CHANNEL(&ptr_chann_desc->channel_lock);
	//spin_unlock(&ptr_chann_desc->channel_lock);

}


/* Interrupt handler routines common to both EP & Host*/
static inline void ps_pcie_chann_intr_handlr(ps_pcie_dma_chann_desc_t *ptr_chann_desc, unsigned int intval, unsigned int offset)
{
	volatile unsigned int regval = intval;
	unsigned int val;

	/* Disable all the interrupts and move to polled context 
	*/	
	val= RD_DMA_REG(ptr_chann_desc->chan_dma_reg_vbaddr, DMA_PCIE_INTR_CNTRL_REG_OFFSET);
	val &= 0xfffffffe;
	WR_DMA_REG(ptr_chann_desc->chan_dma_reg_vbaddr, DMA_PCIE_INTR_CNTRL_REG_OFFSET,val);



	do
	{

		/* Clear the interrupt as we have cached the interrupt status */
		WR_DMA_REG(ptr_chann_desc->chan_dma_reg_vbaddr, offset, regval);

		wmb();

		if(regval & DMA_INTSTATUS_DMAERR_BIT) 
		{
			/* DMA error occured */
			printk(KERN_ERR"\nDMA error occured \n");
		}

		if(regval & DMA_INTSTATUS_SGLINTR_BIT) 
		{
#ifdef GENCHECK_MODE 
			if(ptr_chann_desc->chann_id == 0) 
			{
				queue_work_on(1,ptr_chann_desc->intr_handlr_wq, &ptr_chann_desc->intrh_work);
				queue_work_on(2,ptr_chann_desc->ptr_dma_desc->aux_channels[ptr_chann_desc->chann_id].intr_handlr_wq, 
						&(ptr_chann_desc->ptr_dma_desc->aux_channels[ptr_chann_desc->chann_id].intrh_work));
			}
			else
			{
				queue_work_on(3,ptr_chann_desc->intr_handlr_wq, &ptr_chann_desc->intrh_work);
				queue_work_on(4,ptr_chann_desc->ptr_dma_desc->aux_channels[ptr_chann_desc->chann_id].intr_handlr_wq, 
						&(ptr_chann_desc->ptr_dma_desc->aux_channels[ptr_chann_desc->chann_id].intrh_work));
			}
#else
			queue_work/*_on*/(/*1,*/ptr_chann_desc->intr_handlr_wq, &ptr_chann_desc->intrh_work);
#ifdef PFORM_USCALE_NO_EP_PROCESSOR
			queue_work/*_on*/(/*2,*/ptr_chann_desc->ptr_dma_desc->aux_channels[ptr_chann_desc->chann_id].intr_handlr_wq, 
					&(ptr_chann_desc->ptr_dma_desc->aux_channels[ptr_chann_desc->chann_id].intrh_work));
#endif
#endif


		}

		if(regval & DMA_INTSTATUS_SWINTR_BIT) 
		{
			/* SW interrupt occured */
#ifdef DBG_PRNT
			printk(KERN_ERR"\nSW interrupt occurred \n");
#endif
			if(ptr_chann_desc->scrtch_pad_io_in_progress == true) 
			{
				/* We are blocking to receive a scratch pad command response */
				up(&ptr_chann_desc->scratch_sem);
				ptr_chann_desc->scrtch_pad_io_in_progress = false;
			}
#if defined(VIDEO_ACC_DESIGN)
			/* Received a user application command */
			if(ptr_chann_desc->dbell_cbk) {
				unsigned int command = *((unsigned int*)(ptr_chann_desc->chan_dma_reg_vbaddr + DMA_SCRATCH0_REG_OFFSET));
				log_normal(KERN_ERR"\nFor channel %d Scratch pad Pointer %p Command %x Rx\n",
						ptr_chann_desc->chann_id,((unsigned int*)(ptr_chann_desc->chan_dma_reg_vbaddr + DMA_SCRATCH0_REG_OFFSET)),
						command);
				ptr_chann_desc->dbell_cbk(ptr_chann_desc,(unsigned int*)(ptr_chann_desc->chan_dma_reg_vbaddr + DMA_SCRATCH0_REG_OFFSET),DMA_NUM_SCRPAD_REGS);
			}
			else
			{
				ps_pcie_dma_chann_desc_t *ptr_aux_chann = &(ptr_chann_desc->ptr_dma_desc->aux_channels[ptr_chann_desc->chann_id]);

				if(ptr_aux_chann->dbell_cbk) {
					//printk(KERN_ERR "Triggering AUX Callback !!!!!\n");
					//ptr_aux_chann->dbell_cbk(ptr_chann_desc,(unsigned int*)(ptr_chann_desc->chan_dma_reg_vbaddr + DMA_SCRATCH0_REG_OFFSET),DMA_NUM_SCRPAD_REGS);

				}



			}
			val= RD_DMA_REG(ptr_chann_desc->chan_dma_reg_vbaddr, DMA_PCIE_INTR_CNTRL_REG_OFFSET);
                	val |= DMA_INTCNTRL_ENABLINTR_BIT;
		 	WR_DMA_REG(ptr_chann_desc->chan_dma_reg_vbaddr, DMA_PCIE_INTR_CNTRL_REG_OFFSET,val);
#endif
		}

		rmb();

		regval = RD_DMA_REG(ptr_chann_desc->chan_dma_reg_vbaddr, offset);
	}while(regval);

	/* Enable coalesce count timer */
	if(ptr_chann_desc->coalse_cnt_set == true /*&& timer_pending(&ptr_chann_desc->coal_cnt_timer) == false*/) 
	{
		ptr_chann_desc->coal_cnt_timer.expires = jiffies + COALESCE_TIMER_MAGNITUDE;
		add_timer(&ptr_chann_desc->coal_cnt_timer);
	}
}

void coalesce_cnt_bd_process_tmr(unsigned long arg)
{
	ps_pcie_dma_chann_desc_t *ptr_chann_desc = (ps_pcie_dma_chann_desc_t *)arg;

	printk(KERN_ERR"\nCoalesce count triggered for channel %d\n",ptr_chann_desc->chann_id);

	queue_work_on(1,ptr_chann_desc->intr_handlr_wq, &ptr_chann_desc->intrh_work);
#ifdef PFORM_USCALE_NO_EP_PROCESSOR
	queue_work_on(2,ptr_chann_desc->ptr_dma_desc->aux_channels[ptr_chann_desc->chann_id].intr_handlr_wq, 
			&(ptr_chann_desc->ptr_dma_desc->aux_channels[ptr_chann_desc->chann_id].intrh_work));
#endif

	//add_timer(&ptr_chann_desc->coal_cnt_timer);
}

#ifdef POLL_MODE
static void poll_intr_hndlr_fn(unsigned long data)
{
	unsigned int i;
	unsigned int offset, offset1;
	ps_pcie_dma_desc_t *ptr_dma_desc = (ps_pcie_dma_desc_t *)data;
	ps_pcie_dma_chann_desc_t *ptr_temp_chann_desc = NULL;


	if(ptr_dma_desc->pform == EP) 
	{
		offset = DMA_AXI_INTR_STATUS_REG_OFFSET;
		offset1 = DMA_AXI_INTR_CNTRL_REG_OFFSET;
	}
	else
	{
		offset = DMA_PCIE_INTR_STATUS_REG_OFFSET;
	}

	/* Chech interrupt register of each channel */
	for(i = 0; i < 	PS_PCIE_NUM_DMA_CHANNELS; i++) 
	{
		volatile unsigned int regval;

		ptr_temp_chann_desc = &ptr_dma_desc->channels[i];

		if(ptr_temp_chann_desc->channel_is_active == false) 
		{
			continue;
		}

		/* Check interrupt status register of each channel */
		regval = RD_DMA_REG(ptr_temp_chann_desc->chan_dma_reg_vbaddr, offset);

		if(ptr_temp_chann_desc->chann_id == 0) 
		{
			regval = 4;
		}

		if(regval) 
		{
			unsigned int intr_cntrl_reg = 0;

			ps_pcie_chann_intr_handlr(ptr_temp_chann_desc, regval, offset);

		}
	}


	/* Reschedule */
	ptr_dma_desc->intr_poll_tmr.expires = jiffies + 1; /* parameter */
	add_timer(&ptr_dma_desc->intr_poll_tmr);
}
#else
static irqreturn_t ps_pcie_intr_handler(int irq, void *data)
{
	//TODO probe ways to optimize interrupt handling
	irqreturn_t retval = IRQ_HANDLED;
	unsigned int i;
	unsigned int offset, offset1;
#ifndef USE_MSIX
	ps_pcie_dma_desc_t *ptr_dma_desc = (ps_pcie_dma_desc_t *)data;
	ps_pcie_dma_chann_desc_t *ptr_temp_chann_desc = NULL;
#else
	ps_pcie_dma_chann_desc_t *ptr_temp_chann_desc = (ps_pcie_dma_chann_desc_t*)data;
	ps_pcie_dma_desc_t *ptr_dma_desc = ptr_temp_chann_desc->ptr_dma_desc;
#endif

#ifdef PFORM_USCALE_NO_EP_PROCESSOR
	ps_pcie_dma_chann_desc_t *ptr_temp_aux_chann_desc = NULL;
#endif
#ifdef DBG_PRNT
	printk(KERN_ERR"\nInterrupt %d handler invoked %p\n", irq, ptr_dma_desc);
#endif

	if(ptr_dma_desc->pform == EP) 
	{
		offset = DMA_AXI_INTR_STATUS_REG_OFFSET;
		offset1 = DMA_AXI_INTR_CNTRL_REG_OFFSET;
	}
	else
	{
		offset = DMA_PCIE_INTR_STATUS_REG_OFFSET;
	}
#ifndef USE_MSIX
	/* Chech interrupt register of each channel */
	for(i = 0; i < 	PS_PCIE_NUM_DMA_CHANNELS; i++) 
#endif
	{
		volatile unsigned int regval;
#ifndef USE_MSIX
		ptr_temp_chann_desc = &ptr_dma_desc->channels[i];
#endif
#ifdef PFORM_USCALE_NO_EP_PROCESSOR
#ifndef USE_MSIX
		ptr_temp_aux_chann_desc = &ptr_dma_desc->aux_channels[i];
#else
		ptr_temp_aux_chann_desc = &(ptr_temp_chann_desc->ptr_dma_desc->aux_channels[ptr_temp_chann_desc->chann_id]);
#endif
#endif

#ifndef USE_MSIX
		if(ptr_temp_chann_desc->channel_is_active == false
#ifdef PFORM_USCALE_NO_EP_PROCESSOR
				|| ptr_temp_aux_chann_desc->channel_is_active == false
#endif
		  ) 
		{
			continue;
		}
#endif

		/* Check interrupt status register of each channel */
		regval = RD_DMA_REG(ptr_temp_chann_desc->chan_dma_reg_vbaddr, offset);
		if(regval) 
		{
			//	unsigned int intr_cntrl_reg = 0;
#ifdef DBG_PRNT
			printk(KERN_ERR"\nInterrupt status %x Channel %d\n", regval, ptr_temp_chann_desc->chann_id);
#endif
#ifdef TEST_DBG_ON
			ptr_temp_chann_desc->interrupted = 1;	
#endif


			//printk(KERN_ERR"\nIntr Norm channel\n");
			ps_pcie_chann_intr_handlr(ptr_temp_chann_desc, regval, offset);

			//WR_DMA_REG(ptr_temp_chann_desc->chan_dma_reg_vbaddr, offset, regval);
		}
	}


#ifdef DBG_PRNT
	printk(KERN_ERR"\nInterrupt handled\n");
#endif

	return retval;
}


static irqreturn_t ps_pcie_intr_handler_no_msix(int irq, void *data)
{
	//TODO probe ways to optimize interrupt handling
	irqreturn_t retval = IRQ_HANDLED;
	unsigned int i;
	unsigned int offset, offset1;
	ps_pcie_dma_chann_desc_t *ptr_temp_chann_desc = NULL;
	ps_pcie_dma_desc_t *ptr_dma_desc = (ps_pcie_dma_desc_t *)data;

#ifdef PFORM_USCALE_NO_EP_PROCESSOR
	ps_pcie_dma_chann_desc_t *ptr_temp_aux_chann_desc = NULL;
#endif
#ifdef DBG_PRNT
	printk(KERN_ERR"\nInterrupt %d handler invoked %p\n", irq, ptr_dma_desc);
#endif

	if(ptr_dma_desc->pform == EP) 
	{
		offset = DMA_AXI_INTR_STATUS_REG_OFFSET;
		offset1 = DMA_AXI_INTR_CNTRL_REG_OFFSET;
	}
	else
	{
		offset = DMA_PCIE_INTR_STATUS_REG_OFFSET;
	}

	/* Chech interrupt register of each channel */
	for(i = 0; i < 	PS_PCIE_NUM_DMA_CHANNELS; i++) 
	{
		volatile unsigned int regval;
		ptr_temp_chann_desc = &ptr_dma_desc->channels[i];
#ifdef PFORM_USCALE_NO_EP_PROCESSOR
		ptr_temp_aux_chann_desc = &ptr_dma_desc->aux_channels[i];
#endif


		if(ptr_temp_chann_desc->channel_is_active == false
#ifdef PFORM_USCALE_NO_EP_PROCESSOR
				|| ptr_temp_aux_chann_desc->channel_is_active == false
#endif
		  ) 
		{
			continue;
		}


		/* Check interrupt status register of each channel */
		regval = RD_DMA_REG(ptr_temp_chann_desc->chan_dma_reg_vbaddr, offset);
		if(regval) 
		{
			//	unsigned int intr_cntrl_reg = 0;
#ifdef DBG_PRNT
			printk(KERN_ERR"\nInterrupt status %x Channel %d\n", regval, ptr_temp_chann_desc->chann_id);
#endif
#ifdef TEST_DBG_ON
			ptr_temp_chann_desc->interrupted = 1;	
#endif


			ps_pcie_chann_intr_handlr(ptr_temp_chann_desc, regval, offset);

		}
	}


#ifdef DBG_PRNT
	printk(KERN_ERR"\nInterrupt handled\n");
#endif

	return retval;
}
#endif




/*
 * Interfaces exported
 */
ps_pcie_dma_desc_t* xlnx_get_pform_dma_desc(void *prev_desc, unsigned short vendid, unsigned short devid)
{
	return &g_host_dma_desc; //This will involve walking a list to support multiple EPs

}
EXPORT_SYMBOL(xlnx_get_pform_dma_desc);

int xlnx_get_dma(void *dev, platform_t pform, ps_pcie_dma_desc_t **pptr_dma_desc)
{
	//	int rc;
	ps_pcie_dma_desc_t *ptr_temp_dma_desc = NULL;
	int retval = XLNX_SUCCESS;

	struct pci_dev *pdev = (struct pci_dev *)dev;

	printk(KERN_ERR"\nDMA get handle Host, device %p\n",pdev);

	//pptr_dma_desc->num_channels_active = PS_PCIE_NUM_DMA_CHANNELS; //TODO . This has to come from doorbell register
	*pptr_dma_desc = &g_host_dma_desc; //TODO this has to come after linked list walk when multiple EP will be supported
	g_host_dma_desc.dev = &pdev->dev;

	ptr_temp_dma_desc = *pptr_dma_desc;


#if 0//ndef POLL_MODE
	/* Register interrupt handler if not already done */
	if(ptr_temp_dma_desc->intr_hndlr_registered == false) 
	{
		rc = request_irq(ptr_temp_dma_desc->irq_no, ps_pcie_intr_handler, IRQF_SHARED,
				"PS PCIe DMA Device", ptr_temp_dma_desc);
		if (rc) {
			printk(KERN_ERR"\nUnable to request IRQ %p, error %d\n",
					ptr_temp_dma_desc->device, rc);
			retval = XLNX_INTERRUPT_REG_FAIL;
			*pptr_dma_desc = NULL;
			goto intr_reg_fail;
		}
		else
		{
			ptr_temp_dma_desc->intr_hndlr_registered = true;
		}
	}
intr_reg_fail:
#endif
	return retval;
}
EXPORT_SYMBOL(xlnx_get_dma);

int xlnx_release_dma(ps_pcie_dma_desc_t *ptr_dma_desc)
{
	//TODO populate function
	return XLNX_SUCCESS;
}
EXPORT_SYMBOL(xlnx_release_dma);


int xlnx_get_dma_channel(ps_pcie_dma_desc_t *ptr_dma_desc, u32 channel_id, 
		direction_t dir, ps_pcie_dma_chann_desc_t **pptr_chann_desc,
		func_ptr_chann_health_cbk_no_block ptr_chann_health)
{
	int retval = XLNX_SUCCESS;
	unsigned long flags;
	ps_pcie_dma_chann_desc_t *p_temp_chan = NULL;


	printk(KERN_ERR"\nDMA get channel\n");

	spin_lock_irqsave(&ptr_dma_desc->dma_lock, flags);

	/* Perform sanity checks on parameters */
	if(ptr_dma_desc->num_channels_active == 0 || ptr_dma_desc->num_channels_alloc == ptr_dma_desc->num_channels_active) 
	{
		/* All channels allocated */
		retval = XLNX_NO_FREE_CHANNELS;
		goto error;
	}

	if(channel_id >= PS_PCIE_NUM_DMA_CHANNELS) 
	{
		/* Illegal channel number */
		retval = XLNX_ILLEGAL_CHANN_NO;
		goto error;
	}

	/* Get pointer to channel descriptor */
	p_temp_chan = &(ptr_dma_desc->channels[channel_id]);


	/* Check if channel already allocated. */
	if(p_temp_chan->channel_is_active == true) 
	{
#ifndef PFORM_USCALE_NO_EP_PROCESSOR
		/* Channel already allocated */
		retval = XLNX_CHANN_IN_USE;
		goto error;
#else
		/* Channel is allocated, allocate from auxillary channel array */
		p_temp_chan = &(ptr_dma_desc->aux_channels[channel_id]);
		p_temp_chan->is_aux_chann = true;
#endif
	}


#ifndef PFORM_USCALE_NO_EP_PROCESSOR
	/* Checks done only if platform is host and we have software logic running on EP
	 * The EP software logic is expected to initialize one end of the channel before the HOST side logic 
	 * completed initialization of other end
	 */
	if(ptr_dma_desc->pform == HOST) 
	{
		p_temp_chan->ptr_func_health = ptr_chann_health;

		/* check if this channel is allocated in EP and direction is consistent */
		retval = nwl_dma_is_chann_alloc_ep(ptr_dma_desc, channel_id, dir);
		if(retval < XLNX_SUCCESS)
		{
			printk(KERN_ERR"\nChannel not allocated in EP as neded %d\n", retval);
			goto error;
		}

		/* Latch channel */
		p_temp_chan->latched = true;
	}
#endif

	/* Assign the DMA register base address for this channel */
	p_temp_chan->chan_dma_reg_vbaddr = ptr_dma_desc->dma_chann_reg_virt_base_addr + 
		(channel_id * DMA_REG_TOT_BYTES);
	printk(KERN_ERR"\nDMA channel %d base addr:: %p\n", channel_id, p_temp_chan->chan_dma_reg_vbaddr);

	/* All checks done, we can allocate this channel */
	p_temp_chan->dir = dir; //Set direction
	p_temp_chan->chann_id = channel_id; //Id of channel
	p_temp_chan->ptr_dma_desc = ptr_dma_desc; //Cache the associated DMA descriptor
	printk(KERN_ERR"\nDMA desc for channel %p\n",p_temp_chan->ptr_dma_desc);
	*pptr_chann_desc = p_temp_chan;

	/* Set channel as active */
	p_temp_chan->channel_is_active = true;
	p_temp_chan->chk_hbeat = true;
	/* Increment number of channel allocated */
	ptr_dma_desc->num_channels_alloc++;

error:
	spin_unlock_irqrestore(&ptr_dma_desc->dma_lock,flags);
	printk(KERN_ERR"\nDMA get channel done %d\n",retval);

	return retval;

}
EXPORT_SYMBOL(xlnx_get_dma_channel);

int xlnx_alloc_queues(ps_pcie_dma_chann_desc_t *ptr_chann_desc,
		unsigned int *ptr_data_q_addr_hi, //Physical address
		unsigned int *ptr_data_q_addr_lo,//Physical address
		unsigned int *ptr_sta_q_addr_hi,//Physical address
		unsigned int *ptr_sta_q_addr_lo,//Physical address
		unsigned int q_num_elements)
{
	int retval = XLNX_SUCCESS;
	unsigned int data_q_elem_sz = sizeof(ps_pcie_dst_bd_t); //Src & Dst BD element have same size
	unsigned int sta_q_elem_sz = sizeof(ps_pcie_sta_desc_t);
	dma_addr_t data_q_paddr;
	dma_addr_t sta_q_paddr;
	u64 temp_u64 = 0;
	struct device *dev = ptr_chann_desc->ptr_dma_desc->dev;

	printk(KERN_ERR"\n allocate Qs DMA Channel %d %p %p %p %d %d\n",ptr_chann_desc->chann_id, ptr_chann_desc, dev, ptr_chann_desc->ptr_dma_desc,
			data_q_elem_sz,sta_q_elem_sz);

	// spin_lock_irqsave(&ptr_chann_desc->ptr_dma_desc->dma_lock, flags);

	if(ptr_chann_desc->ptr_data_q.ptr_q || ptr_chann_desc->ptr_sta_q) 
	{
		retval = XLNX_Q_ALREADY_ALLOC;
		goto error_q_already_allocated;
	}

	/* Allocate data Q */
	ptr_chann_desc->ptr_data_q.ptr_q = dma_zalloc_coherent(dev, data_q_elem_sz * q_num_elements,
			&data_q_paddr, GFP_KERNEL );
	if(ptr_chann_desc->ptr_data_q.ptr_q == NULL) 
	{
		retval = XLNX_DATA_Q_ALLOC_FAIL;
		printk(KERN_ERR"\n Data Q allocation failed !!!!!!!!! ERROR \n");
		goto error_dataq_alloc_fail;
	}
	else
	{
		ptr_chann_desc->data_q_paddr = data_q_paddr;
		ptr_chann_desc->dat_q_sz = data_q_elem_sz * q_num_elements;
	}

	/* Allocate status Q */
	ptr_chann_desc->ptr_sta_q = dma_zalloc_coherent(dev, sta_q_elem_sz * q_num_elements,
			&sta_q_paddr, GFP_KERNEL );
	if(ptr_chann_desc->ptr_sta_q == NULL) 
	{
		retval = XLNX_STA_Q_ALLOC_FAIL;
		printk(KERN_ERR"\n Sta Q allocation failed !!!!!!!!! ERROR \n");
		goto error_staq_alloc_fail;
	}
	else
	{
		ptr_chann_desc->stat_q_paddr = sta_q_paddr;
		ptr_chann_desc->stat_q_sz = sta_q_elem_sz * q_num_elements;
	}

	printk(KERN_ERR"\n Channel %d Status Q %p\n",ptr_chann_desc->chann_id,ptr_chann_desc->ptr_sta_q);

#ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
	printk(KERN_ERR"\n System has 64 bit DMA address %p %p\n", (void*)data_q_paddr, (void*)sta_q_paddr);
	temp_u64 = (u64)data_q_paddr;
	temp_u64 &= (0xffffffff00000000);
	temp_u64 = temp_u64 >> 32;
	*ptr_data_q_addr_hi = (u32)temp_u64;
	temp_u64 = (u64)sta_q_paddr;
	temp_u64 &= (0xffffffff00000000);
	temp_u64 = temp_u64 >> 32;
	*ptr_sta_q_addr_hi = (u32)temp_u64;
#else
	printk(KERN_ERR"\n System has 32 bit DMA address %p %p\n", (void*)data_q_paddr, (void*)sta_q_paddr);
	*ptr_data_q_addr_hi = 0;
	*ptr_sta_q_addr_hi = 0;
#endif

	*ptr_data_q_addr_lo = (u32)data_q_paddr;
	*ptr_sta_q_addr_lo = (u32)sta_q_paddr;

	/* Allocate the context array */
	ptr_chann_desc->ptr_ctx = kzalloc(sizeof(data_q_cntxt_t) * q_num_elements, GFP_KERNEL);
	if(ptr_chann_desc->ptr_ctx == NULL) 
	{
		retval = XLNX_CNTX_ARR_ALLOC_FAIL;
		goto error_cntxq_alloc_fail;
	}
	//	ptr_chann_desc->cntxt_q_sz = sizeof(data_q_cntxt_t) * q_num_elements;

#ifdef USE_LATER 
	/* Initialize number of BDs that can be used */
	if(ptr_chann_desc->dir == IN) 
	{
		/*
		 * In case of rx, at start of day we will not preallocate all BDs as this will cause
		 * both next & limit pointers to be 0. This will cause IOs to not start at all.
		 * We will leave last BD empty. Next == 0 & limit == 3 (in cas there are say 4BDs) is what we should look like
		 * at start of day
		 */
		ptr_chann_desc->num_free_bds = q_num_elements - 1;
	}
	else
	{
		ptr_chann_desc->num_free_bds = q_num_elements;
	}
#endif

	printk(KERN_ERR"\n Allocated DataQ Hi: %x DataQ Lo: %x StaQ Hi: %x StaQ Lo %x\n",*ptr_data_q_addr_hi,
			*ptr_data_q_addr_lo, *ptr_sta_q_addr_hi, *ptr_sta_q_addr_lo );



	//TODO  deallocate appropriately in case of errors
error_cntxq_alloc_fail:
error_staq_alloc_fail:
error_dataq_alloc_fail:
error_q_already_allocated:
	//spin_unlock_irqrestore(&ptr_chann_desc->ptr_dma_desc->dma_lock,flags);

	printk(KERN_ERR"\n DMA allocate queues done %d\n",retval);

	return retval;
}
EXPORT_SYMBOL(xlnx_alloc_queues);

int xlnx_dealloc_queues(ps_pcie_dma_chann_desc_t *ptr_chann_desc)
{
	int ret = XLNX_SUCCESS;
	//TODO  complete this
	printk(KERN_ERR"\n Deallocate Qs DMA Channel %d %p\n",ptr_chann_desc->chann_id, ptr_chann_desc);


	/* Free the context array */
	kfree(ptr_chann_desc->ptr_ctx);

	/* Free Data Descriptor Q */
	dma_free_coherent(ptr_chann_desc->ptr_dma_desc->dev,
			ptr_chann_desc->dat_q_sz, ptr_chann_desc->ptr_data_q.ptr_q, ptr_chann_desc->data_q_paddr);

	/* Free Status Descriptor Q */
	dma_free_coherent(ptr_chann_desc->ptr_dma_desc->dev,
			ptr_chann_desc->stat_q_sz, ptr_chann_desc->ptr_sta_q, ptr_chann_desc->stat_q_paddr);

	ptr_chann_desc->ptr_data_q.ptr_q = ptr_chann_desc->ptr_sta_q = NULL;

	//error:
	//spin_unlock_bh(&ptr_chann_desc->channel_lock/*,flags*/);

	printk(KERN_ERR"\n DMA deallocate queues done %d\n",ret);

	return ret;

}
EXPORT_SYMBOL(xlnx_dealloc_queues);


/* 
 * NOTE: API does not take any lock. It is imperative that 'channel_lock' be taken before calling this API.
 * In case 'xlnx_data_frag_io' needs to be called on this channel post calling this function, it is highly reccomended that 'xlnx_data_frag_io' 
 * be called without relinquishing the channel_lock' that was taken for invoking this API
 */
inline unsigned int xlnx_get_chann_num_free_bds(ps_pcie_dma_chann_desc_t *ptr_chan_desc)
{
	return 0;//ptr_chan_desc->num_free_bds;
}
EXPORT_SYMBOL(xlnx_get_chann_num_free_bds);

/* 
 * NOTE: This API assumes that the caller has taken the channel lock across succesive calls to the API to transmit
 * data distributed across multiple fragments
 */
inline int xlnx_data_frag_io(ps_pcie_dma_chann_desc_t *ptr_chan_desc, 
		unsigned char *addr_buf, 
		addr_type_t at,
		size_t sz,
		func_ptr_dma_chann_cbk_noblock cbk,
		unsigned short uid, 
		bool last_frag, /*direction_t dir,*/
		void *ptr_user_data)
{
	int ret = XLNX_SUCCESS;
	dataq_ptr_t ptr_dq =ptr_chan_desc->ptr_data_q;
	data_q_cntxt_t *ptr_ctx = NULL;
	dma_addr_t paddr_buf;
	enum dma_data_direction dr;
	unsigned int offset = 0;

	if(ptr_chan_desc->chann_state == XLNX_DMA_CHANN_IO_QUIESCED) 
	{
		return XLNX_DMA_CHANN_SW_ERR;
	}

	/* determine direction of DMA transfer */
	if(ptr_chan_desc->dir == OUT) 
	{
		dr = DMA_TO_DEVICE;
	}
	else
	{
		dr = DMA_FROM_DEVICE;

		/*
		 * We will have a context for each BD allocated. Hence we will mark each fragment in receive direction
		 * as 'last fragment'
		 */
		last_frag = true;
	}


	if(at == VIRT_ADDR) 
	{
		/* Map the buffer */
		paddr_buf = dma_map_single(ptr_chan_desc->ptr_dma_desc->dev, addr_buf, sz, dr);
#ifdef DBG_PRNT
		printk(KERN_ERR"\n Mapped buffer %p size %d", (void*)paddr_buf, sz);
#endif
	}
	else
	{
		paddr_buf = (dma_addr_t)addr_buf;
	}

	if(ptr_chan_desc->chann_state != XLNX_DMA_CHANN_NO_ERR) 
	{
		log_normal(KERN_ERR"\nDMA channel %d in error state %d\n",ptr_chan_desc->chann_id, ptr_chan_desc->chann_state);
		ret = XLNX_DMA_CHANN_SW_ERR;
		goto error_channel;
	}
#ifdef USE_LATER 
	/* Check if we have BDs free */
	if(ptr_chan_desc->num_free_bds == 0) 
	{
		/* We do not have BDs free */
		printk(KERN_ERR"\n BD list saturated\n");
		ret = XLNX_DMA_CHANN_SW_ERR;
		ptr_chan_desc->chann_state = XLNX_DMA_CHANN_SATURATED;
		goto error_channel;
	}
	else
	{
		printk(KERN_ERR"\nNum BDs %d\n",ptr_chan_desc->num_free_bds);
	}
#endif

	if(last_frag == true) 
	{
		/* This is last fragment, we need to find a context */
		ptr_ctx = &ptr_chan_desc->ptr_ctx[ptr_chan_desc->idx_cntxt_q];

		/* Check if the context is free */
		if(ptr_ctx->under_use == true)
		{
			//printk(KERN_ERR"\nPump next rx frag chann %d\n",ptr_chann->chann_id);
			ptr_chan_desc->chann_state = XLNX_DMA_CNTXTQ_SATURATED;
			ptr_chan_desc->saturate_flag = true;
#ifdef DBG_PRNT
			printk(KERN_ERR"\nDMA channel %d in error state %d\n",ptr_chan_desc->chann_id, ptr_chan_desc->chann_state);
			printk(KERN_ERR"\nContext Q %p Saturated Q element index %d Q element data %x Q element frag src q index %d\n",ptr_ctx, ptr_chan_desc->idx_cntxt_q,
					ptr_ctx->data, ptr_ctx->sop_bd_idx);
#endif

			{


#ifdef DBG_PRNT
				unsigned int i;
				unsigned char *p = (unsigned char*)ptr_ctx;
				printk(KERN_ERR"\nContext Q contents\n");

				for(i = 0; i < sizeof(data_q_cntxt_t); i++) 
				{
					printk(KERN_ERR"Data Byte-%d %x ",i,p[i]);

					if(i == 8) 
					{
						printk("\n");
					}
				}
#endif
			}
			ret = XLNX_DMA_CHANN_SW_ERR;
			goto error_channel;
		}
		else
		{
			ptr_ctx->under_use = true;
#ifdef DBG_PRNT
			printk(KERN_ERR"\nGot a context %p", ptr_ctx);
#endif
		}
	}

	/* Get ourselves an unused BD element */
	if( ptr_chan_desc->dir == OUT) 
	{
		ps_pcie_src_bd_t *ptr_src_bd = &ptr_dq.ptr_src_q[ptr_chan_desc->unusd_bd_idx_data_q];

		/* Check if BD is indeed unused */
		if(ptr_src_bd->phy_src_addr) 
		{
			printk(KERN_ERR"\nDMA channel %d saturated, no free BD element. Unused index %d\n",ptr_chan_desc->chann_id, ptr_chan_desc->unusd_bd_idx_data_q);
			ptr_chan_desc->chann_state = XLNX_DMA_CHANN_SATURATED;
			ret = XLNX_DMA_CHANN_SW_ERR;
			goto error_channel;
		}
#ifdef DBG_PRNT
		printk(KERN_ERR"\nDMA channel %d , found BD element. Unused index %d\n",ptr_chan_desc->chann_id, ptr_chan_desc->unusd_bd_idx_data_q);
#endif

		/* BD is free we will use it */
		ptr_src_bd->phy_src_addr = (unsigned long long)paddr_buf;
		ptr_src_bd->byte_count = sz;
		ptr_src_bd->dma_data_rd_attr = 0x3;
		if(ptr_chan_desc->ptr_dma_desc->pform == EP) 
		{
			ptr_src_bd->loc_axi = 1;
		}
#ifdef PFORM_USCALE_NO_EP_PROCESSOR
		else
		{
			if(at == EP_PHYS_ADDR) 
			{
				/* Buffer is on AXI memory */
				ptr_src_bd->loc_axi = 1;
			}
		}
#endif

		if(last_frag == true) 
		{
			ptr_src_bd->eop = 1;
			ptr_src_bd->intr = 1; //We want interrupt after status Q is written
			ptr_src_bd->usr_handle = ptr_chan_desc->idx_cntxt_q;
			ptr_src_bd->usr_id = uid;
		}
	}
	else
	{
		ps_pcie_dst_bd_t *ptr_dst_bd = &ptr_dq.ptr_dst_q[ptr_chan_desc->unusd_bd_idx_data_q];

		/* Check if BD is indeed unused */
		if(ptr_dst_bd->phy_dst_addr) 
		{
			printk(KERN_ERR"\n DMA channel %d saturated, no free BD element. Unused index %d\n",ptr_chan_desc->chann_id, ptr_chan_desc->unusd_bd_idx_data_q);
			ptr_chan_desc->chann_state = XLNX_DMA_CHANN_SATURATED;
			ret = XLNX_DMA_CHANN_SW_ERR;
			goto error_channel;
		}
#ifdef DBG_PRNT
		printk(KERN_ERR"\n DMA channel %d , found BD element. Unused index %d\n",ptr_chan_desc->chann_id, ptr_chan_desc->unusd_bd_idx_data_q);
#endif

		/* BD is free we will use it */
		ptr_dst_bd->phy_dst_addr = (unsigned long long)paddr_buf;
		ptr_dst_bd->byte_count = sz;

		if(ptr_chan_desc->ptr_dma_desc->pform == EP) 
		{
			ptr_dst_bd->loc_axi = 1;
		}
#ifdef PFORM_USCALE_NO_EP_PROCESSOR
		else
		{
			if(at == EP_PHYS_ADDR) 
			{
				/* Buffer is on AXI memory */

				ptr_dst_bd->loc_axi = 1;
			}
		}
#endif


		ptr_dst_bd->use_nxt_bd_on_eop = 1;
		ptr_dst_bd->usr_handle = ptr_chan_desc->idx_cntxt_q;
		ptr_dst_bd->dma_data_rd_attr = 0x3;
	}

	if(ptr_ctx) 
	{
		/* Populate the context element */
		ptr_ctx->cbk = cbk;
		ptr_ctx->eop_bd_idx = ptr_chan_desc->unusd_bd_idx_data_q;
		ptr_ctx->sop_bd_idx = ptr_chan_desc->sop_bd_idx_data_q;
		ptr_ctx->data = ptr_user_data;
		ptr_ctx->at = at;
		/* Increment context index */
		ptr_chan_desc->idx_cntxt_q++;
		if(ptr_chan_desc->idx_cntxt_q == ptr_chan_desc->data_q_sz) 
		{
			ptr_chan_desc->idx_cntxt_q = 0;
		}
	}

	/* Update the data q indexes */
	ptr_chan_desc->unusd_bd_idx_data_q++;
	if(ptr_chan_desc->unusd_bd_idx_data_q == ptr_chan_desc->data_q_sz /*- 1*/) 
	{
		ptr_chan_desc->unusd_bd_idx_data_q = 0;
	}

	if(last_frag == true) 
	{
		/* This was the last frag. Next BD element will be start of packet (sop) */
		ptr_chan_desc->sop_bd_idx_data_q = ptr_chan_desc->unusd_bd_idx_data_q;
	}

	if(ptr_chan_desc->dir == OUT) 
	{
		offset = DMA_SRCQLMT_REG_OFFSET;
	}
	else
	{
		offset = DMA_DSTQLMT_REG_OFFSET;
	}

	/* Decrement number of BDs avaliable */
	//ptr_chan_desc->num_free_bds--;

	wmb();

	/* Program the hardware with new Q limit value */
	WR_DMA_REG(ptr_chan_desc->chan_dma_reg_vbaddr, offset, ptr_chan_desc->unusd_bd_idx_data_q);

	//	printk(KERN_ERR"\n New Q limit value %d\n",ptr_chan_desc->unusd_bd_idx_data_q);
	return XLNX_SUCCESS;
error_channel:

	if(at == VIRT_ADDR) 
	{
		/* Unmap buffer */
		dma_unmap_single(ptr_chan_desc->ptr_dma_desc->dev, paddr_buf, sz, dr);
	}
	//TODO unmap other buffers if needed

	return ret;
}
EXPORT_SYMBOL(xlnx_data_frag_io);

int xlnx_activate_dma_channel(ps_pcie_dma_desc_t *ptr_dma_desc, 
		ps_pcie_dma_chann_desc_t *ptr_chann_desc,
		unsigned int data_q_addr_hi, //Physical address
		unsigned int data_q_addr_lo,//Physical address
		unsigned int data_q_sz,
		unsigned int sta_q_addr_hi,//Physical address
		unsigned int sta_q_addr_lo,//Physical address
		unsigned int sta_q_sz,
		unsigned char coalesce_cnt //Coalesce count for SGL interrupt resporting
		)
{
	int ret = XLNX_SUCCESS;
	//unsigned long flags;
	unsigned int regval = 0;
	u8 __iomem *ptr_chan_dma_reg_vbaddr = ptr_chann_desc->chan_dma_reg_vbaddr;
	unsigned int intr_msk = 0;
	unsigned int offset = 0;
	char buffer[50];

	//printk(KERN_ERR"\n Return non activate");
	//return XLNX_DATA_Q_ALLOC_FAIL;


	printk(KERN_ERR"\n Activate DMA Channel %d %p %p\n",ptr_chann_desc->chann_id, ptr_chan_dma_reg_vbaddr,ptr_dma_desc);

	/* Ceate workqueue if not created */
	if(ptr_chann_desc->intr_handlr_wq == NULL) 
	{
		sprintf(buffer, "PS PCIe DMA Channel %d Intr handler WQ",ptr_chann_desc->chann_id);
		ptr_chann_desc->intr_handlr_wq = create_singlethread_workqueue((const char*)buffer);
		if(ptr_chann_desc->intr_handlr_wq == NULL) 
		{
			printk(KERN_ERR"\n WQ creation failed %d\n", ptr_chann_desc->chann_id);
			goto error_wq_creat_failed;
		}
		else
		{
			if(ptr_chann_desc->dir == IN) 
			{
				INIT_WORK(&(ptr_chann_desc->intrh_work), ps_pcie_post_process_rx_qs/*, (void *)ptr_chann_desc*/);
			}
			else
			{
				INIT_WORK(&(ptr_chann_desc->intrh_work), ps_pcie_post_process_tx_qs/*, (void *)ptr_chann_desc*/);
			}
		}
	}


	/* If coalesce_cnt is set create timer to handle packets in a coalesce count scenario */
	if(coalesce_cnt && &ptr_chann_desc->coal_cnt_timer == NULL) 
	{
		/* Create timer */
		init_timer(&ptr_chann_desc->coal_cnt_timer);
		ptr_chann_desc->coal_cnt_timer.function = coalesce_cnt_bd_process_tmr;
		ptr_chann_desc->coal_cnt_timer.data = (void*)ptr_chann_desc;
		ptr_chann_desc->coal_cnt_timer.expires = jiffies + COALESCE_TIMER_MAGNITUDE;
		printk(KERN_ERR"\n Invoke BD processing timer %p\n", &ptr_chann_desc->coal_cnt_timer);
		add_timer(&ptr_chann_desc->coal_cnt_timer);

		/* Set coalesce count flag */
		ptr_chann_desc->coalse_cnt_set = true;
	}

	/* Initialize scratch pad communication blocking semaphore & serialization MUTEX */
	sema_init(&(ptr_chann_desc->scratch_sem), 0);
	sema_init(&(ptr_chann_desc->scratch_mutx), 1);

	//spin_lock_irqsave(&ptr_dma_desc->dma_lock, flags);

	if(data_q_addr_lo & 0x3f || sta_q_addr_lo & 0x3f) 
	{
		/* Unaligned Q base address */
		ret = XLNX_Q_UNALIGNED_64BYT;
		goto error_unaligned_q;
	}

	/* Check if channel is active */
	regval = RD_DMA_REG(ptr_chan_dma_reg_vbaddr, DMA_STATUS_REG_OFFSET);
	if(regval & DMA_STATUS_DMA_RUNNING_BIT) {
		ret = XLNX_CHANN_ACTIVE;
		goto error;
	}


#ifdef PFORM_USCALE_NO_EP_PROCESSOR
	if(ptr_chann_desc->is_aux_chann == true)
#else
		if(ptr_dma_desc->pform == EP)
#endif
		{
			/* Reset the DMA channel */
			regval = RD_DMA_REG(ptr_chan_dma_reg_vbaddr, DMA_CNTRL_REG_OFFSET);
			regval |= (DMA_CNTRL_RST_BIT);
			WR_DMA_REG(ptr_chan_dma_reg_vbaddr, DMA_CNTRL_REG_OFFSET, regval);

			/* Give 10ms delay for reset to complete */
			mdelay(10);

			regval = RD_DMA_REG(ptr_chan_dma_reg_vbaddr, DMA_CNTRL_REG_OFFSET);
			regval &= (~(DMA_CNTRL_RST_BIT));
			WR_DMA_REG(ptr_chan_dma_reg_vbaddr, DMA_CNTRL_REG_OFFSET, regval);
		}


	/* Pogram Q addresses */
	ptr_chann_desc->data_q_sz = data_q_sz;
	ptr_chann_desc->sta_q_sz = sta_q_sz;

	data_q_addr_lo &= ~(0x3f); //Mask 6lsbs
	sta_q_addr_lo &= ~(0x3f); //Mask 6lsbs

	data_q_addr_lo |= DMA_QPTRLO_Q_ENABLE_BIT;
	sta_q_addr_lo |= DMA_QPTRLO_Q_ENABLE_BIT;

	if(ptr_chann_desc->ptr_dma_desc->pform == EP)
	{
		/* Tell hardwrae that Q is resident on AXI memory */
		data_q_addr_lo |= DMA_QPTRLO_QLOCAXI_BIT;
		sta_q_addr_lo |= DMA_QPTRLO_QLOCAXI_BIT;
	}

	//TODO #warning take care of m_arcache/PCIE  attr

	if(data_q_sz < PS_PCIE_MIN_Q_SZ) 
	{
		ret = XLNX_ILLEGAL_Q_SZ;
		goto error;
	}

	/* Set the hardware status Q sliding index */
	ptr_chann_desc->idx_sta_q_hw = sta_q_sz - 1;

	if(ptr_chann_desc->dir == OUT) 
	{
		/* SRC Q */
		WR_DMA_REG(ptr_chan_dma_reg_vbaddr, DMA_SRCQNXT_REG_OFFSET, 0);
		WR_DMA_REG(ptr_chan_dma_reg_vbaddr, DMA_SRCQPTRLO_REG_OFFSET, data_q_addr_lo);
		WR_DMA_REG(ptr_chan_dma_reg_vbaddr, DMA_SRCQPTRHI_REG_OFFSET, data_q_addr_hi);
		WR_DMA_REG(ptr_chan_dma_reg_vbaddr, DMA_SRCQSZ_REG_OFFSET, data_q_sz);
		WR_DMA_REG(ptr_chan_dma_reg_vbaddr, DMA_SRCQLMT_REG_OFFSET, 0);

		/* SRC STA Q */
		WR_DMA_REG(ptr_chan_dma_reg_vbaddr, DMA_SSTAQNXT_REG_OFFSET, 0);
		WR_DMA_REG(ptr_chan_dma_reg_vbaddr, DMA_SSTAQPTRLO_REG_OFFSET, sta_q_addr_lo);
		WR_DMA_REG(ptr_chan_dma_reg_vbaddr, DMA_SSTAQPTRHI_REG_OFFSET, sta_q_addr_hi);
		WR_DMA_REG(ptr_chan_dma_reg_vbaddr, DMA_SSTAQSZ_REG_OFFSET, sta_q_sz);
		WR_DMA_REG(ptr_chan_dma_reg_vbaddr, DMA_SSTAQLMT_REG_OFFSET, ptr_chann_desc->idx_sta_q_hw);
	}
	else
	{
		/* DST Q */
		WR_DMA_REG(ptr_chan_dma_reg_vbaddr, DMA_DSTQNXT_REG_OFFSET, 0);
		WR_DMA_REG(ptr_chan_dma_reg_vbaddr, DMA_DSTQPTRLO_REG_OFFSET, data_q_addr_lo);
		WR_DMA_REG(ptr_chan_dma_reg_vbaddr, DMA_DSTQPTRHI_REG_OFFSET, data_q_addr_hi);
		WR_DMA_REG(ptr_chan_dma_reg_vbaddr, DMA_DSTQSZ_REG_OFFSET, data_q_sz);
		WR_DMA_REG(ptr_chan_dma_reg_vbaddr, DMA_DSTQLMT_REG_OFFSET, 0);

		/* DST STA Q */
		WR_DMA_REG(ptr_chan_dma_reg_vbaddr, DMA_DSTAQNXT_REG_OFFSET, 0);
		WR_DMA_REG(ptr_chan_dma_reg_vbaddr, DMA_DSTAQPTRLO_REG_OFFSET, sta_q_addr_lo);
		WR_DMA_REG(ptr_chan_dma_reg_vbaddr, DMA_DSTAQPTRHI_REG_OFFSET, sta_q_addr_hi);
		WR_DMA_REG(ptr_chan_dma_reg_vbaddr, DMA_DSTAQSZ_REG_OFFSET, sta_q_sz);
		WR_DMA_REG(ptr_chan_dma_reg_vbaddr, DMA_DSTAQLMT_REG_OFFSET, ptr_chann_desc->idx_sta_q_hw);
	}

#if 0//def USE_MSIX
	if(ptr_chann_desc->ptr_dma_desc->intr_type == MSIX) 
	{
		/* Clear interrupts if any */
		WR_DMA_REG(ptr_chan_dma_reg_vbaddr, DMA_PCIE_INTR_STATUS_REG_OFFSET, ~0);

		wmb();

		/* Register handler for interrupt vector */
#ifdef PFORM_USCALE_NO_EP_PROCESSOR
		printk(KERN_ERR"\n Is aux channel %d\n",(int)ptr_chann_desc->is_aux_chann);
		if(ptr_chann_desc->is_aux_chann == false && ptr_chann_desc->intr_hndlr_registered == false) 
#endif
		{

			//spin_unlock_irqrestore(&ptr_dma_desc->dma_lock,flags);
			sprintf(ptr_chann_desc->msix_hndlr_name, "PS PCIe DMA Chann %d Interrupt Handler",ptr_chann_desc->chann_id);
			if(request_irq(ptr_chann_desc->ptr_dma_desc->entries[ptr_chann_desc->chann_id].vector,
						ps_pcie_intr_handler,
						0, 
						ptr_chann_desc->msix_hndlr_name, 
						ptr_chann_desc))
			{
				ret = XLNX_MSIX_HNDLR_REG_FAIL;
				goto msix_hndlr_registration_failed;
			}
			else
			{
				ptr_chann_desc->intr_hndlr_registered = true;
				printk(KERN_ERR"\n MSIx Interrupt handler registered\n");
			}
			//spin_lock_irqsave(&ptr_dma_desc->dma_lock, flags);

		}
	}
#endif

	wmb();

	/* Enable interrupts */
	intr_msk |= (DMA_INTCNTRL_ENABLINTR_BIT | DMA_INTCNTRL_DMAERRINTR_BIT | DMA_INTSTATUS_DMASGINTR_BIT);
	intr_msk |= (coalesce_cnt  << DMA_INTSTATUS_SGCOLSCCNT_BIT_SHIFT);
	if(ptr_dma_desc->pform == HOST) 
	{
		offset = DMA_PCIE_INTR_CNTRL_REG_OFFSET;
	}
	else
	{
		offset = DMA_AXI_INTR_CNTRL_REG_OFFSET;
	}
	WR_DMA_REG(ptr_chan_dma_reg_vbaddr, offset, intr_msk);

	ptr_chann_desc->chann_state = XLNX_DMA_CHANN_NO_ERR; //Channel is doing good



	if(ptr_dma_desc->pform == HOST 
#ifdef PFORM_USCALE_NO_EP_PROCESSOR
			&& ptr_chann_desc->is_aux_chann == true
#endif
	  ) 
	{
		/* We are Host, we will now enable the channel */
		regval = RD_DMA_REG(ptr_chan_dma_reg_vbaddr, DMA_CNTRL_REG_OFFSET);
		regval |= ((DMA_CNTRL_64BIT_STAQ_ELEMSZ_BIT) | (DMA_CNTRL_ENABL_BIT));
		WR_DMA_REG(ptr_chan_dma_reg_vbaddr, DMA_CNTRL_REG_OFFSET, regval);
	}

	/* Channel is activated for ios */
	//ptr_chann_desc->channel_active_for_ios = true;

#ifdef POLL_MODE
	init_timer(&ptr_dma_desc->intr_poll_tmr);
	ptr_dma_desc->intr_poll_tmr.function = poll_intr_hndlr_fn;
	ptr_dma_desc->intr_poll_tmr.data = (void*)ptr_dma_desc;
	ptr_dma_desc->intr_poll_tmr.expires = jiffies + 1; /* parameter */
	printk(KERN_ERR"\n Invoke poll mode %p\n", &ptr_dma_desc->intr_poll_tmr);
	add_timer(&ptr_dma_desc->intr_poll_tmr);
#endif


error:
error_unaligned_q:
error_wq_creat_failed:
	//spin_unlock_irqrestore(&ptr_dma_desc->dma_lock,flags);

	printk(KERN_ERR"\n DMA activate channel done %d\n",ret);

	return ret;

}
EXPORT_SYMBOL(xlnx_activate_dma_channel);

int xlnx_deactivate_dma_channel(ps_pcie_dma_chann_desc_t *ptr_chann_desc)
{
	unsigned int intr_msk = 0;
	unsigned int offset = 0;
	//spin_lock_bh(&ptr_chann_desc->channel_lock);
	ptr_chann_desc->chann_state = XLNX_DMA_CHANN_IO_QUIESCED;
	//spin_unlock_bh(&ptr_chann_desc->channel_lock);

	/* Disable interrupt from DMA channel */
	wmb();

	/* Disable interrupts */
	if(ptr_chann_desc->ptr_dma_desc->pform == HOST) 
	{
		offset = DMA_PCIE_INTR_CNTRL_REG_OFFSET;
	}
	else
	{
		offset = DMA_AXI_INTR_CNTRL_REG_OFFSET;
	}
	intr_msk |= (DMA_INTCNTRL_ENABLINTR_BIT);
	WR_DMA_REG(ptr_chann_desc->chan_dma_reg_vbaddr, offset, intr_msk);

	wmb();

	//	spin_unlock(&ptr_chann_desc->channel_lock);
	if(!in_atomic()) 
	{
		/* Flush workqueue */

		flush_workqueue(ptr_chann_desc->intr_handlr_wq);
		printk("Flushing Worker Queque\n");

		mdelay(10);

		destroy_workqueue(ptr_chann_desc->intr_handlr_wq);

		mdelay(10);
		ptr_chann_desc->intr_handlr_wq = NULL;
		if(ptr_chann_desc->coalse_cnt_set == true) 
		{
			del_timer_sync(&ptr_chann_desc->coal_cnt_timer);
		}
	}
	else
	{
		if(ptr_chann_desc->coalse_cnt_set == true) 
		{
			del_timer(&ptr_chann_desc->coal_cnt_timer);
		}
	}

	mdelay(1000);
	LOCK_DMA_CHANNEL(&ptr_chann_desc->channel_lock);

	/* Make DMA enable == 0 */
	{
		unsigned int regval = RD_DMA_REG(ptr_chann_desc->chan_dma_reg_vbaddr, DMA_CNTRL_REG_OFFSET);
		regval &= 0xfffffffe;
		WR_DMA_REG(ptr_chann_desc->chan_dma_reg_vbaddr, DMA_CNTRL_REG_OFFSET, regval);
	}

	mdelay(10);

	/* Check if the DMA is still running */
	{
		unsigned int regval = RD_DMA_REG(ptr_chann_desc->chan_dma_reg_vbaddr, DMA_STATUS_REG_OFFSET);
		if(regval & DMA_STATUS_DMA_RUNNING_BIT) 
		{
			printk(KERN_ERR"\n DMA still running, will reset!!");
		}
		else
		{
			printk(KERN_ERR"\n DMA quiet reset now\n");
		}
	}

	/* Reset DMA */
	{
		unsigned int regval = RD_DMA_REG(ptr_chann_desc->chan_dma_reg_vbaddr, DMA_CNTRL_REG_OFFSET);
		regval |= DMA_CNTRL_RST_BIT;
		WR_DMA_REG(ptr_chann_desc->chan_dma_reg_vbaddr, DMA_CNTRL_REG_OFFSET, regval);

		/* Give 10ms delay for reset to complete */
		mdelay(10);

		regval = RD_DMA_REG(ptr_chann_desc->chan_dma_reg_vbaddr, DMA_CNTRL_REG_OFFSET);
		regval &= (~(DMA_CNTRL_RST_BIT));
		WR_DMA_REG(ptr_chann_desc->chan_dma_reg_vbaddr, DMA_CNTRL_REG_OFFSET, regval);
	}

	/* Memset all Qs to 0*/
	memset(ptr_chann_desc->ptr_ctx, 0, sizeof(data_q_cntxt_t) * ptr_chann_desc->data_q_sz);
	memset(ptr_chann_desc->ptr_data_q.ptr_q, 0, sizeof(ps_pcie_src_bd_t) * ptr_chann_desc->data_q_sz);
	memset(ptr_chann_desc->ptr_sta_q, 0, sizeof(ps_pcie_sta_desc_t) * ptr_chann_desc->sta_q_sz);
	ptr_chann_desc->unusd_bd_idx_data_q = 0; //Index to slide on Data Q. Gives next unused BD
	ptr_chann_desc->sop_bd_idx_data_q = 0; //Index to slide on Data Q. Gives BD which has first fragment of packet data
	ptr_chann_desc->idx_cntxt_q = 0; //Index to slide on Context Q. Gives next unused context
	ptr_chann_desc->idx_rxpostps_cntxt_q = 0; //Index to slide on Context Q. Gives start context from where post processing begins
	ptr_chann_desc->idx_sta_q = 0; //Index to slide on status Q.
	ptr_chann_desc->idx_sta_q_hw = 0;

	ptr_chann_desc->ptr_dma_desc->num_channels_alloc--;
	UNLOCK_DMA_CHANNEL(&ptr_chann_desc->channel_lock);


	/* Disable the channel */
	return XLNX_SUCCESS;
}
EXPORT_SYMBOL(xlnx_deactivate_dma_channel);

int xlnx_stop_channel_IO(ps_pcie_dma_chann_desc_t *ptr_chann_desc, bool do_rst)
{
	int ret_val = XLNX_SUCCESS;
	//spin_lock_bh(&ptr_chann_desc->channel_lock);
	ptr_chann_desc->chann_state = XLNX_DMA_CHANN_IO_QUIESCED;
	//spin_unlock_bh(&ptr_chann_desc->channel_lock);

#ifndef PFORM_USCALE_NO_EP_PROCESSOR
	if(do_rst == true) 
	{
		int ret;
		unsigned int host_2_card_data[DMA_NUM_SCRPAD_REGS] = {0};
		unsigned int card_2_host_data[DMA_NUM_SCRPAD_REGS] = {0}; 

		/* Wait for outstanding IOs to get over */
		msleep(10);

		/* 
		 * We need to do a reset. We will make the EP side do the
		 * reset
		 */
		host_2_card_data[0] = XLNX_CMD_RESET_CHANN;

		ret = xlnx_do_scrtchpd_txn_from_host(ptr_chann_desc,
				host_2_card_data,
				DMA_NUM_SCRPAD_REGS,
				card_2_host_data,
				DMA_NUM_SCRPAD_REGS);
		if(ret == XLNX_SUCCESS && card_2_host_data[0] == XLNX_RSP_RESET_CHANN) 
		{
			printk(KERN_ERR"\n Received reset response channel %d", ptr_chann_desc->chann_id );
#if 0
			/* Make DMA enable == 0 */
			{
				unsigned int regval = RD_DMA_REG(ptr_chann_desc->chan_dma_reg_vbaddr, DMA_CNTRL_REG_OFFSET);
				regval &= 0xfffffffe;
				WR_DMA_REG(ptr_chann_desc->chan_dma_reg_vbaddr, DMA_CNTRL_REG_OFFSET, regval);
			}

			mdelay(10);

			/* Check if the DMA is still running */
			{
				unsigned int regval = RD_DMA_REG(ptr_chann_desc->chan_dma_reg_vbaddr, DMA_STATUS_REG_OFFSET);
				if(regval & DMA_STATUS_DMA_RUNNING_BIT) 
				{
					printk(KERN_ERR"\n DMA still running, will reset!!");
				}
				else
				{
					printk(KERN_ERR"\n DMA quiet reset now\n");
				}
			}

			/* Reset DMA */
			{
				unsigned int regval = RD_DMA_REG(ptr_chann_desc->chan_dma_reg_vbaddr, DMA_CNTRL_REG_OFFSET);
				regval |= DMA_CNTRL_RST_BIT;
				WR_DMA_REG(ptr_chann_desc->chan_dma_reg_vbaddr, DMA_CNTRL_REG_OFFSET, regval);

				/* Give 10ms delay for reset to complete */
				mdelay(10);

				regval = RD_DMA_REG(ptr_chann_desc->chan_dma_reg_vbaddr, DMA_CNTRL_REG_OFFSET);
				regval &= (~(DMA_CNTRL_RST_BIT));
				WR_DMA_REG(ptr_chann_desc->chan_dma_reg_vbaddr, DMA_CNTRL_REG_OFFSET, regval);
			}
#endif
		}
	}
#else
	if(ptr_chann_desc->is_aux_chann == true) 
	{
		//spin_lock_bh(&ptr_chann_desc->ptr_dma_desc->channels[ptr_chann_desc->chann_id].channel_lock);
		ptr_chann_desc->ptr_dma_desc->channels[ptr_chann_desc->chann_id].chann_state = XLNX_DMA_CHANN_IO_QUIESCED;
		//spin_unlock_bh(&ptr_chann_desc->ptr_dma_desc->channels[ptr_chann_desc->chann_id].channel_lock);
	}
	else
	{
		//spin_lock_bh(&ptr_chann_desc->ptr_dma_desc->aux_channels[ptr_chann_desc->chann_id].channel_lock);
		ptr_chann_desc->ptr_dma_desc->aux_channels[ptr_chann_desc->chann_id].chann_state = XLNX_DMA_CHANN_IO_QUIESCED;
		//spin_unlock_bh(&ptr_chann_desc->ptr_dma_desc->aux_channels[ptr_chann_desc->chann_id].channel_lock);
	}
	/* Make DMA enable == 0 */
	{
		unsigned int regval = RD_DMA_REG(ptr_chann_desc->chan_dma_reg_vbaddr, DMA_CNTRL_REG_OFFSET);
		regval &= 0xfffffffe;
		WR_DMA_REG(ptr_chann_desc->chan_dma_reg_vbaddr, DMA_CNTRL_REG_OFFSET, regval);
	}

	mdelay(10);

	/* Check if the DMA is still running */
	{
		unsigned int regval = RD_DMA_REG(ptr_chann_desc->chan_dma_reg_vbaddr, DMA_STATUS_REG_OFFSET);
		if(regval & DMA_STATUS_DMA_RUNNING_BIT) 
		{
			printk(KERN_ERR"\n DMA still running, will reset!!");
		}
		else
		{
			printk(KERN_ERR"\n DMA quiet reset now\n");
		}
	}

	/* Reset DMA */
	{
		unsigned int regval = RD_DMA_REG(ptr_chann_desc->chan_dma_reg_vbaddr, DMA_CNTRL_REG_OFFSET);
		regval |= DMA_CNTRL_RST_BIT;
		WR_DMA_REG(ptr_chann_desc->chan_dma_reg_vbaddr, DMA_CNTRL_REG_OFFSET, regval);

		/* Give 10ms delay for reset to complete */
		mdelay(10);

		regval = RD_DMA_REG(ptr_chann_desc->chan_dma_reg_vbaddr, DMA_CNTRL_REG_OFFSET);
		regval &= (~(DMA_CNTRL_RST_BIT));
		WR_DMA_REG(ptr_chann_desc->chan_dma_reg_vbaddr, DMA_CNTRL_REG_OFFSET, regval);
	}

	rmb();

	/* Check if the DMA is still running */
	{
		unsigned int regval = RD_DMA_REG(ptr_chann_desc->chan_dma_reg_vbaddr, DMA_STATUS_REG_OFFSET);
		if(regval & DMA_STATUS_DMA_RUNNING_BIT) 
		{
			printk(KERN_ERR"\n DMA still running, after reset!!");
		}
	}

#endif

#if 0
#ifdef USE_MSIX
	if(ptr_chann_desc->ptr_dma_desc->intr_type == MSIX) 
	{
		/* Unregister interrupt handler */
		free_irq(ptr_chann_desc->ptr_dma_desc->entries[ptr_chann_desc->chann_id].vector, 
				ptr_chann_desc);
	}
#endif
#endif


	return ret_val;
}
EXPORT_SYMBOL(xlnx_stop_channel_IO);


/*
 * Invoked by DMA driver when there is doorbell data from HOST
 */
void xlnx_register_doorbell_cbk(ps_pcie_dma_chann_desc_t *ptr_chann_desc,
		func_doorbell_cbk_no_block ptr_fn_drbell_cbk)
{
	unsigned long flags;

	spin_lock_irqsave(&ptr_chann_desc->channel_lock, flags);
	ptr_chann_desc->dbell_cbk = ptr_fn_drbell_cbk;
	spin_unlock_irqrestore(&ptr_chann_desc->channel_lock, flags);
}
EXPORT_SYMBOL(xlnx_register_doorbell_cbk);

/*
 * Send scratchpad response data to HOST 
 */
void xlnx_give_scrtchpd_rsp_to_host(ps_pcie_dma_chann_desc_t *ptr_chann_desc,
		unsigned int *ptr_card_2_host_data,
		unsigned int num_dwords_card_2_host
		)
{
	int i;
	unsigned int intr_assrt = 0;

	//spin_lock_bh(&ptr_chann_desc->channel_lock);

	/* Populate data into scratchpad */
	for(i = 0; i < num_dwords_card_2_host; i++) 
	{
		WR_DMA_REG(ptr_chann_desc->chan_dma_reg_vbaddr, (DMA_SCRATCH0_REG_OFFSET + (i*4)),*ptr_card_2_host_data);
		ptr_card_2_host_data++;
	}

	wmb();

	printk(KERN_ERR"\nRespond to HOST\n");

	/* Ring doorbell */
	intr_assrt |= DMA_SW_INTR_ASSRT_BIT;
	WR_DMA_REG(ptr_chann_desc->chan_dma_reg_vbaddr, DMA_PCIE_INTR_ASSRT_REG_OFFSET, intr_assrt);


	//spin_unlock_bh(&ptr_chann_desc->channel_lock);
}
EXPORT_SYMBOL(xlnx_give_scrtchpd_rsp_to_host);

/*
 * Send scratchpad command to EP & block till response arrives
 * Note this function cannot be called from non interrupt context
 */
int xlnx_do_scrtchpd_txn_from_host(ps_pcie_dma_chann_desc_t *ptr_chann_desc,
		unsigned int *ptr_host_2_card_data,
		unsigned int num_dwords_host_2_card,
		unsigned int *ptr_card_2_host_data,
		unsigned int num_dwords_card_2_host
		)
{
	int retval = XLNX_SUCCESS;
	int i;
	unsigned int intr_assrt = 0;

	/* Acquire mutex lock */
	if(down_trylock(&ptr_chann_desc->scratch_mutx))
	{
		retval = XLNX_SCRATCH_PAD_IO_IN_PROGRESS;
		printk(KERN_ERR"\n Scratch pad IO in progress for channel %d\n",ptr_chann_desc->chann_id);
		goto scratchpad_io_in_progress;
	}

	ptr_chann_desc->scrtch_pad_io_in_progress = true;

	/* Populate data into scratchpad */
	for(i = 0; i < num_dwords_host_2_card; i++) 
	{
		WR_DMA_REG(ptr_chann_desc->chan_dma_reg_vbaddr, (DMA_SCRATCH0_REG_OFFSET + (i*4)),*ptr_host_2_card_data);
		ptr_host_2_card_data++;
	}

	wmb();

	/* Ring doorbell */
	intr_assrt |= DMA_SW_INTR_ASSRT_BIT;
	WR_DMA_REG(ptr_chann_desc->chan_dma_reg_vbaddr, DMA_AXI_INTR_ASSRT_REG_OFFSET, intr_assrt);

	/* Wait for response from endpoint */
	down_timeout(&ptr_chann_desc->scratch_sem,jiffies+(HZ*2));
	printk(KERN_ERR"\n Response arrived from EP OR Timeout occured\n");

	rmb();

	/* Populate scratchpad data into buffer */
	for(i = 0; i < num_dwords_card_2_host; i++) 
	{
		*ptr_card_2_host_data = RD_DMA_REG(ptr_chann_desc->chan_dma_reg_vbaddr, (DMA_SCRATCH0_REG_OFFSET + (i*4)));
		printk(KERN_ERR"\n Scratchpad data received %x \n",*ptr_card_2_host_data);
		ptr_card_2_host_data++;
	}

	up(&ptr_chann_desc->scratch_mutx);




scratchpad_io_in_progress:
	return retval;
}
EXPORT_SYMBOL(xlnx_do_scrtchpd_txn_from_host);

/*
 * Interfaces exported End
 */


static int __init xlnx_pcie_dma_driver_init(void)
{
	int retval;

	retval = pci_register_driver(&nwl_dma_driver);

	printk(KERN_ERR" Module loaded/not-loaded with retval %d", retval);
	return retval;
}

static void __exit xlnx_pcie_dma_driver_exit(void)
{
	printk(KERN_ERR"\n PCIe driver unloading\n");
	pci_unregister_driver(&nwl_dma_driver);


}

module_init(xlnx_pcie_dma_driver_init);
module_exit(xlnx_pcie_dma_driver_exit);

MODULE_DESCRIPTION("Xilinx PS PCIe DMA driver");
MODULE_AUTHOR("Xilinx");
MODULE_LICENSE("GPL");
