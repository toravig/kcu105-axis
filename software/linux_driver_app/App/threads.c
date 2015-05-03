
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
 * @file threads.c 
 *
 * Author: Xilinx, Inc.
 *
 * 2014-2015 (c) Xilinx, Inc. This file is licensed uner the terms of the GNU
 * General Public License version 2.1. This program is licensed "as is" without
 * any warranty of any kind, whether express or implied.
 *
 * MODIFICATION HISTORY:
 *
 * Ver   Date     Changes
 * ----- -------- -------------------------------------------------------
 * 1.0  1/1/14  First release
 *
 *****************************************************************************/

#include <stdio.h>
#include <errno.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/ioctl.h>
#include <fcntl.h>
#include <signal.h>
#include <ctype.h>
#include <pthread.h>
#include <xpmon_be.h>
#ifdef CRC_CHECK
#include <crc.h>
#endif

#include <sys/select.h>
#include <sys/socket.h>
#include <sys/un.h>

#define APP_SOCK_PATH "./xt_app_comm_socket"
#define GUI_SOCK_PATH "../gui/jnilib/src/xt_gui_comm_socket"
#define CHECK_INTERVAL 1
#define STAT_FILE_CHK_CMD "/usr/sbin/lsof /dev/xdma_stat 2>&1"



#ifdef DEBUG_VERBOSE /* Enable both normal and verbose logging */
#define log_verbose(args...)    printf(args)
#else
#define log_verbose(x...)
#endif


#define MIN_PKTSIZE 64
#define MAX_PKTSIZE (32*1024)



#define MAX_THREADS 8


#define PAGE_SIZE (4096)
#define BUFFER_SIZE (PAGE_SIZE * 2048 * 4)

static int TestStartFlag0=ENABLE_LOOPBACK;
static int TestStartFlag1=ENABLE_LOOPBACK;
static int TestStartFlag2=ENABLE_LOOPBACK;
static int TestStartFlag3=ENABLE_LOOPBACK;
unsigned short RxSeqNo0 = 0;
unsigned short RxSeqNo1 = 0;
unsigned short RxSeqNo2 = 0;
unsigned short RxSeqNo3 = 0;

unsigned int DbgSize = 0;

unsigned int rxPacketSent0=0;
unsigned int rxPacketSent1=0;
unsigned int rxPacketSent2=0;
unsigned int rxPacketSent3=0;

unsigned int RxBufferSize0 = BUFFER_SIZE;
unsigned int RxBufferSize1 = BUFFER_SIZE;
unsigned int RxBufferSize2 = BUFFER_SIZE;
unsigned int RxBufferSize3 = BUFFER_SIZE;
unsigned int ErrCnt0=0;
unsigned int ErrCnt1=0;
unsigned int ErrCnt2=0;
unsigned int ErrCnt3=0;
unsigned int WrongData0=0;
unsigned int WrongData1=0;
unsigned int WrongData2=0;
unsigned int WrongData3=0;
unsigned char * rxbuffer0=NULL;
unsigned char * rxbuffer1=NULL;
unsigned char * rxbuffer2=NULL;
unsigned char * rxbuffer3=NULL;


TestCmd * testCmd1;
TestCmd * testCmd2;

TestCmd testcmd0,testcmd1,testcmd2,testcmd3;

TestCmd  *localCmd2;

typedef struct DataVerifyStatus
{
	int engine;
	int ErrCnt;
}DataVerifyComm_t;

/**< Memory structure for sync up between Tx and Txdone */

typedef struct MemorySync
{
	unsigned long int iAvailableMemory; /**< Available memory */
	pthread_mutex_t iLock;				/**<  Lock for checking memory */
}MemorySync;

MemorySync TxDoneSync0={0,PTHREAD_MUTEX_INITIALIZER};
MemorySync TxDoneSync1={0,PTHREAD_MUTEX_INITIALIZER};
MemorySync TxDoneSync2={0,PTHREAD_MUTEX_INITIALIZER};
MemorySync TxDoneSync3={0,PTHREAD_MUTEX_INITIALIZER};

MemorySync RxDoneSync0={0,PTHREAD_MUTEX_INITIALIZER};
MemorySync RxDoneSync1={0,PTHREAD_MUTEX_INITIALIZER};
MemorySync RxDoneSync2={0,PTHREAD_MUTEX_INITIALIZER};
MemorySync RxDoneSync3={0,PTHREAD_MUTEX_INITIALIZER};



// function uses memorysync structure to init/reserve/free memory availability status
int initMemorySync (MemorySync*, unsigned long int totalMemory);
int ReserveAvailable(MemorySync *, unsigned int requested);
int FreeAvailable(MemorySync *, unsigned int completed);
int UpdateAvailable(MemorySync *, int engine );
// function checks if gui is running or not
int check_gui_present();

pthread_t threads[MAX_THREADS];
int thread_done[MAX_THREADS];
int thread0_exit;
int thread1_exit;
int thread2_exit;
int thread3_exit;

int xlnx_thread_create(void *fp(void *),void *data);
void * txthread_ioctl(TestCmd *);
void * txthread_write(TestCmd *);
void * rxthread_write(TestCmd *);
void * rxthread_ioctl(TestCmd *);
void * LBthread_write(TestCmd *);
void * LBthread_Xcross_write(TestCmd *);
int sendDataVerifyStatus(DataVerifyComm_t dcomm);

void sigint_callback_handler(int signum);
void sigsegv_callback_handler(int signum);
void sigterm_callback_handler(int signum);
char sigint_recv;
char sigterm_recv;
char sigsegv_recv;  

int getErrorCount0(){
	return ErrCnt0;
}

int getErrorCount1(){
	return ErrCnt1;
}
int getErrorCount2(){
	return ErrCnt2;
}
int getErrorCount3(){
	return ErrCnt3;
}

/* Stop the running test */
int StopTest(int engine, int testmode, int maxSize)
{
	int retval=0;
	TestCmd testCmd;
	int i=0;

	testCmd.Engine = engine;
	testCmd.TestMode = testmode;
	testCmd.MaxPktSize = maxSize;

	testCmd.TestMode &= ~(TEST_START);
	log_verbose("mode is %x\n", testCmd.TestMode);


	/* Clear test flag */
	if(engine == 0) 
	{

		TestStartFlag0 &= ~(TEST_START);

		//log_verbose("TestStartFlag0 is %x Size %d\n", TestStartFlag0,testCmd1->MinPktSize);
	}
	else if(engine ==1) 
	{
		TestStartFlag1 &= ~(TEST_START);

		//log_verbose("TestStartFlag1 is %x Size %d\n", TestStartFlag1,testCmd2->MinPktSize);
	}
	else if(engine ==2) 
	{
		TestStartFlag2 &= ~(TEST_START);

		//log_verbose("TestStartFlag2 is %x Size %d\n", TestStartFlag2,testCmd2->MinPktSize);
	}
	else if(engine ==3) 
	{
		TestStartFlag3 &= ~(TEST_START);

		//log_verbose("TestStartFlag3 is %x Size %d\n", TestStartFlag3,testCmd2->MinPktSize);
	}

	if(engine == 0)
	{
		thread0_exit = 1;    
		//	while(thread0_exit);

		for(i=0;i< 4;i++)
		{ 
			while(thread_done[i]==1);
		}
		log_verbose("\n#TxAvail0 %d RxAvail0 %d DataMismatch %d \n",TxDoneSync0.iAvailableMemory,RxDoneSync0.iAvailableMemory,WrongData0); 
	}
	else if(engine == 1)
	{
		thread1_exit = 1;   

		for(i=4;i< 8;i++)
		{ 
			while(thread_done[i]==1);
		}
		log_verbose("\n#TxAvail1 %d RxAvail1 %d DataMismAtch %d \n",TxDoneSync1.iAvailableMemory,RxDoneSync1.iAvailableMemory,WrongData1); 
	}
	else if(engine == 2)
	{
		thread2_exit = 1;   

		for(i=8;i< 12;i++)
		{ 
			while(thread_done[i]==1);
		}
		log_verbose("\n#TxAvail2 %d RxAvail2 %d DataMismAtch %d \n",TxDoneSync2.iAvailableMemory,RxDoneSync2.iAvailableMemory,WrongData2); 
	}
	else if(engine == 3)
	{
		thread3_exit = 1;   

		for(i=12;i< 16;i++)
		{ 
			while(thread_done[i]==1);
		}
		log_verbose("\n#TxAvail3 %d RxAvail3 %d DataMismAtch %d \n",TxDoneSync3.iAvailableMemory,RxDoneSync3.iAvailableMemory,WrongData3); 
	}



	log_verbose("##Thread %d %d %d %d %d %d %d %d is running##\n",thread_done[0],thread_done[1],thread_done[2],thread_done[3],thread_done[4],thread_done[5],thread_done[6],thread_done[7]);
	log_verbose("Test stopped\n");

	return retval;
}

