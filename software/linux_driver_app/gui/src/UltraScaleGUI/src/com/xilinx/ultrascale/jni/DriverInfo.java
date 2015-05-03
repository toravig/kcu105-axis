
/****************************************************************************
 ****************************************************************************/
/** Copyright (C) 2014-2015 Xilinx, Inc.  All rights reserved.
 ** Permission is hereby granted, free of charge, to any person obtaining
 ** a copy of this software and associated documentation files (the
 ** "Software"), to deal in the Software without restriction, including
 ** without limitation the rights to use, copy, modify, merge, publish,
 ** distribute, sublicense, and/or sell copies of the Software, and to
 ** permit persons to whom the Software is furnished to do so, subject to
 ** the following conditions:
 ** The above copyright notice and this permission notice shall be included
 ** in all copies or substantial portions of the Software.Use of the Software 
 ** is limited solely to applications: (a) running on a Xilinx device, or 
 ** (b) that interact with a Xilinx device through a bus or interconnect.  
 ** THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 ** EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 ** MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 ** NONINFRINGEMENT. IN NO EVENT SHALL XILINX BE LIABLE FOR ANY
 ** CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 ** TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 ** SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 ** Except as contained in this notice, the name of the Xilinx shall
 ** not be used in advertising or otherwise to promote the sale, use or other
 ** dealings in this Software without prior written authorization from Xilinx
 **/
/*****************************************************************************
*****************************************************************************/
/**
 *
 * @file DriverInfo.java
 *
 * Author: Xilinx, Inc.
 *
 * 2007-2010 (c) Xilinx, Inc. This file is licensed uner the terms of the GNU
 * General Public License version 2.1. This program is licensed "as is" without
 * any warranty of any kind, whether express or implied.
 *
 * MODIFICATION HISTORY:
 *
 * Ver Date Changes ----- --------
 * ------------------------------------------------------- 1.0 5/15/12 First
 * release
 *
 ****************************************************************************
 */
package com.xilinx.ultrascale.jni;

import com.xilinx.ultrascale.gui.LandingPage;
import com.xilinx.ultrascale.gui.MainScreen;
import com.xilinx.ultrascale.gui.MainScreen_video;

public class DriverInfo {

    public static int ENABLE_LOOPBACK = 0;
    public static int CHECKER = 1;
    public static int GENERATOR = 2;
    public static int CHECKER_GEN = 3;
    DriverInfoRaw diraw;
    DriverInfoGen digen;
    DriverInfoGenDV digendv;
    DriverInfoRawDV dirawdv;
    int mode;

    public DriverInfo() {
    }

    public void init(int mode, int drivermode) {
        this.mode = mode;
        if (digen == null) {
            digen = new DriverInfoGen();
        }
        DriverInfoGen.initlibs(drivermode);
        /*if (mode == LandingPage.PERFORMANCE_MODE_RAW)
         {
         if (diraw == null)
         diraw = new DriverInfoRaw();
         DriverInfoRaw.initlibs();
         }else if (mode == LandingPage.PERFORMANCE_MODE_GENCHK){
         if (digen == null)
         digen = new DriverInfoGen();
         DriverInfoGen.initlibs();
         }else if (mode == LandingPage.PERFORMANCE_MODE_GENCHK_DV){
         if (digendv == null)
         digendv = new DriverInfoGenDV();
         DriverInfoGenDV.initlibs();
         }else if (mode == LandingPage.PERFORMANCE_MODE_RAW_DV){
         if (dirawdv == null)
         dirawdv = new DriverInfoRawDV();
         DriverInfoRawDV.initlibs();
         }else if (mode == LandingPage.APPLICATION_MODE){
         if (digen == null)
         digen = new DriverInfoGen();
         DriverInfoGen.initlibs();
         }
         else if (mode == LandingPage.APPLICATION_MODE_P2P){
         if (digen == null)
         digen = new DriverInfoGen();
         DriverInfoGen.initlibs();
         }*/
    }

    protected void finalize() {
        diraw = null;
        digen = null;
        digendv = null;
        dirawdv = null;
        System.gc();
    }

    public int get_PCIstate() {
        return digen.get_PCIstate();
    }

    public int get_EngineState() {
        return digen.get_EngineState();
    }

    public int get_DMAStats() {
        return -1;
    }

    public int get_TRNStats() {
        return digen.get_TRNStats();
    }

    public int get_SWStats() {
        return -1;
    }

    public int get_PowerStats() {
        return digen.get_PowerStats();
    }

    public int startTest(int engine, int testmode, int maxsize) {
        return digen.startTest(engine, testmode, maxsize);
    }

    public int stopTest(int engine, int testmode, int maxsize) {
        return digen.stopTest(engine, testmode, maxsize);
    }
    
    public int startTest1(int engine, int testmode, int maxsize) {
        return digen.startTest1(engine, testmode, maxsize);
    }

    public int stopTest1(int engine, int testmode, int maxsize) {
        return digen.stopTest1(engine, testmode, maxsize);
    }
    
    public int startVideoTest(int engine, int testmode,int mincoeff, int maxcoeff, int invert, int maxsize) {
        return digen.startVideoTest(engine, testmode, mincoeff, maxcoeff, invert, maxsize);
    }

    public int stopVideoTest(int engine, int testmode, int maxsize) {
        return digen.stopVideoTest(engine, testmode, maxsize);
    }
    public int setSobelParams(int engine, int testmode,int mincoeff, int maxcoeff, int invert, int maxsize) {
        return digen.setSobelParams(engine, testmode, mincoeff, maxcoeff, invert, maxsize);
    }
    public void flush() {
        digen.flush();
    }

    public PCIState getPCIInfo() {
        return digen.getPCIInfo();
    }

    public EngState[] getEngState() {
        return digen.getEngState();
    }

    public DMAStats[] getDMAStats() {
        return null;
    }

    public TRNStats getTRNStats() {
        return digen.getTRNStats();
    }

    public PowerStats getPowerStats() {
        return digen.getPowerStats();
    }

    public int setLinkSpeed(int speed) {
        return -1;
    }

    public int setLinkWidth(int width) {
        return -1;
    }

    public int get_LedStats() {
        return digen.LedStats();
    }

    public LedStats getLedStats() {
        return digen.getLedStats();
    }

    public int getBarInfo() {
        return digen.BarInfo();
    }

    public EndPointInfo getEndPointInfo() {
        return digen.getEndPointInfo();
    }

    public void readCmd(MainScreen mscr, int bar, int offset) {
        digen.msc = mscr;

        digen.ReadCmd(bar, offset);
    }

    public void writeCmd(MainScreen mscr, int bar, int offset, long vdata) {
        digen.msc = mscr;
        digen.WriteCmd(bar, offset, vdata);
    }

    public void readDump(MainScreen mscr, int bar, int adress, int size) {
        digen.msc = mscr;
        digen.ReadDump(bar, adress, size);
    }
        public void readCmd(MainScreen_video mscr, int bar, int offset) {
        digen.msc_vid = mscr;

        digen.ReadCmd(bar, offset);
    }

    public void writeCmd(MainScreen_video mscr, int bar, int offset, long vdata) {
        digen.msc_vid = mscr;
        digen.WriteCmd(bar, offset, vdata);
    }

    public void readDump(MainScreen_video mscr, int bar, int adress, int size) {
        digen.msc_vid = mscr;
        digen.ReadDump(bar, adress, size);
    }
    
    
    public int ResetVDMA(int engine, int testmode,int mincoeff, int maxcoeff, int invert, int maxsize){
        return digen.ResetVDMA(engine, testmode, mincoeff, maxcoeff, invert, maxsize);   
}
}
