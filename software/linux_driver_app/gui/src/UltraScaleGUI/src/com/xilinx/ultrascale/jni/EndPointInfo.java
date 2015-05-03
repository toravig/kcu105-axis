
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
/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package com.xilinx.ultrascale.jni;

/**
 *
 * @author testadvs
 */
public class EndPointInfo {
    int MAX_BARS = 6;
    public int designMode;
    public int barmask; 
    public BarInfo[] barList = new BarInfo[MAX_BARS];
    
    public EndPointInfo(){}
    public void setEndPointInfo(int[] einfo, long[][] binfo){
        designMode = einfo[0];
        barmask = einfo[1];
        
        for (int i = 0; i < MAX_BARS; ++i){
            barList[i] = new BarInfo();
            barList[i].setBarInfo(binfo[i][0], binfo[i][1]);
        }
    }
    
    public Object[][] getBarStats(){
        Object[][] bstats = {
            {"BAR", "2"},
            {"Address", "0x"+Long.toHexString(barList[0].barAddress).toUpperCase()},
            {"Size", barList[0].barSize/1024+"K"},
            {"", ""},
            {"BAR", "4"},
            {"Address", "0x"+Long.toHexString(barList[2].barAddress).toUpperCase()},
            {"Size", barList[2].barSize/1024+"K"},
            {"", ""},
            {"BAR", "6"},
            {"Address", "0x"+Long.toHexString(barList[4].barAddress).toUpperCase()},
            {"Size", barList[4].barSize/1024+"K"}
        };
        return bstats;
    }
}
