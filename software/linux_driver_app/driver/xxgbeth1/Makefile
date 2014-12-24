TARGET  = xxgbeth1
KBUILD_EXTRA_SYMBOL = $(KDIR)/Module.symvers
obj-m   := $(TARGET).o 
$(TARGET)-objs := Xenet_host.o xxgethernet.o xbasic_types.o
ccflags-y += -DK7_TRD -DX86_64 -DAXI_VERSION  -DX86_PC -DXENV_LINUX -DUSE_IO_MACROS -DMDIO_CHANGES -DPHYSETUP -DXGEMAC_MAC2__ -DUSE_NW_PATH1 -I $(ROOTDIR)/include
#For Jumbo Enable use below flag
#DENABLE_JUMBO
all:
	$(MAKE) $(CFLAGS) -C $(KDIR) M=$(PWD)/xxgbeth1 modules

$(TARGET).o:$(OBJS)
	$(LD) $(LD_FLAGS) -r -o $@ $(OBJS)

clean:
	rm -rf *.o *.ko *.mod.* .c* .t*  .*.cmd modules.order Module.symvers

