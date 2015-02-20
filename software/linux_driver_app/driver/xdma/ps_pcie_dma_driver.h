
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
 ** NONINFRINGEMENT. IN NO EVENT SHALL THE X CONSORTIUM BE LIABLE FOR ANY
 ** CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 ** TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 ** SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 ** Except as contained in this notice, the name of the Xilinx shall
 ** not be used in advertising or otherwise to promote the sale, use or other
 ** dealings in this Software without prior written authorization from Xilinx
 **/
/*****************************************************************************
*****************************************************************************/
#ifndef __PS_PCIE_DMA_DRV_H
#define __PS_PCIE_DMA_DRV_H


#include <linux/pci.h>
#include <linux/semaphore.h>

#include "ps_pcie_pf.h" 


#ifdef DDR_DESIGN
#define GC_BUFF_ADDR (0xC0000000)
#else
#define GC_BUFF_ADDR (0x44000000)
#endif

#define PKT_SZ 		(4096 * 8)
#define AXI_DOMAIN_ADDR (0x44A00000)
#define CFG_AXI_MASTER  0x08
#define CFG_PCIE_CREDIT 0x28
#ifdef HW_SGL_DESIGN
#define MAX_RW_AXI_MM 	0x22
#endif
#if defined(DDR_DESIGN) || defined (PFORM_USCALE_NO_EP_PROCESSOR)
#define MAX_RW_AXI_MM 	0x33
#endif 
#define FC_COMP_HEADER_DATA 0x806003E0
/* Defines */
#define PS_PCIE_NUM_DMA_CHANNELS (4) //4 DMA channels
#define PS_PCIE_REG_AXI_LEN_BYTES (4 * 2 * 1024) //4KB
#define PS_PCIE_MIN_Q_SZ (2) //Minimum 2 elements in Q is needed
#define PS_PCIE_MAX_PKT_LEN (128 * 1024 * 1024) //Maximum bytes per packet
#define DMA_NUM_SCRPAD_REGS (4) //Number of scratch pad registers


/* Testing and debug related defines */
#ifdef TEST_DBG_ON



#define COALESE_CNT (0)



/* AXI performance monitor related defines */
#ifdef AXI_PERF_MON
#ifdef PFORM_RONALDO
#define AXI_PERF_MON_REG_BASE_ADDR (0x43C30000)

#else
#error "Define AXI side platform type in *_pf.h"
#endif
#endif
#endif



//#define HOST_APP //A simple loopback application on EP for Raw data
//#define USE_MSIX /* Use MSIX interrupt vector associated with each channel */
//#define NUM_MSIX_VECS (PS_PCIE_NUM_DMA_CHANNELS)/* Number of MSIx vectors */



#define RD_DMA_REG(base, offset) readl(base + offset)
#define WR_DMA_REG(base, offset, value) writel((value), base + offset)





#define PCI_VENDOR_XILINX (0x10EE)

/* Supported device ids */
#define NWL_DMA_VAL_DEVID (0x8083)
#define NWL_DMA_VAL_DEVID_VIDEO (0x8183)
#define NWL_DMA_x4G1_PFMON_DEVID (0x7024) //x4g1 perfmon
#define NWL_DMA_HW_SGL_CNTRL (0x8082) //SGL controlled by HW logic
#define NWL_DMA_HW_SGL_ETHER (0x8182) //SGL controlled by HW logic

/* 
 * Number of packets after which post processing worker thread must yield. This needs to be tuned
 * as a large number may cause CPU to be held up by post processing
 */
//#define PKT_YIELD_CNT_PER_CHANN (500)
//#define PKT_YIELD_CNT_PER_CHANN (5)
#define PKT_YIELD_CNT_PER_CHANN (500)

#define HEART_BEAT_INTERVAL_SECS (1)

/*
 * Time in terms of HZ after which the coalesce count timer runs
 * Lower value means quicker response time
 */
#define COALESCE_TIMER_MAGNITUDE (10*HZ)



/* PCI specific defines */
#define PCIE_CONFIG_BAR2_BASE_ADDR_OFFSET (0x18)

/* DMA channels and bridge BAR */
#define PS_PCIE_BRDG_DMA_CHANN_BAR (0)

#if defined(PFORM_USCALE_NO_EP_PROCESSOR) || defined(HW_SGL_DESIGN) || defined(DDR_DESIGN)
#define PS_PCIE_CNTRL_FUNCT_INGRESS_TRANS_BAR (2)
#define PS_PCIE_CNTRL_FUNCT_INGRESS_TRANS_LEN_BYTES (64 * 1024) //64KB
#endif