int StartTest(int engine, int testmode, int maxSize)
{


	int retval=0;
	TestCmd testCmd;
	int i, ret0,ret1,ret2,ret3,ret4;



	testCmd.Engine = engine;
	testCmd.TestMode = testmode;
	testCmd.MaxPktSize = maxSize; 
printf("\n###Test mode %d ###\n",testmode);
	
	testCmd.TestMode |= TEST_START;
#ifdef RAW_ETH 
	testCmd.TestMode = ENABLE_PKTCHK | ENABLE_PKTGEN;
	testCmd.TestMode |= ENABLE_CRISCROSS;
#endif

	if(engine == 0)
	{ 
		for(i=0;i< 4;i++)
		{ 
			while(thread_done[i]==1);
		}
		thread0_exit = 0;
		ErrCnt0 = 0;
		RxSeqNo0=0;
	}
	else if(engine == 1)
	{
		for(i=4;i< 8;i++)
		{ 
			while(thread_done[i]==1);
		}
		thread1_exit = 0;
		ErrCnt1 = 0;
		RxSeqNo1=0;
	}
	else if(engine == 2)
	{
		for(i=8;i< 12;i++)
                { 
                        while(thread_done[i]==1);
                }
                thread2_exit = 0;
                ErrCnt2 = 0;
                RxSeqNo2=0;

	}
	else if(engine == 3)
	{
		for(i=12;i< 16;i++)
                { 
                        while(thread_done[i]==1);
                }
                thread3_exit = 0;
                ErrCnt3 = 0;
                RxSeqNo3=0;

	}

	log_verbose("mode is %x engine is %d\n", testCmd.TestMode,testCmd.Engine);



	/* Set test flag */
	if(engine == 0) 
	{
		memcpy(&testcmd0,&testCmd,sizeof(TestCmd));
		log_verbose("TestStartFlag0 is %x size %d\n", TestStartFlag0);
#if 1
		if((testCmd.TestMode & ENABLE_LOOPBACK) || ((testCmd.TestMode & (ENABLE_PKTCHK)) && (testCmd.TestMode & ENABLE_PKTGEN)))
		{
#if 0
#if 1
			if(thread_done[0] == 0)
				ret1 = xlnx_thread_create(&txthread_write, &testcmd0);
			else
			{
				printf("Exiting at %d %s()\n",__LINE__,__FUNCTION__);
				exit(-1);
			}

			if (ret1){
				printf("ERROR; return code from pthread_create() is %d\n", ret1);
				exit(-1);
			}
#if 0   
			ret2 = xlnx_thread_create(&txthread_ioctl, &testCmd);

			if (ret2){
				printf("ERROR; return code from pthread_create() is %d\n", ret2);
				exit(-1);
			}
#endif      
#endif
#if 1             
			if(rxbuffer0 == NULL) {
				rxbuffer0 =(char *) valloc(BUFFER_SIZE);

				if(!rxbuffer0)
				{
					printf("Unable to allocate memory \n");
					exit(-1);
				}
				log_verbose("\n##Alloc Sucess %x ##\n",rxbuffer0);
			}	 

			if(thread_done[2] == 0)
			{
				if(testCmd.TestMode &  ENABLE_CRISCROSS)
					ret3 = xlnx_thread_create(&LBthread_Xcross_write, &testcmd0);
				else 
					ret3 = xlnx_thread_create(&LBthread_write, &testcmd0);
			}
			else
			{
				printf("Exiting at %d %s()\n",__LINE__,__FUNCTION__);
				exit(-1);
			}

			if (ret3){
				printf("ERROR; return code from pthread_create() is %d\n", ret3);
				exit(-1);
			}
#if 1       
			if(thread_done[3] == 0)
			{
				log_verbose("Starting rxthread_ioctl with engine number %d at %d and %s()\n",testCmd.Engine,__LINE__,__FUNCTION__);
				ret4 = xlnx_thread_create(&rxthread_ioctl, &testcmd0);
			}
			else
			{
				log_verbose("Exiting at %d %s()\n",__LINE__,__FUNCTION__);
				exit(-1);
			}

			if (ret4){
				printf("ERROR; return code from pthread_create() is %d\n", ret4);
				exit(-1);
			}
#endif       
#endif
#endif
		}
		if(testCmd.TestMode & (ENABLE_PKTCHK))  
		{
#if 1
			if(thread_done[0] == 0)
				ret1 = xlnx_thread_create(&txthread_write, &testcmd0);
			else
			{
				printf("Exiting at %d %s()\n",__LINE__,__FUNCTION__);
				exit(-1);
			}

			if (ret1){
				printf("ERROR; return code from pthread_create() is %d\n", ret1);
				exit(-1);
			}
#if 1   
			if(thread_done[1] == 0)
				ret2 = xlnx_thread_create(&txthread_ioctl, &testcmd0);
			else
			{
				printf("Exiting at %d %s()\n",__LINE__,__FUNCTION__);
				exit(-1);
			}

			if (ret2){
				printf("ERROR; return code from pthread_create() is %d\n", ret2);
				exit(-1);
			}
#endif
#endif
		}
		if(testCmd.TestMode & (ENABLE_PKTGEN))  
		{
#if 1
			if(rxbuffer0 == NULL) {  
				rxbuffer0 =(char *) valloc(BUFFER_SIZE);
				if(!rxbuffer0)
				{
					printf("Unable to allocate memory \n"); 
					exit(-1); 
				}
				log_verbose("\n##Alloc Sucess %x ##\n",rxbuffer0);
			}	  

			if(thread_done[2] == 0)
				ret3 = xlnx_thread_create(&rxthread_write, &testcmd0);
			else
			{
				printf("Exiting at %d %s()\n",__LINE__,__FUNCTION__);
				exit(-1);
			}

			if (ret3){
				printf("ERROR; return code from pthread_create() is %d\n", ret3);
				exit(-1);
			}
#if 1       
			if(thread_done[3] == 0)
			{
				log_verbose("Starting rxthread_ioctl with engine number %d at %d and %s()\n",testCmd.Engine,__LINE__,__FUNCTION__);
				ret4 = xlnx_thread_create(&rxthread_ioctl, &testcmd0);
			}
			else
			{
				printf("Exiting at %d %s()\n",__LINE__,__FUNCTION__);
				exit(-1);
			}

			if (ret4){
				printf("ERROR; return code from pthread_create() is %d\n", ret4);
				exit(-1);
			}
#endif
#endif

		}

#endif






	}
	else if(engine == 1) 
	{
		log_verbose("Test 2 started"); 
		memcpy(&testcmd1,&testCmd,sizeof(TestCmd));
		//log_verbose("TestStartFlag1 is %x Size %d \n", TestStartFlag1,testCmd2->MinPktSize);

#if 1
		if((testCmd.TestMode & ENABLE_LOOPBACK) || ((testCmd.TestMode & (ENABLE_PKTCHK)) && (testCmd.TestMode & ENABLE_PKTGEN)))
		{
#if 0
			if(thread_done[4] == 0)
				ret1 = xlnx_thread_create(&txthread_write, &testcmd1);
			else
			{
				printf("Exiting at %d %s()\n",__LINE__,__FUNCTION__);
				exit(-1);
			}

			if (ret1){
				printf("ERROR; return code from pthread_create() is %d\n", ret1);
				exit(-1);
			}
#if 0   
			ret2 = xlnx_thread_create(&txthread_ioctl, &testCmd);

			if (ret2){
				printf("ERROR; return code from pthread_create() is %d\n", ret2);
				exit(-1);
			}
#endif      
#endif
#if 0             
			if(rxbuffer1 == NULL) {
				rxbuffer1 =(char *) valloc(BUFFER_SIZE);
				if(!rxbuffer1)
				{
					printf("Unable to allocate memory \n");
					exit(-1);
				}
				log_verbose("\n##Alloc Sucess %x ##\n",rxbuffer1);
			}	 
			if(thread_done[6] == 0)
			{        
				if(testCmd.TestMode & ENABLE_CRISCROSS)
					ret3 = xlnx_thread_create(&LBthread_Xcross_write, &testcmd1);
				else 
					ret3 = xlnx_thread_create(&LBthread_write, &testcmd1);
			}
			else
			{
				printf("Exiting at %d %s()\n",__LINE__,__FUNCTION__);
				exit(-1);
			}

			if (ret3){
				printf("ERROR; return code from pthread_create() is %d\n", ret3);
				exit(-1);
			}
#if 1       
			if(thread_done[7] == 0)
			{
				log_verbose("Starting rxthread_ioctl with engine number %d at %d and %s()\n",testCmd.Engine,__LINE__,__FUNCTION__);
				ret4 = xlnx_thread_create(&rxthread_ioctl, &testcmd1);
			}
			else
			{
				printf("Exiting at %d %s()\n",__LINE__,__FUNCTION__);
				exit(-1);
			}

			if (ret4){
				printf("ERROR; return code from pthread_create() is %d\n", ret4);
				exit(-1);
			}
#endif       
#endif
		}
		if(testCmd.TestMode & (ENABLE_PKTCHK))  
		{
#if 1
			if(thread_done[4] == 0)
				ret1 = xlnx_thread_create(&txthread_write, &testcmd1);
			else
			{
				printf("Exiting at %d %s()\n",__LINE__,__FUNCTION__);
				exit(-1);
			}

			if (ret1){
				printf("ERROR; return code from pthread_create() is %d\n", ret1);
				exit(-1);
			}
#if 1   
			if(thread_done[5] == 0)
				ret2 = xlnx_thread_create(&txthread_ioctl, &testcmd1);
			else
			{
				printf("Exiting at %d %s()\n",__LINE__,__FUNCTION__);
				exit(-1);
			}

			if (ret2){
				printf("ERROR; return code from pthread_create() is %d\n", ret2);
				exit(-1);
			}
#endif
#endif
		}
		if(testCmd.TestMode & (ENABLE_PKTGEN))  
		{
#if 1
			if(rxbuffer1 == NULL) {  
				rxbuffer1 =(char *) valloc(BUFFER_SIZE);
				if(!rxbuffer1)
				{
					printf("Unable to allocate memory \n"); 
					exit(-1); 
				}
				log_verbose("\n##Alloc Sucess %x ##\n",rxbuffer1);
			}	  

			if(thread_done[6] == 0)
				ret3 = xlnx_thread_create(&rxthread_write, &testcmd1);
			else
			{
				printf("Exiting at %d %s()\n",__LINE__,__FUNCTION__);
				exit(-1);
			}

			if (ret3){
				printf("ERROR; return code from pthread_create() is %d\n", ret3);
				exit(-1);
			}
#if 1       
			if(thread_done[7] == 0)
			{
				log_verbose("Starting rxthread_ioctl with engine number %d at %d and %s()\n",testCmd.Engine,__LINE__,__FUNCTION__);
				ret4 = xlnx_thread_create(&rxthread_ioctl, &testcmd1);
			}
			else
			{
				printf("Exiting at %d %s()\n",__LINE__,__FUNCTION__);
				exit(-1);
			}

			if (ret4){
				printf("ERROR; return code from pthread_create() is %d\n", ret4);
				exit(-1);
			}
#endif
#endif

		}

#endif

	}
	else if(engine == 2) 
	{
		memcpy(&testcmd2,&testCmd,sizeof(TestCmd));
		log_verbose("TestStartFlag2 is %x size %d\n", TestStartFlag2);
#if 1
		if((testCmd.TestMode & ENABLE_LOOPBACK) || ((testCmd.TestMode & (ENABLE_PKTCHK)) && (testCmd.TestMode & ENABLE_PKTGEN)))
		{
#if 1
			if(thread_done[8] == 0)
				ret1 = xlnx_thread_create(&txthread_write, &testcmd2);
			else
			{
				printf("Exiting at %d %s()\n",__LINE__,__FUNCTION__);
				exit(-1);
			}

			if (ret1){
				printf("ERROR; return code from pthread_create() is %d\n", ret1);
				exit(-1);
			}
#if 0   
			ret2 = xlnx_thread_create(&txthread_ioctl, &testCmd);

			if (ret2){
				printf("ERROR; return code from pthread_create() is %d\n", ret2);
				exit(-1);
			}
#endif      
#endif
#if 1             
			if(rxbuffer2 == NULL) {
				rxbuffer2 =(char *) valloc(BUFFER_SIZE);

				if(!rxbuffer2)
				{
					printf("Unable to allocate memory \n");
					exit(-1);
				}
				log_verbose("\n##Alloc Sucess %x ##\n",rxbuffer2);
			}	 

			if(thread_done[10] == 0)
			{
				if(testCmd.TestMode &  ENABLE_CRISCROSS)
					ret3 = xlnx_thread_create(&LBthread_Xcross_write, &testcmd2);
				else 
					ret3 = xlnx_thread_create(&LBthread_write, &testcmd2);
			}
			else
			{
				printf("Exiting at %d %s()\n",__LINE__,__FUNCTION__);
				exit(-1);
			}

			if (ret3){
				printf("ERROR; return code from pthread_create() is %d\n", ret3);
				exit(-1);
			}
#if 1       
			if(thread_done[11] == 0)
			{
				log_verbose("Starting rxthread_ioctl with engine number %d at %d and %s()\n",testCmd.Engine,__LINE__,__FUNCTION__);
				ret4 = xlnx_thread_create(&rxthread_ioctl, &testcmd2);
			}
			else
			{
				log_verbose("Exiting at %d %s()\n",__LINE__,__FUNCTION__);
				exit(-1);
			}

			if (ret4){
				printf("ERROR; return code from pthread_create() is %d\n", ret4);
				exit(-1);
			}
#endif       
#endif
		}
		else if(testCmd.TestMode & (ENABLE_PKTCHK))  
		{
#if 1
			if(thread_done[8] == 0)
				ret1 = xlnx_thread_create(&txthread_write, &testcmd2);
			else
			{
				printf("Exiting at %d %s()\n",__LINE__,__FUNCTION__);
				exit(-1);
			}

			if (ret1){
				printf("ERROR; return code from pthread_create() is %d\n", ret1);
				exit(-1);
			}
#if 1   
			if(thread_done[9] == 0)
				ret2 = xlnx_thread_create(&txthread_ioctl, &testcmd2);
			else
			{
				printf("Exiting at %d %s()\n",__LINE__,__FUNCTION__);
				exit(-1);
			}

			if (ret2){
				printf("ERROR; return code from pthread_create() is %d\n", ret2);
				exit(-1);
			}
#endif
#endif
		}
		else
		{
#if 1
			if(rxbuffer2 == NULL) {  
				rxbuffer2 =(char *) valloc(BUFFER_SIZE);
				if(!rxbuffer2)
				{
					printf("Unable to allocate memory \n"); 
					exit(-1); 
				}
				log_verbose("\n##Alloc Sucess %x ##\n",rxbuffer2);
			}	  

			if(thread_done[10] == 0)
				ret3 = xlnx_thread_create(&rxthread_write, &testcmd2);
			else
			{
				printf("Exiting at %d %s()\n",__LINE__,__FUNCTION__);
				exit(-1);
			}

			if (ret3){
				printf("ERROR; return code from pthread_create() is %d\n", ret3);
				exit(-1);
			}
#if 1       
			if(thread_done[11] == 0)
			{
				log_verbose("Starting rxthread_ioctl with engine number %d at %d and %s()\n",testCmd.Engine,__LINE__,__FUNCTION__);
				ret4 = xlnx_thread_create(&rxthread_ioctl, &testcmd2);
			}
			else
			{
				printf("Exiting at %d %s()\n",__LINE__,__FUNCTION__);
				exit(-1);
			}

			if (ret4){
				printf("ERROR; return code from pthread_create() is %d\n", ret4);
				exit(-1);
			}
#endif
#endif

		}

#endif






	}
        else if(engine == 3)
	{
		memcpy(&testcmd3,&testCmd,sizeof(TestCmd));
		log_verbose("TestStartFlag3 is %x size %d\n", TestStartFlag3);
#if 1
		if((testCmd.TestMode & ENABLE_LOOPBACK) || ((testCmd.TestMode & (ENABLE_PKTCHK)) && (testCmd.TestMode & ENABLE_PKTGEN)))
		{
#if 1
			if(thread_done[12] == 0)
				ret1 = xlnx_thread_create(&txthread_write, &testcmd3);
			else
			{
				printf("Exiting at %d %s()\n",__LINE__,__FUNCTION__);
				exit(-1);
			}

			if (ret1){
				printf("ERROR; return code from pthread_create() is %d\n", ret1);
				exit(-1);
			}
#if 0   
			ret2 = xlnx_thread_create(&txthread_ioctl, &testCmd);

			if (ret2){
				printf("ERROR; return code from pthread_create() is %d\n", ret2);
				exit(-1);
			}
#endif      
#endif
#if 1             
			if(rxbuffer3 == NULL) {
				rxbuffer3 =(char *) valloc(BUFFER_SIZE);

				if(!rxbuffer3)
				{
					printf("Unable to allocate memory \n");
					exit(-1);
				}
				log_verbose("\n##Alloc Sucess %x ##\n",rxbuffer3);
			}	 

			if(thread_done[14] == 0)
			{
				if(testCmd.TestMode &  ENABLE_CRISCROSS)
					ret3 = xlnx_thread_create(&LBthread_Xcross_write, &testcmd3);
				else 
					ret3 = xlnx_thread_create(&LBthread_write, &testcmd3);
			}
			else
			{
				printf("Exiting at %d %s()\n",__LINE__,__FUNCTION__);
				exit(-1);
			}

			if (ret3){
				printf("ERROR; return code from pthread_create() is %d\n", ret3);
				exit(-1);
			}
#if 1       
			if(thread_done[15] == 0)
			{
				log_verbose("Starting rxthread_ioctl with engine number %d at %d and %s()\n",testCmd.Engine,__LINE__,__FUNCTION__);
				ret4 = xlnx_thread_create(&rxthread_ioctl, &testcmd3);
			}
			else
			{
				log_verbose("Exiting at %d %s()\n",__LINE__,__FUNCTION__);
				exit(-1);
			}

			if (ret4){
				printf("ERROR; return code from pthread_create() is %d\n", ret4);
				exit(-1);
			}
#endif       
#endif
		}
		else if(testCmd.TestMode & (ENABLE_PKTCHK))  
		{
#if 1
			if(thread_done[12] == 0)
				ret1 = xlnx_thread_create(&txthread_write, &testcmd3);
			else
			{
				printf("Exiting at %d %s()\n",__LINE__,__FUNCTION__);
				exit(-1);
			}

			if (ret1){
				printf("ERROR; return code from pthread_create() is %d\n", ret1);
				exit(-1);
			}
#if 1   
			if(thread_done[13] == 0)
				ret2 = xlnx_thread_create(&txthread_ioctl, &testcmd3);
			else
			{
				printf("Exiting at %d %s()\n",__LINE__,__FUNCTION__);
				exit(-1);
			}

			if (ret2){
				printf("ERROR; return code from pthread_create() is %d\n", ret2);
				exit(-1);
			}
#endif
#endif
		}
		else
		{
#if 1
			if(rxbuffer3 == NULL) {  
				rxbuffer3 =(char *) valloc(BUFFER_SIZE);
				if(!rxbuffer3)
				{
					printf("Unable to allocate memory \n"); 
					exit(-1); 
				}
				log_verbose("\n##Alloc Sucess %x ##\n",rxbuffer3);
			}	  

			if(thread_done[14] == 0)
				ret3 = xlnx_thread_create(&rxthread_write, &testcmd3);
			else
			{
				printf("Exiting at %d %s()\n",__LINE__,__FUNCTION__);
				exit(-1);
			}

			if (ret3){
				printf("ERROR; return code from pthread_create() is %d\n", ret3);
				exit(-1);
			}
#if 1       
			if(thread_done[3] == 0)
			{
				log_verbose("Starting rxthread_ioctl with engine number %d at %d and %s()\n",testCmd.Engine,__LINE__,__FUNCTION__);
				ret4 = xlnx_thread_create(&rxthread_ioctl, &testcmd3);
			}
			else
			{
				printf("Exiting at %d %s()\n",__LINE__,__FUNCTION__);
				exit(-1);
			}

			if (ret4){
				printf("ERROR; return code from pthread_create() is %d\n", ret4);
				exit(-1);
			}
#endif
#endif

		}

#endif






	}


	

	//msg_info("Test Started\n");
	return retval;
}

