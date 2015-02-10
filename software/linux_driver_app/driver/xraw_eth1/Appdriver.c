#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/delay.h>
#include <linux/interrupt.h>
#include <linux/slab.h>
#include <linux/timer.h>
#include <linux/sched.h>
#include <linux/pagemap.h>	
#include <linux/slab.h>
#include <linux/kthread.h>
#include <linux/dma-mapping.h>
#include <linux/cdev.h>



#include "../xdma/ps_pcie_dma_driver.h"
#include "../xdma/ps_pcie_pf.h"
#include "../include/xpmon_be.h"





#define MYNAME   "Raw Data 1"
#define DEV_NAME  "xraw_data1"



#define WRITE_TO_CARD   0	
#define READ_FROM_CARD  1


#define QSUCCESS 0
#define QFAILURE -1
#define FRAG_SZ PKT_SZ 
#define MAX_BUFF_INFO 16384
#define NUM_Q_ELEM (2048 * 4)
#define PKT_SOP 0x0001
#define PKT_EOP 0x0002

#define TX_CHANNEL 2
#define RX_CHANNEL 3



#define GEN_CHK_BUF_ADDR GC_BUFF_ADDR 
#if 1   // Raw Ethernet mode
#define XXGE_RCW0_OFFSET	0x00000400 /**< Rx Configuration Word 0 */
#define XXGE_RCW1_OFFSET	0x00000404 /**< Rx Configuration Word 1 */
#define XXGE_TC_OFFSET		0x00000408 /**< Tx Configuration 	*/
#endif


unsigned int tx_channel_num_empty_bds[] = {NUM_Q_ELEM - 2,NUM_Q_ELEM - 2,NUM_Q_ELEM - 2,NUM_Q_ELEM - 2}; //NOTE::::We can fill (Q len - 1) BD elements in rx side at start of day
unsigned int tx_auxchannel_num_empty_bds[] = {NUM_Q_ELEM - 2,NUM_Q_ELEM - 2,NUM_Q_ELEM - 2,NUM_Q_ELEM - 2}; //NOTE::::We can fill (Q len - 1) BD elements in rx side at start of day

unsigned int rx_channel_num_empty_bds = NUM_Q_ELEM - 2; //NOTE::::We can fill (Q len - 1) BD elements in rx side at start of day
unsigned int rx_auxchannel_num_empty_bds[] = {NUM_Q_ELEM - 2,NUM_Q_ELEM - 2,NUM_Q_ELEM - 2,NUM_Q_ELEM - 2}; //NOTE::::We can fill (Q len - 1) BD elements in rx side at start of day


ps_pcie_dma_desc_t *ptr_txapp_dma_desc = NULL;
ps_pcie_dma_desc_t *ptr_TxAuxapp_dma_desc = NULL;


//struct timer_list data_pump_timer[PS_PCIE_NUM_DMA_CHANNELS];
ps_pcie_dma_chann_desc_t *ptr_chan_s2c = NULL;
ps_pcie_dma_chann_desc_t *ptr_Auxchan_s2c = NULL;

unsigned char *glb_buf[PS_PCIE_NUM_DMA_CHANNELS];
addr_type_t addr_typ_pmp[PS_PCIE_NUM_DMA_CHANNELS];




ps_pcie_dma_desc_t *ptr_rxapp_dma_desc = NULL;
ps_pcie_dma_desc_t *ptr_rxauxapp_dma_desc = NULL;

//struct timer_list data_pump_timer[PS_PCIE_NUM_DMA_CHANNELS];
ps_pcie_dma_chann_desc_t *ptr_rxchan_s2c = NULL;
ps_pcie_dma_chann_desc_t *ptr_rxauxchan_s2c = NULL;

unsigned char *gbl_buf[PS_PCIE_NUM_DMA_CHANNELS];
addr_type_t addr_typ_rx[PS_PCIE_NUM_DMA_CHANNELS];




struct cdev *xrawCdev=NULL;
int xraw_UserOpen = 0;





unsigned int  RawTestMode = TEST_STOP;
unsigned int RawMinPktSize = 0x40;
unsigned int RawMaxPktSize = 0x4000;



typedef struct BufferInfoQ
{
	spinlock_t iLock;		           /** < will be init to unlock by default  */
	BufferInfo iList[MAX_BUFF_INFO]; /** < Buffer Queue implimented in driver for storing incoming Pkts */
	unsigned int iPutIndex;          /** < Index to put the packets in Queue */
	unsigned int iGetIndex;          /** < Index to get the packets in Queue */ 
	unsigned int iPendingDone;       /** < Indicates number of packets to read */  
} BufferInfoQue;

BufferInfoQue TxDoneQ;		// assuming everything to be initialized to 0 as these are global
BufferInfoQue RxDoneQ;		// assuming everything to be initialized to 0 as these are global


typedef struct {
	unsigned char * pktBuf;     /**< Virtual Address of packet buffer */
	unsigned char * bufInfo;    /**< Per-packet identifier */
	unsigned int size;          /**< Size of packet buffer */
	unsigned int flags;         /**< Flags associated with packet */
	unsigned long long userInfo;/**< User info associated with packet */ 
	unsigned char * pageAddr;   /**< User page address associated with buffer */
	unsigned int pageOffset;    /**< User Page offset associated with page address */
	unsigned int numberFrags; 	/**< Number of Frags */
	dma_addr_t bufPA;	
} PktBuf;



// routines use for queue manipulation.
/* 
   putBuffInfo is used for adding an buffer element to the queue.
   it updates the queue parameters (by holding QUpdateLock).

Returns: 0 for success / -1 for failure 

*/

int putBuffInfo (BufferInfoQue * bQue, BufferInfo buff);

/* 
   getBuffInfo is used for fetching the oldest buffer info from the queue.
   it updates the queue parameters (by holding QUpdateLock).

Returns: 0 for success / -1 for failure 

*/
int getBuffInfo (BufferInfoQue * bQue, BufferInfo * buff);






PktBuf ** Dqueue=NULL;
PktBuf ** Rxqueue=NULL;


unsigned int WriteIndex;
unsigned int ReadIndex;

unsigned int RxWriteIndex;
unsigned int RxReadIndex;



/* 
   putBuffInfo is used for adding an buffer element to the queue.
   it updates the queue parameters (by holding QUpdateLock).

Returns: 0 for success / -1 for failure 

*/

	int
putBuffInfo (BufferInfoQue * bQue, BufferInfo buff)
{

	// assert (bQue != NULL)

	int currentIndex = 0;
	spin_lock_bh (&(bQue->iLock));

	currentIndex = (bQue->iPutIndex + 1) % MAX_BUFF_INFO;

	if (currentIndex == bQue->iGetIndex)
	{
		spin_unlock_bh (&(bQue->iLock));
		//   printk (KERN_ERR "%s: BufferInfo Q is FULL in %s , drop the incoming buffers",
		//	      __func__,__FILE__);
		return QFAILURE;		// array full
	}

	bQue->iPutIndex = currentIndex;

	bQue->iList[bQue->iPutIndex] = buff;
	bQue->iPendingDone++;
#ifdef BACK_PRESSURE
	if(bQue == &RxDoneQ)
	{
		if((impl_bp == NO_BP)&& ( bQue->iPendingDone > MAX_QUEUE_THRESHOLD))
		{
			impl_bp = YES_BP;
			//			printk(KERN_ERR "XXXXXX Maximum Queue Threshold reached.Turning on BACK PRESSURE XRAW0 %d  \n",bQue->iPendingDone);
		} 
	}
#endif  
	spin_unlock_bh (&(bQue->iLock));
	return QSUCCESS;
}

/* 
   getBuffInfo is used for fetching the oldest buffer info from the queue.
   it updates the queue parameters (by holding QUpdateLock).

Returns: 0 for success / -1 for failure 

*/
	int
