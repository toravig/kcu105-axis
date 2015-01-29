package com.xilinx.ultrascale.gui;

/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

/**
 *
 * @author xhdpssa
 */
import java.rmi.RemoteException;


public class RmiListenerImpl implements IRmiListener {

    @Override
    public boolean isAlreadyRunning() throws RemoteException {
        // here I notify my GUI class to pop up the window
        return true;
    }
} 