/* Define common to both host & EP software */
#define DMA_REG_TOT_BYTES (0x80) //128 bytes of register per DMA channel


#define DMA_CNTRL_RST_BIT (1 << 1)
#define DMA_CNTRL_64BIT_STAQ_ELEMSZ_BIT (1 << 2)
#define DMA_CNTRL_ENABL_BIT (1 << 0)
#define DMA_STATUS_DMA_PRES_BIT (1 << 15)
#define DMA_STATUS_DMA_RUNNING_BIT (1 << 0)
#define DMA_QPTRLO_QLOCAXI_BIT (1 << 0)
#define DMA_QPTRLO_Q_ENABLE_BIT (1 << 1)
#define DMA_INTSTATUS_DMAERR_BIT (1 << 1)
#define DMA_INTSTATUS_SGLINTR_BIT (1 << 2)
#define DMA_INTSTATUS_SWINTR_BIT (1 << 3)
#define DMA_INTCNTRL_ENABLINTR_BIT (1 << 0)
#define DMA_INTCNTRL_DMAERRINTR_BIT (1 << 1)
#define DMA_INTSTATUS_DMASGINTR_BIT (1 << 2)
#define DMA_SW_INTR_ASSRT_BIT (1 << 3)

#define DMA_INTSTATUS_SGCOLSCCNT_BIT_SHIFT (16)

#if defined(PFORM_USCALE_NO_EP_PROCESSOR) || defined(HW_SGL_DESIGN) || defined(DDR_DESIGN)
/* Bridge registers 
*/
#define REG_BRDG_BASE		  0x00008000 /**< bridge base register base */

#define REG_BRDG_E_BASE           0x00000200 /**< bridge egress  register base */

#define OFFSET_BRDG_E_CAP         0x00000000 /**< bridge egress  Capability offset  */
#define OFFSET_BRDG_E_STATS       0x00000004 /**< bridge egress status register offset  */
#define OFFSET_BRDG_E_CTRL        0x00000008  /**< bridge egress control register offset*/
#define OFFSET_BRDG_E_SRC_LO      0x00000010 /**< bridge egress source base address low register */
#define OFFSET_BRDG_E_SRC_HI      0x00000014 /**< bridge egress source base address high register */
#if defined(VIDEO_ACC_DESIGN)
#define OFFSET_BRDG_D_CAP         0x00000080
#define OFFSET_BRDG_D_CTRL        0x00000088
#define OFFSET_BRDG_D_SRC_LO      0x00000090 
#define OFFSET_BRDG_D_SRC_HI      0x00000094
#endif 

/* Ingress AXI translations
*/
#define REG_INGR_AXI_BASE 		0x00000800 /**< Ingress AXI transalation base register */

#define OFFSET_INGR_AXI_CTRL	0x00000008 /**< Ingress AXI translation Control Offser */
#define OFFSET_INGR_AXI_SRC_LO   0x00000010 /**< Ingress AXI transaltion Source Base low */
#define OFFSET_INGR_AXI_SRC_HI   0x00000014 /**< Ingress AXI transaltion Source Base high */
#define OFFSET_INGR_AXI_DST_LO   0x00000018 /**< Ingress AXI transaltion Destination  Base low */


/** PVTMON Macros */
#define   	 PVTMON_BASE			0x2000
#define		PVTMON_VCCINT 		0x040
#define 	PVTMON_VCCAUX 		0x044
#define		PVTMON_VCC3 			0x048
#define 	PVTMON_VADJ 			0x04C
#define		PVTMON_VCC1 			0x050
#define 	PVTMON_VCC2 			0x054
#define 	PVTMON_MGT_AVCC 		0x058
#define 	PVTMON_MGT_AVTT 		0x05C
#define 	PVTMON_VCCAUX_IO 		0x060
#define 	PVTMON_VCCBRAM 		0x064
#define 	PVTMON_MGT_VCCAUX	0x068
#define 	PVTMON_VCC1_8			0x06C
#define	PVTMON_TEMP			0x070


#endif