getBuffInfo (BufferInfoQue * bQue, BufferInfo * buff)
{
	// assert if bQue is NULL
	if (!buff || !bQue)
	{
		printk (KERN_ERR "%s: BAD BufferInfo pointer", __func__);
		return QFAILURE;
	}

	spin_lock_bh (&(bQue->iLock));

	// assuming we get the right buffer
	if (!bQue->iPendingDone)
	{
		spin_unlock_bh (&(bQue->iLock));
		//    printk(KERN_ERR "%s: BufferInfo Q is Empty",__func__);
		return QFAILURE;
	}

	bQue->iGetIndex++;
	bQue->iGetIndex %= MAX_BUFF_INFO;
	*buff = bQue->iList[bQue->iGetIndex];
	bQue->iPendingDone--;
#ifdef BACK_PRESSURE
	if(bQue == &RxDoneQ) 
	{
		if((impl_bp == YES_BP) && (bQue->iPendingDone < MIN_QUEUE_THRESHOLD))
		{
			impl_bp = NO_BP;
			//		printk(KERN_ERR "XXXXXXX Minimum Queue Threshold reached.Turning off Back Pressure at %d %s\n",__LINE__,__FILE__);
		}
	}
#endif
	spin_unlock_bh (&(bQue->iLock));

	return QSUCCESS;

}




void cbk_data_pump(struct _ps_pcie_dma_chann_desc *ptr_chann, void *data, unsigned int compl_bytes,unsigned short uid, unsigned int num_frags)
{
	//struct task_struct* task = (struct task_struct*)data;
	PktBuf * pbuf;
	int i=0;
	unsigned int flags;
	static int pktSize;
	unsigned char *usrAddr = NULL;
	BufferInfo tempBuffInfo;


#if 0
	if(ptr_chann->chann_state == XLNX_DMA_CNTXTQ_SATURATED || ptr_chann->chann_state == XLNX_DMA_CHANN_SATURATED)
	{
		/* Make the channel state as 'no error' */
		ptr_chann->chann_state = XLNX_DMA_CHANN_NO_ERR;

		/* Make task running */
		//set_task_state(task, TASK_RUNNING);
#ifdef PUMP_APP_DBG_PRNT
		printk(KERN_ERR"\n --> Thread woekn up\n");
#endif
		//schedule();
		wake_up_process(task);
	}
	else
	{
		wake_up_process(task);
	}
#else
	int retval;
	unsigned int burst_fill = PKT_YIELD_CNT_PER_CHANN;
	if(ptr_chann->chann_state == XLNX_DMA_CNTXTQ_SATURATED || ptr_chann->chann_state == XLNX_DMA_CHANN_SATURATED)
	{
		/* Make the channel state as 'no error' */
		ptr_chann->chann_state = XLNX_DMA_CHANN_NO_ERR;
	}
	if(ptr_chann->dir == OUT )
	{
		for(i=0; i< num_frags; i++)
		{
			pbuf = Dqueue[ReadIndex];
			flags = pbuf->flags;
			dma_unmap_page(ptr_chann->ptr_dma_desc->dev,pbuf->pktBuf,pbuf->size,DMA_TO_DEVICE);
			if(pbuf->pageAddr)
				page_cache_release( (struct page *)pbuf->pageAddr);

			pktSize = pktSize + pbuf->size;

			if (flags & PKT_SOP)
			{
				usrAddr = pbuf->bufInfo;
				pktSize = pbuf->size;
			}

			if (flags & PKT_EOP)
			{
				tempBuffInfo.bufferAddress = usrAddr;
				tempBuffInfo.buffSize = pktSize;
				putBuffInfo (&TxDoneQ, tempBuffInfo);
				pktSize = 0;
				usrAddr = NULL;
			}

			ReadIndex++;
			if(ReadIndex >=NUM_Q_ELEM)
				ReadIndex=0;

			tx_channel_num_empty_bds[ptr_chann->chann_id]++;


		}

	}


#if 0

fill_another:
	//printk(KERN_ERR"\n --> CBK Tx channel\n");
	retval = xlnx_data_frag_io(ptr_chann, glb_buf[ptr_chann->chann_id], 

			addr_typ_pmp[ptr_chann->chann_id],
			FRAG_SZ,cbk_data_pump ,/*ptr_chann->num_pkts_io+*/1, true, /*OUT,*/ (void*)current);
	if(retval < XLNX_SUCCESS)
	{
		int state = ptr_chann->chann_state;

		//spin_unlock_irqrestore(&chann->channel_lock, flags);
#if 0//def PUMP_APP_DBG_PRNT
		printk(KERN_ERR"\n - Failed::::::Buffer allocated transmit %d\n", retval);
#endif
		if(state == XLNX_DMA_CNTXTQ_SATURATED || state == XLNX_DMA_CHANN_SATURATED) 
		{
#if 0//def PUMP_APP_DBG_PRNT
			printk(KERN_ERR"\n - Context Q saturated %d\n",state);
#endif
		}

		ptr_chann->chann_state = XLNX_DMA_CHANN_NO_ERR;
	}
	else
	{
		if(/*burst_fill*/1) 
		{
			burst_fill--;
			goto fill_another;
		}
	}



#endif
#endif
}






void cbk_data_rxpump(struct _ps_pcie_dma_chann_desc *ptr_chann, void *data, unsigned int compl_bytes,unsigned short uid, unsigned int num_frags)
{
	//struct task_struct* task = (struct task_struct*)data;
	PktBuf * pbuf;
	int i=0;
	unsigned int flags;
	static int pktSize;
	unsigned char *usrAddr = NULL;
	BufferInfo tempBuffInfo;
	static int  noPages =0 ;


#if 0
	if(ptr_chann->chann_state == XLNX_DMA_CNTXTQ_SATURATED || ptr_chann->chann_state == XLNX_DMA_CHANN_SATURATED)
	{
		/* Make the channel state as 'no error' */
		ptr_chann->chann_state = XLNX_DMA_CHANN_NO_ERR;

		/* Make task running */
		//set_task_state(task, TASK_RUNNING);
#ifdef PUMP_APP_DBG_PRNT
		printk(KERN_ERR"\n --> Thread woekn up\n");
#endif
		//schedule();
		wake_up_process(task);
	}
	else
	{
		wake_up_process(task);
	}
#else
	int retval;
	unsigned int burst_fill = PKT_YIELD_CNT_PER_CHANN;
	if(ptr_chann->chann_state == XLNX_DMA_CNTXTQ_SATURATED || ptr_chann->chann_state == XLNX_DMA_CHANN_SATURATED)
	{
		/* Make the channel state as 'no error' */
		ptr_chann->chann_state = XLNX_DMA_CHANN_NO_ERR;
	}
	//printk(" %s data %x frags %d   ",__FUNCTION__,data,num_frags);
	//  rx_channel_num_empty_bds += num_frags;	

#if  1

	for(i=0; i< num_frags; i++)
	{
		pbuf =Rxqueue[RxReadIndex];
		flags = pbuf->flags;
		if(pbuf->bufPA) 
			dma_unmap_page(ptr_chann->ptr_dma_desc->dev,pbuf->bufPA,pbuf->size,DMA_FROM_DEVICE);
		if(pbuf->pageAddr)
			page_cache_release( (struct page *)pbuf->pageAddr);

		pktSize = pktSize + pbuf->size;
		if (flags & PKT_SOP)
		{
			usrAddr = pbuf->bufInfo;
			pktSize = pbuf->size;
		}
		noPages++;
		if (flags & PKT_EOP)
		{
			tempBuffInfo.bufferAddress = usrAddr;
			tempBuffInfo.buffSize = pktSize;
			tempBuffInfo.noPages= noPages ;  
			tempBuffInfo.endAddress= pbuf->bufInfo;
			tempBuffInfo.endSize=pbuf->size;
			/* put the packet in driver queue*/
			putBuffInfo (&RxDoneQ, tempBuffInfo);
			pktSize = 0;
			noPages=0;
			usrAddr = NULL;
		}

		RxReadIndex++;
		if(RxReadIndex >=NUM_Q_ELEM)
			RxReadIndex=0;
		rx_channel_num_empty_bds++;



	}

	//	 kfree(cachePages);

	//    for(i=0; i<num_frags; i++) {
	//       kfree(pkts[i]);
	//    }
	//   kfree(pkts);



#endif	

#if 0

fill_another:
	//printk(KERN_ERR"\n --> CBK Tx channel\n");
	retval = xlnx_data_frag_io(ptr_chann, glb_buf[ptr_chann->chann_id], 

			addr_typ_pmp[ptr_chann->chann_id],
			FRAG_SZ,cbk_data_pump ,/*ptr_chann->num_pkts_io+*/1, true, /*OUT,*/ (void*)current);
	if(retval < XLNX_SUCCESS)
	{
		int state = ptr_chann->chann_state;

		//spin_unlock_irqrestore(&chann->channel_lock, flags);
#if 0//def PUMP_APP_DBG_PRNT
		printk(KERN_ERR"\n - Failed::::::Buffer allocated transmit %d\n", retval);
#endif
		if(state == XLNX_DMA_CNTXTQ_SATURATED || state == XLNX_DMA_CHANN_SATURATED) 
		{
#if 0//def PUMP_APP_DBG_PRNT
			printk(KERN_ERR"\n - Context Q saturated %d\n",state);
#endif
		}

		ptr_chann->chann_state = XLNX_DMA_CHANN_NO_ERR;
	}
	else
	{
		if(/*burst_fill*/1) 
		{
			burst_fill--;
			goto fill_another;
		}
	}



#endif
#endif
}

