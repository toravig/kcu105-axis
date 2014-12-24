TARGET  = xdma_pcie
KDIR= /lib/modules/$(shell uname -r)/build
#ROOTDIR = $(PWD)

ifeq ($(DRIVER_MODE),$(filter $(DRIVER_MODE),RAWETHERNET ETHERNETAPP))
EXTRA_CFLAGS += -DETH_APP
endif
KBUILD_EXTRA_SYMBOL = $(KDIR)/Module.symvers
obj-m   := $(TARGET).o 
$(TARGET)-objs :=  ps_pcie_dma_driver.o
all:
	$(MAKE) $(CFLAGS) -C $(KDIR) M=$(PWD)/xdma modules

$(TARGET).o:$(OBJS)
	$(LD) $(LD_FLAGS) -r -o $@ $(OBJS)

clean:
	rm -rf *.o *.ko *.mod.* .c* .t*  .*.cmd modules.order Module.symvers 

