
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
#include <linux/version.h>
#include <linux/module.h>
#include <linux/delay.h>
#include <linux/interrupt.h>
#include <linux/slab.h>
#include <linux/timer.h>
#include <linux/sched.h>
#include <linux/kthread.h>
#include <linux/netdevice.h>
#include <linux/etherdevice.h>


#include "../xdma/ps_pcie_dma_driver.h"
#include "../xdma/ps_pcie_pf.h"
#include "xxgethernet.h"



/* Must be shorter than length of ethtool_drvinfo.driver field to fit */
#define DRIVER_NAME         "xxgbeth_driver"
#define DRIVER_DESCRIPTION  "Xilinx Gigabit Ethernet (XGEMAC) Linux driver"
#define DRIVER_VERSION      "1.0"
/*@}*/

#define XGMAC_TX_CHANNID 	0
#define XGMAC_RX_CHANNID 	1
#ifdef ENABLE_JUMBO    
#define XGMAC_RX_BUF_SIZE	XXGE_MAX_JUMBO_FRAME_SIZE
#else
#define XGMAC_RX_BUF_SIZE		1536
#endif
typedef enum DUPLEX { UNKNOWN_DUPLEX, HALF_DUPLEX, FULL_DUPLEX } DUPLEX;


struct net_device *ndev = NULL;	    /* This networking device */

static struct net_device_ops xenet_netdev_ops;





/** @name Our private per-device data. When a net_device is allocated we 
 * will ask for enough extra space for this.
 * @{
 */
struct net_local {
	struct list_head rcv;
	struct list_head xmit;

	struct net_device *ndev;	    /* This device instance */
	struct net_device_stats stats;	/* Statistics for this device */
	struct timer_list phy_timer;	/* PHY monitoring timer */

	u32 index;		                /* Which interface is this */
	u32 xgmii_addr;		            /* The XGMII address of the PHY */	
	u32 versionReg;                 /* User-specific version info */

	void * TxHandle;                /* Handle of TX DMA engine */
	void * RxHandle;                /* Handle of RX DMA engine */

	int DriverState;                /* State of driver */
	/* The underlying OS independent code needs space as well.  A
	 * pointer to the following XXgEthernet structure will be passed to
	 * any XXgEthernet_ function that requires it.  However, we treat the
	 * data as an opaque object in this file (meaning that we never
	 * reference any of the fields inside this structure). */
	XXgEthernet Emac;

	unsigned int max_frame_size;
	/* buffer for one skb in case no room is available for transmission */
	struct sk_buff *deferred_skb;

	/* Stats which could not fit in net_device_stats */
	int tx_pkts;
	int rx_pkts;
	int max_frags_in_a_packet;
	unsigned long realignments;
	unsigned long local_features;

	unsigned int ptr_host_2_card_data[4];
	unsigned int ptr_card_2_host_data[4];


	/* EP specific changes for NWL DMA Rx descriptors */
	ps_pcie_dma_chann_desc_t *ptr_dma_chan_rx;
	ps_pcie_dma_desc_t *ptr_dma_rx;

	/* EP specific changes for NWL DMA Tx descriptors */
	ps_pcie_dma_chann_desc_t *ptr_dma_chan_tx;
	ps_pcie_dma_desc_t *ptr_dma_tx;

};



#define FRAG_SZ (42)
#define NUM_Q_ELEM (512)


#define PUMP_APP_DBG_PRNT
int free_num_q_elements = 0;
bool tx_channel[] = {true,false,false,false}; //All 4 channels pump data
//bool rx_channel[] = {false,false,false,false}; //None of the 4 channels rx data

unsigned int tx_channel_num_empty_bds[] = {NUM_Q_ELEM - 2,NUM_Q_ELEM - 2,NUM_Q_ELEM - 2,NUM_Q_ELEM - 2}; //NOTE::::We can fill (Q len - 1) BD elements in rx side at start of day

ps_pcie_dma_desc_t *ptr_txapp_dma_desc = NULL;
//struct timer_list data_pump_timer[PS_PCIE_NUM_DMA_CHANNELS];
ps_pcie_dma_chann_desc_t *ptr_chan_s2c[PS_PCIE_NUM_DMA_CHANNELS] = {0};
unsigned char *glb_buf[PS_PCIE_NUM_DMA_CHANNELS];

/*****************************************************************************/
/**
 * This function returns the DMA base address to the user driver
 *
 * In 10G support, the MAC address registers are not mapped to MAC address
 * space. The MAC address registers are mapped to the DMA address area.
 * Hence, the user driver should know the DMA base address, so that it can
 * access the MAC address registers to Set/Get MAC address.
 *
 * @param bar is the BAR register the user driver wants to use.
 *
 * @return DMABaseAddress
 *
 *****************************************************************************/
void * DmaBaseAddress(int bar)
{
	if((bar < 0) || (bar > 5)) {
		log_verbose(KERN_ERR "Requested BAR %d is not valid\n", bar);
		return NULL;
	}

	return (ptr_txapp_dma_desc->cntrl_func_virt_base_addr);
}

int DmaMac_WriteReg(int offset, int data)
{
	XIo_Out32( (ptr_txapp_dma_desc->cntrl_func_virt_base_addr) + offset, data );
	return 0;
}
int DmaMac_ReadReg(int offset)
{
	int data;
	data = XIo_In32( (ptr_txapp_dma_desc->cntrl_func_virt_base_addr) + offset );

	return data;
}