#if 0
void cbk_data_rxaux(struct _ps_pcie_dma_chann_desc *ptr_chann, void *data, unsigned int compl_bytes,unsigned short uid, unsigned int num_frags)
{
	struct task_struct* task = (struct task_struct*)data;
	int retval;
	unsigned int i;
	unsigned int packet_size;

	//printk(KERN_ERR"\n --> Channel %d User data %p Num bytes %d User id %x Packet id %d Direction %d Number of frags %d",
	//	   ptr_chann->chann_id, data, compl_bytes, uid, ptr_chann->num_pkts_io, (unsigned int)ptr_chann->dir, num_frags);



	if(ptr_chann->chann_state == XLNX_DMA_CNTXTQ_SATURATED || ptr_chann->chann_state == XLNX_DMA_CHANN_SATURATED)
	{
		/* Make the channel state as 'no error' */
		ptr_chann->chann_state = XLNX_DMA_CHANN_NO_ERR;
	}


	//	rx_auxchannel_num_empty_bds[ptr_chann->chann_id] += num_frags;
	//   printk("**");
	ptr_chann->bds_freed += num_frags;
	ptr_chann->cbk_called++;
#if 0
	if(rx_channel_stalled[ptr_chann->chann_id] == true) 
	{
		/* Make task running */
		rx_channel_stalled[ptr_chann->chann_id] = false;
#ifdef RX_APP_DBG_PRNT
		printk(KERN_ERR"\n --> Thread woekn up %d\n",ptr_chann->chann_id);
#endif
		wake_up_process(task);
	}
	else
	{
		wake_up_process(task);
	}
#else
	/* TODO  This should work debug hang!!*/
	//printk(KERN_ERR"\n --> Pump next rx frag chann %d\n",ptr_chann->chann_id);

#if 1
#if 0
	if((ptr_chann->num_pkts_io % (NUM_Q_ELEM/2))) 
	{
		return;
	}
	else
		for(i = 0; i < (NUM_Q_ELEM/2);i++) 
#endif
		{
			unsigned int burst_fill = num_frags;
fill_another:

			if((RawTestMode & TEST_START) &&  (RawTestMode & ENABLE_PKTGEN) )
			{
				packet_size=RawMaxPktSize;
				retval = xlnx_data_frag_io(ptr_chann, GEN_CHK_BUF_ADDR, 

						EP_PHYS_ADDR,packet_size,cbk_data_rxaux ,1, true, /*OUT,*/ (void*)current);
				if(retval < XLNX_SUCCESS) 
				{
					int state = ptr_chann->chann_state;

					//spin_unlock_irqrestore(&chann->channel_lock, flags);
#if 0//def RX_APP_DBG_PRNT
					printk(KERN_ERR"\n - Failed::::::Buffer allocated rx %d\n", retval);
#endif
					if(state == XLNX_DMA_CNTXTQ_SATURATED || state == XLNX_DMA_CHANN_SATURATED) 
					{
#if 0//def RX_APP_DBG_PRNT
						printk(KERN_ERR"\n - Context Q saturated %d\n",state);
#endif
					}

					ptr_chann->chann_state = XLNX_DMA_CHANN_NO_ERR;
				}
				else
				{
					//    rx_auxchannel_num_empty_bds[ptr_chann->chann_id]--;
					if(burst_fill) 
					{
						burst_fill--;
						goto fill_another;
					}

				}
			}
		}
#endif

#endif

}
#endif

void cbk_data_txaux(struct _ps_pcie_dma_chann_desc *ptr_chann, void *data, unsigned int compl_bytes,unsigned short uid, unsigned int num_frags)
{
	int retval;

	//printk(KERN_ERR"\n --> Channel %d User data %p Num bytes %d User id %x Packet id %d Direction %d Number of frags %d",
	//	   ptr_chann->chann_id, data, compl_bytes, uid, ptr_chann->num_pkts_io, (unsigned int)ptr_chann->dir, num_frags);



	if(ptr_chann->chann_state == XLNX_DMA_CNTXTQ_SATURATED || ptr_chann->chann_state == XLNX_DMA_CHANN_SATURATED)
	{
		/* Make the channel state as 'no error' */
		ptr_chann->chann_state = XLNX_DMA_CHANN_NO_ERR;
	}


	//	tx_auxchannel_num_empty_bds[ptr_chann->chann_id] += num_frags;

	ptr_chann->bds_freed += num_frags;
	ptr_chann->cbk_called++;
#if 1


	/* TODO  This should work debug hang!!*/
	//printk(KERN_ERR"\n --> Pump next rx frag chann %d\n",ptr_chann->chann_id);

#if 1
	{
		unsigned int burst_fill = num_frags;
fill_another:
		retval = xlnx_data_frag_io(ptr_chann, glb_buf[ptr_chann->chann_id], 
				addr_typ_pmp[ptr_chann->chann_id],
				FRAG_SZ,cbk_data_txaux ,1, true, /*OUT,*/ (void*)current);
		if(retval < XLNX_SUCCESS) 
		{
			int state = ptr_chann->chann_state;

			//spin_unlock_irqrestore(&chann->channel_lock, flags);
#if 0//def RX_APP_DBG_PRNT
			printk(KERN_ERR"\n - Failed::::::Buffer allocated rx %d\n", retval);
#endif
			if(state == XLNX_DMA_CNTXTQ_SATURATED || state == XLNX_DMA_CHANN_SATURATED) 
			{
#if 0//def RX_APP_DBG_PRNT
				printk(KERN_ERR"\n - Context Q saturated %d\n",state);
#endif
			}

			ptr_chann->chann_state = XLNX_DMA_CHANN_NO_ERR;
		}
		else
		{
			if(burst_fill) 
			{
				burst_fill--;
				goto fill_another;
			}

		}
	}
#endif

#endif

}




