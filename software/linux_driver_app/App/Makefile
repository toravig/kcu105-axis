
CC = gcc 

CFLAGS = -DK7_TRD -I $(PWD)
LFLAGS = -lpthread
ifeq ($(APP_MODE),RAWETHERNET)
CFLAGS += -DRAW_ETH
endif

GUI_OBJS = App.o crc.o

all = APP

APP:	$(GUI_OBJS) 
	$(CC) $(CFLAGS) $(GUI_OBJS) $(LFLAGS) -o App

App.o:	threads.c ../driver/include/xpmon_be.h
	$(CC) -c $(CFLAGS) -I ../driver/include/ threads.c -o App.o

crc.o:	crc.c
	$(CC) -c crc.c -o crc.o

clean:
	rm -f $(GUI_OBJS) App  xt_app_comm_socket
