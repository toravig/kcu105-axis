TARGET  = xrawdata
KDIR= /lib/modules/$(shell uname -r)/build
KBUILD_EXTRA_SYMBOL = $(KDIR)/Module.symvers
obj-m   := $(TARGET).o 
$(TARGET)-objs :=  Appdriver.o


all:
	$(MAKE) $(CFLAGS) -C $(KDIR) M=$(PWD)/xraw_data modules

$(TARGET).o:$(OBJS)
	$(LD) $(LD_FLAGS) -r -o $@ $(OBJS)
clean:
	rm -rf *.o *.ko *.mod.* .c* .t* modules.order Module.symvers  .*.cmd