static int DmaSetupTransmit( int num ,const char __user * buffer, size_t length)   
{
	int j;
	int total;
	int status;                
	int offset;                
	unsigned int allocPages;   
	unsigned long first, last; 
	struct page** cachePages;  
	unsigned long flags;
	PktBuf * pbuf;
	int retval;
	int last_frag =0;

	ps_pcie_dma_chann_desc_t *chann = (ps_pcie_dma_chann_desc_t *)ptr_chan_s2c;

	/* Check number of packets */
	if(!num)
	{
		printk("Came with 0 packets for sending\n");
		return 0;
	}

	

	total = 0;
	/****************************************************************/
	// SECTION 1: generate CACHE PAGES for USER BUFFER
	//
	offset = offset_in_page(buffer);
	first = ((unsigned long)buffer & PAGE_MASK) >> PAGE_SHIFT;
	last  = (((unsigned long)buffer + length-1) & PAGE_MASK) >> PAGE_SHIFT;
	allocPages = (last-first)+1;

	if(tx_channel_num_empty_bds[chann->chann_id] > allocPages)

	{

		cachePages = kzalloc( (allocPages * (sizeof(struct page*))), GFP_KERNEL );
		if( cachePages == NULL )
		{
			printk(KERN_ERR "Error: unable to allocate memory for cachePages\n");
			return -1;
		}

		//	memset(cachePages, 0, sizeof(allocPages * sizeof(struct page*)) );

#if 0	
		down_read(&(current->mm->mmap_sem));
		status = get_user_pages(current,        // current process id
				current->mm,                // mm of current process
				(unsigned long)buffer,      // user buffer
				allocPages,
				WRITE_TO_CARD,
				0,                          /* don't force */
				cachePages,
				NULL);
		up_read(&current->mm->mmap_sem);
#endif

		status = get_user_pages_fast((unsigned long)buffer,	allocPages,WRITE_TO_CARD,cachePages);


		if( status < allocPages) {
			printk(KERN_ERR ".... Error: requested pages=%d, granted pages=%d ....\n", allocPages, status);

			for(j=0; j<status; j++)
				page_cache_release(cachePages[j]);

			kfree(cachePages);
			return -1;
		}


		allocPages = status;	// actual number of pages system gave

		for(j=0; j< allocPages; j++)		/* Packet fragments loop */
		{


			pbuf =(Dqueue[WriteIndex]);

			if(j==0) {
				if(j == (allocPages-1)) { 
					pbuf->size = length;
				}
				else
					pbuf->size = ((PAGE_SIZE)-offset);
			} 
			else {
				if(j == (allocPages-1)) { 
					pbuf->size = length-total;
				}
				else pbuf->size = (PAGE_SIZE);
			}
			pbuf->pktBuf = (unsigned char *)dma_map_page(chann->ptr_dma_desc->dev, cachePages[j],(j == 0) ? offset : 0, pbuf->size,DMA_TO_DEVICE);		

			pbuf->pageOffset = (j == 0) ? offset : 0;	// try pci_page_map

			pbuf->bufInfo = (unsigned char *) buffer + total;
			pbuf->pageAddr= (unsigned char*)cachePages[j];
			pbuf->userInfo = length;
			pbuf->numberFrags=allocPages; 
			if(j == 0)
			{
				pbuf->flags |= PKT_SOP;
				last_frag = false;
			}
			if(j == (allocPages - 1) )
			{
				pbuf->flags |= PKT_EOP;
				last_frag = true;
			}


			spin_lock_irqsave(&chann->channel_lock, flags);
			//		spin_lock_bh(&chann->channel_lock);
			//spin_lock(&chann->channel_lock);
			retval = xlnx_data_frag_io(chann,pbuf->pktBuf,PHYS_ADDR, pbuf->size ,cbk_data_pump ,/*num_pkts+1*/1, last_frag, /*OUT,*/Dqueue);
			if(retval < XLNX_SUCCESS) 
			{
				int state = chann->chann_state;

				//spin_unlock_irqrestore(&chann->channel_lock, flags);

				dma_unmap_page(chann->ptr_dma_desc->dev,(dma_addr_t)pbuf->pktBuf,pbuf->size,DMA_TO_DEVICE);
				page_cache_release(cachePages[j]);

				printk(KERN_ERR"\n - Failed::::::Buffer allocated transmit %d\n", retval);

				if(state == XLNX_DMA_CNTXTQ_SATURATED || state == XLNX_DMA_CHANN_SATURATED) 
				{

					printk(KERN_ERR"\n - Context Q saturated %d\n",state);

					//ptr_chan_s2c_0->chann_state = XLNX_DMA_CHANN_NO_ERR;

					spin_unlock_irqrestore(&chann->channel_lock, flags);
					//spin_unlock(&chann->channel_lock);

				}

			}
			else
			{


				total += pbuf->size;
				WriteIndex++;
				if(WriteIndex >= NUM_Q_ELEM)
					WriteIndex=0;
				tx_channel_num_empty_bds[chann->chann_id]--;

				//	 kfree(cachePages);

				spin_unlock_irqrestore(&chann->channel_lock, flags);
				//	spin_unlock(&chann->channel_lock);
			}




		}
		/****************************************************************/

	}
	else 
	{

		// printk("No Room for Pkts BD full \n");
		//		for(j=0; j<allocPages; j++)
		//			page_cache_release(cachePages[j]);

		//		kfree(cachePages);
		//	kfree(pkts);
		//printk("#");

		return -1; 
	}

	allocPages = j;           // actually used pages

	kfree(cachePages);

	//  for(j=0; j<allocPages; j++) {
	//      kfree(pkts[j]);
	//  }
	//  kfree(pkts);

	return total;
}





static int DmaSetupReceive( int num ,const char __user * buffer, size_t length)   
{
	int j;
	int total;
	int status;                
	int offset;                
	unsigned int allocPages;   
	unsigned long first, last; 
	struct page** cachePages;  
	unsigned long flags;
	PktBuf * pbuf;
	int retval;
	int last_frag =0;
	dma_addr_t bufPA;

	ps_pcie_dma_chann_desc_t *chann = (ps_pcie_dma_chann_desc_t *)ptr_rxchan_s2c;

	/* Check number of packets */
	if(!num)
	{
		printk("Came with 0 packets for sending\n");
		return 0;
	}



	total = 0;
	/****************************************************************/
	// SECTION 1: generate CACHE PAGES for USER BUFFER
	//
	offset = offset_in_page(buffer);
	first = ((unsigned long)buffer & PAGE_MASK) >> PAGE_SHIFT;
	last  = (((unsigned long)buffer + length-1) & PAGE_MASK) >> PAGE_SHIFT;
	allocPages = (last-first)+1;

	if(rx_channel_num_empty_bds > allocPages)
	{
		cachePages = kzalloc( (allocPages * (sizeof(struct page*))), GFP_ATOMIC );
		if( cachePages == NULL )
		{
			printk(KERN_ERR "Error: unable to allocate memory for cachePages\n");
			return -1;
		}
		status = get_user_pages_fast((unsigned long)buffer,	allocPages,READ_FROM_CARD,cachePages);
		if( status < allocPages) {
			printk(KERN_ERR ".... Error: requested pages=%d, granted pages=%d ....\n", allocPages, status);

			for(j=0; j<status; j++)
				page_cache_release(cachePages[j]);

			kfree(cachePages);
			return -1;
		}
		allocPages = status;	// actual number of pages system gave



		for(j=0; j< allocPages; j++)		/* Packet fragments loop */
		{
			pbuf=Rxqueue[RxWriteIndex];
			if(pbuf == NULL)
			{
				printk("##Kmalloc failed ###\n");
				return -1;
			}
			
			if(j==0) {
				if(j == (allocPages-1)) { 
					pbuf->size = length;
				}
				else
					pbuf->size = ((PAGE_SIZE)-offset);
			} 
			else {
				if(j == (allocPages-1)) { 
					pbuf->size = length-total;
				}
				else pbuf->size = (PAGE_SIZE);
			}	
			pbuf->pageOffset = (j == 0) ? offset : 0;		
			pbuf->pageAddr= (unsigned char*)cachePages[j];	
			bufPA= dma_map_page(chann->ptr_dma_desc->dev, cachePages[j],pbuf->pageOffset, pbuf->size,DMA_FROM_DEVICE);	
			pbuf->bufPA = bufPA;
			pbuf->bufInfo = (unsigned char *) buffer + total;
			pbuf->userInfo = length;
			pbuf->numberFrags=allocPages; 
			if(j == 0)
			{
				pbuf->flags |= PKT_SOP;
				last_frag = false;
			}
			if(j == (allocPages - 1) )
			{
				pbuf->flags |= PKT_EOP;
				last_frag = true;
			}


			spin_lock_irqsave(&chann->channel_lock, flags);
			//  spin_lock(&chann->channel_lock);
			//		spin_lock_bh(&chann->channel_lock);
			retval = xlnx_data_frag_io(chann,(unsigned char *)bufPA,PHYS_ADDR, pbuf->size ,cbk_data_rxpump ,/*num_pkts+1*/1, last_frag, /*OUT,*/ Rxqueue);
			if(retval < XLNX_SUCCESS) 
			{
				int state = chann->chann_state;

				//spin_unlock_irqrestore(&chann->channel_lock, flags);

				dma_unmap_page(chann->ptr_dma_desc->dev,pbuf->bufPA,pbuf->size,DMA_FROM_DEVICE);
				page_cache_release((struct page *)pbuf->pageAddr);

				printk(KERN_ERR"\n - Failed::::::Buffer allocated transmit %d\n", retval);

				if(state == XLNX_DMA_CNTXTQ_SATURATED || state == XLNX_DMA_CHANN_SATURATED) 
				{

					printk(KERN_ERR"\n - Context Q saturated %d\n",state);

					//	chann->chann_state = XLNX_DMA_CHANN_NO_ERR;



				}


			}

			else
			{


				total += pbuf->size;
				RxWriteIndex++;
				if(RxWriteIndex >= NUM_Q_ELEM)
					RxWriteIndex=0;
				//	printk("!!");
				rx_channel_num_empty_bds--;
				//	 kfree(cachePages);


			}

			//	spin_unlock(&chann->channel_lock);

			spin_unlock_irqrestore(&chann->channel_lock, flags);

		}



	}

	else 
	{

		// printk("No Room for Pkts BD full \n");

		return -1; 
	}


	kfree(cachePages);



	return total;
}