#define DMA_SRCQPTRLO_REG_OFFSET (0x00) //Source Q pointer Lo offset
#define DMA_SRCQPTRHI_REG_OFFSET (0x04) //Source Q pointer Hi offset
#define DMA_SRCQSZ_REG_OFFSET (0x08) // Source Q size offset
#define DMA_SRCQLMT_REG_OFFSET (0x0C) //Source Q limit offset
#define DMA_DSTQPTRLO_REG_OFFSET (0x10) //Destination Q pointer Lo offset
#define DMA_DSTQPTRHI_REG_OFFSET (0x14) //Destination Q pointer Hi offset
#define DMA_DSTQSZ_REG_OFFSET (0x18) //Destination Q size offset
#define DMA_DSTQLMT_REG_OFFSET (0x1C) //Destination Q limit offset
#define DMA_SSTAQPTRLO_REG_OFFSET (0x20) //Source Status Q pointer Lo offset
#define DMA_SSTAQPTRHI_REG_OFFSET (0x24) //Source Status Q pointer Hi offset
#define DMA_SSTAQSZ_REG_OFFSET (0x28) // Source Status Q size offset
#define DMA_SSTAQLMT_REG_OFFSET (0x2C) //Source Status Q limit offset
#define DMA_DSTAQPTRLO_REG_OFFSET (0x30) //Destination Status Q pointer Lo offset
#define DMA_DSTAQPTRHI_REG_OFFSET (0x34) //Destination Status Q pointer Hi offset
#define DMA_DSTAQSZ_REG_OFFSET (0x38) // Destination Status Q size offset
#define DMA_DSTAQLMT_REG_OFFSET (0x3C) //Destination Status Q limit offset
#define DMA_SRCQNXT_REG_OFFSET (0x40) //Source Q next offset
#define DMA_DSTQNXT_REG_OFFSET (0x44) //Destination Q next offset
#define DMA_SSTAQNXT_REG_OFFSET (0x48) // Source Status Q next offset
#define DMA_DSTAQNXT_REG_OFFSET (0x4C) //Destination Status Q next offset
#define DMA_SCRATCH0_REG_OFFSET (0x50) //Scratch pad register 0 offset

#define DMA_PCIE_INTR_CNTRL_REG_OFFSET (0x60) //DMA PCIe interrupt control register offset
#define DMA_PCIE_INTR_STATUS_REG_OFFSET (0x64) //DMA PCIe interrupt status register offset
#define DMA_AXI_INTR_CNTRL_REG_OFFSET (0x68) //DMA AXI interrupt control register offset
#define DMA_AXI_INTR_STATUS_REG_OFFSET (0x6C) //DMA AXI interrupt status register offset
#define DMA_PCIE_INTR_ASSRT_REG_OFFSET (0x70) //PCIe interrupt assert register offset
#define DMA_AXI_INTR_ASSRT_REG_OFFSET (0x74) //AXI interrupt assert register offset
#define DMA_STATUS_REG_OFFSET (0x7C) //DMA status register offset
#define DMA_CNTRL_REG_OFFSET (0x78) //DMA control register offset
#define DMA_STATUS_REG_OFFSET (0x7C) //DMA status register offset

#define MAX_STATS   100
#define MULTIPLIER      (8*4)
#define DIVISOR         (1024*1024*1024)



#define UNINITIALIZED       0           /**< State at system start */
#define INITIALIZED         1           /**< After probe */
#define USER_ASSIGNED       2           /**< Engine assigned to user */
#define UNREGISTERING       3           /**< In the process of unregistering */

#define USER_BASE	       	0x1000
#define SCAL_FACTOR_REG          0x008
#define CLK_PERIOD_REG           0x014
#define TX_UTIL_BC               0x100
#define RX_UTIL_BC               0x104
#define MInitFCCplD              0x110 /* Initial Completion Data Credits for Downstream Port*/
#define MInitFCCplH              0x114 /* Initial Completion Header Credits for Downstream Port*/
#define MInitFCNPD               0x118 /* Initial NPD Credits for Downstream Port */
#define MInitFCNPH               0x11c /* Initial NPH Credits for Downstream Port */
#define MInitFCPD                0x120 /* Initial PD Credits for Downstream Port */
#define MInitFCPH                0x124 /* Initial PH Credits for Downstream Port */

#define AXI_PERF_MON_BASE       0x10000
#define SAMPLE_INTERVAL		0x024
#define SAMPLE_INTERVAL_CTRL	0x028
#define METRIC_SEL_REG0 	0x044
#define APM_CTRL_REG		0x300
#define APM_METRIC_CNTR0	0x200
#define APM_METRIC_CNTR1	0x210
#define APM_METRIC_CNTR2	0x220
#define APM_METRIC_CNTR3	0x230

#define CLK_300MHZ_PERIOD       0x11E1A300  
#define CLK_250MHZ_PERIOD       0xEE6B280  
#define CLK_150MHZ_PERIOD       0x94C5F00 
#define CLK_200MHZ_PERIOD       0xBEBC200  
#define CLK_125MHZ_PERIOD       0x7735940  
#define CLK_267MHZ_PERIOD       0xFE64830  