//////////////////  Thread synchronisation for tx <--> txDone & rx <--> rxDone /////////////////

#define MEM_SUCCESS		0
#define MEM_FAILURE		-1
#define MEM_NOTAVLB     -2


// this function should be used only once and used very carefully, as it resets all previous bookmarkings.
int initMemorySync (MemorySync* memInfo, unsigned long int totalMemory)
{
	// assert if bad MemorySync pointer memInfo
	if (!memInfo)
	{
		//error
		return MEM_FAILURE;
	}

	pthread_mutex_lock(&memInfo->iLock);
	memInfo->iAvailableMemory = totalMemory;
	pthread_mutex_unlock(&memInfo->iLock);
	return MEM_SUCCESS;
}


int ReserveAvailable(MemorySync *memInfo, unsigned int requested)
{
	// assert if bad MemorySync pointer memInfo
	if (!memInfo)
	{
		//error
		return MEM_FAILURE;
	}

	if (requested > 0)
	{
		pthread_mutex_lock(&memInfo->iLock);
		if (memInfo->iAvailableMemory >= requested)
		{
			memInfo->iAvailableMemory -= requested;
			requested = 0; // or we can break here, if we need while (1) implementation.
			// log_verbose("res %d ",memInfo->iAvailableMemory); 
			//       break ;
		}
		pthread_mutex_unlock(&memInfo->iLock);
	}
	if(requested ==0)
		return MEM_SUCCESS;
	else
		return MEM_NOTAVLB;
}