void cbk_data_pump(struct _ps_pcie_dma_chann_desc *ptr_chann, void *data, unsigned int compl_bytes,unsigned short uid, unsigned int num_frags)
{
	int retval=0;
	struct net_local *lp=netdev_priv(ndev);
	struct sk_buff *skb=(struct sk_buff*)data;
	struct sk_buff *new_skb;
	unsigned int nfrags;
	int ret=0; 
	if(ptr_chann->chann_state == XLNX_DMA_CHANN_SATURATED)
	{
		printk(KERN_ERR "DMA CHANN ERRR ***\n");
		ptr_chann->chann_state = XLNX_DMA_CHANN_NO_ERR;
	}

	if(ptr_chann->dir==OUT)
	{
		nfrags = skb_shinfo(skb)->nr_frags +1;
		free_num_q_elements = free_num_q_elements + nfrags;	
		if (skb)
			dev_kfree_skb(skb);
		//need to increment stats and counters.
		netif_wake_queue(lp->ndev);	
	}
	else
	{
		skb_put(skb, compl_bytes);	/* Tell the skb how much data we got. */
		skb->dev = ndev;

		/* this routine adjusts skb->data to skip the header */
		skb->protocol = eth_type_trans(skb, ndev);
		skb->ip_summed = CHECKSUM_NONE;
		ret=netif_rx(skb);	/* Send the packet upstream. */

		if(ret!=NET_RX_SUCCESS)
			printk(KERN_ERR " :: Rx Error \n");

		new_skb = alloc_skb(XGMAC_RX_BUF_SIZE, GFP_ATOMIC);
		if (new_skb == NULL) {
			printk("Alloc SKB failed for \n");    
		}
		else {
		
		retval = xlnx_data_frag_io(ptr_chann, new_skb->data, 

				VIRT_ADDR, 

				XGMAC_RX_BUF_SIZE,cbk_data_pump ,/*ptr_chann->num_pkts_io+*/1, true, /*OUT,*/ (void *)new_skb);

		if(retval < XLNX_SUCCESS)
		{
			printk(KERN_ERR"\n Context RX Q saturated \n");


		}
		} 

	}


}

static int xenet_send(struct sk_buff *skb, struct net_device *dev)
{
	int retval;
	struct net_local *lp;
	unsigned long flags;
	unsigned int nfrags;
	skb_frag_t *frag;
	void *virt_addr;
	unsigned int len;

	lp = netdev_priv(dev);
	//spin_lock_bh(&lp->ptr_dma_chan_tx->channel_lock);
	//	spin_lock(&lp->ptr_dma_chan_tx->channel_lock);
	spin_lock_irqsave(&lp->ptr_dma_chan_tx->channel_lock,flags);
	nfrags = skb_shinfo(skb)->nr_frags +1;
	if(nfrags > (free_num_q_elements - 1))
	{
		netif_stop_queue(dev);
		//		spin_unlock_bh(&lp->ptr_dma_chan_tx->channel_lock);
		spin_unlock_irqrestore(&lp->ptr_dma_chan_tx->channel_lock, flags);
		return NETDEV_TX_BUSY;
	}
	if(nfrags == 1)
	{
		//		spin_lock_bh(&lp->ptr_dma_chan_tx->channel_lock);
		retval = xlnx_data_frag_io(lp->ptr_dma_chan_tx, skb->data,  VIRT_ADDR, 
				skb->len,cbk_data_pump ,/*num_pkts+1*/1, true, /*OUT,*/(void *) skb);
		if(retval < XLNX_SUCCESS) 
		{
			printk(KERN_ERR"\n - Context Q saturated \n");
		}
		//			spin_unlock_bh(&lp->ptr_dma_chan_tx->channel_lock);

	}
	else 
	{
		int i=0; 

		//	 spin_lock_bh(&lp->ptr_dma_chan_tx->channel_lock);
		frag = &skb_shinfo(skb)->frags[0];
		for(i=0;i< nfrags;i++)
		{
			if(i == 0)
			{
				len=skb_headlen(skb);
#ifdef DEBUG_NORMAL
				printk(KERN_ERR"\n########################################\n");
				printk(KERN_ERR"Eth0 Frag %d Length %d Data %x %x %x %x %x %x %x %x ",i,len,skb->data[0],skb->data[1],skb->data[2],skb->data[3],skb->data[4],skb->data[5],skb->data[6],skb->data[7]);
				printk(KERN_ERR"\n########################################\n");
#endif			
				//		spin_lock_bh(&lp->ptr_dma_chan_tx->channel_lock);
				retval = xlnx_data_frag_io(lp->ptr_dma_chan_tx, skb->data,  VIRT_ADDR, 
						len,cbk_data_pump ,/*num_pkts+1*/1, false, /*OUT,*/(void *) skb);
				if(retval < XLNX_SUCCESS) 
				{
					printk(KERN_ERR"\n Context Q saturated Eth0\n");
				}
				//		spin_unlock_bh(&lp->ptr_dma_chan_tx->channel_lock);

			}

			else
			{
				len =  skb_frag_size(frag);

				virt_addr = skb_frag_address(frag);
#ifdef DEBUG_NORMAL
				printk(KERN_ERR"\n########################################\n");
				printk(KERN_ERR"Eth0 Frag %d Length %d Data %x %x %x %x %x %x %x %x ",i,len,*((int *)(virt_addr)),*((int *)(virt_addr)+ 1),*((int *)(virt_addr)+ 2),*((int *)(virt_addr)+ 3),*((int *)(virt_addr)+4),*((int *)(virt_addr)+5 ),*((int *)(virt_addr)+6),*((int *)(virt_addr)+7 ));
				printk(KERN_ERR"\n########################################\n");
#endif
				// spin_lock_bh(&lp->ptr_dma_chan_tx->channel_lock);

				if(i== nfrags-1)
				{
					retval = xlnx_data_frag_io(lp->ptr_dma_chan_tx, virt_addr,  VIRT_ADDR, len,cbk_data_pump ,/*num_pkts+1*/1, true, /*OUT,*/(void *) skb);
				}
				else
				{
					retval = xlnx_data_frag_io(lp->ptr_dma_chan_tx,  virt_addr,  VIRT_ADDR, len,cbk_data_pump ,/*num_pkts+1*/1, false, /*OUT,*/(void *) skb);
				}
				if(retval < XLNX_SUCCESS) 
				{
					printk(KERN_ERR"\n Context Q saturated Eth0\n");

				}
				//		spin_unlock_bh(&lp->ptr_dma_chan_tx->channel_lock);					   
				frag++	;				
			}

		}

		//	spin_unlock_bh(&lp->ptr_dma_chan_tx->channel_lock);					   


	}
	free_num_q_elements= free_num_q_elements - nfrags;


	//spin_unlock_bh(&lp->ptr_dma_chan_tx->channel_lock);					   
	//	spin_unlock(&lp->ptr_dma_chan_tx->channel_lock);					   

	spin_unlock_irqrestore(&lp->ptr_dma_chan_tx->channel_lock, flags);
	return 0;
}