/* 
 * Scatter gather Buffer Descriptors (BDs) 
 */

/* SRC Q BD */
struct ps_pcie_src_bd
{
	unsigned long long phy_src_addr; //Physical address of source data buffer
	unsigned int byte_count: 24; //Size of data buffer in bytes
	unsigned int loc_axi: 1; //Set to 1 if data buffer is on AXI memory
	unsigned int eop: 1; //Last fragment 
	unsigned int intr: 1; //Generate interrupt after status Q is written
	unsigned int rsvd: 1; //Reserved
	unsigned int dma_data_rd_attr: 4; //DMA data read attributes
	unsigned short usr_handle; //User handle copied in status Q BD
	unsigned short usr_id; //User handle copied in status Q BD			
}__attribute__((__packed__));

typedef struct ps_pcie_src_bd ps_pcie_src_bd_t;

/* DST Q BD */
struct ps_pcie_dst_bd
{
	unsigned long long phy_dst_addr; //Physical address of source data buffer
	unsigned int byte_count: 24; //Size of data buffer in bytes
	unsigned int loc_axi: 1; //Set to 1 if data buffer is on AXI memory
	unsigned int use_nxt_bd_on_eop: 1; //Skip to Next Destination SGL on End of Packet
	unsigned int rsvd: 2; //Reserved
	unsigned int dma_data_rd_attr: 4; //DMA data read attributes
	unsigned short usr_handle; //User handle copied in status Q BD
	unsigned short rsvd1; //Reserved			
}__attribute__((__packed__));

typedef struct ps_pcie_dst_bd ps_pcie_dst_bd_t;

/* STA Q BD, 64 bytes mode of operation. We are not supporting 32 byte mode */
struct ps_pcie_sta_desc
{
	unsigned int completed: 1; //BD processing complete
	unsigned int src_err: 1; //SRC error detected
	unsigned int dst_err: 1; //DST error detected
	unsigned int intrnl_error: 1; //Internal error
	unsigned int compl_bytes: 27; //Completed byte count
	unsigned int upper_sta_nz: 1; //Upper fields have data
	unsigned short usr_handle; //User handle copied in status Q BD
	unsigned short usr_id; //User handle copied in status Q BD          
}__attribute__((__packed__));

typedef struct ps_pcie_sta_desc ps_pcie_sta_desc_t;

typedef union
{
	ps_pcie_src_bd_t *ptr_src_q;
	ps_pcie_dst_bd_t *ptr_dst_q;
	u8 *ptr_q;
}dataq_ptr_t;



/*
 * This enumeration lists the DMA channels
 */
typedef enum
{
	CHAN_0,
	CHAN_1,
	CHAN_2,
	CHAN_3
}chan_t;

/*
 * This enumeration indicates the platform (Host/EP) on which the driver is executing
 */
typedef enum
{
	HOST,
	EP
}platform_t;

/* 
 * Address is virtual or physical 
 */
typedef enum
{
	VIRT_ADDR, //Unmapped Virtual address. Driver maps/unmaps this for DMA access
	PHYS_ADDR //Physical address. Driver will not flush/invalidate the buffer. This is callers responsibility
#ifdef PFORM_USCALE_NO_EP_PROCESSOR
		,EP_PHYS_ADDR //Physical address on platform across PCIe interface i.e. for HOST side software the address is for EP physical memory
#endif
}addr_type_t;


/*
 * This enumeration indicates the direction of data flow with respect to the platform (Host/EP).
 * Taking C2S data flow as example, host would indicate direction of channel as IN, while EP would indicate 
 * the direction of channel as OUT
 */
typedef enum
{
	OUT,
	IN
}direction_t;

typedef enum
{
	HW = 0,
	MSI,
	MSIX
}intr_type_t;

struct _ps_pcie_dma_chann_desc; //forward declaration



/* Callback firect by DMA driver when the underlying health of channel changes in EP
 * e.g. If channel is not allocated or is shut down asynchronously by EP.
 * The function is invoked by the driver after taking the channel lock
 */
typedef void (*func_ptr_chann_health_cbk_no_block)(struct _ps_pcie_dma_chann_desc *);

typedef void (*func_doorbell_cbk_no_block)(struct _ps_pcie_dma_chann_desc *,
		unsigned int *ptr_host_2_card_data,
		unsigned int num_dwords_host_2_card);


typedef void (*func_ptr_dma_chann_cbk_noblock)(struct _ps_pcie_dma_chann_desc *, 
		void *data, 
		unsigned int compl_bytes, 
		unsigned short uid, 
		unsigned int num_frags);