#if 0
int data_rxaux_function(ps_pcie_dma_chann_desc_t *data)
{
	int retval;
	//unsigned int num_pkts = 0;
	//unsigned long flags;
	int i=0;
	ps_pcie_dma_chann_desc_t *chann = (ps_pcie_dma_chann_desc_t *)data;
	unsigned int packet_size =0;



	for(i=0;i< NUM_Q_ELEM -2 ;i++)
	{


		//spin_lock_irqsave(&chann->channel_lock, flags);
		spin_lock_bh(&chann->channel_lock);

		packet_size = RawMaxPktSize ;
		retval = xlnx_data_frag_io(chann, GEN_CHK_BUF_ADDR, 

				EP_PHYS_ADDR,
				packet_size,cbk_data_rxaux ,1, true, /*OUT,*/ (void*)current);
		if(retval < XLNX_SUCCESS) 
		{
			if(chann->chann_state == XLNX_DMA_CNTXTQ_SATURATED || chann->chann_state == XLNX_DMA_CHANN_SATURATED) 
			{
				//	set_task_state(current, TASK_INTERRUPTIBLE);   
				//	printk(KERN_ERR"\n --> Rx BDs saturated \n");
				//spin_unlock_irqrestore(&chann->channel_lock, flags);
				spin_unlock_bh(&chann->channel_lock);
				//	schedule();
			}
			else
			{
				//spin_unlock_irqrestore(&chann->channel_lock, flags);
				spin_unlock_bh(&chann->channel_lock);
			}
		}
		else
		{
			chann->bds_alloc++;
			//	rx_auxchannel_num_empty_bds[chann->chann_id]--;
			//spin_unlock_irqrestore(&chann->channel_lock, flags);
			spin_unlock_bh(&chann->channel_lock);
		}



	}



	return 0;
}
#endif

	static int
xraw_dev_open (struct inode *in, struct file *filp)
{

	/* Allowing more than one Application accesing the driver */

	xraw_UserOpen++;		  

	printk ("========>>>>> XDMA driver instance %d \n", xraw_UserOpen);

	return 0;
}


	static int
xraw_dev_release (struct inode *in, struct file *filp)
{


	if (!xraw_UserOpen)
	{
		/* Should not come here */
		printk ("Device not in use\n");
		return -EFAULT;
	}

	xraw_UserOpen--;
	printk ("========>>>>> XDMA driver instance %d \n", xraw_UserOpen);


	return 0;
}


	static long