#ifdef USE_LATER

int check_link_state(struct net_device *dev)
{
	struct net_local *lp;
	int link=0;


	lp = netdev_priv(dev);


	lp->ptr_host_2_card_data[0]= XLNX_SPAD_CMD_GET_LINK_STATE;
	lp->ptr_host_2_card_data[1]=XLNX_SPAD_CMD_GET_LINK_STATE;
	xlnx_do_scrtchpd_txn_from_host(lp->ptr_dma_chan_tx,&lp->ptr_host_2_card_data,4,&lp->ptr_card_2_host_data,4);
	link=lp->ptr_card_2_host_data[2];
	printk(KERN_ERR "Link %d ",link);

	return link; 

}



/*****************************************************************************/
/**
 * XXgEthernet_GetMacAddress gets the MAC address for the XGEMAC Ethernet,
 * specified by <i>InstancePtr</i> into the memory buffer specified by
 * <i>AddressPtr</i>.
 *
 * @param	InstancePtr is a pointer to the XGEMAC Ethernet instance to be
 *		worked on.
 * @param	AddressPtr references the memory buffer to store the retrieved
 *		MAC address. This memory buffer must be at least 6 bytes in
 *		length.
 *
 * @return	None.
 *
 * @note
 *
 * This routine also supports the extended/new VLAN and multicast mode. The
 * XXGE_RAF_NEWFNCENBL_MASK bit dictates which offset will be configured.
 *
 ******************************************************************************/
void XXgEthernet_GetMacAddress(XXgEthernet *InstancePtr, void *AddressPtr)
{
	u32 MacAddr;
	u8 *Aptr = (u8 *) AddressPtr;

	Xil_AssertVoid(InstancePtr != NULL);
	Xil_AssertVoid(AddressPtr != NULL);
	Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

	/* Read MAC bits [31:0] in UAW0 */
	MacAddr = DmaMac_ReadReg(XXGE_MACL_OFFSET);
	Aptr[0] = (u8) MacAddr;
	Aptr[1] = (u8) (MacAddr >> 8);
	Aptr[2] = (u8) (MacAddr >> 16);
	Aptr[3] = (u8) (MacAddr >> 24);

	/* Read MAC bits [47:32] in UAW1 */
	MacAddr = DmaMac_ReadReg(XXGE_MACU_OFFSET);
	Aptr[4] = (u8) MacAddr;
	Aptr[5] = (u8) (MacAddr >> 8);

	/* Read XGEMAC MAC bits [31:0] in XXGE_MACL_OFFSET */
	MacAddr = DmaMac_ReadReg(XXGE_MACL_OFFSET);
	Aptr[0] = (u8) MacAddr;
	Aptr[1] = (u8) (MacAddr >> 8);
	Aptr[2] = (u8) (MacAddr >> 16);
	Aptr[3] = (u8) (MacAddr >> 24);

	/* Read XGEMAC MAC bits [47:32] in XXGE_MACU_OFFSET */
	MacAddr = DmaMac_ReadReg(XXGE_MACU_OFFSET);
	Aptr[4] = (u8) MacAddr;
	Aptr[5] = (u8) (MacAddr >> 8);

}


#endif

/*@}*/

/** @name For protection exclusion of all program flows
 * Calls from upper layer, and calls from DMA driver, and timer handlers.
 * Wrap certain temac routines with a lock, so access to the shared hard temac
 * interface is accessed mutually exclusive for dual channel temac support.
 * @{
 */