typedef volatile struct
{
	unsigned int sop_bd_idx; //BD Index using which the first fragment is pointed
	unsigned int eop_bd_idx; //BD Index using which the last fragment is pointed
	func_ptr_dma_chann_cbk_noblock cbk; //Non blocking Callback function
	bool under_use; //Conext element is in use
	dma_addr_t eop_phy_addr; 
	dma_addr_t sop_phy_addr; 
	unsigned char *data;
	addr_type_t at;
}data_q_cntxt_t;

/*
 * This structure is a placeholder for data pertaining to the 
 * each PCIe DMA channel supported by DMA.
 */
typedef struct _ps_pcie_dma_chann_desc
{
	bool channel_is_active; //application is using this channel
	bool latched;	//host-EP driver-application in synch
	direction_t dir; //data flow direction from platform (IN/OUT)
	u32 chann_id;
	int chann_state;
	dma_addr_t data_q_paddr;
	dma_addr_t stat_q_paddr;
	unsigned int dat_q_sz;
	unsigned int stat_q_sz;
#ifdef USE_MSIX
	char msix_hndlr_name[64];
	bool intr_hndlr_registered;
	bool reset_given;
#endif
#ifdef PFORM_USCALE_NO_EP_PROCESSOR
	bool is_aux_chann;
#endif
#ifdef TEST_DBG_ON
	unsigned int prev_num_pkts_io; //Used to detect stalling
	unsigned int bds_alloc;
	unsigned int bds_freed;
	unsigned int cbk_called;
	unsigned int interrupted;
	unsigned int wake_up_count;
	unsigned char *test_buf;
	unsigned int saturate_flag;
#endif
	//#ifndef PFORM_USCALE_NO_EP_PROCESSOR
	func_ptr_chann_health_cbk_no_block ptr_func_health;
	struct task_struct *hbeat_thrd;
	char hbeat_thrd_name[64];
	bool chk_hbeat;
	//#endif
	struct semaphore scratch_sem;
	struct semaphore scratch_mutx;
	func_doorbell_cbk_no_block dbell_cbk;
	bool scrtch_pad_io_in_progress;
	unsigned int num_pkts_io;
	unsigned int yield_weight;
	struct _ps_pcie_dma_desc *ptr_dma_desc; //Associated DMA descriptor
	unsigned int data_q_sz;
	unsigned int sta_q_sz;
	u8 __iomem *chan_dma_reg_vbaddr; //Virtual Base address of the DMA registers
	dataq_ptr_t ptr_data_q;
	ps_pcie_sta_desc_t *ptr_sta_q;
	data_q_cntxt_t *ptr_ctx; //Pointer to context array
	unsigned int unusd_bd_idx_data_q; //Index to slide on Data Q. Gives next unused BD
	unsigned int sop_bd_idx_data_q; //Index to slide on Data Q. Gives BD which has first fragment of packet data
	unsigned int idx_cntxt_q; //Index to slide on Context Q. Gives next unused context
	unsigned int idx_rxpostps_cntxt_q; //Index to slide on Context Q. Gives start context from where post processing begins
	unsigned int idx_sta_q; //Index to slide on status Q.
	unsigned int idx_sta_q_hw; //Index to slide on status Q, used by hardware.
	//bool channel_active_for_ios;
	unsigned int num_free_bds; //Number of BDs free for use
	spinlock_t channel_lock;
	bool coalse_cnt_set; //Flag to check if coalesce count is set
	struct timer_list coal_cnt_timer; //Timer to periodically check BDs for residual packets with coalesce count set
	struct workqueue_struct *intr_handlr_wq; //Work Q to handle interrupts for this channel
	struct work_struct intrh_work; //Work instance to handle interrupt
	unsigned int src_sgl_err;
	unsigned int dst_sgl_err;
	unsigned int internal_err;	
}ps_pcie_dma_chann_desc_t;

/*
 * This structure is a placeholder for data pertaining to the 
 * PCIe DMA. There is a single global instance of this structure maintained by the driver
 * executing on Host/EP
 */