int FreeAvailable(MemorySync *memInfo, unsigned int completed)
{
	// assert if bad MemorySync pointer memInfo
	if (!memInfo)
	{
		//error
		return MEM_FAILURE;
	}

	pthread_mutex_lock(&memInfo->iLock);
	memInfo->iAvailableMemory += completed;



	if((memInfo== &RxDoneSync0)&& (memInfo->iAvailableMemory > (BUFFER_SIZE ))) 
		log_verbose("# RX0 %d #",memInfo->iAvailableMemory); 
	else if((memInfo== &RxDoneSync2) && (memInfo->iAvailableMemory > (BUFFER_SIZE )))
		log_verbose("# RX2  %d #",memInfo->iAvailableMemory);
	else if((memInfo== &TxDoneSync0)&& (memInfo->iAvailableMemory > BUFFER_SIZE))
		log_verbose("# TXO %d #",memInfo->iAvailableMemory);
	else if((memInfo== &TxDoneSync2)&& (memInfo->iAvailableMemory > BUFFER_SIZE))
		log_verbose("# TX2 %d #",memInfo->iAvailableMemory); 

	pthread_mutex_unlock(&memInfo->iLock);

	return MEM_SUCCESS;
}

int UpdateAvailable(MemorySync *memInfo, int engine)
{
	// assert if bad MemorySync pointer memInfo
	if (!memInfo)
	{
		//error
		return MEM_FAILURE;
	}
	if(engine == 0)
	{ 
		pthread_mutex_lock(&memInfo->iLock);
		RxBufferSize0= memInfo->iAvailableMemory;
		pthread_mutex_unlock(&memInfo->iLock);
	}
	else if(engine == 1)
	{
		pthread_mutex_lock(&memInfo->iLock);
		RxBufferSize1= memInfo->iAvailableMemory;
		pthread_mutex_unlock(&memInfo->iLock);
	}
	else if(engine == 2)
	{
		pthread_mutex_lock(&memInfo->iLock);
		RxBufferSize2= memInfo->iAvailableMemory;
		pthread_mutex_unlock(&memInfo->iLock);
	}
	else if(engine == 3)
	{
		pthread_mutex_lock(&memInfo->iLock);
		RxBufferSize3= memInfo->iAvailableMemory;
		pthread_mutex_unlock(&memInfo->iLock);
	}
	
	else
	{
		printf("##wrong engine ##\n"); 
	}
	return 0;
}
#ifdef DATA_VERIFY
	static void
VerifyBuffer (BufferInfo * buf,int engine)
{
	unsigned short check4;
	unsigned short check3;
	unsigned short check2, check6;
	BufferInfo *binfo;
	unsigned char * bptr;

	unsigned char * endAddr;
	unsigned char * startAddr;
	static unsigned int k;
	unsigned int size;
	char buffer[50];
#ifdef RAW_ETH
	int lower_limit = 15;
#else
	int lower_limit = 3;
	int upper_limit;
	int intermediate_byte;
#endif

	DataVerifyComm_t dcomm; 
#ifdef CRC_CHECK
	crc crcval;
#endif

	int i=0;
	binfo= buf;
	startAddr = binfo->bufferAddress;
	endAddr=binfo->endAddress;


	if(endAddr >= startAddr) 
	{
		size = (unsigned int)buf->buffSize;  
		bptr = startAddr; 
	}
	else
	{
		size = (unsigned int)buf->endSize; 
		if(size < 4)
		{
			printf("##unusual hit##\n");
			if(engine == 0)
			{
				RxSeqNo0++;
				if(RxSeqNo0 >= TX_CONFIG_SEQNO)
					RxSeqNo0=0;
			}
			else if(engine == 1)
			{
				RxSeqNo1 ++;
				if(RxSeqNo1 >= TX_CONFIG_SEQNO)
					RxSeqNo1=0;
			}
			else if(engine == 2)
			{
				RxSeqNo2 ++;
				if(RxSeqNo2 >= TX_CONFIG_SEQNO)
					RxSeqNo2=0;
			}
			else if(engine == 3)
			{
				RxSeqNo3 ++;
				if(RxSeqNo3 >= TX_CONFIG_SEQNO)
					RxSeqNo3=0;
			}

			return;
		} 
		bptr = endAddr;
#ifdef CRC_CHECK
		if(engine == 0)
		{
			RxSeqNo0++;
			if(RxSeqNo0 >= TX_CONFIG_SEQNO)
				RxSeqNo0=0;
		}
		else if(engine == 1)
		{
			RxSeqNo1 ++;
			if(RxSeqNo1 >= TX_CONFIG_SEQNO)
				RxSeqNo1=0;
		}
		else if(engine == 2)
		{
			RxSeqNo2 ++;
			if(RxSeqNo2 >= TX_CONFIG_SEQNO)
				RxSeqNo2=0;
		}
		else if(engine == 3)
		{
			RxSeqNo3 ++;
			if(RxSeqNo3 >= TX_CONFIG_SEQNO)
				RxSeqNo3=0;
		}

		return;
#endif
	}
#if 0
	upper_limit = size;
	srand ( time(NULL) );
	intermediate_byte = rand() % (upper_limit - lower_limit + 1) + lower_limit; 
	if(intermediate_byte >= size)
	{
		intermediate_byte = upper_limit - 1;
	}
	if(intermediate_byte%2)
		check6 =   *(unsigned short *) (bptr + (intermediate_byte -1));
	else
		check6 =  *(unsigned short *) (bptr + intermediate_byte);
#endif

	if((size/2) %2)
		check4 =   *(unsigned short *) (bptr + ((size/2) -1));
	else
		check4 =  *(unsigned short *) (bptr + (size/2));

#ifdef RAW_ETH 
	check2 = *(unsigned short *) (bptr + 22);
#else
	check2 = *(unsigned short *) (bptr + 2);
#endif

#if 0
	if(size%2)
		check3 = *(unsigned short *) (bptr + (size - 3) );
	else
		check3 = *(unsigned short *) (bptr + (size - 2) );
#endif

	if(engine ==0)
	{
#ifdef CRC_CHECK
		crcval = crcSlow(bptr,4);
		if (crcval != *(crc *)(bptr + 4)) 
#else
			if (check2 != RxSeqNo0)
#endif
			{
				ErrCnt0++;
				WrongData0++;
#ifdef CRC_CHECK
				printf("\n##Mismatch Path 0: Expected crc = %X calculated crc = %X bptr = %x  Size %x## \n",crcval,*(crc *)bptr,bptr,size);
#else
				printf ("/n##Mismatch Path 0: SeqNo0 %x check2 %x bptr %x ##\n",
						RxSeqNo0,check2,bptr);
				printf("##Size %x\n",size );
				/* Update RxSeqNo */
				RxSeqNo0 = check2;
#endif
				dcomm.engine = engine; 
				dcomm.ErrCnt = ErrCnt0;
				sendDataVerifyStatus(dcomm);

			}


		RxSeqNo0++;
		if(RxSeqNo0 >= TX_CONFIG_SEQNO)
			RxSeqNo0=0;
	} 	
	else if(engine == 1)
	{
#ifdef CRC_CHECK
		crcval = crcSlow(bptr,4);
		if (crcval != *(crc *)(bptr + 4))
#else
			if (check2 != RxSeqNo1)
#endif
			{
				ErrCnt1++;
				WrongData1++;
#ifdef CRC_CHECK
				printf("\n##Mismatch Path 1: Expected crc = %X calculated crc = %X bptr = %x  Size %x## \n",crcval,*(crc *)bptr,bptr,size);
#else
				printf("/n##Mismatch Path 1: SeqNo1 %x check2 %x bptr %x ##\n",
						RxSeqNo1,check2,bptr);
				printf("##Size %x\n",size );

				/* Update RxSeqNo */
				RxSeqNo1 = check2;
#endif
				dcomm.engine = engine; 
				dcomm.ErrCnt = ErrCnt1;
				sendDataVerifyStatus(dcomm);

			}


		RxSeqNo1 ++;
		if(RxSeqNo1 >= TX_CONFIG_SEQNO)
			RxSeqNo1=0;

	}
	else if(engine == 2)
	{
#ifdef CRC_CHECK
		crcval = crcSlow(bptr,4);
		if (crcval != *(crc *)(bptr + 4))
#else
			if (check2 != RxSeqNo2)
#endif
			{
				ErrCnt2++;
				WrongData2++;
#ifdef CRC_CHECK
				printf("\n##Mismatch Path 1: Expected crc = %X calculated crc = %X bptr = %x  Size %x## \n",crcval,*(crc *)bptr,bptr,size);
#else
				printf("/n##Mismatch Path 1: SeqNo1 %x check2 %x bptr %x ##\n",
						RxSeqNo2,check2,bptr);
				printf("##Size %x\n",size );

				/* Update RxSeqNo */
				RxSeqNo2 = check2;
#endif
				dcomm.engine = engine; 
				dcomm.ErrCnt = ErrCnt2;
				sendDataVerifyStatus(dcomm);

			}


		RxSeqNo2 ++;
		if(RxSeqNo2 >= TX_CONFIG_SEQNO)
			RxSeqNo2=0;

	}
	else if(engine == 3)
	{
#ifdef CRC_CHECK
		crcval = crcSlow(bptr,4);
		if (crcval != *(crc *)(bptr + 4))
#else
			if (check2 != RxSeqNo3)
#endif
			{
				ErrCnt3++;
				WrongData3++;
#ifdef CRC_CHECK
				printf("\n##Mismatch Path 1: Expected crc = %X calculated crc = %X bptr = %x  Size %x## \n",crcval,*(crc *)bptr,bptr,size);
#else
				printf("/n##Mismatch Path 1: SeqNo1 %x check2 %x bptr %x ##\n",
						RxSeqNo3,check2,bptr);
				printf("##Size %x\n",size );

				/* Update RxSeqNo */
				RxSeqNo3 = check2;
#endif
				dcomm.engine = engine; 
				dcomm.ErrCnt = ErrCnt3;
				sendDataVerifyStatus(dcomm);

			}


		RxSeqNo3 ++;
		if(RxSeqNo3 >= TX_CONFIG_SEQNO)
			RxSeqNo3=0;

	}

}
#endif