spinlock_t XTE_spinlock;

/* Queues with locks */
LIST_HEAD(receivedQueue);
static spinlock_t receivedQueueSpin;

LIST_HEAD(sentQueue);
static spinlock_t sentQueueSpin;
/*@}*/


/***************** Macros (Inline Functions) Definitions *********************/

/** @name Inline functions for programming the TEMAC. The underscore version
 * holds the spinlock and then calls the non-underscore version.
 * @{
 */
static inline void _XXgEthernet_Start(XXgEthernet *InstancePtr)
{
	spin_lock_bh(&XTE_spinlock);
	XXgEthernet_Start(InstancePtr);
	spin_unlock_bh(&XTE_spinlock);
}

static inline void _XXgEthernet_Stop(XXgEthernet *InstancePtr)
{
	spin_lock_bh(&XTE_spinlock);
	XXgEthernet_Stop(InstancePtr);
	spin_unlock_bh(&XTE_spinlock);
}

static inline void _XXgEthernet_Reset(XXgEthernet *InstancePtr)
{
	spin_lock_bh(&XTE_spinlock);
	XXgEthernet_Reset(InstancePtr);
	spin_unlock_bh(&XTE_spinlock);
}

static inline int _XXgEthernet_SetMacAddress(XXgEthernet *InstancePtr,
		void *AddressPtr)
{
	int status;

	spin_lock_bh(&XTE_spinlock);
	status = XXgEthernet_SetMacAddress(InstancePtr, AddressPtr);
	spin_unlock_bh(&XTE_spinlock);

	return	status;
}

static inline void _XXgEthernet_GetMacAddress(XXgEthernet *InstancePtr,
		void *AddressPtr)
{
	spin_lock_bh(&XTE_spinlock);
	XXgEthernet_GetMacAddress(InstancePtr, AddressPtr);
	spin_unlock_bh(&XTE_spinlock);
}

static inline int _XXgEthernet_SetOptions(XXgEthernet *InstancePtr, u32 Options)
{
	int status;

	spin_lock_bh(&XTE_spinlock);
	status = XXgEthernet_SetOptions(InstancePtr, Options);
	spin_unlock_bh(&XTE_spinlock);

	return status;
}

static inline int _XXgEthernet_ClearOptions(XXgEthernet *InstancePtr, u32 Options)
{
	int status;

	spin_lock_bh(&XTE_spinlock);
	status = XXgEthernet_ClearOptions(InstancePtr, Options);
	spin_unlock_bh(&XTE_spinlock);

	return status;
}

static inline void _XXgEthernet_PhyRead(XXgEthernet *InstancePtr, u32 PhyAddress,
		u32 RegisterNum, u16 *PhyDataPtr)
{
	spin_lock_bh(&XTE_spinlock);
	XXgEthernet_PhyRead(InstancePtr, PhyAddress, RegisterNum, PhyDataPtr);
	spin_unlock_bh(&XTE_spinlock);
}

static inline void _XXgEthernet_PhyWrite(XXgEthernet *InstancePtr, u32 PhyAddress,
		u32 RegisterNum, u16 PhyData)
{
	spin_lock_bh(&XTE_spinlock);
	XXgEthernet_PhyWrite(InstancePtr, PhyAddress, RegisterNum, PhyData);
	spin_unlock_bh(&XTE_spinlock);
}

#ifdef	MDIO_CHANGES
/*
 * The PHY registers read here should be standard registers in all PHY chips
 */
static int get_phy_status(struct net_device *dev, DUPLEX * duplex, int *linkup)
{
#if LINUX_VERSION_CODE >= KERNEL_VERSION(2, 6, 28)
	struct net_local *lp = netdev_priv(dev);
#else	
	struct net_local *lp = (struct net_local *) dev->priv;	
#endif	

	u16 reg;

	*duplex = FULL_DUPLEX;

	_XXgEthernet_PhyRead(&lp->Emac, lp->xgmii_addr, XXGE_MDIO_REGISTER_ADDRESS, &reg);
#ifdef MDIO_CHANGES
	*linkup = reg & XXGE_MDIO_PHY_LINK_UP_MASK;
#else
	//	 Forced this to 1 when there is no PHY
	*linkup = 1;
#endif

	return 0;
}
#endif

/*
 * This routine is used for two purposes.  The first is to keep the
 * EMAC's duplex setting in sync with the PHY's.  The second is to keep
 * the system appraised of the state of the link.  Note that this driver
 * does not configure the PHY.  Either the PHY should be configured for
 * auto-negotiation or it should be handled by something like mii-tool. */
