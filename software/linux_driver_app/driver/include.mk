
ifndef DRIVER_MODE
export DRIVER_MODE=PERFORMANCE
endif

export KDIR= /lib/modules/$(shell uname -r)/build
export XDMA_PATH=$(ROOTDIR)/xdma
export XRAWDATA_PATH=$(ROOTDIR)/xraw_data
export XRAWETH0_PATH=$(ROOTDIR)/xraw_eth0
export XRAWETH1_PATH=$(ROOTDIR)/xraw_eth1
export XETHERNET0_PATH=$(ROOTDIR)/xxgbeth0
export XETHERNET1_PATH=$(ROOTDIR)/xxgbeth1
export INSMOD=/sbin/insmod
export RMMOD=/sbin/rmmod
export RM=/bin/rm
export MKNOD_CMD=/bin/mknod
export DMA_STATS_FILE=xdma_stats
export RAW_FILE_NAME=xraw_data0
export RAWETH0_FILE_NAME=xraw_data0
export RAWETH1_FILE_NAME=xraw_data1
export DMA_DRIVER_NAME=xdma_pcie.ko
export RAW_DRIVER_NAME=xrawdata.ko
export RAWETH0_DRIVER_NAME=xraw_eth0.ko
export RAWETH1_DRIVER_NAME=xraw_eth1.ko
export XETHERNET0_DRIVER_NAME=xxgbeth0.ko
export XETHERNET1_DRIVER_NAME=xxgbeth1.ko
export SLEEP_TIME=1

MKNOD = `awk '/$(DMA_STATS_FILE)/ {print $$1}' /proc/devices`
MKNOD0 =`awk '/$(RAWETH0_FILE_NAME)/ {print $$1}' /proc/devices`
MKNOD1 =`awk '/$(RAWETH1_FILE_NAME)/ {print $$1}' /proc/devices`

define compile_performance_driver
	echo Compiling Performance Driver
	$(MAKE) -C $(XDMA_PATH)
	$(MAKE) -C $(XRAWDATA_PATH)
#	$(MAKE) -C $(XRAWDATA1_PATH)
endef

define compile_rawethernet_driver
	echo Compiling Performance Driver
	$(MAKE) -C $(XDMA_PATH)
	$(MAKE) -C $(XRAWETH0_PATH)
	$(MAKE) -C $(XRAWETH1_PATH)
endef

define compile_ethernet_driver
	echo Compiling Ethernet Driver
	$(MAKE) -C $(XDMA_PATH)
	$(MAKE) -C $(XETHERNET0_PATH)
	$(MAKE) -C $(XETHERNET1_PATH)
endef

define clean_performance_driver
	echo Cleaning Performance Driver
	$(MAKE) -C $(XDMA_PATH) clean
	$(MAKE) -C $(XRAWDATA_PATH) clean
#	$(MAKE) -C $(XRAWDATA1_PATH) clean
endef

define clean_rawethernet_driver
	echo Cleaning Performance Driver
	$(MAKE) -C $(XDMA_PATH) clean
	$(MAKE) -C $(XRAWETH0_PATH) clean
	$(MAKE) -C $(XRAWETH1_PATH) clean
endef

define clean_ethernet_driver
	echo Cleaning Ethernet Driver
	$(MAKE) -C $(XDMA_PATH) clean
	$(MAKE) -C $(XETHERNET0_PATH) clean
	$(MAKE) -C $(XETHERNET1_PATH) clean
endef

define insert_performance_driver
	echo Inserting Performance Driver
	$(INSMOD) $(XDMA_PATH)/$(DMA_DRIVER_NAME); sleep $(SLEEP_TIME)
	$(MKNOD_CMD) /dev/$(DMA_STATS_FILE) c $(MKNOD) 0
	$(INSMOD) $(XRAWDATA_PATH)/$(RAW_DRIVER_NAME); sleep $(SLEEP_TIME)
	$(MKNOD_CMD) /dev/$(RAW_FILE_NAME) c $(MKNOD0) 0
#	$(INSMOD) $(XRAWDATA1_PATH)/$(RAW1_DRIVER_NAME)
#	$(MKNOD_CMD) /dev/$(RAW1_FILE_NAME) c $(MKNOD1) 0
endef

define insert_rawethernet_driver
	echo Inserting Performance Driver
	$(INSMOD) $(XDMA_PATH)/$(DMA_DRIVER_NAME); sleep $(SLEEP_TIME)
	$(MKNOD_CMD) /dev/$(DMA_STATS_FILE) c $(MKNOD) 0
	$(INSMOD) $(XRAWETH0_PATH)/$(RAWETH0_DRIVER_NAME); sleep $(SLEEP_TIME)
	$(MKNOD_CMD) /dev/$(RAWETH0_FILE_NAME) c $(MKNOD0) 0
	$(INSMOD) $(XRAWETH1_PATH)/$(RAWETH1_DRIVER_NAME)
	$(MKNOD_CMD) /dev/$(RAWETH1_FILE_NAME) c $(MKNOD1) 0
endef

define insert_ethernet_driver
	echo Inserting Ethernet Driver
	$(INSMOD) $(XDMA_PATH)/$(DMA_DRIVER_NAME); sleep $(SLEEP_TIME)
	$(MKNOD_CMD) /dev/$(DMA_STATS_FILE) c $(MKNOD) 0
	$(INSMOD) $(XETHERNET0_PATH)/$(XETHERNET0_DRIVER_NAME); sleep $(SLEEP_TIME)
	$(INSMOD) $(XETHERNET1_PATH)/$(XETHERNET1_DRIVER_NAME)
endef

define remove_performance_driver
	echo Removing Performance Driver
#	$(RMMOD) $(RAW1_DRIVER_NAME); sleep $(SLEEP_TIME)
	$(RMMOD) $(RAW_DRIVER_NAME); sleep $(SLEEP_TIME); $(RM) -f /dev/$(DMA_STATS_FILE)
	$(RM) -f /dev/$(RAW_FILE_NAME)
	$(RMMOD) $(DMA_DRIVER_NAME)
endef

define remove_rawethernet_driver
	echo Removing Performance Driver
	$(RMMOD) $(RAWETH1_DRIVER_NAME); sleep $(SLEEP_TIME)
	$(RMMOD) $(RAWETH0_DRIVER_NAME); sleep $(SLEEP_TIME); $(RM) -f /dev/$(DMA_STATS_FILE)
	$(RM) -f /dev/$(RAWETH1_FILE_NAME);$(RM) -f /dev/$(RAWETH0_FILE_NAME)
	$(RMMOD) $(DMA_DRIVER_NAME)
endef

define remove_ethernet_driver
	echo Removing Ethernet Driver
	$(RMMOD) $(XETHERNET1_DRIVER_NAME); sleep $(SLEEP_TIME)
	$(RMMOD) $(XETHERNET0_DRIVER_NAME); sleep $(SLEEP_TIME); $(RM) -f /dev/$(DMA_STATS_FILE)
	$(RMMOD) $(DMA_DRIVER_NAME)
endef