typedef struct _ps_pcie_dma_desc
{
#ifdef POLL_MODE
	struct timer_list intr_poll_tmr;
#endif
	bool intr_hndlr_registered;
	unsigned int irq_no;
	intr_type_t intr_type;
	void *device;
	struct device *dev;
#ifdef USE_MSIX
	struct msix_entry entries[NUM_MSIX_VECS];
#endif
	u32 num_channels; //total number of channels supported by DMA 
	u32 num_channels_active; //number of channels active
	u32 num_channels_alloc; //number of channels allocated for use
	platform_t pform; //Host/EP
	ps_pcie_dma_chann_desc_t channels[PS_PCIE_NUM_DMA_CHANNELS]; //array of channel descriptors
#if defined(PFORM_USCALE_NO_EP_PROCESSOR) || defined(HW_SGL_DESIGN) || defined(DDR_DESIGN)
	unsigned long cntrl_func_phy_base_addr; //Physical Base address of the AXI control functions via ingress translation
	u8 __iomem *cntrl_func_virt_base_addr; //Virtual Base address of the AXI control functions via ingress translation
	ps_pcie_dma_chann_desc_t aux_channels[PS_PCIE_NUM_DMA_CHANNELS]; //array of channel descriptors
#endif
	u64 dma_reg_phy_base_addr; //Physical Base address of the DMA registers
	u8 __iomem *dma_reg_virt_base_addr; //Virtual Base address of the DMA registers
	u64 dma_chann_reg_phy_base_addr; //Physical Base address of the DMA Channel registers
	u8 __iomem *dma_chann_reg_virt_base_addr; //Virtual Base address of the DMA Channel registers
	spinlock_t dma_lock; //lock
}ps_pcie_dma_desc_t;


/*
 * Union abstracting underlying device pcie/axi corresponding to Host/EP
 */
typedef union
{
	struct platform_device *op;
	struct pci_device *pci;
	void *ptr;
}xlnx_device_t;



/*
 * APIs exported only on Host platform
 */
struct pci_device *xlnx_get_pcie_devs(u16 dev_id, u16 vendor_id);//Invoked by host applications to get pcie devices
//with matching device and vendor id combination
//The pcie devices are probed by the dma driver
// NULL 


/* 
 * Exported Common API list
 * These APIs are exported on both Host & EP platforms
 */

/*
 * Description: This API returns an instance of the 'ps_pcie_dma_desc_t' structure discovered in a system. On HOST the number of 'ps_pcie_dma_desc_t'
 * instances is equal to the PCIe end points having Xilinx PCIe IP(NWL AXI-PCIe Bridge). On HOST the API traverses a list of 'ps_pcie_dma_desc_t' to get 
 * next instance to return. 
 * On EP a single instance of 'ps_pcie_dma_desc_t' is present which is returned back.
 * On HOST side the API can be called successively till NULL is returned signalling no more instances of 'ps_pcie_dma_desc_t'
 * This API is used by a higher level application specific software driver (ethernet, SCSI, Video, Raw IO, etc) to discover compatible devices using which
 * services can be provided to overhead stacks/applications 
 *
 * Parameter(s):
 * @prev_desc - Upon first invocation NULL is passed. Successive invocation will require passing pointer to 'ps_pcie_dma_desc_t' that was returned as
 *				a result of previous invocation.
 * @vendid - On HOST side provide PCIe vendor id identifying EP that the driver wants to control. On EP pass 0.
 * @devid - On EP side provide PCIe device id identifying EP that the driver wants to control. On EP pass 0.
 *
 * Return: Pointer to 'ps_pcie_dma_desc_t' discovered in system. 
 * Locking - No locks need to be taken. 
 * Blocking - API does not block
 */
ps_pcie_dma_desc_t* xlnx_get_pform_dma_desc(void *prev_desc, 
		unsigned short vendid, 
		unsigned short devid
		); 

int xlnx_get_dma(void *dev, platform_t pform, ps_pcie_dma_desc_t **pptr_dma_desc); //Invoked by ep-application & host application 
// driver during init to get dma engine descriptor
// corresponding to device 

/*
 * Description: This API is used to acquire a DMA channel for IOs. higher level application specific software driver (ethernet, SCSI, Video, Raw IO, etc)
 * require to first get a DMA channel to perform IOs with HOST/EP.
 *
 * Parameter(s):
 * @ptr_dma_desc: Pointer to instance of 'ps_pcie_dma_desc_t' which encapsulates the DMA channel. This pointer can be acquired by maing a call to
 *				'xlnx_get_pform_dma_desc'
 * @channel_id: Decimal number indicating DMA channel number to acquire. 1st channel is indicated by number 0.
 * @dir: Enumeration IN/OUT, indicating direction of data transfer. If platform is transferring data pass 'OUT'. In case of data reception
 *		pass 'IN'
 * @pptr_chann_desc: 
 */
int xlnx_get_dma_channel(ps_pcie_dma_desc_t *ptr_dma_desc, u32 channel_id, 
		direction_t dir, ps_pcie_dma_chann_desc_t **pptr_chann_desc,
		func_ptr_chann_health_cbk_no_block ptr_chann_health);