static void poll_gmii(unsigned long data)
{
#ifdef	MDIO_CHANGES
	struct net_device *dev;
	struct net_local *lp;
	DUPLEX phy_duplex;
	int phy_carrier;
	int netif_carrier;

	dev = (struct net_device *) data;

#if LINUX_VERSION_CODE >= KERNEL_VERSION(2, 6, 28) 
	lp = netdev_priv(dev);
#else	
	lp = (struct net_local *) dev->priv;	
#endif	



	/* First, find out what's going on with the PHY. */
	log_verbose(KERN_ERR "poll_gmii\n");
	if (get_phy_status(dev, &phy_duplex, &phy_carrier)) {
		log_normal(KERN_ERR "%s: XXgEthernet: terminating link monitoring.\n",
				dev->name);
		return;
	}
	netif_carrier = netif_carrier_ok(dev) != 0;
	if (phy_carrier != netif_carrier) {
		if (phy_carrier) {
			log_normal(KERN_INFO
					"%s: XXgEthernet: PHY Link carrier restored.\n",
					dev->name);
			netif_carrier_on(dev);
			/*!!            set_mac_speed(lp);	*/
		}
		else {
			log_normal(KERN_INFO "%s: XXgEthernet: PHY Link carrier lost.\n",
					dev->name);
			netif_carrier_off(dev);
		}
	}

	/* Set up the timer so we'll get called again in 2 seconds. */
	lp->phy_timer.expires = jiffies + 2 * HZ;
	add_timer(&lp->phy_timer);
#endif
}


/* Gets called when ifconfig opens the interface */
static int xenet_open(struct net_device *dev)
{
	struct net_local *lp;
	u32 Options;
	printk(KERN_INFO "calling xenet_open\n");

	/*
	 * Just to be safe, stop TX queue and the device first.  If the device is
	 * already stopped, an error will be returned.  In this case, we don't
	 * really care.
	 */
	netif_stop_queue(dev);
	lp = netdev_priv(dev);


	//Intialize MAC here 
	_XXgEthernet_Stop(&lp->Emac);
	/* Set the MAC address each time opened. */
	if (_XXgEthernet_SetMacAddress(&lp->Emac, dev->dev_addr) != XST_SUCCESS) {
		printk(KERN_ERR "%s: xgbeth_axi: could not set MAC address.\n",
				dev->name);
		return -EIO;
	}

	/*
	 * If the device is not configured for polled mode, connect to the
	 * interrupt controller and enable interrupts.	Currently, there
	 * isn't any code to set polled mode, so this check is probably
	 * superfluous.
	 */
	Options = XXgEthernet_GetOptions(&lp->Emac);
	Options |= XXGE_FLOW_CONTROL_OPTION;
#ifdef ENABLE_JUMBO    
	Options |= XXGE_JUMBO_OPTION;
#endif    
	Options |= XXGE_TRANSMITTER_ENABLE_OPTION;
	Options |= XXGE_RECEIVER_ENABLE_OPTION;
	//#if XXGE_AUTOSTRIPPING
	//	Options |= XXGE_FCS_STRIP_OPTION;
	//#endif

	(int) _XXgEthernet_SetOptions(&lp->Emac, Options);
	Options = XXgEthernet_GetOptions(&lp->Emac);
	log_normal(KERN_INFO "%s: XXgEthernet: Options: 0x%x\n", dev->name, Options);
	/* give the system enough time to establish a link */
	mdelay(2000);

	/* Start TEMAC device */
	_XXgEthernet_Start(&lp->Emac);

	/* We're ready to go. */
	netif_start_queue(dev);
	/* Set up the PHY monitoring timer. */
	lp->phy_timer.expires = jiffies + 2 * HZ;
	lp->phy_timer.data = (unsigned long) dev;
	lp->phy_timer.function = &poll_gmii;
	init_timer(&lp->phy_timer);
	add_timer(&lp->phy_timer);

	INIT_LIST_HEAD(&sentQueue);
	INIT_LIST_HEAD(&receivedQueue);

	spin_lock_init(&sentQueueSpin);
	spin_lock_init(&receivedQueueSpin);


	return 0;
}

static int xenet_close(struct net_device *dev)
{
	struct net_local *lp;

	printk(KERN_INFO "xenet_close:\n");

#if LINUX_VERSION_CODE >= KERNEL_VERSION(2, 6, 28)
	lp = netdev_priv(dev);
#else
	lp = (struct net_local *) dev->priv;	
#endif	

	/* Shut down the PHY monitoring timer. */
	del_timer_sync(&lp->phy_timer);
	/* Stop Send queue */
	//   netif_carrier_off(dev); 
	netif_stop_queue(dev);
	/* Now we could stop the device */
	_XXgEthernet_Stop(&lp->Emac);

	return 0;
}

static int xenet_change_mtu(struct net_device *dev, int new_mtu)
{
	//	u32 SetMtu=0; 
#ifdef CONFIG_XILINX_GIGE_VLAN
	int head_size = XXGE_HDR_VLAN_SIZE;
#else
	int head_size = XXGE_HDR_SIZE;
#endif

#if LINUX_VERSION_CODE >= KERNEL_VERSION(2, 6, 28)
	struct net_local *lp = netdev_priv(dev);
#else			
	struct net_local *lp = (struct net_local *) dev->priv;	
#endif	


	int max_frame = new_mtu + head_size + XXGE_TRL_SIZE;
	int min_frame = 1 + head_size + XXGE_TRL_SIZE;

	log_verbose(KERN_INFO "xenet_change_mtu:\n");

	if ((max_frame < min_frame) || (max_frame > lp->max_frame_size))
		return -EINVAL;

	dev->mtu = new_mtu;	/* change mtu in net_device structure */
	//- XGEMAC provides MTU configuration registers but Jumbo bit takes precendence over them
	//    SetMtu = lp->max_frame_size;
	//    SetMtu = SetMtu | XXGE_RMTU_FI_MASK ;

	//    XXgEthernet_WriteReg((lp->Emac.Config.BaseAddress),XXGE_TMTU_OFFSET, SetMtu);
	//    XXgEthernet_WriteReg((lp->Emac.Config.BaseAddress),XXGE_RMTU_OFFSET, SetMtu);

	return 0;
}

