/**
 * *****************************************************************************
 ** © Copyright 2012 - 2013 Xilinx, Inc. All rights reserved. * This file
 * contains confidential and proprietary information of Xilinx, Inc. and * is
 * protected under U.S. and international copyright and other intellectual
 * property laws.
 * ******************************************************************************
 * * ____ ____ * / /\/ / * /___/ \ / Vendor: Xilinx * \ \ \/ * \ \ * / / * /___/
 * \ * \ \ / \ Virtex-7XT PCIe-DMA-DDR3-10GMAC-10GBASER Targeted Reference
 * Design * \___\/\___\ * * Device: xc7k325t * Version: 1.0 * Reference: UG927 *
 * ******************************************************************************
 * * * Disclaimer: * * This disclaimer is not a license and does not grant any
 * rights to the materials * distributed herewith. Except as otherwise provided
 * in a valid license issued to you * by Xilinx, and to the maximum extent
 * permitted by applicable law: * (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS"
 * AND WITH ALL FAULTS, * AND XILINX HEREBY DISCLAIMS ALL WARRANTIES AND
 * CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, * INCLUDING BUT NOT LIMITED TO
 * WARRANTIES OF MERCHANTABILITY, NON-INFRINGEMENT, OR * FITNESS FOR ANY
 * PARTICULAR PURPOSE; and (2) Xilinx shall not be liable (whether in contract *
 * or tort, including negligence, or under any other theory of liability) for
 * any loss or damage * of any kind or nature related to, arising under or in
 * connection with these materials, * including for any direct, or any indirect,
 * special, incidental, or consequential loss * or damage (including loss of
 * data, profits, goodwill, or any type of loss or damage suffered * as a result
 * of any action brought by a third party) even if such damage or loss was *
 * reasonably foreseeable or Xilinx had been advised of the possibility of the
 * same.
 *
 *
 ** Critical Applications: * * Xilinx products are not designed or intended to
 * be fail-safe, or for use in any application * requiring fail-safe
 * performance, such as life-support or safety devices or systems, * Class III
 * medical devices, nuclear facilities, applications related to the deployment
 * of airbags, * or any other applications that could lead to death, personal
 * injury, or severe property or * environmental damage (individually and
 * collectively, "Critical Applications"). Customer assumes * the sole risk and
 * liability of any use of Xilinx products in Critical Applications, subject
 * only * to applicable laws and regulations governing limitations on product
 * liability.
 *
 ** THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS PART OF THIS FILE
 * AT ALL TIMES.
 *
 ******************************************************************************
 */
/**
 * **************************************************************************
 */
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
