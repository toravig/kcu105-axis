#!/bin/sh
DMA_MODULE_NAME="xdma_pcie"
RAWMODULE="xrawdata"
RAWETHMODULE="xraw_eth0"
ETHERAPP="xxgbeth0"
STATSFILE="xdma_stat"
XRAWSTATS="xraw_data0"
XRAWETH0STATS="xraw_data0"
XRAWETH1STATS="xraw_data1"

if [ -d /sys/module/$DMA_MODULE_NAME ]; then
	if [ -d /sys/module/$RAWMODULE ]; then
		cd driver && sudo make remove
	elif [ -d /sys/module/$RAWETHMODULE ]; then
		cd driver && sudo make DRIVER_MODE=RAWETHERNET remove
	elif [ -d /sys/module/$ETHERAPP ]; then
		cd driver && sudo make DRIVER_MODE=ETHERNETAPP remove
	else
		sudo rmmod $DMA_MODULE_NAME
	fi
fi
if [ -c /dev/$STATSFILE ]; then
	if [ -c /dev/$XRAWSTATS]; then
	sudo rm -rf /dev/$STATSFILE
	sudo rm -rf /dev/$XRAWSTATS
	elif [ -c /dev/$RAWETHSTATS]; then
	sudo rm -rf /dev/$XRAWETH0STATS
	sudo rm -rf /dev/$XRAWETH1STATS
	sudo rm -rf /dev/$STATSFILE
	else
	sudo rm -rf /dev/$STATSFILE
	fi
fi
