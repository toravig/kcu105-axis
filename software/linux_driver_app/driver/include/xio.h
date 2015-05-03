
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
* @file xio.h
*
* This file contains the Input/Output functions, and the changes
* required for swapping endianness. 
*
* MODIFICATION HISTORY:
*
* Ver   Date     Changes
* ----- -------- -------------------------------------------------------
* 1.0   5/15/12 First release
*
******************************************************************************/

#ifndef XIO_H           /* prevent circular inclusions */
#define XIO_H           /* by using protection macros */

#ifdef __cplusplus
extern "C" {
#endif

/***************************** Include Files *********************************/

#include "xbasic_types.h"


/************************** Constant Definitions *****************************/


/**************************** Type Definitions *******************************/

/**
 * Typedef for an I/O address.  Typically correlates to the width of the
 * address bus.
 */
typedef Xuint32 XIo_Address;

/***************** Macros (Inline Functions) Definitions *********************/

/* The following macro is specific to the GNU compiler. It performs an 
 * EIEIO instruction such that I/O operations are synced correctly.
 * This macro is not necessarily portable across compilers since it uses
 * inline assembly.
 */
#if defined __GNUC__
#  define SYNCHRONIZE_IO __asm__ volatile ("eieio")
#else
#  define SYNCHRONIZE_IO
#endif

/* The following macros allow the software to be transportable across
 * processors which use big or little endian memory models.
 *
 * Defined first are processor-specific endian conversion macros specific to
 * the GNU compiler and the x86 family, as well as a no-op endian conversion
 * macro. These macros are not to be used directly by software. Instead, the
 * XIo_To/FromLittleEndianXX and XIo_To/FromBigEndianXX macros below are to be
 * used to allow the endian conversion to only be performed when necessary.
 */

#define XIo_EndianNoop(Source, DestPtr)    (*DestPtr = Source)

#if defined __GNUC__ && !defined X86_PC

#define XIo_EndianSwap16(Source, DestPtr)  __asm__ __volatile__(\
                                           "sthbrx %0,0,%1\n"\
                                           : : "r" (Source), "r" (DestPtr)\
                                           )

#define XIo_EndianSwap32(Source, DestPtr)  __asm__ __volatile__(\
                                           "stwbrx %0,0,%1\n"\
                                           : : "r" (Source), "r" (DestPtr)\
                                           )
#else

#define XIo_EndianSwap16(Source, DestPtr) \
{\
   Xuint16 src = (Source); \
   Xuint16 *destptr = (DestPtr); \
   *destptr = src >> 8; \
   *destptr |= (src << 8); \
}

#define XIo_EndianSwap32(Source, DestPtr) \
{\
   unsigned int src = (Source); \
   unsigned int *destptr = (DestPtr); \
   *destptr = src >> 24; \
   *destptr |= ((src >> 8)  & 0x0000FF00); \
   *destptr |= ((src << 8)  & 0x00FF0000); \
   *destptr |= ((src << 24) & 0xFF000000); \
}

#endif

#ifdef XLITTLE_ENDIAN
/* little-endian processor */

#define XIo_ToLittleEndian16                XIo_EndianNoop
#define XIo_ToLittleEndian32                XIo_EndianNoop
#define XIo_FromLittleEndian16              XIo_EndianNoop
#define XIo_FromLittleEndian32              XIo_EndianNoop

#define XIo_ToBigEndian16(Source, DestPtr)  XIo_EndianSwap16(Source, DestPtr)
#define XIo_ToBigEndian32(Source, DestPtr)  XIo_EndianSwap32(Source, DestPtr);
#define XIo_FromBigEndian16                 XIo_ToBigEndian16
#define XIo_FromBigEndian32(Source, DestPtr) XIo_ToBigEndian32(Source, DestPtr);

#else
/* big-endian processor */

