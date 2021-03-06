rm -rf *.so ../*.so ../64/libxilinxlib.so

g++ -o libxilinxlib.so -fpermissive -DK7_TRD -DPM_SUPPORT -shared -lpthread -Wl,-soname,libxilinx.so -I/usr/java/latest/include/ -I/usr/java/latest/include/linux -I. com_xilinx_ultrascale_jni_DriverInfoGen.cpp threads.cpp -Bstatic -lc -fPIC
#g++ -o libxilinxlib.so -fpermissive -DK7_TRD -DPM_SUPPORT -shared -lpthread -Wl,-soname,libxilinx.so -I/usr/lib/jvm/java-1.6.0-openjdk/include -I/usr/lib/jvm/java-1.6.0-openjdk/include/linux -I. com_xilinx_ultrascale_jni_DriverInfoGen.cpp threads.cpp -Bstatic -lc -fPIC

#g++ -o libxilinxlibraw.so -fpermissive -DRAW_ETH -DK7_TRD -DPM_SUPPORT -shared -lpthread -Wl,-soname,libxilinxraw.so -I/usr/lib/jvm/java-1.7.0-openjdk-1.7.0.9/include -I/usr/lib/jvm/java-1.7.0-openjdk-1.7.0.9/include/linux -I. com_xilinx_gui_DriverInfoRaw.cpp threads.cpp -Bstatic -lc -fPIC 

#g++ -o libxilinxlibdv.so -fpermissive -DDATA_VERIFY -DK7_TRD -DPM_SUPPORT -shared -lpthread -Wl,-soname,libxilinxdv.so -I/usr/lib/jvm/java-1.7.0-openjdk-1.7.0.9/include -I/usr/lib/jvm/java-1.7.0-openjdk-1.7.0.9/include/linux -I. com_xilinx_gui_DriverInfoGenDV.cpp threads.cpp -Bstatic -lc -fPIC

#g++ -o libxilinxlibrawdv.so -fpermissive -DDATA_VERIFY -DRAW_ETH -DK7_TRD -DPM_SUPPORT -shared -lpthread -Wl,-soname,libxilinxrawdv.so -I/usr/lib/jvm/java-1.7.0-openjdk-1.7.0.9/include -I/usr/lib/jvm/java-1.7.0-openjdk-1.7.0.9/include/linux -I. com_xilinx_gui_DriverInfoRawDV.cpp threads.cpp -Bstatic -lc -fPIC 

cp *.so ../
cp *.so ../64/