xraw_dev_ioctl (struct file *filp,
		unsigned int cmd, unsigned long arg)
{
	int retval = 0;
	TestCmd tc;
	int reg_val;
	u8 __iomem *gen_chk_reg_vbaseaddr = ptr_txapp_dma_desc->cntrl_func_virt_base_addr + GEN_CHECK_OFFSET_START;
	/* Check cmd type and value */
	if (_IOC_TYPE (cmd) != XPMON_MAGIC)
		return -ENOTTY;
	if (_IOC_NR (cmd) > XPMON_MAX_CMD)
		return -ENOTTY;

	/* Check read/write and corresponding argument */
	if (_IOC_DIR (cmd) & _IOC_READ)
		if (!access_ok (VERIFY_WRITE, (void *) arg, _IOC_SIZE (cmd)))
			return -EFAULT;
	if (_IOC_DIR (cmd) & _IOC_WRITE)
		if (!access_ok (VERIFY_READ, (void *) arg, _IOC_SIZE (cmd)))
			return -EFAULT;

	switch (cmd)
	{
		case ISTART_TEST:
		case ISTOP_TEST:

			if(copy_from_user(&tc, (TestCmd *)arg, sizeof(TestCmd)))
			{
				printk("copy_from_user failed\n");
				retval = -EFAULT;
				break;
			}
			printk(KERN_ERR"####Engine %d Testmode %x Min %x Max %x #####\n ",tc.Engine,tc.TestMode,tc.MinPktSize,tc.MaxPktSize);

		
			/* Valid only for TX engine */

			/* Set up the value to be written into the register */
			RawTestMode = tc.TestMode;
			RawMaxPktSize = tc.MaxPktSize;
			RawMinPktSize = tc.MinPktSize;

			if (RawTestMode & TEST_START)
			{

#if 0	
				if (RawTestMode & ENABLE_PKTCHK)
				{
#if 0
					reg_val =RD_DMA_REG(gen_chk_reg_vbaseaddr,ENABLE_CHK);
					reg_val &= ~( GENCHK_ENABLE);
					printk("##CHECKER Disable reg %d  %x  ##\n",reg_val,RD_DMA_REG(gen_chk_reg_vbaseaddr,ENABLE_CHK));	
					WR_DMA_REG(gen_chk_reg_vbaseaddr,ENABLE_CHK,reg_val);
#endif
					printk("Wrap Count %d \n", RD_DMA_REG(gen_chk_reg_vbaseaddr,CNT_WRAP));
					reg_val= 0x200 -1 ;
					WR_DMA_REG(gen_chk_reg_vbaseaddr, CNT_WRAP,reg_val);
					printk("Wrap Count %d \n", RD_DMA_REG(gen_chk_reg_vbaseaddr,CNT_WRAP));


					//	       reg_val = RD_DMA_REG(gen_chk_reg_vbaseaddr,CHK_PKT_LENGTH);
					reg_val = RawMaxPktSize;	   
					WR_DMA_REG(gen_chk_reg_vbaseaddr,CHK_PKT_LENGTH,reg_val);

					reg_val = RD_DMA_REG(gen_chk_reg_vbaseaddr,ENABLE_CHK);
					reg_val |= GENCHK_ENABLE;
					WR_DMA_REG(gen_chk_reg_vbaseaddr,ENABLE_CHK,reg_val);
					printk("##CHECKER ENABLED ##\n");
				}
				if (RawTestMode & ENABLE_PKTGEN)
				{



					printk("Wrap Count %d \n", RD_DMA_REG(gen_chk_reg_vbaseaddr,CNT_WRAP));
					reg_val= 0x200 -1 ;
					WR_DMA_REG(gen_chk_reg_vbaseaddr, CNT_WRAP,reg_val);
					printk("Wrap Count %d \n", RD_DMA_REG(gen_chk_reg_vbaseaddr,CNT_WRAP));


					//		 reg_val = RD_DMA_REG(gen_chk_reg_vbaseaddr,GEN_PKT_LENGTH);
					reg_val = RawMaxPktSize;	   
					WR_DMA_REG(gen_chk_reg_vbaseaddr, GEN_PKT_LENGTH,reg_val);

					reg_val = RD_DMA_REG(gen_chk_reg_vbaseaddr,ENABLE_GEN);
					reg_val |= GENCHK_ENABLE;
					WR_DMA_REG(gen_chk_reg_vbaseaddr,ENABLE_GEN,reg_val);

					printk("##GENERATOR Enabled #### Pak length %x  \n ",RD_DMA_REG(gen_chk_reg_vbaseaddr,GEN_PKT_LENGTH));
					//		data_rxaux_function(ptr_rxauxchan_s2c);

				}

#endif            
				//	if(RawTestMode & ENABLE_CRISCROSS)
				{
					printk("\n RAW ETHER CRISSCROSS ");
					WR_DMA_REG(gen_chk_reg_vbaseaddr,NW_PATH0_OFFSET + XXGE_RCW1_OFFSET ,0x50000000);
				}
				//	else
				//	{
				//	printk("\n RAW ETHER LOOPBACK ");
				//	        WR_DMA_REG(gen_chk_reg_vbaseaddr,NW_PATH1_OFFSET + XXGE_RCW1_OFFSET ,0x50000000);
				//	}

				WR_DMA_REG(gen_chk_reg_vbaseaddr,NW_PATH1_OFFSET + XXGE_TC_OFFSET ,0x50000000);
			}
			else
			{
				/* Deliberately not clearing the loopback bit, incase a
				 * loopback test was going on - allows the loopback path
				 * to drain off packets. Just stopping the source of packets.
				 */
#if 0		   
				if (RawTestMode & ENABLE_PKTCHK)
				{
					reg_val =RD_DMA_REG(gen_chk_reg_vbaseaddr,ENABLE_CHK);
					reg_val &= ~( GENCHK_ENABLE);
					printk("##CHECKER Disable reg %d  %x  ##\n",reg_val,RD_DMA_REG(gen_chk_reg_vbaseaddr,ENABLE_CHK));	
					WR_DMA_REG(gen_chk_reg_vbaseaddr,ENABLE_CHK,reg_val);	

				}



				if (RawTestMode & ENABLE_PKTGEN)
				{
					reg_val =RD_DMA_REG(gen_chk_reg_vbaseaddr,ENABLE_GEN);
					reg_val &= ~( GENCHK_ENABLE);
					WR_DMA_REG(gen_chk_reg_vbaseaddr,ENABLE_GEN,reg_val);	
				}

#endif   

			}


			break;       

		case IGET_TRN_TXUSRINFO:
			{
				int count = 0;

				int expect_count;
				if(copy_from_user(&expect_count,&(((FreeInfo *)arg)->expected),sizeof(int)) != 0)
				{
					printk ("##### ERROR in copy from usr #####");
					break;
				}
				while (count < expect_count)
				{
					BufferInfo buff;
					if (0 != getBuffInfo (&TxDoneQ, &buff))
					{
						break;
					}
					if (copy_to_user
							(((BufferInfo *) (((FreeInfo *)arg)->buffList) + count), &buff,
							 sizeof (BufferInfo)))
					{
						printk ("##### ERROR in copy to usr #####");

					}
					// log_verbose(" %s:bufferAddr %x   PktSize %d", __func__, usrArgument->buffList[count].bufferAddress, usrArgument->buffList[count].buffSize);
					count++;
				}
				if(copy_to_user(&(((FreeInfo *)arg)->expected),&count,(sizeof(int))) != 0)
				{
					printk ("##### ERROR in copy to usr #####");
				}

				break;
			}
		case IGET_TRN_RXUSRINFO:
			{
				int count = 0;
				int expect_count;

				if(copy_from_user(&expect_count,&(((FreeInfo *)arg)->expected),sizeof(int)) != 0)
				{
					printk ("##### ERROR in copy from usr #####");
					break;
				}

				while (count < expect_count)
				{
					BufferInfo buff;
					if (0 != getBuffInfo (&RxDoneQ, &buff))
					{
						break;
					}
					if (copy_to_user
							(((BufferInfo *) (((FreeInfo *)arg)->buffList) + count), &buff,
							 sizeof (BufferInfo)))
					{
						printk ("##### ERROR in copy to usr #####");

					}
					//	 printk(" %s:bufferAddr %x   PktSize %d", __func__, usrArgument->buffList[count].bufferAddress, usrArgument->buffList[count].buffSize);
					count++;
				}
				if(copy_to_user(&(((FreeInfo *)arg)->expected),&count,(sizeof(int))) != 0)
				{
					printk ("##### ERROR in copy to usr #####");
				}

				break;
			}
		default:
			printk ("Invalid command %d\n", cmd);
			retval = -1;
			break;
	}

	return retval;
}


/* 
 * This function is called when somebody tries to
 * write into our device file. 
 */
	static ssize_t
xraw_dev_write (struct file *file,
		const char __user * buffer, size_t length, loff_t * offset)
{
	int ret_pack=0;



	//   if ((RawTestMode & TEST_START) &&	  (RawTestMode & ENABLE_PKTCHK ))
	ret_pack = DmaSetupTransmit( 1, buffer, length);


	/* 
	 *  return the number of bytes sent , currently one or none
	 */
	return ret_pack;
}



	static ssize_t
xraw_dev_read (struct file *file,
		char __user * buffer, size_t length, loff_t * offset)
{
	int ret_pack=0;

#ifdef BACK_PRESSURE
	if(impl_bp == NO_BP)
#endif
		ret_pack = DmaSetupReceive(1,buffer,length);

	/* 
	 *  return the number of bytes sent , currently one or none
	 */

	return ret_pack;
}

#if 0

int data_txaux_function(ps_pcie_dma_chann_desc_t *data)
{
	int retval;
	int i=0;
	//unsigned int num_pkts = 0;
	//unsigned long flags;
	ps_pcie_dma_chann_desc_t *chann = (ps_pcie_dma_chann_desc_t *)data;



	glb_buf[chann->chann_id] = GEN_CHK_BUF_ADDR;
	addr_typ_pmp[chann->chann_id] = EP_PHYS_ADDR;



	for(i=0;i< (NUM_Q_ELEM-2) ;i++)
	{
		//spin_lock_irqsave(&chann->channel_lock, flags);
		spin_lock_bh(&chann->channel_lock);


		retval = xlnx_data_frag_io(chann,GEN_CHK_BUF_ADDR, 

				EP_PHYS_ADDR,
				FRAG_SZ,cbk_data_txaux ,1, true, /*OUT,*/ (void*)current);
		if(retval < XLNX_SUCCESS) 
		{
			if(chann->chann_state == XLNX_DMA_CNTXTQ_SATURATED || chann->chann_state == XLNX_DMA_CHANN_SATURATED) 
			{
				//set_task_state(current, TASK_INTERRUPTIBLE);   
				printk(KERN_ERR"\n Rx BDs saturated \n");
				//spin_unlock_irqrestore(&chann->channel_lock, flags);
				spin_unlock_bh(&chann->channel_lock);
				//	schedule();
			}
			else
			{
				//spin_unlock_irqrestore(&chann->channel_lock, flags);
				spin_unlock_bh(&chann->channel_lock);
			}
		}
		else
		{
			chann->bds_alloc++;
			tx_auxchannel_num_empty_bds[chann->chann_id]--;
			//spin_unlock_irqrestore(&chann->channel_lock, flags);
			spin_unlock_bh(&chann->channel_lock);
		}


	}


	return 0;
}
#endif