#ifdef RAW_ETH
static void FormatBuffer(unsigned char * buf,int bufferSize,int chunkSize,int pktSize)
{
	int i,j=0,k;
	unsigned short TxSeqNo=0;
	/* Apply data pattern in the buffer */
	log_verbose("##PKTSIZE %d ##\n",pktSize);
	while(j <  bufferSize)
	{
		*(unsigned short *)(buf + j + 0) = 0xFFFF;
		*(unsigned short *)(buf + j + 2) = 0xFFFF;
		*(unsigned short *)(buf + j + 4) = 0xFFFF;
		*(unsigned short *)(buf + j + 6) = 0xAABB;
		*(unsigned short *)(buf + j + 8) = 0xCCDD;
		*(unsigned short *)(buf + j + 10) = 0xEEFF;

		//- For jumbo frame, make T/L field opcode 0x8870	
		//- for certain lengths lesser than 1500B, 
		//there are opcode conflicts leading to dropped packets
		*(unsigned short *)(buf + j + 12) = 0x8870;

		/* Apply data pattern in the buffer */
		for(i = 14; i < chunkSize; i = i+2)
			*(unsigned short *)(buf + j + i) = TxSeqNo;
#ifdef CRC_CHECK
		*(crc *)(buf+ j + 18) = crcSlow(buf+j+14,4);
#endif
		j +=i;
		TxSeqNo++;
		if(TxSeqNo >= TX_CONFIG_SEQNO)
			TxSeqNo=0;
	}

}
#else
static void FormatBuffer(unsigned char * buf,int bufferSize,int chunksize,int pktSize)
{
	int i,j=0;
	unsigned short TxSeqNo=0;
	/* Apply data pattern in the buffer */


	// log_verbose("##CHUNK SIZE %d PKTSIZE %d ##\n",chunksize,pktSize);
	while( j  <  bufferSize)
	{
		for(i = 0; i < chunksize; i = i+2)
		{
			if(i==0)
				*(unsigned short *)(buf + j + i) = pktSize;
			else
				*(unsigned short *)(buf + j + i) = TxSeqNo;

		}
		// if((j+(2 * pktsize))>= blocksize)
		//  log_verbose("##TxSeqno %d j %d ##",TxSeqNo,j); 
#ifdef CRC_CHECK
		*(crc *)(buf+ j + 4) = crcSlow(buf+j,4);
#endif
		j +=i;
		TxSeqNo++;
		if(TxSeqNo >= TX_CONFIG_SEQNO)
			TxSeqNo=0;

	}
	// log_verbose("##TxSeqno %d ##",TxSeqNo); 
} 
#endif

void* LBthread_write(TestCmd *test)
{
	char *buffer;
	unsigned long fileLen;
	int file_desc,ret_val,ret,itre,engine= test->Engine;
	TestCmd testCmd;
	int PacketSize = test->MaxPktSize;
	MemorySync *TxDoneSync;
	MemorySync *RxDoneSync;
	FreeInfo usrInfo;
	int PacketSent=0;
	int id=0,j=0;
	int chunksize=0;
	int retry=0;

	unsigned int completed = 0;
	if(PacketSize % 4){

		chunksize = PacketSize + (4 - (PacketSize % 4));

	}
	else
	{
		chunksize = PacketSize;
	}
	log_verbose("Size %d  chunk %d", PacketSize,chunksize); 
	PacketSize=0x20000;   
	// log_verbose("rxthread_read %d started \n", id );
#if 1
	if(test->Engine == 0)
	{     
		file_desc= open("/dev/xraw_data0",O_RDWR);
		if(file_desc < 0){
			printf("Can't open file \n");
			exit(-1);
		}
		buffer = rxbuffer0 ;
		PacketSent=rxPacketSent0;
		RxDoneSync = &RxDoneSync0;
		TxDoneSync = &TxDoneSync0;
		thread_done[2] = 1;
	}
	else if(test->Engine == 1)
	{
		file_desc= open("/dev/xraw_data1",O_RDWR);
		if(file_desc < 0){
			printf("Can't open file \n");
			exit(-1);
		}
		buffer = rxbuffer1;
		PacketSent=rxPacketSent1;
		RxDoneSync = &RxDoneSync1;
		TxDoneSync = &TxDoneSync1;
		thread_done[6] = 1;
	}
	else if(test->Engine == 2)
	{
		file_desc= open("/dev/xraw_data2",O_RDWR);
		if(file_desc < 0){
			printf("Can't open file \n");
			exit(-1);
		}
		buffer = rxbuffer2;
		PacketSent=rxPacketSent2;
		RxDoneSync = &RxDoneSync2;
		TxDoneSync = &TxDoneSync2;
		thread_done[10] = 1;
	}
	else if(test->Engine == 3)
	{
		file_desc= open("/dev/xraw_data3",O_RDWR);
		if(file_desc < 0){
			printf("Can't open file \n");
			exit(-1);
		}
		buffer = rxbuffer3;
		PacketSent=rxPacketSent3;
		RxDoneSync = &RxDoneSync3;
		TxDoneSync = &TxDoneSync3;
		thread_done[14] = 1;
	}
#endif    
	//Allocate memory
	//initialize the available memory with the total memory.
	//	if (0 != initMemorySync(RxDoneSync, BUFFER_SIZE))
	if(engine == 0)
	{
		if (0 != initMemorySync(RxDoneSync,RxBufferSize0))
		{
			//error
			perror("Bad Pointer TxDoneSync: MemorySync");
		}
	}
	else if(engine == 1)
	{  
		if (0 != initMemorySync(RxDoneSync,RxBufferSize1))
		{
			//error
			perror("Bad Pointer TxDoneSync: MemorySync");
		}
	}
	else if(engine == 2)
	{  
		if (0 != initMemorySync(RxDoneSync,RxBufferSize2))
		{
			//error
			perror("Bad Pointer TxDoneSync: MemorySync");
		}
	}
	else if(engine == 3)
	{  
		if (0 != initMemorySync(RxDoneSync,RxBufferSize3))
		{
			//error
			perror("Bad Pointer TxDoneSync: MemorySync");
		}
	}

#if 1

	while(1)
	{


		if (0 == ReserveAvailable(RxDoneSync, PacketSize))
		{
			//error
			//		  perror("Bad Pointer TxDoneSync: MemorySync");
			//	  }
		if( PacketSent + PacketSize <= BUFFER_SIZE)
		{
			ret=read(file_desc,buffer+PacketSent,PacketSize);
			if(ret ==-1)
			{
				perror("Bad read ");
			}
			else if(ret < PacketSize)
			{
				FreeAvailable(RxDoneSync, PacketSize);
			}
			else
			{
				PacketSent = PacketSent + ret;
			}
		}
		else
		{
			FreeAvailable(RxDoneSync, PacketSize);
			PacketSent = 0;
		}
	}

	completed =0 ;
	usrInfo.expected = MAX_LIST;

	ret_val=ioctl(file_desc,IGET_TRN_TXUSRINFO, &usrInfo);
	if(ret_val < 0){
		printf("IOCTL FAILED\n");
		//return(-1);
		break;
	}

	for (j = 0; j < usrInfo.expected; j++)
	{
		//	completed += usrInfo.buffList[j].buffSize;

		completed += chunksize;
	}

	if (0 != FreeAvailable(TxDoneSync, completed))
	{
		//error
		perror("Bad Pointer TxDoneSync: MemorySync");
	}

	if(engine == 0)
	{
		if((thread0_exit == 1 ) && (usrInfo.expected == 0))
		{
			if(thread_done[3] == 0)
			{		
				// log_verbose("Ending %s thread \n",__func__);
				rxPacketSent0 = PacketSent ;
				UpdateAvailable(RxDoneSync,engine);

				thread_done[2] = 0;
				//  while(thread_done[3]); 
				goto ERROR;
			}
			//  retry++;

		} 
	}
	else if(engine == 1)
	{
		if((thread1_exit == 1 ) && (usrInfo.expected == 0))
		{
			//  log_verbose("Ending %s thread \n",__func__);

			if(thread_done[7] == 0)
			{
				rxPacketSent1 = PacketSent ;
				UpdateAvailable(RxDoneSync,engine);

				thread_done[6] = 0;
				//  while(thread_done[7]);    
				goto ERROR;
			}
			//   retry++;
		} 
	}
	else if(engine == 2)
	{
		if((thread2_exit == 1 ) && (usrInfo.expected == 0))
		{
			//  log_verbose("Ending %s thread \n",__func__);

			if(thread_done[11] == 0)
			{
				rxPacketSent2 = PacketSent ;
				UpdateAvailable(RxDoneSync,engine);

				thread_done[10] = 0;
				//  while(thread_done[7]);    
				goto ERROR;
			}
			//   retry++;
		} 
	}
	else if(engine == 3)
	{
		if((thread3_exit == 1 ) && (usrInfo.expected == 0))
		{
			//  log_verbose("Ending %s thread \n",__func__);

			if(thread_done[15] == 0)
			{
				rxPacketSent3 = PacketSent ;
				UpdateAvailable(RxDoneSync,engine);

				thread_done[14] = 0;
				//  while(thread_done[7]);    
				goto ERROR;
			}
			//   retry++;
		} 
	}



}

//	 log_verbose("ending rxthread_read id %i iter:%d \n", id, itre );
//  thread_done[0] = 1;
ERROR:
close(file_desc);
pthread_exit(NULL);
#endif
}

