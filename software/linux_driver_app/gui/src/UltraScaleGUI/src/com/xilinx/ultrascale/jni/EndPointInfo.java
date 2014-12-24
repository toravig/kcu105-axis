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
