
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
/*****************************************************************************/
/**
*
* @file xpmon_be.h
*
* This file contains the data required for the interface between the
* xpmon GUI and the xdma driver.
*
* The Xilinx Performance Monitor GUI (xpmon) contacts the DMA driver (xdma)
* in order to start/stop a packet generation test, and also to periodically
* read the state and statistics of the drivers, the PCIe link and the DMA
* engine and payload.
*
* xpmon opens the device file <pre> /dev/xdma_stat </pre> which enables it 
* to communicate with the xdma driver. 
*
* <b> Driver IOCTLs </b>
*
* After opening the device file, xpmon issues various IOCTLs in order
* to read different kinds of information from the DMA driver, and to 
* modify the driver behaviour.
*
* <b> Start/Stop Test </b>
*
* To start a test, xpmon does the following, specifying minimum/maximum
* packet sizes, and whether to enable loopback or not. Loopback is not enabled 
* in this TRD -
* <pre>
* ioctl(int fd, ISTART_TEST, TestCmd * testCmd);
* </pre>
* ... and to stop a test, xpmon does the following -
* <pre>
* ioctl(int fd, ISTOP_TEST, TestCmd * testCmd);
* </pre>
*
* <b> Per-one-second IOCTLs </b>
*
* In order to read the DMA engine payload statistics,
* <pre>
* ioctl(int fd, IGET_DMA_STATISTICS, EngStatsArray * es);
* </pre>
*
* In order to read the driver's software-level statistics,
* <pre>
* ioctl(int fd, IGET_SW_STATISTICS, SWStatsArray * ssa);
* </pre>
*
* In order to read the PCIe TRN statistics,
* <pre>
* ioctl(int fd, IGET_TRN_STATISTICS, TRNStatsArray * tsa);
* </pre>
*
* <b> Per-five-second IOCTLs </b>
*
* In order to read the DMA and Software status, 
* <pre>
* ioctl(int fd, IGET_ENG_STATE, EngState * enginfo);
* </pre>
*
* In order to read the PCIe link status,
* <pre>
* ioctl(int fd, IGET_PCI_STATE, PCIState * ps);
* </pre>
*
* MODIFICATION HISTORY:
*
* Ver   Date    Changes
* ----- ------- -------------------------------------------------------
* 1.0  5/15/12  First release
*
*
******************************************************************************/

#ifndef XPMON_BE_H
#define XPMON_BE_H