static int xenet_set_mac_address(struct net_device *dev, void * ptr)
{

#if LINUX_VERSION_CODE >= KERNEL_VERSION(2, 6, 28)
	struct net_local *lp = netdev_priv(dev);
#else		
	struct net_local *lp = (struct net_local *) dev->priv;	
#endif	

	struct sockaddr *addr = ptr;

	if (netif_running(dev))
	{
		log_normal(KERN_INFO "set_mac_address: Interface should be down\n");
		return -EBUSY;
	}

	if (!is_valid_ether_addr(addr->sa_data))
	{
		log_normal(KERN_INFO "set_mac_address: Invalid Ethernet address\n");
		return -EADDRNOTAVAIL;
	}

	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);

#ifdef DEBUG_VERBOSE
	{
		int i;
		log_verbose(KERN_INFO "Setting MAC address: ");
		for(i=0; i<6; i++)
			printk("%x ", dev->dev_addr[i]);
		printk("\n");
	}
#endif

	if (_XXgEthernet_SetMacAddress(&lp->Emac, dev->dev_addr) != XST_SUCCESS) {
		printk(KERN_ERR "xgbeth_axi: could not set MAC address.\n");
		return -EIO;
	}

	return 0;
}


static void xenet_set_netdev_ops(struct net_device *ndev, struct net_device_ops *ndops)
{
	ndops->ndo_open = xenet_open;
	ndops->ndo_stop = xenet_close;
	ndops->ndo_start_xmit = xenet_send;
	ndops->ndo_set_mac_address = xenet_set_mac_address;
	//    ndops->ndo_do_ioctl = xenet_ioctl;
	ndops->ndo_change_mtu = xenet_change_mtu;
	//    ndops->ndo_tx_timeout = xenet_tx_timeout;
	//    ndops->ndo_get_stats = xenet_get_stats;
	ndev->netdev_ops = ndops;
}

static int xgmac_nwl_rx_init(struct net_device  *ndev)
{
	int retval = 0;
	unsigned int q_num_elements = NUM_Q_ELEM;
	unsigned int data_q_addr_hi;
	unsigned int data_q_addr_lo;
	unsigned int sta_q_addr_hi;
	unsigned int sta_q_addr_lo;
	struct net_local  *lp;
	struct sk_buff *skb;
	int i=0;

	platform_t pfrom = HOST;


	lp=netdev_priv(ndev);
	lp->ptr_dma_rx =  xlnx_get_pform_dma_desc((void*)NULL, 0, 0);

	retval = xlnx_get_dma((void*)lp->ptr_dma_rx->device , pfrom, &lp->ptr_dma_rx);
	if(!lp->ptr_dma_rx) 
	{
		printk(KERN_ERR"\n Could not get valid dma descriptor %d\n", retval);
		goto error;
	}


	retval = xlnx_get_dma_channel(lp->ptr_dma_rx, XGMAC_RX_CHANNID, 
			IN, &lp->ptr_dma_chan_rx,NULL);
	if(retval < XLNX_SUCCESS) 
	{
		printk(KERN_ERR"\n - Could not get s2c error %d\n", retval);
		goto channel_ack_failed;
	}

	retval = xlnx_alloc_queues(lp->ptr_dma_chan_rx, &data_q_addr_hi, //Physical address
			&data_q_addr_lo,//Physical address
			&sta_q_addr_hi,//Physical address
			&sta_q_addr_lo,//Physical address
			q_num_elements);
	if(retval < XLNX_SUCCESS) 
	{
		printk(KERN_ERR"\n - Could not allocate Qs for s2c  %d\n", retval);
		goto channel_q_alloc0_failed;
	}


	retval = xlnx_activate_dma_channel(lp->ptr_dma_rx, lp->ptr_dma_chan_rx,
			data_q_addr_hi,data_q_addr_lo,q_num_elements,
			sta_q_addr_hi,sta_q_addr_lo,q_num_elements, 0);
	if(retval < XLNX_SUCCESS) 
	{
		printk(KERN_ERR"\n - Could not activate s2c  %d\n",retval);
		goto channel_act_failed;
	}


	spin_lock_bh(&lp->ptr_dma_chan_rx->channel_lock);

	for(i=0;i< NUM_Q_ELEM -2 ;i++)
	{
		skb = alloc_skb(XGMAC_RX_BUF_SIZE, GFP_ATOMIC);
		if (skb == NULL) {
			printk("Alloc SKB failed \n");    
			goto error;
		}		
		retval = xlnx_data_frag_io(lp->ptr_dma_chan_rx, skb->data,  VIRT_ADDR, 
				XGMAC_RX_BUF_SIZE,cbk_data_pump ,/*num_pkts+1*/1, true, /*OUT,*/(void *) skb);
		if(retval < XLNX_SUCCESS) 
		{
			if(lp->ptr_dma_chan_rx->chann_state == XLNX_DMA_CNTXTQ_SATURATED || lp->ptr_dma_chan_rx->chann_state == XLNX_DMA_CHANN_SATURATED) 
			{
				printk(KERN_ERR"\n --> Rx BDs saturated \n");

			}

		}
	}		
	spin_unlock_bh(&lp->ptr_dma_chan_rx->channel_lock);

	printk(KERN_ERR"\n --> Module Host pump on all 4 channels loaded %d", retval);
	return 0;
error:
channel_ack_failed:
channel_act_failed:
channel_q_alloc0_failed:


	printk(KERN_ERR"--> Error channels not activated %d!!", retval);
	return -1;
}