int rx_driver_init(void)
{
	int retval = 0;
	int i;

	platform_t pfrom = HOST;

	ps_pcie_dma_desc_t* ptr_rxdma_desc = xlnx_get_pform_dma_desc((void*)NULL, 0, 0);

	retval = xlnx_get_dma((void*)ptr_rxdma_desc->device , pfrom, &ptr_rxapp_dma_desc);
	if(ptr_rxapp_dma_desc == NULL) 
	{
		printk(KERN_ERR"\n - Could not get valid dma descriptor %d\n", retval);
		goto error;
	}
	else
	{


		int ret = 0;
		unsigned int q_num_elements = NUM_Q_ELEM;
		unsigned int data_q_addr_hi;
		unsigned int data_q_addr_lo;
		unsigned int sta_q_addr_hi;
		unsigned int sta_q_addr_lo;
		char name_buf[50];
		direction_t dir;


		ret = xlnx_get_dma_channel(ptr_rxapp_dma_desc, RX_CHANNEL, 
				/*dir*/IN, &ptr_rxchan_s2c,NULL);
		if(ret < XLNX_SUCCESS) 
		{
			printk(KERN_ERR"\n - Could not get s2c returned %d\n", ret);
			goto channel_ack_failed;
		}

		ret = xlnx_alloc_queues(ptr_rxchan_s2c, &data_q_addr_hi, //Physical address
				&data_q_addr_lo,//Physical address
				&sta_q_addr_hi,//Physical address
				&sta_q_addr_lo,//Physical address
				q_num_elements);
		if(ret < XLNX_SUCCESS) 
		{
			printk(KERN_ERR"\n Could not allocate Qs for s2c returned %d\n", ret);
			goto channel_q_alloc0_failed;
		}


		ret = xlnx_activate_dma_channel(ptr_rxapp_dma_desc, ptr_rxchan_s2c,
				data_q_addr_hi,data_q_addr_lo,q_num_elements,
				sta_q_addr_hi,sta_q_addr_lo,q_num_elements, 0);
		if(ret < XLNX_SUCCESS) 
		{
			printk(KERN_ERR"\n Could not activate s2c returned %d\n", ret);
			goto channel_act_failed;
		}


	}


#if 0

	ps_pcie_dma_desc_t* ptr_rxauxdma_desc = xlnx_get_pform_dma_desc((void*)NULL, 0, 0);

	retval = xlnx_get_dma((void*)ptr_rxauxdma_desc->device , pfrom, &ptr_rxauxapp_dma_desc);
	if(ptr_rxauxapp_dma_desc == NULL) 
	{
		printk(KERN_ERR"\n Could not get valid dma descriptor %d\n", retval);
		goto error;
	}
	else
	{


		int ret = 0;
		unsigned int q_num_elements = NUM_Q_ELEM;
		unsigned int data_q_addr_hi;
		unsigned int data_q_addr_lo;
		unsigned int sta_q_addr_hi;
		unsigned int sta_q_addr_lo;
		char name_buf[50];
		direction_t dir;


		ret = xlnx_get_dma_channel(ptr_rxauxapp_dma_desc, RX_CHANNEL, 
				/*dir*/OUT, &ptr_rxauxchan_s2c,NULL);
		if(ret < XLNX_SUCCESS) 
		{
			printk(KERN_ERR"\n Could not get s2c %d channel error %d\n", ret);
			goto channel_ack_failed;
		}

		ret = xlnx_alloc_queues(ptr_rxauxchan_s2c, &data_q_addr_hi, //Physical address
				&data_q_addr_lo,//Physical address
				&sta_q_addr_hi,//Physical address
				&sta_q_addr_lo,//Physical address
				q_num_elements);
		if(ret < XLNX_SUCCESS) 
		{
			printk(KERN_ERR"\n Could not allocate Qs for s2c %d channel %d\n", ret);
			goto channel_q_alloc0_failed;
		}


		ret = xlnx_activate_dma_channel(ptr_rxauxapp_dma_desc, ptr_rxauxchan_s2c,
				data_q_addr_hi,data_q_addr_lo,q_num_elements,
				sta_q_addr_hi,sta_q_addr_lo,q_num_elements, 0);
		if(ret < XLNX_SUCCESS) 
		{
			printk(KERN_ERR"\n Could not activate s2c %d channel %d\n", ret);
			goto channel_act_failed;
		}
		else
		{
			struct task_struct* task = NULL;
			sprintf(name_buf,"DataRxChann%d Thread",i);
#if 0
			/* Spawn a kernel thread to pump data */
			task = kthread_run(&data_rxaux_function,(void *)ptr_rxauxchan_s2c,name_buf);
			if(task == NULL) 
			{
				printk(KERN_ERR"\n Thread spawning failed for channel %d",RX_CHANNEL);
				goto error;
			}
			else
			{
				printk(KERN_ERR"\n Thread spawning success for channel %d",RX_CHANNEL);
			}
#endif		
		}


	}
#endif

	printk(KERN_ERR"\n Module Host pump on all 4 channels loaded %d", retval);
	return 0;
error:
channel_ack_failed:
channel_act_failed:
channel_q_alloc0_failed:


	printk(KERN_ERR" Error channels not activated %d!!", retval);
	return -1;
}




