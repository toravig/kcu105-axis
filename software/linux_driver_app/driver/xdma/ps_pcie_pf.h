#ifndef _PF_H
#define _PF_H

//#define XILINX_PCIE_EP //TODO This has to come from makefile


#define TEST_DBG_ON //Testing & debug code enable

#ifdef XILINX_PCIE_EP
#define PFORM_RONALDO
#else
//#define PFORM_USCALE_NO_EP_PROCESSOR
#define HW_SGL_DESIGN //SGL on EP side is managed by HW logic
//#define DDR_DESIGN
//#define VIDEO_ACC_DESIGN
//#define ETH_APP
#endif

#endif
