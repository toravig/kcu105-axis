#!/bin/sh
compilation_error=1
module_insertion_error=2
compilation_clean_error=3

pgrep App|xargs kill -SIGINT 1>/dev/null 2>&1
sleep 5;
cd App
make clean 1>/dev/null 2>&1
make 1>/dev/null 2>&1
./App 1>Applog 2>&1 &
cd ../
/bin/sh remove_modules.sh
cd driver

make DRIVER_MODE=PERFORMANCE clean 
if [ "$?" != "0" ]; then
	echo "Error in cleaning Performance Driver"
	exit $compilation_clean_error;
fi
make DRIVER_MODE=PERFORMANCE 
if [ "$?" != "0" ]; then
	echo "Error in compiling Performance Driver"
	exit $compilation_error;
fi
sudo make DRIVER_MODE=PERFORMANCE insert
if [ "$?" != "0" ]; then
	echo "Error in Inserting Performance Driver"
	exit $module_insertion_error;
fi
