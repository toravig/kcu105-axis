/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package com.xilinx.ultrascale.jni;

/**
 *
 * @author testadvs
 */
public class BarInfo {
    public long barAddress;
    public long barSize;
    
    public BarInfo(){}
    public void setBarInfo(long addr, long size){
        barAddress = addr;
        barSize = size;
    }
}
