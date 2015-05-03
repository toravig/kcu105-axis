
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
/*****************************************************************************/
/**
 *
 * @file DriverInfoGenDV.java  
 *
 * Author: Xilinx, Inc.
 *
 * 2007-2010 (c) Xilinx, Inc. This file is licensed uner the terms of the GNU
 * General Public License version 2.1. This program is licensed "as is" without
 * any warranty of any kind, whether express or implied.
 *
 * MODIFICATION HISTORY:
 *
 * Ver   Date     Changes
 * ----- -------- -------------------------------------------------------
 * 1.0  5/15/12  First release
 *
 *****************************************************************************/

package com.xilinx.ultrascale.jni;

import com.xilinx.ultrascale.gui.MainScreen;

public class DriverInfoGenDV {
    public static int ENABLE_LOOPBACK = 0;
    public static int CHECKER = 1;
    public static int GENERATOR = 2;
    public static int CHECKER_GEN = 3;
   
    // Native method declaration
    static native void init();
    public native int flush();
    public native int get_PCIstate();
    public native int get_EngineState();
    public native int get_DMAStats();
    public native int get_TRNStats();
    public native int get_SWStats();
    public native int get_PowerStats();
    public native int startTest(int engine, int testmode, int maxsize);
    public native int stopTest(int engine, int testmode, int maxsize);
    public native int setLinkSpeed(int speed);
    public native int setLinkWidth(int width);
    public native int LedStats();
       
    private void pciStateCallback(int[] response){
        pciState.setPCIState(response);
    } 

    private void engStateCallback(int[][] eng){
        engState[0] = new EngState();
        engState[0].setEngState(eng[0]);
        engState[1] = new EngState();
        engState[1].setEngState(eng[1]);
        engState[2] = new EngState();
        engState[2].setEngState(eng[2]);
        engState[3] = new EngState();
        engState[3].setEngState(eng[3]);
        engState[4] = new EngState();
        engState[4].setEngState(eng[4]);
        engState[5] = new EngState();
        engState[5].setEngState(eng[5]);
        engState[6] = new EngState();
        engState[6].setEngState(eng[6]);
        engState[7] = new EngState();
        engState[7].setEngState(eng[7]);
    
    }

    private void dmaStatsCallback(float [][] stats){
        dmaStats[0] = new DMAStats();
        dmaStats[0].setDMAStats(stats[0]);
        dmaStats[1] = new DMAStats();
        dmaStats[1].setDMAStats(stats[1]);
        dmaStats[2] = new DMAStats();
        dmaStats[2].setDMAStats(stats[2]);
        dmaStats[3] = new DMAStats();
        dmaStats[3].setDMAStats(stats[3]);
        dmaStats[4] = new DMAStats();
        dmaStats[4].setDMAStats(stats[4]);
        dmaStats[5] = new DMAStats();
        dmaStats[5].setDMAStats(stats[5]);
        dmaStats[6] = new DMAStats();
        dmaStats[6].setDMAStats(stats[6]);
        dmaStats[7] = new DMAStats();
        dmaStats[7].setDMAStats(stats[7]);
    }

    private void trnStatsCallback(float[] stats){
        trnStats.setTRNStats(stats);
    }

    private void swsStatsCallback(int[][] stats){
    }
    
    private void powerStatsCallback(int[] stats){
        powerStats.setStats(stats);
    }
       
    private void showLogCallback(int log){
        System.out.println("Got back into Java: "+log);
    }
    
    private void ledStatsCallback(int[] res){
        System.out.println("here dv");
       ledStats.ddrCalib1 = res[0];
        ledStats.ddrCalib2 = res[1];
        ledStats.phy0 = res[2];
        ledStats.phy1 = res[3];
        ledStats.phy2 = res[4];
        ledStats.phy3 = res[5];
    }
    
    public DriverInfoGenDV(){
        pciState = new PCIState();
        engState = new EngState[8];
        dmaStats = new DMAStats[8];
        trnStats = new TRNStats();
        powerStats = new PowerStats();
        ledStats = new LedStats();
    }

    public static void initlibs(){
        System.loadLibrary("xilinxlibdv");
        init();
    }
    
    public PCIState getPCIInfo(){
       return pciState;
    }
 
    public EngState[] getEngState(){
       return engState;
    }
    
    public DMAStats[] getDMAStats(){
        return dmaStats;
    }
    
    public TRNStats getTRNStats(){
        return trnStats;
    }
    
    public PowerStats getPowerStats(){
        return powerStats;
    }
    
    public LedStats getLedStats(){
        return ledStats;
    }
    
    private PCIState pciState;
    private EngState[] engState;
    private DMAStats[] dmaStats;
    private TRNStats trnStats;
    private PowerStats powerStats;
     private LedStats ledStats;
}