void* LBthread_Xcross_write(TestCmd *test)
{
	char *buffer;
	unsigned long fileLen;
	int ret_val,ret,itre,engine= test->Engine;
	TestCmd testCmd;
	int PacketSize = test->MaxPktSize;
	MemorySync *TxDoneSync;
	MemorySync *RxDoneSync;
	FreeInfo usrInfo;
	int PacketSent=0;
	int id=0,j=0;
	int read_fd,ioctl_fd;
	int chunksize=0;
	int retry=0;

	unsigned int completed = 0;
	printf("LB X cross %d started \n", id );

	if(PacketSize % 4){

		chunksize = PacketSize + (4 - (PacketSize % 4));

	}
	else
	{
		chunksize = PacketSize;
	}
	log_verbose("Size %d  chunk %d", PacketSize,chunksize); 
	PacketSize=0x20000;   
#if 1
	if(test->Engine == 0)
	{     
		read_fd= open("/dev/xraw_data1",O_RDWR);
		if(read_fd < 0){
			printf("Can't open file \n");
			exit(-1);
		}
		ioctl_fd= open("/dev/xraw_data0",O_RDWR); 
		if(ioctl_fd < 0){
			printf("Can't open file \n");
			exit(-1);
		}
		buffer = rxbuffer0 ;
		PacketSent=rxPacketSent0;
		RxDoneSync = &RxDoneSync0;
		TxDoneSync = &TxDoneSync0;
		thread_done[2] = 1;
	}
	else if(engine == 1)
	{

		read_fd= open("/dev/xraw_data0",O_RDWR);
		if(read_fd < 0){
			printf("Can't open file \n");
			exit(-1);
		}
		ioctl_fd= open("/dev/xraw_data1",O_RDWR); 
		if(ioctl_fd < 0){
			printf("Can't open file \n");
			exit(-1);
		}
		buffer = rxbuffer1;
		PacketSent=rxPacketSent1;
		RxDoneSync = &RxDoneSync1;
		TxDoneSync = &TxDoneSync1;
		thread_done[6] = 1;
	}
	else if(engine == 2)
	{

		read_fd= open("/dev/xraw_data3",O_RDWR);
		if(read_fd < 0){
			printf("Can't open file \n");
			exit(-1);
		}
		ioctl_fd= open("/dev/xraw_data2",O_RDWR); 
		if(ioctl_fd < 0){
			printf("Can't open file \n");
			exit(-1);
		}
		buffer = rxbuffer2;
		PacketSent=rxPacketSent2;
		RxDoneSync = &RxDoneSync2;
		TxDoneSync = &TxDoneSync2;
		thread_done[10] = 1;
	}
	else if(engine == 3)
	{

		read_fd= open("/dev/xraw_data2",O_RDWR);
		if(read_fd < 0){
			printf("Can't open file \n");
			exit(-1);
		}
		ioctl_fd= open("/dev/xraw_data3",O_RDWR); 
		if(ioctl_fd < 0){
			printf("Can't open file \n");
			exit(-1);
		}
		buffer = rxbuffer3;
		PacketSent=rxPacketSent3;
		RxDoneSync = &RxDoneSync3;
		TxDoneSync = &TxDoneSync3;
		thread_done[14] = 1;
	}
#endif    
	//Allocate memory
	//initialize the available memory with the total memory.

	if(engine == 0)
	{
		if (0 != initMemorySync(RxDoneSync,RxBufferSize0))
		{
			//error
			perror("Bad Pointer TxDoneSync: MemorySync");
		}
	}
	else if(engine == 1)
	{  
		if (0 != initMemorySync(RxDoneSync,RxBufferSize1))
		{
			//error
			perror("Bad Pointer TxDoneSync: MemorySync");
		}
	}
	else if(engine == 2)
	{  
		if (0 != initMemorySync(RxDoneSync,RxBufferSize2))
		{
			//error
			perror("Bad Pointer TxDoneSync: MemorySync");
		}
	}
	else if(engine == 3)
	{  
		if (0 != initMemorySync(RxDoneSync,RxBufferSize3))
		{
			//error
			perror("Bad Pointer TxDoneSync: MemorySync");
		}
	}

#if 1

	while(1)
	{


		if (0 == ReserveAvailable(RxDoneSync, PacketSize))
		{
			//error
			//		  perror("Bad Pointer TxDoneSync: MemorySync");
			//	  }
		if( PacketSent + PacketSize <= BUFFER_SIZE)
		{
			ret=read(read_fd,buffer+PacketSent,PacketSize);
			if(ret ==-1)
			{
				perror("Bad read ");
			}
			else if(ret < PacketSize)
			{
				FreeAvailable(RxDoneSync, PacketSize);
				//TODO 
			}
			else
			{
				PacketSent = PacketSent + ret;
			}
		}
		else
		{
			FreeAvailable(RxDoneSync, PacketSize);
			PacketSent = 0;
		}
	}

	completed =0 ;
	usrInfo.expected = MAX_LIST;

	ret_val=ioctl(ioctl_fd,IGET_TRN_TXUSRINFO, &usrInfo);
	if(ret_val < 0){
		printf("IOCTL FAILED\n");
		break;
	}

	for (j = 0; j < usrInfo.expected; j++)
	{
		//	completed += usrInfo.buffList[j].buffSize;

		completed += chunksize;
	}

	if (0 != FreeAvailable(TxDoneSync, completed))
	{
		//error
		perror("Bad Pointer TxDoneSync: MemorySync");
	}


	if(engine == 0)
	{
		if((thread0_exit == 1 ) && (usrInfo.expected == 0))
		{
			if(thread_done[3]== 0)
			{		
				// log_verbose("Ending %s thread \n",__func__);
				rxPacketSent0 = PacketSent ;
				UpdateAvailable(RxDoneSync,engine);

				thread_done[2] = 0;
				//while(thread_done[3]); 
				goto ERROR;
			}
			//  retry++;

		} 
	}
	else if(engine == 1)
	{
		if((thread1_exit == 1 ) && (usrInfo.expected == 0))
		{

			if(thread_done[7] == 0)
			{
				rxPacketSent1 = PacketSent ;
				UpdateAvailable(RxDoneSync,engine);
				thread_done[6] = 0;
				//  while(thread_done[7]);    
				goto ERROR;
			}
			//   retry++;
		} 
	}
	else if(engine == 2)
	{
		if((thread2_exit == 1 ) && (usrInfo.expected == 0))
		{

			if(thread_done[11] == 0)
			{
				rxPacketSent2 = PacketSent ;
				UpdateAvailable(RxDoneSync,engine);
				thread_done[10] = 0;
				//  while(thread_done[7]);    
				goto ERROR;
			}
			//   retry++;
		} 
	}
	else if(engine == 3)
	{
		if((thread3_exit == 1 ) && (usrInfo.expected == 0))
		{

			if(thread_done[15] == 0)
			{
				rxPacketSent3 = PacketSent ;
				UpdateAvailable(RxDoneSync,engine);
				thread_done[14] = 0;
				//  while(thread_done[7]);    
				goto ERROR;
			}
			//   retry++;
		} 
	}



}

log_verbose("ending rxthread_read id %i iter:%d \n", id, itre );
ERROR:
close(read_fd);
close(ioctl_fd);
pthread_exit(NULL);
#endif
}
void * rxthread_ioctl(TestCmd *test  )
{
	int ret_val,ret,itre,j,k=0;
	RxUsrInfo buffer;
	int readfd=0,id=1,engine = test->Engine;
	int mode = test->TestMode;   
	FreeInfo usrInfo;
	unsigned int completed =0 ;
	MemorySync *RxDoneSync;
	unsigned char * bptr;
	int flag=0;
	int retry=0;
	int lastBuff=0;
	int PacketSize = test->MaxPktSize;
	int noPages=0;
	if(PacketSize > PAGE_SIZE) 
	{
		if (PacketSize % PAGE_SIZE)
			noPages=(PacketSize/PAGE_SIZE)+1;
		else
			noPages=(PacketSize/PAGE_SIZE);
	}
	else 
		noPages=1;
	//  printf("## Number of pages %d ##",noPages);

	//  log_verbose("thread rxthread_ioctl %d started \n", id );

#if 1
	if(engine == 0)
	{     
		if(mode & ENABLE_CRISCROSS)
			readfd= open("/dev/xraw_data1",O_RDWR);
		else
			readfd= open("/dev/xraw_data0",O_RDWR);
		if(readfd < 0){
			printf("Can't open file \n");
			exit(-1);
		}
		RxDoneSync = &RxDoneSync0;
		thread_done[3] = 1;
	}
	else if(engine ==1)
	{

		if(mode & ENABLE_CRISCROSS)
			readfd= open("/dev/xraw_data0",O_RDWR);
		else
			readfd= open("/dev/xraw_data1",O_RDWR);
		if(readfd < 0){
			printf("Can't open file at %d %s() \n",__LINE__,__FUNCTION__);
			exit(-1);
		}
		RxDoneSync =&RxDoneSync1;
		thread_done[7] = 1;
	}
	else if(engine == 2)
	{     
		if(mode & ENABLE_CRISCROSS)
			readfd= open("/dev/xraw_data3",O_RDWR);
		else
			readfd= open("/dev/xraw_data2",O_RDWR);
		if(readfd < 0){
			printf("Can't open file \n");
			exit(-1);
		}
		RxDoneSync = &RxDoneSync2;
		thread_done[11] = 1;
	}
	else if(engine ==3 )
	{

		if(mode & ENABLE_CRISCROSS)
			readfd= open("/dev/xraw_data2",O_RDWR);
		else
			readfd= open("/dev/xraw_data3",O_RDWR);
		if(readfd < 0){
			printf("Can't open file at %d %s() \n",__LINE__,__FUNCTION__);
			exit(-1);
		}
		RxDoneSync =&RxDoneSync3;
		thread_done[15] = 1;
	}
	else
	{
		printf("#####engine wrong%d ",engine);
		exit(-1); 
	}
#endif

	while(1)
	{

		completed =0 ;
		usrInfo.expected = MAX_LIST;
		ret_val=ioctl(readfd,IGET_TRN_RXUSRINFO, &usrInfo);
		if(ret_val < 0){
			printf("IOCTL FAILED\n");
			//return(-1);
			break;
		}

		for (j = 0; j < usrInfo.expected; j++)
		{
#ifdef DATA_VERIFY
			VerifyBuffer (( BufferInfo *) &(usrInfo.buffList[j]), engine);
#endif
#if DEBUG_VERBOSE
			if(ErrCnt0 || ErrCnt1)
			{       
				if(ErrCnt0 && (engine==0))
				{
					printf("\npath 0 List last Buffer %x %x %x \n",lastBuff,*(unsigned short *)(lastBuff),*(unsigned short *)(lastBuff+2)); 
					for(flag=0;flag < usrInfo.expected;flag++ )
						printf("%x ",usrInfo.buffList[flag].bufferAddress);   
					ErrCnt0=0;
				}

				if(ErrCnt1 && (engine==1))
				{
					printf("\npath 1 List last buffer %x %x %x \n",lastBuff,*(unsigned short *)(lastBuff),*(unsigned short *)(lastBuff+2)); 
					for(flag=0;flag < usrInfo.expected;flag++ )
						printf("%x ",usrInfo.buffList[flag].bufferAddress);   
					ErrCnt1=0; 
				}
				if(ErrCnt2 && (engine==2))
				{
					printf("\npath 3 List last buffer %x %x %x \n",lastBuff,*(unsigned short *)(lastBuff),*(unsigned short *)(lastBuff+2)); 
					for(flag=0;flag < usrInfo.expected;flag++ )
						printf("%x ",usrInfo.buffList[flag].bufferAddress);   
					ErrCnt2=0; 
				}	
				if(ErrCnt3 && (engine==3))
				{
					printf("\npath 4 List last buffer %x %x %x \n",lastBuff,*(unsigned short *)(lastBuff),*(unsigned short *)(lastBuff+2)); 
					for(flag=0;flag < usrInfo.expected;flag++ )
						printf("%x ",usrInfo.buffList[flag].bufferAddress);   
					ErrCnt3=0; 
				}




#endif

				completed += ((usrInfo.buffList[j].noPages) * PAGE_SIZE);
				lastBuff=usrInfo.buffList[j].bufferAddress;
			}

			FreeAvailable(RxDoneSync, completed);

			if(engine == 0)
			{
				if((thread0_exit == 1) && (usrInfo.expected == 0) )
				{
					// log_verbose("Ending Engine 0 %s thread \n",__func__);
					//  log_verbose("## SeqNO %x  Size %x##", RxSeqNo,DbgSize);   
					if(retry >= 20)
					{	 
						log_verbose("## Last RxSeqNO1 %x ##", RxSeqNo0);   
						thread_done[3] = 0;
						goto ERROR;
					}	
					usleep(100 * 1000);
					retry++; 
				} 
			}
			else if(engine == 1)
			{
				if((thread1_exit == 1) && (usrInfo.expected == 0))
				{
					//   log_verbose("Ending Engine 1%s thread \n",__func__);
					if(retry >= 20)
					{ 
						log_verbose("## Last RxSeqNO1  %x ##", RxSeqNo1);   
						thread_done[7] = 0;
						goto ERROR;
					}	
					usleep(100 * 1000);
					retry++; 
				} 
			}
			else if(engine == 2)
			{
				if((thread2_exit == 1) && (usrInfo.expected == 0))
				{
					//   log_verbose("Ending Engine 1%s thread \n",__func__);
					if(retry >= 20)
					{ 
						log_verbose("## Last RxSeqNO2  %x ##", RxSeqNo2);   
						thread_done[11] = 0;
						goto ERROR;
					}	
					usleep(100 * 1000);
					retry++; 
				} 
			}
			else if(engine == 3)
			{
				if((thread3_exit == 1) && (usrInfo.expected == 0))
				{
					//   log_verbose("Ending Engine 1%s thread \n",__func__);
					if(retry >= 20)
					{ 
						log_verbose("## Last RxSeqNO3  %x ##", RxSeqNo3);   
						thread_done[15] = 0;
						goto ERROR;
					}	
					usleep(100 * 1000);
					retry++; 
				} 
			} 

		}


		//   log_verbose("ending rxthread_ioctl id %i iter:%d \n", id, itre );
		//    thread_done[id] = 1;	// indicate, end of this thread
ERROR:    
		//	thread_done[id] = 1;	// indicate, end of this thread
		close(readfd);
		pthread_exit(NULL);
	}

	void* rxthread_write(TestCmd *test)
	{
		char *buffer;
		int file_desc,ret_val,ret,itre;
		int id=0,j=0;
		TestCmd testCmd;
		int engine= test->Engine;
		int PacketSize = 0x20000;
		MemorySync *RxDoneSync;
		int PacketSent=0;
		unsigned int completed = 0;
		int retry=0;  
		int mode = test->TestMode;

		//	   log_verbose("rxthread_write %d started \n", id );

#if 1
		if(test->Engine == 0)
		{     
		if(mode & ENABLE_CRISCROSS)
			file_desc= open("/dev/xraw_data1",O_RDWR);
		else
			file_desc= open("/dev/xraw_data0",O_RDWR);
			if(file_desc < 0){
				printf("Can't open file \n");
				exit(-1);
			}

			buffer = rxbuffer0 ;
			PacketSent=rxPacketSent0;
			RxDoneSync = &RxDoneSync0;
			thread_done[2] = 1;

		}
		else if(test->Engine == 1)
		{
		if(mode & ENABLE_CRISCROSS)
			file_desc= open("/dev/xraw_data0",O_RDWR);
		else
			file_desc= open("/dev/xraw_data1",O_RDWR);
			if(file_desc < 0){
				printf("Can't open file \n");
				exit(-1);
			}
			buffer = rxbuffer1;
			PacketSent=rxPacketSent1;
			RxDoneSync = &RxDoneSync1;
			thread_done[6] = 1;
		}
		else if(test->Engine == 2)
		{     
			file_desc= open("/dev/xraw_data2",O_RDWR);
			if(file_desc < 0){
				printf("Can't open file \n");
				exit(-1);
			}

			buffer = rxbuffer2 ;
			PacketSent=rxPacketSent2;
			RxDoneSync = &RxDoneSync2;
			thread_done[10] = 1;

		}
		else if(test->Engine == 3)
		{
			file_desc= open("/dev/xraw_data3",O_RDWR);
			if(file_desc < 0){
				printf("Can't open file \n");
				exit(-1);
			}
			buffer = rxbuffer3;
			PacketSent=rxPacketSent3;
			RxDoneSync = &RxDoneSync3;
			thread_done[14] = 1;
		}
#endif    
		if(engine == 0)
		{
			if (0 != initMemorySync(RxDoneSync,RxBufferSize0))
			{
				//error
				perror("Bad Pointer TxDoneSync: MemorySync");
			}
		}
		else if(engine == 1)
		{  
			if (0 != initMemorySync(RxDoneSync,RxBufferSize1))
			{
				//error
				perror("Bad Pointer TxDoneSync: MemorySync");
			}
		}
		else if(engine == 2)
		{  
			if (0 != initMemorySync(RxDoneSync,RxBufferSize2))
			{
				//error
				perror("Bad Pointer TxDoneSync: MemorySync");
			}
		}
		else if(engine == 3)
		{  
			if (0 != initMemorySync(RxDoneSync,RxBufferSize3))
			{
				//error
				perror("Bad Pointer TxDoneSync: MemorySync");
			}
		}


#if 1

		while(1)
		{


			if (0 == ReserveAvailable(RxDoneSync, PacketSize))
			{
				if( PacketSent + PacketSize <= BUFFER_SIZE)
				{
					ret=read(file_desc,buffer+PacketSent,PacketSize);

					if(ret < PacketSize)
					{
						FreeAvailable(RxDoneSync, PacketSize);           
						//TODO
					}
					else
					{
						PacketSent = PacketSent + ret;
					}
				}
				else
				{
					FreeAvailable(RxDoneSync, PacketSize);
					PacketSent = 0;
				}
			}


			if(engine == 0)
			{
				if(thread0_exit == 1)
				{

					if(thread_done[3]== 0)
					{		
						//	printf("Ending %s thread \n",__func__);
						rxPacketSent0 = PacketSent ;
						UpdateAvailable(RxDoneSync,engine);
						thread_done[2] = 0;
						goto ERROR;
					}
					//   retry++;
				} 
			}
			else if(engine == 1)
			{
				if(thread1_exit == 1)
				{

					if(thread_done[7] == 0)
					{		
						//	printf("Ending %s thread \n",__func__);
						rxPacketSent1 = PacketSent ;
						UpdateAvailable(RxDoneSync,engine);
						thread_done[6] = 0;
						goto ERROR;
					}
					//      retry++;
				} 
			}
			else if(engine == 2)
			{
				if(thread2_exit == 1)
				{

					if(thread_done[11] == 0)
					{		
						//	printf("Ending %s thread \n",__func__);
						rxPacketSent2 = PacketSent ;
						UpdateAvailable(RxDoneSync,engine);
						thread_done[10] = 0;
						goto ERROR;
					}
					//      retry++;
				} 
			}
			else if(engine == 3)
			{
				if(thread3_exit == 1)
				{

					if(thread_done[15] == 0)
					{		
						//	printf("Ending %s thread \n",__func__);
						rxPacketSent3 = PacketSent ;
						UpdateAvailable(RxDoneSync,engine);
						thread_done[14] = 0;
						goto ERROR;
					}
					//      retry++;
				} 
			}


		}

		// log_verbose("ending rxthread_read id %i iter:%d \n", id, itre );
		//  thread_done[0] = 1;
ERROR:
		close(file_desc);
		pthread_exit(NULL);
#endif
	}
	void *  txthread_write(TestCmd *test)
	{
		char *buffer;
		unsigned long bufferLen;
		MemorySync *TxDoneSync = NULL;
		int file_desc,ret_val,ret,itre;
		int chunksize=0;
		TestCmd testCmd;
		int PacketSent=0;
		int id=0,i=0,j=0;
		int engine= test->Engine;
		int PacketSize = test->MaxPktSize;

		if(PacketSize % 4){

			chunksize = PacketSize + (4 - (PacketSize % 4));

		}
		else
		{
			chunksize = PacketSize;
		}


		bufferLen = BUFFER_SIZE - (BUFFER_SIZE % (chunksize * 512)); 

		//log_verbose("thread TxWrite %d started engine is %d size %d \n", id ,test->Engine,test->MaxPktSize);

		buffer =(char *) valloc(bufferLen);
		if(!buffer)
		{
			printf("Unable to allocate memory \n"); 
			exit(-1);
		}
		//			 log_verbose("Alloc Sucess \n");

		if(test->Engine == 0)
		{     
			file_desc= open("/dev/xraw_data0",O_RDWR);
			if(file_desc < 0){
				printf("Can't open file \n");
				free(buffer);
				exit(-1);
			}

			TxDoneSync = &TxDoneSync0;
			thread_done[0] = 1;

		}
		else if(test->Engine == 1)
		{
			file_desc= open("/dev/xraw_data1",O_RDWR);
			if(file_desc < 0){
				printf("Can't open file \n");
				free(buffer);
				exit(-1);
			}
			TxDoneSync = &TxDoneSync1;
			thread_done[4] = 1;

		}
		if(test->Engine == 2)
		{     
			file_desc= open("/dev/xraw_data2",O_RDWR);
			if(file_desc < 0){
				printf("Can't open file \n");
				free(buffer);
				exit(-1);
			}

			TxDoneSync = &TxDoneSync2;
			thread_done[8] = 1;

		}
		if(test->Engine == 3)
		{     
			file_desc= open("/dev/xraw_data3",O_RDWR);
			if(file_desc < 0){
				printf("Can't open file \n");
				free(buffer);
				exit(-1);
			}

			TxDoneSync = &TxDoneSync3;
			thread_done[12] = 1;

		}


		//initialize the available memory with the total memory.
		if (0 != initMemorySync(TxDoneSync, bufferLen))
		{
			//error
			perror("Bad Pointer TxDoneSync: MemorySync");
		}
		FormatBuffer(buffer,bufferLen,chunksize,PacketSize);


		while(1)
		{
			if(0 == ReserveAvailable(TxDoneSync, chunksize))
			{
				if(PacketSent + chunksize <= bufferLen )
				{
					ret=write(file_desc,buffer+PacketSent,PacketSize);

					if(ret < PacketSize)
					{

						FreeAvailable(TxDoneSync, chunksize); 

						//TODO  
					}
					else
					{
						PacketSent = PacketSent + chunksize;
					}

				}
				else
				{
					FreeAvailable(TxDoneSync,chunksize);
					PacketSent = 0;
				}

			}

			if(engine == 0)
			{
				if(thread0_exit == 1)
				{
					//	printf("Ending %s thread \n",__func__);
					thread_done[0] = 0;
					while(thread_done[1] || thread_done[2]);
					goto ERROR;
				} 
			}
			else if(engine == 1)
			{
				if(thread1_exit == 1)
				{
					//		printf("Ending %s thread \n",__func__);
					thread_done[4] = 0;
					while(thread_done[5] || thread_done[6]);           
					goto ERROR;
				} 
			}
			else if(engine == 2)
			{
				if(thread2_exit == 1)
				{
					//		printf("Ending %s thread \n",__func__);
					thread_done[8] = 0;
					while(thread_done[9] || thread_done[10]);           
					goto ERROR;
				} 
			}     
			else if(engine == 3)
			{
				if(thread3_exit == 1)
				{
					//		printf("Ending %s thread \n",__func__);
					thread_done[12] = 0;
					while(thread_done[13] || thread_done[14]);           
					goto ERROR;
				} 
			}  

		}

ERROR:
		close(file_desc);
		free(buffer);
		pthread_exit(NULL);

	}


	void * txthread_ioctl(TestCmd *test)
	{
		int ret_val,ret,itre,j;
		TxUsrInfo* buffer;
		int txreadfd=0,id=1,engine = test->Engine;
		int retry=0;
		FreeInfo usrInfo;
		MemorySync *TxDoneSync;
		unsigned int completed = 0;
		int chunksize=0;
		int PacketSize = test->MaxPktSize;

		if(PacketSize % 4){

			chunksize = PacketSize + (4 - (PacketSize % 4));

		}
		else
		{
			chunksize = PacketSize;
		}



#if 1
		if(test->Engine == 0)
		{     
			txreadfd= open("/dev/xraw_data0",O_RDWR);
			if(txreadfd < 0){
				printf("Can't open file \n");
				exit(-1);
			}
			TxDoneSync = &TxDoneSync0;
			thread_done[1] = 1;
		}
		else if(test->Engine == 1)
		{
			txreadfd= open("/dev/xraw_data1",O_RDWR);
			if(txreadfd < 0){
				printf("Can't open file \n");
				exit(-1);
			}
			TxDoneSync = &TxDoneSync1;
			thread_done[5] = 1;

		}
		else if(test->Engine == 2)
		{
			txreadfd= open("/dev/xraw_data2",O_RDWR);
			if(txreadfd < 0){
				printf("Can't open file \n");
				exit(-1);
			}
			TxDoneSync = &TxDoneSync2;
			thread_done[9] = 1;

		}
		else if(test->Engine == 3)
		{
			txreadfd= open("/dev/xraw_data3",O_RDWR);
			if(txreadfd < 0){
				printf("Can't open file \n");
				exit(-1);
			}
			TxDoneSync = &TxDoneSync3;
			thread_done[13] = 1;

		}
#endif
		while(1)
		{

			completed =0 ;
			usrInfo.expected = MAX_LIST;

			ret_val=ioctl(txreadfd,IGET_TRN_TXUSRINFO, &usrInfo);
			if(ret_val < 0){
				printf("IOCTL FAILED\n");
				//return(-1);
				break;
			}

			for (j = 0; j < usrInfo.expected; j++)
			{
				//		completed += usrInfo.buffList[j].buffSize;

				completed += chunksize;
			}

			if (0 != FreeAvailable(TxDoneSync, completed))
			{
				//error
				perror("Bad Pointer TxDoneSync: MemorySync");
			}

			if(engine == 0)
			{
				if((thread0_exit == 1 ) && (usrInfo.expected == 0))
				{
					retry++;
					if(retry >= 4)
					{
						thread_done[1] = 0;
						goto ERROR;
					}
					usleep(100 * 1000);
				} 
			}
			else if(engine == 1)
			{
				if((thread1_exit == 1) && (usrInfo.expected ==0))
				{  
					retry++;
					if(retry >= 4)
					{
						thread_done[5] = 0;
						goto ERROR;
					}
					usleep(100 * 1000);
				} 
			}       
			else if(engine == 2)
			{
				if((thread2_exit == 1) && (usrInfo.expected ==0))
				{  
					retry++;
					if(retry >= 4)
					{
						thread_done[9] = 0;
						goto ERROR;
					}
					usleep(100 * 1000);
				} 
			}
			else if(engine == 3)
			{
				if((thread3_exit == 1) && (usrInfo.expected ==0))
				{  
					retry++;
					if(retry >= 4)
					{
						thread_done[13] = 0;
						goto ERROR;
					}
					usleep(100 * 1000);
				} 
			}

		}

ERROR:
		close(txreadfd);

		pthread_exit(NULL);
	}

	int xlnx_thread_create(void *fp(void *),void *data)
	{
		pthread_attr_t        attr;
		pthread_t             thread;
		int                   rc=0;

		rc = pthread_attr_init(&attr);
		if(rc != 0)
		{
			printf("pthread_attr_init() returns error: %s\n",strerror(errno));
			return -1;
		}
		rc = pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_DETACHED);
		if(rc != 0)
		{
			printf("pthread_attr_setdetachstate() returns error: %s\n",strerror(errno));
			return -1;
		}
		rc = pthread_create(&thread, &attr,fp, data);
		if(rc != 0)
		{
			printf("pthread_create() returns error: %s\n",strerror(errno));
			return -1;
		}
		return 0;
	}

	int main(void)
	{
		int s, t, len, flags;
		int sret,n;
		struct sockaddr_un local, remote;
		fd_set read_set;
		struct timeval  timeout;
		TestCmd testCmd;
		int i;

		if(signal(SIGINT, sigint_callback_handler) == SIG_ERR)
			perror("signal:");
		if(signal(SIGSEGV, sigsegv_callback_handler) == SIG_ERR)
			perror("signal:");
		if(signal(SIGTERM, sigterm_callback_handler) == SIG_ERR)
			perror("signal:");

		if ((s = socket(AF_UNIX, SOCK_DGRAM, 0)) == -1) 
		{
			perror("socket");
			exit(1);
		}

		flags = fcntl(s,F_GETFL,0); 
		fcntl(s,F_SETFL,flags | O_NONBLOCK);

		local.sun_family = AF_UNIX;
		strcpy(local.sun_path, APP_SOCK_PATH);
		unlink(local.sun_path);
		len = strlen(local.sun_path) + sizeof(local.sun_family);

		if (bind(s, (struct sockaddr *)&local, len) == -1) 
		{
			perror("bind");
			exit(1);
		}



		t = sizeof(remote);

		for(;;) 
		{
			FD_ZERO(&read_set);
			FD_SET(s, &read_set);

			timeout.tv_sec  = CHECK_INTERVAL;
			timeout.tv_usec = 0;

			sret = select(s + 1, &read_set, NULL, NULL, &timeout);

			if(sret <= 0)
			{
#if 0
				if(check_gui_present())
					continue;
				break;
#endif
				if(sigint_recv || sigsegv_recv || sigterm_recv)
				{
					TestStartFlag0 &= ~(TEST_START);
					TestStartFlag1 &= ~(TEST_START);
					TestStartFlag2 &= ~(TEST_START);
					TestStartFlag3 &= ~(TEST_START);
					thread0_exit = 1;    
					thread1_exit = 1;    
					thread2_exit = 1;    
					thread3_exit = 1;
					sigint_recv = 0;
					sigsegv_recv = 0;
					sigterm_recv = 0;
					for(i=0;i< 4;i++)
					{ 
						while(thread_done[i]==1);
					}
					for(i=4;i< 8;i++)
					{ 
						while(thread_done[i]==1);
					}
					break;
				}
				else
				{
					continue;
				}                                                          
			}

			if (FD_ISSET(s, &read_set))
			{
				if ((n = recvfrom(s, &testCmd, sizeof(testCmd), 0,
								(struct sockaddr *)&remote, &t)) == -1) 
				{
					perror("recvfrom");
					continue ;
				}
				printf("Received command for engine %d and max pkt size as %d\n",testCmd.Engine,testCmd.MaxPktSize);
				if(testCmd.TestMode & TEST_START)
					StartTest(testCmd.Engine,testCmd.TestMode , testCmd.MaxPktSize);
				else 
					StopTest(testCmd.Engine,testCmd.TestMode , testCmd.MaxPktSize);

			}
		}

		close(s); 
		return 0;
	}

	int check_gui_present()
	{
		FILE *pf;
		char command[48];

		sprintf(command, STAT_FILE_CHK_CMD); 

		pf = popen(command,"r"); 

		if(!pf)
		{
			fprintf(stderr, "Could not open pipe for output.\n");
			return 0;
		}
		if (pclose(pf) != 0)
		{
			fprintf(stderr," Error: command stream not executed \n");
			return 0;
		}

		return 1;

	}

	int sendDataVerifyStatus(DataVerifyComm_t dcomm)
	{
		int s,ret;
		struct sockaddr_un remote;

		if ((s = socket(AF_UNIX, SOCK_DGRAM, 0)) == -1) {
			perror("socket");
			exit(1);
		}

		remote.sun_family = AF_UNIX;
		strcpy(remote.sun_path,GUI_SOCK_PATH);

		ret = sendto(s, &dcomm, sizeof(dcomm), 0, 
				(struct sockaddr*)&remote, sizeof(remote));

		if(ret < 0)
			perror("sendto()");

		close(s);

		return ret;
	}

	void
		sigint_callback_handler(int signum)
		{
			sigint_recv++;
		}

	void
		sigsegv_callback_handler(int signum)
		{
			sigsegv_recv++;
		}

	void
		sigterm_callback_handler(int signum)
		{
			sigterm_recv++;
		}