static int xgmac_nwl_tx_init(struct net_device *ndev)
{
	int retval=0;
	unsigned int q_num_elements = NUM_Q_ELEM;
	unsigned int data_q_addr_hi;
	unsigned int data_q_addr_lo;
	unsigned int sta_q_addr_hi;
	unsigned int sta_q_addr_lo;
	struct net_local *lp;

#ifdef XILINX_PCIE_EP
	platform_t pfrom = EP;
#else
	platform_t pfrom = HOST;
#endif		 

	lp=netdev_priv(ndev);
	/* Registerging DMA */

	lp->ptr_dma_tx = xlnx_get_pform_dma_desc((void*)NULL, 0, 0);
	ptr_txapp_dma_desc = xlnx_get_pform_dma_desc((void*)NULL, 0, 0); 

	retval = xlnx_get_dma((void*)lp->ptr_dma_tx->device , pfrom, &lp->ptr_dma_tx);
	if(!lp->ptr_dma_tx) 
	{
		printk(KERN_ERR"\n - Could not get valid dma descriptor %d\n", retval);
		goto error;
	}

	retval = xlnx_get_dma_channel(lp->ptr_dma_tx, XGMAC_TX_CHANNID, 
			OUT, &lp->ptr_dma_chan_tx,NULL);
	if(retval < XLNX_SUCCESS) 
	{
		printk(KERN_ERR"\n - Could not get s2c tx channel error %d\n",retval);
		goto channel_ack_failed;
	}

	retval = xlnx_alloc_queues(lp->ptr_dma_chan_tx, &data_q_addr_hi, //Physical address
			&data_q_addr_lo,//Physical address
			&sta_q_addr_hi,//Physical address
			&sta_q_addr_lo,//Physical address
			q_num_elements);
	if(retval < XLNX_SUCCESS) 
	{
		printk(KERN_ERR"\n Could not allocate Qs for s2c Tx channel %d\n", retval);
		goto channel_q_alloc0_failed;
	}


	retval = xlnx_activate_dma_channel(lp->ptr_dma_tx, lp->ptr_dma_chan_tx,
			data_q_addr_hi,data_q_addr_lo,q_num_elements,
			sta_q_addr_hi,sta_q_addr_lo,q_num_elements, 0);
	if(retval < XLNX_SUCCESS) 
	{
		printk(KERN_ERR"\n - Could not activate s2c Tx channel %d\n", retval);
		goto channel_act_failed;
	}


	//xlnx_register_doorbell_cbk(lp->ptr_dma_tx,cbk_scratch_pad);


	free_num_q_elements = NUM_Q_ELEM ; 	
	printk(KERN_ERR"\n--> Module Host pump on all 4 channels loaded %d", retval);
	return 0;
error:
channel_ack_failed:
channel_act_failed:
channel_q_alloc0_failed:


	printk(KERN_ERR" --> Error channels not activated %d!!", retval);
	return -1;
}

#ifdef USE_LATER
void xenet_getmacaddr(struct net_device *ndev )
{

	struct net_local *lp=NULL;

	lp=netdev_priv(ndev);

	lp->ptr_host_2_card_data[0]= XLNX_SPAD_CMD_GET_MAC;
	lp->ptr_host_2_card_data[1]=XLNX_SPAD_CMD_GET_MAC;

	printk(KERN_ERR"\n --> Get mac\n");
	xlnx_do_scrtchpd_txn_from_host(lp->ptr_dma_chan_tx,&lp->ptr_host_2_card_data,4,&lp->ptr_card_2_host_data,4);
	printk(KERN_ERR"\n--> Got mac response\n");

	printk(KERN_ERR "Mac Addr  %x %x  ",lp->ptr_host_2_card_data[2],lp->ptr_card_2_host_data[3]);




}
#endif


