
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
 * @file EngState.java  
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
 * EngState Class defines the structure similar to the EngState in the driver along with four additional properties.
 */

public class EngState{

    public int Engine;                 /**< Engine Number */
    public int srcSGLBDs;                    /**< Total Number of BDs */
    public int destSGLBDs;
    public int srcStatsBD;
    public int destStatsBD;
    public int Buffers;                /**< Total Number of buffers */
    public int MinPktSize;    /**< Minimum packet size */
    public int MaxPktSize;    /**< Maximum packet size */
    public int srcErrs;                 /**< Total BD errors */
    public int destErrs;                /**< Total BD short errors - only TX BDs */
    public int internalErrs;
    public int DataMismatch;
    public int IntEnab;                /**< Interrupts enabled or not */
    public int TestMode;      /**< Current Test Mode */

    // Additional parameters from EngStats
    public int TXEnab;
    public int LBEnab;
    public int PktGenEnab;
    public int PktChkEnab;

    public EngState(){}
    public void setEngState(int[] state){
    /*   Engine = state[0];
       srcSGLBDs = state[1];
       destSGLBDs = state[2];
       srcStatsBD = state[3];
       destStatsBD = state[4];
       Buffers = state[5];
       MinPktSize = state[6];
       MaxPktSize = state[7];*/
       srcErrs = state[0];
       destErrs = state[1];
       internalErrs = state[2];/*
       DataMismatch = state[11];
       IntEnab = state[12];
       TestMode = state[13];
       TXEnab = state[14];
       LBEnab = state[15];
       PktGenEnab = state[16];
       PktChkEnab = state[17];*/
    }  
}