#define XIo_ToLittleEndian16(Source, DestPtr) XIo_EndianSwap16(Source, DestPtr)
#define XIo_ToLittleEndian32(Source, DestPtr) XIo_EndianSwap32(Source, DestPtr)
#define XIo_FromLittleEndian16                XIo_ToLittleEndian16
#define XIo_FromLittleEndian32                XIo_ToLittleEndian32

#define XIo_ToBigEndian16                     XIo_EndianNoop
#define XIo_ToBigEndian32                     XIo_EndianNoop
#define XIo_FromBigEndian16                   XIo_EndianNoop
#define XIo_FromBigEndian32                   XIo_EndianNoop

#endif


/************************** Function Prototypes ******************************/

/* The following functions allow the software to be transportable across
 * processors which may use memory mapped I/O or I/O which is mapped into a
 * seperate address space such as X86.  The functions are better suited for
 * debugging and are therefore the default implementation. Macros can instead
 * be used if USE_IO_MACROS is defined.
 */
#ifndef USE_IO_MACROS

/* Functions */
Xuint8 XIo_In8(XIo_Address InAddress);
Xuint16 XIo_In16(XIo_Address InAddress);
Xuint32 XIo_In32(XIo_Address InAddress);

void XIo_Out8(XIo_Address OutAddress, Xuint8 Value);
void XIo_Out16(XIo_Address OutAddress, Xuint16 Value);
void XIo_Out32(XIo_Address OutAddress, Xuint32 Value);

#else

/* The following macros allow optimized I/O operations for memory mapped I/O
 * Note that the SYNCHRONIZE_IO may be moved by the compiler during
 * optimization.
 */

#ifdef X86_PC

#include <asm/io.h>

#ifdef NWLDMA
/* NWL DMA design is little-endian, so values need not be swapped.
 */
#define XIo_In32(addr)      (readl((unsigned int *)(addr)))
#define XIo_Out32(addr, data) (writel((data), (unsigned int *)(addr)))

#else                // NWLDMA

static inline unsigned int readbe2le(unsigned int * addr)
{
  unsigned int source, dest;
  source = readl(addr);
  XIo_FromBigEndian32(source, &dest);
  return dest;
}
static inline void writele2be(unsigned int data, unsigned int * addr)
{
  unsigned int wdest;
  XIo_ToBigEndian32((data), &wdest);
  writel(wdest, (unsigned long *)(addr));
}

#define XIo_In32(addr)      (readbe2le((unsigned int *)(addr)))
#define XIo_Out32(addr, data) (writele2be((data), (unsigned int *)(addr)))

#endif          // NWLDMA

#define Xil_In32    XIo_In32
#define Xil_Out32   XIo_Out32

#else           // X86_PC

#define XIo_In8(InputPtr)  (*(volatile Xuint8  *)(InputPtr)); SYNCHRONIZE_IO;
#define XIo_In16(InputPtr) (*(volatile Xuint16 *)(InputPtr)); SYNCHRONIZE_IO;
#define XIo_In32(InputPtr) (*(volatile Xuint32 *)(InputPtr)); SYNCHRONIZE_IO;

#define XIo_Out8(OutputPtr, Value)  \
    { (*(volatile Xuint8  *)(OutputPtr) = Value); SYNCHRONIZE_IO; }
#define XIo_Out16(OutputPtr, Value) \
    { (*(volatile Xuint16 *)(OutputPtr) = Value); SYNCHRONIZE_IO; }
#define XIo_Out32(OutputPtr, Value) \
    { (*(volatile Xuint32 *)(OutputPtr) = Value); SYNCHRONIZE_IO; }

#endif          // X86_PC 

#endif          // USE_IO_MACROS

/* The following functions handle IO addresses where data must be swapped
 * They cannot be implemented as macros
 */
Xuint16 XIo_InSwap16(XIo_Address InAddress);
Xuint32 XIo_InSwap32(XIo_Address InAddress);
void XIo_OutSwap16(XIo_Address OutAddress, Xuint16 Value);
void XIo_OutSwap32(XIo_Address OutAddress, Xuint32 Value);

#ifdef __cplusplus
}
#endif

#endif          /* end of protection macro */