#ifndef XILINX_PCIE_EP
static 
#endif
int host_pump_driver_init(void)
{
	int chrRet;
	dev_t xrawDev;
	static struct file_operations xrawDevFileOps;
	int retval = 0;
	int i;
#ifdef XILINX_PCIE_EP
	platform_t pfrom = EP;
#else
	platform_t pfrom = HOST;
#endif

	ps_pcie_dma_desc_t* ptr_dma_desc = xlnx_get_pform_dma_desc((void*)NULL, 0, 0);

	retval = xlnx_get_dma((void*)ptr_dma_desc->device , pfrom, &ptr_txapp_dma_desc);
	if(ptr_txapp_dma_desc == NULL) 
	{
		printk(KERN_ERR"\n Could not get valid dma descriptor %d\n", retval);
		goto error;
	}
	else
	{


		int ret = 0;
		unsigned int q_num_elements = NUM_Q_ELEM;
		unsigned int data_q_addr_hi;
		unsigned int data_q_addr_lo;
		unsigned int sta_q_addr_hi;
		unsigned int sta_q_addr_lo;
		char name_buf[50];
		direction_t dir;


		ret = xlnx_get_dma_channel(ptr_txapp_dma_desc, TX_CHANNEL, 
				/*dir*/OUT, &ptr_chan_s2c,NULL);
		if(ret < XLNX_SUCCESS) 
		{
			printk(KERN_ERR"\n Could not get s2c returned %d\n", ret);
			goto channel_ack_failed;
		}

		ret = xlnx_alloc_queues(ptr_chan_s2c, &data_q_addr_hi, //Physical address
				&data_q_addr_lo,//Physical address
				&sta_q_addr_hi,//Physical address
				&sta_q_addr_lo,//Physical address
				q_num_elements);
		if(ret < XLNX_SUCCESS) 
		{
			printk(KERN_ERR"\n Could not allocate Qs for s2c returned %d\n",ret);
			goto channel_q_alloc0_failed;
		}


		ret = xlnx_activate_dma_channel(ptr_txapp_dma_desc, ptr_chan_s2c,
				data_q_addr_hi,data_q_addr_lo,q_num_elements,
				sta_q_addr_hi,sta_q_addr_lo,q_num_elements, COALESE_CNT);
		if(ret < XLNX_SUCCESS) 
		{
			printk(KERN_ERR"\n Could not activate s2c returned %d \n", ret);
			goto channel_act_failed;
		}



	}

#if 0
	{


		platform_t pfrom = HOST;

		ps_pcie_dma_desc_t* ptr_Auxdma_desc = xlnx_get_pform_dma_desc((void*)NULL, 0, 0);

		retval = xlnx_get_dma((void*)ptr_dma_desc->device , pfrom, &ptr_TxAuxapp_dma_desc);
		if(ptr_TxAuxapp_dma_desc == NULL) 
		{
			printk(KERN_ERR"\n Could not get valid dma descriptor %d\n", retval);
			goto error;
		}
		else
		{

			int ret = 0;
			unsigned int q_num_elements = NUM_Q_ELEM;
			unsigned int data_q_addr_hi;
			unsigned int data_q_addr_lo;
			unsigned int sta_q_addr_hi;
			unsigned int sta_q_addr_lo;
			char name_buf[50];
			direction_t dir= IN;


			ret = xlnx_get_dma_channel(ptr_TxAuxapp_dma_desc, TX_CHANNEL, 
					/*dir*/IN, &ptr_Auxchan_s2c,NULL);
			if(ret < XLNX_SUCCESS) 
			{
				printk(KERN_ERR"\n Could not get s2c %d channel error %d\n", ret);
				goto channel_ack_failed;
			}

			ret = xlnx_alloc_queues(ptr_Auxchan_s2c, &data_q_addr_hi, //Physical address
					&data_q_addr_lo,//Physical address
					&sta_q_addr_hi,//Physical address
					&sta_q_addr_lo,//Physical address
					q_num_elements);
			if(ret < XLNX_SUCCESS) 
			{
				printk(KERN_ERR"\n - Could not allocate Qs for s2c %d channel %d\n", ret);
				goto channel_q_alloc0_failed;
			}


			ret = xlnx_activate_dma_channel(ptr_TxAuxapp_dma_desc, ptr_Auxchan_s2c,
					data_q_addr_hi,data_q_addr_lo,q_num_elements,
					sta_q_addr_hi,sta_q_addr_lo,q_num_elements, 0);
			if(ret < XLNX_SUCCESS) 
			{
				printk(KERN_ERR"\n Could not activate s2c %d channel %d\n",ret);
				goto channel_act_failed;
			}
			else
			{
				struct task_struct* task = NULL;
				sprintf(name_buf,"DataRxChann%d Thread",i);

				ret = data_txaux_function(ptr_Auxchan_s2c );
				if(ret <0)
					printk("Failed to Run Tx Aux Function ");
#if 0
				/* Spawn a kernel thread to pump data */
				task = kthread_run(&data_txaux_function,(void *)ptr_Auxchan_s2c,name_buf);
				if(task == NULL) 
				{
					printk(KERN_ERR"\n--> Thread spawning failed for channel %d",TX_CHANNEL);
					goto error;
				}
				else
				{
					printk(KERN_ERR"\n--> Thread spawning success for channel %d",TX_CHANNEL);
				}
#endif				
			}


		}





	}
#endif

	retval= rx_driver_init();
	if(retval < XLNX_SUCCESS) 
	{
		printk(KERN_ERR"\n Could not activate Rx Channel  returned %d\n",retval);
		goto channel_act_failed;
	}
	printk(KERN_ERR"\n --> Module Host pump on all 4 channels loaded %d", retval);



	/* First allocate a major/minor number. */
	chrRet = alloc_chrdev_region (&xrawDev, 0, 1, DEV_NAME);
	if (IS_ERR ((int *) chrRet))
	{
		printk(KERN_ERR "Error allocating char device region\n");
		return -1;
	}
	else
	{
		/* Register our character device */
		xrawCdev = cdev_alloc ();
		if (IS_ERR (xrawCdev))
		{
			printk(KERN_ERR "Alloc error registering device driver\n");
			unregister_chrdev_region (xrawDev, 1);
			return -1;
		}
		else
		{
			xrawDevFileOps.owner = THIS_MODULE;
			xrawDevFileOps.open = xraw_dev_open;
			xrawDevFileOps.release = xraw_dev_release;
			xrawDevFileOps.unlocked_ioctl = xraw_dev_ioctl;
			xrawDevFileOps.write = xraw_dev_write;
			xrawDevFileOps.read = xraw_dev_read;
			xrawCdev->owner = THIS_MODULE;
			xrawCdev->ops = &xrawDevFileOps;
			xrawCdev->dev = xrawDev;
			chrRet = cdev_add (xrawCdev, xrawDev, 1);
			if (chrRet < 0)
			{
				printk (KERN_ERR "Add error registering device driver\n");
				cdev_del(xrawCdev);
				unregister_chrdev_region (xrawDev, 1);
				return -1;
			}
		}
	}

	if (!IS_ERR ((int *) chrRet))
	{
		printk (KERN_INFO "Device registered with major number %d\n",
				MAJOR (xrawDev));

	}

	Dqueue =  kzalloc(NUM_Q_ELEM * (sizeof(PktBuf*)), GFP_ATOMIC);
	if(Dqueue ==NULL)
	{
		printk("Not Able to Allocate Queue ");
		return -1;
	}
	for(i=0; i < NUM_Q_ELEM ;i++)
	{
		Dqueue[i]= kzalloc( (sizeof(PktBuf)), GFP_ATOMIC);
		if(Dqueue[i] ==NULL)
		{
			printk("Not Able to Allocate Queue ");
			return -1;
		}
	}

	Rxqueue =  kzalloc(NUM_Q_ELEM * (sizeof(PktBuf*)), GFP_ATOMIC);
	if(Rxqueue ==NULL)
	{
		printk("Not Able to Allocate Queue ");
		return -1;
	}
	for(i=0; i < NUM_Q_ELEM ;i++)
	{
		Rxqueue[i]= kzalloc( (sizeof(PktBuf)), GFP_ATOMIC);
		if(Rxqueue[i] ==NULL)
		{
			printk("Not Able to Allocate Queue ");
			return -1;
		}
	}

	printk(KERN_ERR"\n--> Module Host pump on all 4 channels loaded %d", retval);


	return 0;
error:
channel_ack_failed:
channel_act_failed:
channel_q_alloc0_failed:


	printk(KERN_ERR"--> Error channels not activated %d!!", retval);
	return -1;
}

static void host_pump_driver_exit(void)
{
	int i;
	u8 __iomem *gen_chk_reg_vbaseaddr = ptr_txapp_dma_desc->cntrl_func_virt_base_addr ;
	WR_DMA_REG(gen_chk_reg_vbaseaddr,NW_PATH1_OFFSET + XXGE_TC_OFFSET ,0x80000000);
	WR_DMA_REG(gen_chk_reg_vbaseaddr,NW_PATH1_OFFSET + XXGE_RCW1_OFFSET ,0x80000000);


	//Tx cHannel
	/* Stop the IOs over channel */
	xlnx_deactivate_dma_channel(ptr_chan_s2c);
	//xlnx_stop_channel_IO(ptr_chan_s2c, true);
	xlnx_dealloc_queues(ptr_chan_s2c);
	//TxAux Channel
	//	xlnx_deactivate_dma_channel(ptr_Auxchan_s2c);
	//	xlnx_stop_channel_IO(ptr_TxAuxapp_dma_desc, true);
	//	xlnx_dealloc_queues(ptr_Auxchan_s2c);

	//Rx Channel

	xlnx_deactivate_dma_channel(ptr_rxchan_s2c);
	//	xlnx_stop_channel_IO(ptr_rxapp_dma_desc, true);
	xlnx_dealloc_queues(ptr_rxchan_s2c);

	//Rx Aux Channel	
	//	xlnx_deactivate_dma_channel(ptr_rxauxchan_s2c);
	//	xlnx_stop_channel_IO(ptr_rxauxapp_dma_desc, true);
	//	xlnx_dealloc_queues(ptr_rxauxchan_s2c);

	if(xrawCdev !=NULL)
	{
		cdev_del(xrawCdev);
		unregister_chrdev_region(xrawCdev->dev,1);

	}

}

module_init(host_pump_driver_init);
module_exit(host_pump_driver_exit);

MODULE_DESCRIPTION("Xilinx PS PCIe DMA driver");
MODULE_AUTHOR("Xilinx");
MODULE_LICENSE("GPL");