int xlnx_rel_dma_channel(ps_pcie_dma_chann_desc_t *ptr_chann_desc);//Invoked by ep-application & host application driver 
// to relinquish acquired DMA channel
int xlnx_activate_dma_channel(ps_pcie_dma_desc_t *ptr_dma_desc, 
		ps_pcie_dma_chann_desc_t *ptr_chann_desc,
		unsigned int data_q_addr_hi, //Physical address
		unsigned int data_q_addr_lo,//Physical address
		unsigned int data_q_sz,
		unsigned int sta_q_addr_hi,//Physical address
		unsigned int sta_q_addr_lo,//Physical address
		unsigned int sta_q_sz,
		unsigned char coalesce_cnt //Coalesce count for SGL interrupt resporting
		);
int xlnx_alloc_queues(ps_pcie_dma_chann_desc_t *ptr_chann_desc,
		unsigned int *ptr_data_q_addr_hi, //Physical address
		unsigned int *ptr_data_q_addr_lo,//Physical address
		unsigned int *ptr_sta_q_addr_hi,//Physical address
		unsigned int *ptr_sta_q_addr_lo,//Physical address
		unsigned int q_num_elements);
int xlnx_dealloc_queues(ps_pcie_dma_chann_desc_t *ptr_chann_desc);

int xlnx_data_frag_io(ps_pcie_dma_chann_desc_t *ptr_chan_desc, 
		unsigned char *addr_buf,
		addr_type_t at,
		size_t sz,
		func_ptr_dma_chann_cbk_noblock cbk,
		unsigned short uid, 
		bool last_frag, 
		/* direction_t dir, */
		void *ptr_user_data);
unsigned int xlnx_get_chann_num_free_bds(ps_pcie_dma_chann_desc_t *ptr_chan_desc);
void xlnx_register_doorbell_cbk(ps_pcie_dma_chann_desc_t *ptr_chann_desc,
		func_doorbell_cbk_no_block ptr_fn_drbell_cbk);
void xlnx_give_scrtchpd_rsp_to_host(ps_pcie_dma_chann_desc_t *ptr_chann_desc,
		unsigned int *ptr_card_2_host_data,
		unsigned int num_dwords_card_2_host
		);
int xlnx_do_scrtchpd_txn_from_host(ps_pcie_dma_chann_desc_t *ptr_chann_desc,
		unsigned int *ptr_host_2_card_data,
		unsigned int num_dwords_host_2_card,
		unsigned int *ptr_card_2_host_data,
		unsigned int num_dwords_card_2_host
		);
int xlnx_stop_channel_IO(ps_pcie_dma_chann_desc_t *ptr_chann_desc, bool do_rst);
int xlnx_deactivate_dma_channel(ps_pcie_dma_chann_desc_t *ptr_chann_desc);

/* Xilinx DMA driver status messages */
#define XLNX_SUCCESS (0)
#define XLNX_NO_FREE_CHANNELS (-1)		/* All DMA channels under use */
#define XLNX_ILLEGAL_CHANN_NO (-2)		/* Channel number provided is not legal */
#define XLNX_CHANN_IN_USE (-3)			/* Channel requested is already allocated to application */
#define XLNX_UNALLOCATED_IN_EP	(-4)	/* Channel is unallocated in Endpoint. Only host driver can get this response */
#define XLNX_ILLEGAL_DIR (-5)			/* Direction is not valid based on what is configured in endpoint. Only host driver can get this response */
#define XLNX_CHANN_NOT_PRES (-6)		/* Channel is not present in hardware */
#define XLNX_CHANN_ACTIVE (-7)			/* Channel is already active */
#define XLNX_ILLEGAL_Q_SZ (-8)			/* Q size less than 2 */
#define XLNX_INTERRUPT_REG_FAIL (-9)	/* Registration of interrupt handler failed */
#define XLNX_Q_ALREADY_ALLOC (-10)		/* Qs already allocated for channel */
#define XLNX_STA_Q_ALLOC_FAIL (-11)		/* Status Q allocation failed */
#define XLNX_DATA_Q_ALLOC_FAIL (-12)	/* Data Q allocation failed */
#define XLNX_Q_UNALIGNED_64BYT (-13)	/* 64byte Unaligned Q */
#define XLNX_CNTX_ARR_ALLOC_FAIL (-14)	/* Context Q allocation failed */
#define XLNX_DMA_CHANN_SW_ERR (-15)		/* Channel cannot complete IO due to software error, see channel state */
#define XLNX_DMA_CHANN_HW_ERR (-16)		/* Channel cannot complete IO due to hardware error, see channel state */
#define XLNX_SCRATCH_PAD_IO_IN_PROGRESS (-17) /* Scratch pad IO is in progress, try after sometime */
#define XLNX_MSIX_HNDLR_REG_FAIL (-18) /* MSIx interrupt handle registration failed */
#define XLNX_UNDEF_DMA_SCPD_CMD_RXD (-19) /* Received an undefined scratch pad command */