int xgenet_init(void)
{
	int retval = 0;
	struct net_local *lp = NULL;
	u8 mac_addr[6];
	int rc=0;

	XXgEthernet_Config Temac_Config;

	u64 net_path_vbaseaddr;


	/*
	 * Make sure the locks are initialized
	 */
	spin_lock_init(&XTE_spinlock);


	/*
	 * No kernel boot options used,
	 * so we just need to register the driver
	 */
	printk(KERN_INFO "Inserting Xilinx GigE driver in kernel.\n");

	ndev = alloc_etherdev(sizeof(struct net_local));
	if (!ndev) {
		printk(KERN_ERR "xgbeth_axi: Could not allocate net device.\n");
		retval= -ENOMEM;
		return retval;
	}

	/* Initialize the private data used by XEmac_LookupConfig().
	 * The private data are zeroed out by alloc_etherdev() already.
	 */

	lp = netdev_priv(ndev);

	lp->ndev = ndev;
	//   lp->deferred_skb = NULL;



	//Rx Channel Initilization 
	xgmac_nwl_rx_init(ndev);
	//Tx Channel intilization
	xgmac_nwl_tx_init(ndev);
	net_path_vbaseaddr = (ptr_txapp_dma_desc->cntrl_func_virt_base_addr) + NW_PATH0_OFFSET;

	/* Setup the Config structure for the XXgEthernet_CfgInitialize() call. */
	Temac_Config.BaseAddress =  net_path_vbaseaddr;
#ifdef X86_64
	if (XXgEthernet_CfgInitialize(&lp->Emac, &Temac_Config,  net_path_vbaseaddr) != XST_SUCCESS) 
	{
#else
		if (XXgEthernet_CfgInitialize(&lp->Emac, &Temac_Config, (u32)  net_path_vbaseaddr) != XST_SUCCESS) 
		{
#endif	
			printk(KERN_ERR "xgbeth_axi: Could not initialize device.\n");
			goto error;
		}

	/* Default MAC address assignment */
	mac_addr[0]=0xAA;
	mac_addr[1]=0xBB;
	mac_addr[2]=0xCC;
	mac_addr[3]=0xDD;
	mac_addr[4]=0xEE;
	mac_addr[5]=0xFF;
#ifdef USE_NW_PATH0
	mac_addr[1]=0xBB;
#else
	mac_addr[1]=0x00;
#endif

	if (_XXgEthernet_SetMacAddress(&lp->Emac, mac_addr) != XST_SUCCESS) {
		printk(KERN_ERR "Could not set MAC address.\n");
		goto error;
	}

#ifdef DEBUG_NORMAL
		printk("**Set the MAC adress in init_bottom**\n");
#endif

		_XXgEthernet_GetMacAddress(&lp->Emac,ndev->dev_addr);

		printk("addr_len is %d, perm_addr[0] is %x, [1] = %x, [2] = %x, [3] = %x, perm_addr[4] is %x, [5] = %x\n", 
				ndev->addr_len, ndev->dev_addr[0], ndev->dev_addr[1], ndev->dev_addr[2],
				ndev->dev_addr[3], ndev->dev_addr[4], ndev->dev_addr[5]);


#ifdef ENABLE_JUMBO    
		lp->max_frame_size = XXGE_MAX_JUMBO_FRAME_SIZE;
#else
		lp->max_frame_size = 1600;
#endif
		log_verbose(KERN_INFO "MTU size is %d\n", ndev->mtu);
		if (ndev->mtu > XXGE_JUMBO_MTU)
			ndev->mtu = XXGE_JUMBO_MTU;
		log_verbose(KERN_INFO "MTU size is %d\n", ndev->mtu);


		/** Scan to find the PHY */
		lp->xgmii_addr = XXGE_PHY_ADDRESS;
		log_verbose("xgmii_addr is %x\n", lp->xgmii_addr);



		xenet_set_netdev_ops(ndev, &xenet_netdev_ops);
		ndev->flags &= ~IFF_MULTICAST;
		ndev->features = NETIF_F_SG | NETIF_F_FRAGLIST;

		rc = register_netdev(ndev);
		if (rc) {
			printk(KERN_ERR
					"%s: Cannot register net device, aborting.\n", ndev->name);
			goto error; /* rc is already set here... */
		}




		return retval;



error:
		if (ndev) {
			free_netdev(ndev);
		}
		return -1;
	}

static void xgenet_cleanup(void)
{
		//Deregister Dma channels here 
		struct net_local *lp;
#if LINUX_VERSION_CODE >= KERNEL_VERSION(2, 6, 28)
		lp = netdev_priv(ndev);
#else
		lp = (struct net_local *) ndev->priv;	
#endif	



		//Tx cHannel
		/* Stop the IOs over channel */
		xlnx_deactivate_dma_channel(lp->ptr_dma_chan_tx);
		//xlnx_stop_channel_IO(ptr_chan_s2c, true);
		xlnx_dealloc_queues(lp->ptr_dma_chan_tx);
		//TxAux Channel
		//	xlnx_deactivate_dma_channel(ptr_Auxchan_s2c);
		//	xlnx_stop_channel_IO(ptr_TxAuxapp_dma_desc, true);
		//	xlnx_dealloc_queues(ptr_Auxchan_s2c);

		//Rx Channel

		xlnx_deactivate_dma_channel(lp->ptr_dma_chan_rx);
		//	xlnx_stop_channel_IO(ptr_rxapp_dma_desc, true);
		xlnx_dealloc_queues(lp->ptr_dma_chan_rx);

		//Rx Aux Channel	
		//	xlnx_deactivate_dma_channel(ptr_rxauxchan_s2c);
		//	xlnx_stop_channel_IO(ptr_rxauxapp_dma_desc, true);
		//	xlnx_dealloc_queues(ptr_rxauxchan_s2c);
		//



		unregister_netdev(ndev);
		if(ndev != NULL)
			free_netdev(ndev);

	}


	module_init(xgenet_init);
	module_exit(xgenet_cleanup);

	MODULE_AUTHOR("Xilinx, Inc.");
	MODULE_DESCRIPTION(DRIVER_DESCRIPTION);
	MODULE_LICENSE("GPL");
	MODULE_VERSION(DRIVER_VERSION);



