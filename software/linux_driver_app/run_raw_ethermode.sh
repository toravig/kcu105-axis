#!/bin/sh
compilation_error=1
module_insertion_error=2
compilation_clean_error=3

pgrep App|xargs kill -SIGINT 1>/dev/null 2>&1
sleep 5;
cd App
make clean 1>/dev/null 2>&1
make APP_MODE=RAWETHERNET 1>/dev/null 2>&1
./App 1>Applog 2>&1 &
cd ../

/bin/sh remove_modules.sh
cd driver
make DRIVER_MODE=RAWETHERNET clean
if [ "$?" != "0" ]; then
	echo "Error in cleaning RAW_ETHERNET performance driver"
	exit $compilation_clean_error;
fi
make DRIVER_MODE=RAWETHERNET
if [ "$?" != "0" ]; then
	echo "Error in compiling RAW_ETHERNET performance driver"
	exit $compilation_error;
fi
sudo make DRIVER_MODE=RAWETHERNET insert 
if [ "$?" != "0" ]; then
	echo "Error in inserting RAW_ETHERNET performance driver"
	exit $module_insertion_error;
fi