/* DMA Channel states */
#define XLNX_DMA_CHANN_NO_ERR (0) /* No error, DMA channel fine */
#define XLNX_DMA_CHANN_SATURATED (-1) /* Data Q BD element not available. HOST/EP is producing more data than EP/HOST is consuming */
#define XLNX_DMA_CNTXTQ_SATURATED (-2) /* Context Q element not available. HOST/EP is producing more data than EP/HOST is consuming */
#define XLNX_DMA_DST_ERROR (-3) /* Destination error reported in BD by hardware */
#define XLNX_DMA_SRC_ERROR (-4) /* Source error reported in BD by hardware */
#define XLNX_DMA_INTRNL_ERROR (-5) /* Internal error reported in BD by hardware */
#define XLNX_DMA_USRDATA_ERROR (-6) /* User data unavailable reported in BD by hardware */
#define XLNX_DMA_CHANN_IO_QUIESCED (-7) /* Channel is quiesced */
#define XLNX_DMA_CHANN_NOT_READY_EP (-8) /* Channel not yet ready in EP */
#define XLNX_DMA_CHANN_NO_HBEAT_FROM_EP (-8) /* Channel not yet ready in EP */



/* Commands used by DMA driver for communicating with EP side of channel */
#define XLNX_CMD_CHANN_HBEAT (0x01) /* Command used to check heart beat of EP channel */
#define XLNX_CMD_STOP_CHANN_IO (0x2) /* Command used to stop IOs on channel */
#define XLNX_CMD_START_CHANN_IO (0x3) /* Command used to start IOs on channel */
#define XLNX_CMD_RESET_CHANN (0x4) /* Command to reset channel */

#define XLNX_CMD_DMA_DRV_END (0xFF) /* Last command value used by DMA driver */

/* Response used by DMA driver for responding to HOST side of channel */
#define XLNX_RSP_CHANN_HBEAT (~(XLNX_CMD_CHANN_HBEAT)) 
#define XLNX_RSP_STOP_CHANN_IO (~(XLNX_CMD_STOP_CHANN_IO))
#define XLNX_RSP_START_CHANN_IO (~(XLNX_CMD_START_CHANN_IO))
#define XLNX_RSP_RESET_CHANN (~(XLNX_CMD_RESET_CHANN))

#ifdef HW_SGL_DESIGN
#define GEN_CHECK_OFFSET_START (0x00000)

//#define GEN_CHK_PKT_LEN_OFFSET (0x8)

#define ENABLE_GEN  		 0x4
#define ENABLE_CHK   		 0x8
#define GEN_PKT_LENGTH    0x0c
#define CHK_PKT_LENGTH    0x10
#define CNT_WRAP      		 0x14
#define CHK_STATUS   		 0x18

#define GENCHK_ENABLE	 0x1

#endif

#ifdef PFORM_USCALE_NO_EP_PROCESSOR
#define GEN_CHECK_OFFSET_START (0x00000)

#define GEN_CHK_PKT_LEN_OFFSET (0x8)

#define ENABLE_GEN  	0x0
#define ENABLE_CHK    0x4
#define PKT_LENGTH    0x8
#define CHK_STATUS   0xc
#define CNT_WRAP       0x10
#define GENCHK_ENABLE 0x1

#endif

#ifdef DDR_DESIGN
#define GEN_CHECK_OFFSET_START (0x00000)

#define GEN_CHK_PKT_LEN_OFFSET (0x8)
#endif
#define NW_PATH0_OFFSET      0x20000
#define NW_PATH1_OFFSET      0x30000

/* Operating mode */
#define NO_CACHE_FLUSH_INVALIDATE //Turn off flushing and invalidation of cache
//This can be set for increased performance if the processor is 
//not accessing data being ferried across PCIe and is just forwarding/receiving packets

#ifdef TEST_DBG_ON
#if defined(PFORM_USCALE_NO_EP_PROCESSOR) || defined(DDR_DESIGN)
//#define GENERATOR_MODE
//#define CHECKER_MODE
//#define GENCHECK_MODE
#define POLL_STATS
#endif
#endif

#endif
