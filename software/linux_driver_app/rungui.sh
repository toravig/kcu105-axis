if [ $(getconf LONG_BIT) == "64" ]
then
echo "***** Driver Compiling for 64 bit Linux*****"
sudo java -Djava.library.path=./gui/jnilib/64 -jar gui/UltraScaleGUI.jar
else
echo "***** Driver Compiling for 32 bit Linux*****"
sudo java -Djava.library.path=./gui/jnilib/32 -jar gui/UltraScaleGUI.jar
fi