#ifdef __cplusplus
extern "C" {
#endif

/***************************** Include Files *********************************/


/************************** Constant Definitions *****************************/

/* Defining constants require us to decide upon four things
 *   1. Type or magic number (type)
 *   2. Sequence number which is eight bits wide. This means we can have up 
 *      to 256 IOCTL commands (nr)
 *   3. Direction, whether we are reading or writing 
 *   4. Size of user data involved
 *      
 *  To arrive at unique numbers easily, we use the following macros:
 *  _IO(type, nr);
 *  _IOW(type, nr, dataitem) 
 *  _IOR(type, nr, dataitem)
 *  _IOWR(type, nr, dataitem)
 */

/* Selecting magic number for our ioctls */
#define XPMON_MAGIC 'C'     /**< Magic number for use in IOCTLs */

//#ifdef PM_SUPPORT
#define XPMON_MAX_CMD 19     /**< Total number of IOCTLs */
//#else
//#define XPMON_MAX_CMD 11     /**< Total number of IOCTLs */
//#endif

/** Get the current test state from the driver */
#define IGET_TEST_STATE     _IOR(XPMON_MAGIC, 1, TestCmd)

/** Start a test in the driver */
#define ISTART_TEST         _IOW(XPMON_MAGIC, 2, TestCmd)

/** Stop a test in the driver */
#define ISTOP_TEST          _IOW(XPMON_MAGIC, 3, TestCmd)

/** Get PCIe state from the driver */
#define IGET_PCI_STATE      _IOR(XPMON_MAGIC, 4, PCIState)

/** Get DMA engine state from the driver */
#define IGET_ENG_STATE      _IOR(XPMON_MAGIC, 5, EngState)

/** Get DMA engine statistics from the driver */
#define IGET_DMA_STATISTICS _IOR(XPMON_MAGIC, 6, EngStatsArray)

/** Get PCIe TRN engine statistics from the driver */
#define IGET_TRN_STATISTICS _IOR(XPMON_MAGIC, 7, TRNStatsArray)

/** Get driver software statistics from the driver */
#define IGET_SW_STATISTICS  _IOR(XPMON_MAGIC, 8, SWStatsArray)

/** Get Tx done statistics from the driver queue */
#define IGET_TRN_TXUSRINFO _IOR(XPMON_MAGIC, 9, TxUsrInfo)

/** Get Rx packets from the driver queue */
#define IGET_TRN_RXUSRINFO _IOR(XPMON_MAGIC, 10, RxUsrInfo)

/** Get Led stats for PHY and DDR3 calibration */
#define IGET_LED_STATISTICS _IOR(XPMON_MAGIC, 11, LedStats)

//#ifdef PM_SUPPORT
/** Set PCIe Link Speed in the driver */
#define ISET_PCI_LINKSPEED  _IOW(XPMON_MAGIC, 12, DirectLinkChg)

/** Set PCIe Link Width in the driver */
#define ISET_PCI_LINKWIDTH  _IOW(XPMON_MAGIC, 13, DirectLinkChg)

/** Set PCIe in suspend state (to test runtime_suspend) */
#define ISET_PCI_RUNTIME_SUSPEND    _IOR(XPMON_MAGIC, 14, PCIState)

/** Set PCIe in resume state (to test runtime_resume) */
#define ISET_PCI_RUNTIME_RESUME    _IOR(XPMON_MAGIC, 15, PCIState)
/** Power monitoring values update */

//#endif
#define IGET_PMVAL _IOR(XPMON_MAGIC, 16, PowerMonitorVal)

#define IGET_BARINFO _IOR(XPMON_MAGIC, 17, EndpointInfo)

#define ISET_SOBEL_THRSLD _IOW(XPMON_MAGIC, 18, TestCmd)

#define ISET_RESET_VDMA _IOW(XPMON_MAGIC, 19, TestCmd)

/* State of test - shared in TestMode flag */
#define TEST_STOP           0x00000000  /**< Stop the test */
#define TEST_START          0x00008000  /**< Start the test */
#define TEST_IN_PROGRESS    0x00004000  /**< Test is in progress */

#define ENABLE_PKTCHK             0x00000100  /**< Enable TX-side packet checker */
#define ENABLE_PKTGEN             0x00000400  /**< Enable RX-side packet generator */
#define ENABLE_LOOPBACK           0x00000200  /**< Enable loopback mode in test */
#define ENABLE_CRISCROSS          0x00002000  /**< Enable loopback mode in CRISCROSS test */
#define ENABLE_SOBELFILTER        0x00010000  /**< Enable SobelFilter mode in Zynq */
#define ENABLE_SOBELFILTER_SW     0x00020000  /**< Enable SobelFilter in Software  */
#define ENABLE_VIDEOLOOPBACK      0x00040000  /**< Enable VideoLoop back to host   */
#define ENABLE_MOVINGVIDEO        0x00100000  /**< Enable Moving Video Generation   */
#define ENABLE_SOBELFILTER_INVERT 0x00080000  /**< Enable Inverted SobelFilter  */

#define SOBEL_MIN_COEF_MASK       0x000000FF
#define SOBEL_MAX_COEF_MASK       0xFF000000

/* Link States */
#define LINK_UP             1           /**< Link State is Up */
#define LINK_DOWN           0           /**< Link State is Down */

/* PCI-related states */
#define INT_MSIX            0x3         /**< MSI-X Interrupts capability */
#define INT_MSI             0x2         /**< MSI Interrupts capability */
#define INT_LEGACY          0x1         /**< Legacy Interrupts capability */
#define INT_NONE            0x0         /**< No Interrupt capability */
#define LINK_SPEED_25       1           /**< 2.5 Gbps */
#define LINK_SPEED_5        2           /**< 5 Gbps */

/* The following initialisation should be changed in case of any changes in
 * the hardware demo design.
 */

#define MAX_ENGS    4       /**< Max DMA engines being used in this design */
#define MAX_TRN     2       /**< Max TRN types being used in this design */
#define MAX_BARS    6
#define TX_MODE     0x1     /**< Incase there are screens specific to TX */
#define RX_MODE     0x2     /**< Incase there are screens specific to RX */
#define MAX_SIZE_DONE 100    /**< Max size of pkts that user App can handle */

#define TX_CONFIG_SEQNO 512  /**< Sequence number wrap around */

#ifdef RES_720P
#define FRAME_PIXEL_ROWS    720
#define FRAME_PIXEL_COLS    1280
#else
#define FRAME_PIXEL_ROWS    1080
#define FRAME_PIXEL_COLS    1920
#endif
#define NUM_BYTES_PIXEL     4
#define NUM_PARLEL_BUFFS    3
#define NUM_BLANK_FRAMES    4

/***************** Macros (Inline Functions) Definitions *********************/

#define SET_SOBEL_MIN_COEF(x,y) \
{                               \
    y = y & SOBEL_MIN_COEF_MASK;\
    x = x | y;                  \
} 

#define SET_SOBEL_MAX_COEF(x,y)   \
{                                 \
    y = y << 24;                  \
    y = y & SOBEL_MAX_COEF_MASK;  \
    x = x | y;                    \
}



/**************************** Type Definitions *******************************/

/** Structure used in IOCTL to get PCIe state from driver */
typedef struct {
    unsigned int Version;       /**< Hardware design version info */
    int LinkState;              /**< Link State - up or down */
    int LinkSpeed;              /**< Link Speed */
    int LinkWidth;              /**< Link Width */
	int LinkUpCap;              /**< Link up configurable capability */
    unsigned int VendorId;      /**< Vendor ID */
    unsigned int DeviceId;      /**< Device ID */
    int IntMode;                /**< Legacy or MSI interrupts */
    int MPS;                    /**< Max Payload Size */
    int MRRS;                   /**< Max Read Request Size */
    int InitFCCplD;             /**< Initial FC Credits for Completion Data */
    int InitFCCplH;             /**< Initial FC Credits for Completion Header */
    int InitFCNPD;              /**< Initial FC Credits for Non-Posted Data */
    int InitFCNPH;              /**< Initial FC Credits for Non-Posted Data */
    int InitFCPD;               /**< Initial FC Credits for Posted Data */
    int InitFCPH;               /**< Initial FC Credits for Posted Data */
} PCIState;

/** Structure used in IOCTL to get DMA engine state from driver */
typedef struct {
    int Engine;                 /**< Engine Number */
    int SrcSglBD;                    /**< Total Number of BDs */
    int DstSglBD;
    int SrcStatsBD;
    int DstStatsBD;	

    unsigned int MinPktSize;    /**< Minimum packet size */
    unsigned int MaxPktSize;    /**< Maximum packet size */
    int SrcErrors;                 /**< Total BD errors */
    int DstErrors;
    int IntErrors;	
    int DataMismatch;           /**<  Data Mismatch error */
    int IntEnab;                /**< Interrupts enabled or not */
    unsigned int TestMode;      /**< Current Test Mode */
} EngState;

/** Structure used to hold DMA engine statistics */
typedef struct {
    int Engine;                 /**< Engine Number */
    unsigned int LBR;           /**< Last Byte Rate */
    unsigned int LAT;           /**< Last Active Time */
    unsigned int LWT;           /**< Last Wait Time */
                int scaling_factor;
} DMAStatistics;

/** Structure used in IOCTL to get DMA engine statistics from driver */
typedef struct {
    int Count;                  /**< Number of statistics captures */
    DMAStatistics * engptr;     /**< Pointer to array to store statistics */
} EngStatsArray;

/** Structure used to hold PCIe TRN statistics */
typedef struct {
    unsigned int LTX;           /**< Last TX Byte Rate */
    unsigned int LRX;           /**< Last RX Byte Rate */
    unsigned int WBC_APM0;  /**< Write Byte Count APM */
    unsigned int RBC_APM0; 	/**< Read Byte Count APM */	
    unsigned int WBC_APM1;  /**< Write Byte Count APM */
    unsigned int RBC_APM1; 	/**< Read Byte Count APM */	
    unsigned int WBC_DDR;
    unsigned int RBC_DDR;
    int scaling_factor; 		/**< Scalling factor */
} TRNStatistics;

/** Structure used in IOCTL to get PCIe TRN statistics from driver */
typedef struct {
    int Count;                  /**< Number of statistics captures */
    TRNStatistics * trnptr;     /**< Pointer to array to store statistics */
} TRNStatsArray;

/** Structure used to hold software statistics */
typedef struct {
    int Engine;                 /**< Engine Number */
    unsigned int LBR;           /**< Last Byte Rate */
} SWStatistics;

/** Structure used in IOCTL to get software statistics from driver */
typedef struct {
    int Count;                  /**< Number of statistics captures */
    SWStatistics * swptr;       /**< Pointer to array to store statistics */
} SWStatsArray;

//#ifdef PM_SUPPORT
typedef struct {
    int LinkSpeed;              /**< Direct change in Link Speed */
    int LinkWidth;              /**< Direct change in Link Width */
} DirectLinkChg;


//#endif

typedef struct {
    int vcc;          /*VCCINT Power     Consumption 0x9040 */
    int vccaux;       /*VCCAUX Power     Consumption 0x9044 */
    int vcc3v3;       /*VCC3V3 Power     Consumption 0x9048 */
    int vadj;         /*VADJ                         0x904C */
    int vcc2v5;       /*VCC2V5 Power     Consumption 0x9050 */
    int vcc1v5;       /*VCC1V5 Power     Consumption 0x9054 */ 
    int mgt_avcc;     /*MGT_AVCC Power   Consumption 0x9058 */
    int mgt_avtt;     /*MGT_AVTT Power   Consumption 0x905C */
    int vccaux_io;    /*VCCAUX_IO Power  Consumption 0x9060 */
    int vccbram;      /*VCCBRAM Power    Consumption 0x9064 */
    int mgt_vccaux;   /*MGT_VCCAUX Power Consumption 0x9068 */
    int pwr_rsvd;     /*RESERVED                     0x906C */
    int die_temp;     /*DIE TEMPERATURE              0x9070 */
}PowerMonitorVal;


/** Structure used in IOCTL to start/stop a test & to get current test state */
typedef struct {
    int Engine;                 /**< Engine Number */
    unsigned int TestMode;      /**< Test Mode - Enable TX, Enable loopback */
    unsigned int MinPktSize;    /**< Min packet size */
    unsigned int MaxPktSize;    /**< Max packet size */
} TestCmd;



typedef struct {
		int DdrCalib0;		    /**< DDR3 calibration statistics */
		int DdrCalib1;		    /**< DDR3 calibration statistics */
	int Phy0;                   /**< PHY0 Link status */
	int Phy1;                   /**< PHY1 Link status */
		int Phy2;		    	/**< PHY2 Link status */
		int Phy3;		    	/**< PHY3 Link status */
} LedStats;

typedef struct
{
	unsigned int buffSize;      /**< Size of the buffer received/transmitted */
	char *bufferAddress;		/**< Buffer Address received/transmitted */
        char *endAddress;
        unsigned int endSize;
        int noPages;
}BufferInfo;

#define MAX_LIST 1024
typedef struct
{
	BufferInfo buffList[MAX_LIST];  /**< Array of buffers Transmitted/received */
	unsigned int expected;			/**< Expected  number of buffers from driver */
}FreeInfo;


typedef struct {
	char* usrBuf;				/**< User buffer address */
	int pktSize;				/**< User Transmit packet Size */
} TxUsrInfo;

typedef struct {				
	char* usrBuf;				/**< User buffer address */
    int pktSize;				/**< User Receive packet Size */
} RxUsrInfo;
typedef struct
{
       int bar;
       unsigned int offset;                  /**< Size of the buffer received/transmitted */
       int * bufferAddress;		/**< Buffer Address received/transmitted */
       unsigned int size;                   /**< Size of the buffer received/transmitted */   
}readdata,writedata;

typedef struct
{
 unsigned long BarAddress;
 unsigned long BarSize;
}BarInfo;


typedef struct
{

	int designMode;
	int barmask;
	BarInfo BarList[MAX_BARS];
}EndpointInfo;

typedef struct {
    char *pktAdrs;
    char frameDelimiter;
    int pktSize;
}TxWriteInfo;

/************************** Function Prototypes ******************************/


#ifdef __cplusplus
}
#endif

#endif  /* end of protection macro */

