
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
 * @file PCIState.java 
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
/*
 * PCIState Class defines the structure similar to the PCIState in the driver.
 */

public class PCIState{
    int Version;       /**< Hardware design version info */
    int LinkState;     /**< Link State - up or down */
    public int LinkSpeed;     /**< Link Speed */
    public int LinkWidth;     /**< Link Width */
    int VendorId;      /**< Vendor ID */
    int DeviceId;      /**< Device ID */
    int IntMode;       /**< Legacy or MSI interrupts */
    int MPS;           /**< Max Payload Size */
    int MRRS;          /**< Max Read Request Size */
    // #if defined(V6_TRD) || defined(K7_TRD)
    int InitFCCplD;    /**< Initial FC Credits for Completion Data */
    int InitFCCplH;    /**< Initial FC Credits for Completion Header */
    int InitFCNPD;     /**< Initial FC Credits for Non-Posted Data */
    int InitFCNPH;     /**< Initial FC Credits for Non-Posted Data */
    int InitFCPD;      /**< Initial FC Credits for Posted Data */
    int InitFCPH;      /**< Initial FC Credits for Posted Data */
    public int LinkUpCap;

    public PCIState(){

    }

    public String getVersionInfo(){
         String ver = ""; 
         int major = (Version & 0x000000F0) >> 4;
         int minor = (Version & 0x0000000F);
         ver = "UltraScale ControlPlane TRD v"+major+"."+minor;
        
         return ver;
    }
    
    public void setPCIState(int[] data)
    {
       	Version = data[0];
        LinkState = data[1];
        LinkSpeed = data[2];
        LinkWidth = data[3];
        VendorId = data[4];
        DeviceId = data[5];
        IntMode = data[6];
        MPS = data[7];
        MRRS = data[8];
        InitFCCplD =  data[9];
        InitFCCplH = data[10];
        InitFCNPD = data[11];
        InitFCNPH = data[12];
        InitFCPD = data[13];
	InitFCPH = data[14]; 
        LinkUpCap = data[15];
    }
   
    public Object[][] getPCIData(){
        String lst = "Up";
        String lsp = "2.5 Gbps";
        String vid = "";
        String did = "";
        String intp = "";
        
        if (LinkState == 1)
            lst = "Up";
        else
            lst = "Down";
        if (LinkSpeed == 1)
            lsp = "2.5 GT/s";
        else if(LinkSpeed == 2)
            lsp = "5 GT/s";
        else if (LinkSpeed == 4)
            lsp = "8 GT/s";
        else
            lsp = "8 GT/s";
        if (IntMode == 0)
            intp = "None";
        else if (IntMode == 1)
            intp = "Legacy";
        else if (IntMode == 2)
            intp = "MSI";
        else if (IntMode == 3)
            intp = "MSI-X";
        vid = "0x"+Integer.toHexString(VendorId).toUpperCase();
        did = "0x"+Integer.toHexString(DeviceId).toUpperCase();
        String lw = "x"+LinkWidth;
        Object [][] pcie = {
            {"Link State", lst},
            {"Link Speed", lsp},
            {"Link Width", lw},
            {"", ""},
            {"Interrupts", intp},
            {"Vendor ID", vid},
            {"Device ID", did},
            {"", ""},
            {"MPS (bytes)", MPS},
            {"MRRS (bytes)", MRRS},
            {"", ""}
                /*,{"", ""},{"", ""},{"", ""},{"", ""},{"", ""}*/
        };
        return pcie;
    }
    
    public Object[][] getHostedData(){
        Object[][] hostData = {
            {"Posted Header", InitFCPH},
            {"Non-Posted Header", InitFCNPH},            
            {"Completion Header", InitFCCplH},
            {"",""},
            {"",""},
            {"Posted Data", InitFCPD},
            {"Non-Posted Data", InitFCNPD},
            {"Completion Data", InitFCCplD},
            {"", ""},
            /*{"",""},
            {"",""},
            {"", ""},{"", ""},{"", ""},{"", ""},{"", ""}*/
        };
        return hostData;
    }
        public Object[][] getPCIDataForCP(){
        String lst = "Up";
        String lsp = "2.5 Gbps";
        String vid = "";
        String did = "";
        String intp = "";
        
        if (LinkState == 1)
            lst = "Up";
        else
            lst = "Down";
        if (LinkSpeed == 1)
            lsp = "2.5 Gbps";
        else if(LinkSpeed == 2)
            lsp = "5 Gbps";
        else if (LinkSpeed == 4)
            lsp = "8 Gbps";
        else
            lsp = "Unknown";
        if (IntMode == 0)
            intp = "None";
        else if (IntMode == 1)
            intp = "Legacy";
        else if (IntMode == 2)
            intp = "MSI";
        else if (IntMode == 3)
            intp = "MSI-X";
        vid = "0x"+Integer.toHexString(VendorId).toUpperCase();
        did = "0x"+Integer.toHexString(DeviceId).toUpperCase();
        String lw = "x"+LinkWidth;
        Object [][] pcie = {
            {"Link State", lst},
            {"Link Speed", lsp},
            {"Link Width", lw},
            {"", ""},
            //{"Interrupts", intp},
            {"Vendor ID", vid},
            {"Device ID", did},
            {"", ""},
            {"MPS (bytes)", MPS},
            {"MRRS (bytes)", MRRS},
            {"", ""}
               // ,{"", ""},{"", ""},{"", ""},{"", ""},{"", ""}
        };
        return pcie;
    }
    
    public Object[][] getHostedDataForCP(){
        Object[][] hostData = {
            {"Bar", InitFCPH},
            {"Address Range", InitFCNPH},            
            {"Size", InitFCCplH},
            {"",""},
            {"Bar", InitFCPD},
            {"Address Range", InitFCNPD},
            {"Size", InitFCCplD},
            {"", ""},
            {"Bar", InitFCPD},
            {"Address Range", InitFCNPD},
            {"Size", InitFCCplD},
            {"",""},
            {"", ""},{"", ""},{"", ""},{"", ""}
        };
        return hostData;
    }
}
