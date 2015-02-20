
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
/*****************************************************************************/
/**
*
* @file xdebug.h
*
* This file contains logging tools for Xilinx software IP. 
*
* @note
*
* This file contains items which are architecture dependent.
*
* MODIFICATION HISTORY:
*
* Ver     Date   Changes
* ----- -------- -------------------------------------------------------
* 1.0    5/15/12 First release
*
******************************************************************************/

/***************************** Include Files *********************************/

#ifdef __cplusplus
extern "C" {
#endif


/************************** Constant Definitions *****************************/

#ifndef XDEBUG  /* prevent circular inclusions */
#define XDEBUG  /* by using protection macros */

//#define MYDEBUG
#if defined(MYDEBUG) && !defined(NDEBUG)

#ifndef XDEBUG_WARNING
#define XDEBUG_WARNING
//#warning DEBUG is enabled
#endif 

#define XDBG_DEBUG_ERROR             0x00000001 /**< error condition messages */
#define XDBG_DEBUG_GENERAL           0x00000002 /**< general debug  messages */
#define XDBG_DEBUG_ALL               0xFFFFFFFF /**< all debugging data */

#define XDBG_DEBUG_FIFO_REG          0x00000100 /**< display register reads/writes */
#define XDBG_DEBUG_FIFO_RX           0x00000101 /**< receive debug messages */
#define XDBG_DEBUG_FIFO_TX           0x00000102 /**< transmit debug messages */
#define XDBG_DEBUG_FIFO_ALL          0x0000010F /**< all fifo debug messages */

#define XDBG_DEBUG_TEMAC_REG         0x00000400 /**< display register reads/writes */
#define XDBG_DEBUG_TEMAC_RX          0x00000401 /**< receive debug messages */
#define XDBG_DEBUG_TEMAC_TX          0x00000402 /**< transmit debug messages */
#define XDBG_DEBUG_TEMAC_ALL         0x0000040F /**< all temac  debug messages */

#define XDBG_DEBUG_TEMAC_ADPT_RX     0x00000800 /**< receive debug messages */
#define XDBG_DEBUG_TEMAC_ADPT_TX     0x00000801 /**< transmit debug messages */
#define XDBG_DEBUG_TEMAC_ADPT_IOCTL  0x00000802 /**< ioctl debug messages */
#define XDBG_DEBUG_TEMAC_ADPT_MISC   0x00000803 /**< debug msg for other routines */
#define XDBG_DEBUG_TEMAC_ADPT_ALL    0x0000080F /**< all temac adapter debug messages */

#define xdbg_current_types (XDBG_DEBUG_ERROR | XDBG_DEBUG_GENERAL | XDBG_DEBUG_TEMAC_REG)

#define xdbg_stmnt(x)  x
#define xdbg_printf(type, ...) (((type) & xdbg_current_types) ? printk (__VA_ARGS__) : 0)

#else
#define xdbg_stmnt(x)
#define xdbg_printf(...)
#endif


/**************************** Type Definitions *******************************/


/***************** Macros (Inline Functions) Definitions *********************/

/* Macros for handling normal and verbose logging in adapter and DMA code */

#ifdef DEBUG_VERBOSE /* Enable both normal and verbose logging */

#define log_verbose(args...)    printk(args)
#define log_normal(args...)     printk(args)

#elif defined DEBUG_NORMAL /* Enable only normal logging */

#define log_verbose(x...)
#define log_normal(args...)     printk(args)

#else

#define log_normal(x...)
#define log_verbose(x...)

#endif /* DEBUG_VERBOSE and DEBUG_NORMAL */


/************************** Function Prototypes ******************************/

#ifdef __cplusplus
}
#endif

#endif /* XDEBUG */ /* end of protection macro */
